"""Shared TensorFlow helpers for Buddy-Up training notebooks.

Prefer TF/Keras. PyTorch is used only where a TF implementation is not yet
mature (JEPA research lane). Export always produces the ONNX artifacts the AI
service consumes (INT8 CPU via onnxruntime quantization).
"""
from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

import numpy as np

# --- environment ----------------------------------------------------------


def on_gpu() -> bool:
    import tensorflow as tf

    return len(tf.config.list_physical_devices('GPU')) > 0


def set_memory_growth() -> None:
    import tensorflow as tf

    for dev in tf.config.list_physical_devices('GPU'):
        try:
            tf.config.experimental.set_memory_growth(dev, True)
        except ValueError:
            pass


def tf_version() -> str:
    import tensorflow as tf

    return tf.__version__


# --- data helpers ----------------------------------------------------------


def food101_image_generator(split_csv: Path, img_dir: Path, class_to_idx: dict,
                            target_size=(224, 224), batch_size=32, augment=False):
    """Yield (image_batch, onehot_label_batch) from a process_food_data split CSV."""
    import tensorflow as tf

    rows = [line.split(',') for line in split_csv.read_text().splitlines()[1:] if line]
    rows = [(r[0], r[1]) for r in rows if len(r) >= 2]

    def gen():
        for img_path, cls in rows:
            try:
                img = tf.keras.utils.load_img(img_path, target_size=target_size)
                arr = tf.keras.utils.img_to_array(img)
                if augment:
                    arr = tf.image.random_flip_left_right(arr) / 255.0
                else:
                    arr = arr / 255.0
                yield arr, tf.keras.utils.to_categorical([class_to_idx[cls]], len(class_to_idx))[0]
            except Exception:
                continue

    ds = tf.data.Dataset.from_generator(
        gen,
        output_types=(tf.float32, tf.float32),
        output_shapes=((*target_size, 3), (len(class_to_idx),)),
    )
    return ds.batch(batch_size).prefetch(tf.data.AUTOTUNE)


def nutrition_regression_targets(df: np.ndarray) -> np.ndarray:
    """Log1p-calories regression target (train against log(kcal))."""
    return np.log1p(np.clip(df, 0, 5000)).astype(np.float32)


# --- models -----------------------------------------------------------------


def build_food_model(backbone: str = 'efficientnetv2s', n_classes: int = 101,
                     n_nutrition: int = 6, input_shape=(224, 224, 3)):
    """Multi-head food model: classification (Food-101) + nutrition regression.

    Returns (model, metrics_dict) with a shared backbone and two heads:
      - class_head: softmax over Food-101 classes
      - nutrition_head: linear over [calories, fat%DV, sugar%DV, sodium%DV,
        protein%DV, carbs%DV] (raw %DV are 0-1k scales; fit with log1p).
    """
    import tensorflow as tf

    base = tf.keras.applications.EfficientNetV2S(
        weights='imagenet', include_top=False, input_shape=input_shape,
    )
    base.trainable = False
    x = tf.keras.layers.GlobalAveragePooling2D()(base.output)
    class_head = tf.keras.layers.Dense(n_classes, activation='softmax', name='class_head')(x)
    nutrition_head = tf.keras.layers.Dense(n_nutrition, activation='linear', name='nutrition_head')(x)

    model = tf.keras.Model(base.input, [class_head, nutrition_head])
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-4),
        loss={'class_head': 'categorical_crossentropy', 'nutrition_head': 'mse'},
        loss_weights={'class_head': 1.0, 'nutrition_head': 0.3},
        metrics={'class_head': 'accuracy'},
    )
    return model


def build_text_toxicity_model(vocab_size: int = 60_000, seq_len: int = 256, embed_dim: int = 128):
    """Small TF text model for moderation (Reddit/IRL + profanity corpus)."""
    import tensorflow as tf

    inputs = tf.keras.Input(shape=(seq_len,), dtype='int64')
    x = tf.keras.layers.Embedding(vocab_size, embed_dim)(inputs)
    x = tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(64, return_sequences=True))(x)
    x = tf.keras.layers.GlobalAveragePooling1D()(x)
    x = tf.keras.layers.Dropout(0.3)(x)
    out = tf.keras.layers.Dense(1, activation='sigmoid')(x)
    model = tf.keras.Model(inputs, out)
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    return model


def build_two_tower(embed_dim: int = 128, n_users: int = 10_000, n_items: int = 10_000):
    """Two-tower recommender for matching/feed ranking (uses food.com interactions)."""
    import tensorflow as tf

    user_in = tf.keras.Input(shape=(1,), dtype='int64')
    item_in = tf.keras.Input(shape=(1,), dtype='int64')
    u = tf.keras.layers.Embedding(n_users, embed_dim)(user_in)
    i = tf.keras.layers.Embedding(n_items, embed_dim)(item_in)
    u = tf.keras.layers.Flatten()(u)
    i = tf.keras.layers.Flatten()(i)
    score = tf.keras.layers.Dot(axes=1)([u, i])
    model = tf.keras.Model([user_in, item_in], score)
    model.compile(optimizer='adam', loss='mse')
    return model


# --- export -----------------------------------------------------------------


def export_keras_onnx(model, out_dir: Path, name: str, version: str, input_signature=None):
    """Export Keras -> ONNX (+ dynamic-int8 quantized copy) for the AI service.

    The service looks for `<name>_int8.onnx` first (see app/ml/serving.py).
    """
    import tf2onnx
    import tensorflow as tf

    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    spec = input_signature or [tf.TensorSpec(model.inputs[0].shape, tf.float32, name='input')]
    onnx_path = out_dir / f'{name}-{version}.onnx'
    tf2onnx.convert.from_keras(model, input_signature=spec, output_path=str(onnx_path))
    return onnx_path


def quantize_dynamic_onnx(onnx_path: Path) -> Path:
    """Create `<name>_int8.onnx` CPU INT8 copy consumed by the AI service."""
    from onnxruntime.quantization import quantize_dynamic, QuantType

    qpath = onnx_path.with_name(onnx_path.stem + '_int8.onnx')
    quantize_dynamic(str(onnx_path), str(qpath), weight_type=QuantType.QUInt8)
    return qpath


# --- tracking ----------------------------------------------------------------


def mlflow_log(meta: dict, tracking_uri: str | None = None, run_name: str = ''):
    """Log metrics/artifacts to MLflow if configured; else print model-card JSON."""
    if tracking_uri:
        import mlflow

        mlflow.set_tracking_uri(tracking_uri)
        with mlflow.start_run(run_name=run_name):
            for k, v in (meta.get('metrics') or {}).items():
                mlflow.log_metric(k, float(v))
            if meta.get('artifact_path'):
                mlflow.log_artifact(meta['artifact_path'])
    else:
        print(json.dumps(meta, indent=2))

"""Shared training harness for Buddy-Up models.

Run on a GPU (Colab / Kaggle). Logs to MLflow, exports serving artifacts,
and prints a model-card JSON you can paste into ModelMetadata.

Usage:
    python train_template.py --model food_classifier --epochs 3
"""
import argparse
import json
import os
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description='Buddy-Up model training')
    parser.add_argument('--model', required=True,
                        choices=['food_classifier', 'form_analyzer', 'nsfw_classifier',
                                 'toxicity_classifier', 'matching_embeddings', 'feed_ranker',
                                 'workout_forecast', 'jepa_pose'])
    parser.add_argument('--data-dir', default='../data')
    parser.add_argument('--out-dir', default='../models')
    parser.add_argument('--epochs', type=int, default=3)
    parser.add_argument('--batch-size', type=int, default=32)
    parser.add_argument('--mlflow-tracking-uri', default=os.environ.get('MLFLOW_TRACKING_URI', ''))
    return parser.parse_args()


def export_model(model, out_dir: Path, name: str, version: str):
    """Export ONNX (CPU INT8) + TFLite + safetensors into out_dir."""
    out_dir.mkdir(parents=True, exist_ok=True)
    # ONNX export (int8-quantized for CPU-only serving):
    #   torch.onnx.export(model, dummy, f, opset_version=17)
    #   then onnxruntime.quantization.quantize_dynamic -> *_int8.onnx
    # TFLite (edge path for Flutter):
    #   tf.lite.TFLiteConverter.from_keras_model(...) -> .tflite
    # Native:
    #   torch.save(model.state_dict(), out_dir / f'{name}-{version}.safetensors')
    return {
        'name': name,
        'version': version,
        'artifact_path': str(out_dir / f'{name}-{version}.onnx'),
        'framework': 'pytorch',
        'input_schema': {},
        'output_schema': {},
        'metrics': {},
    }


def write_model_card(meta: dict, out_dir: Path):
    card = {
        'name': meta['name'],
        'version': meta['version'],
        'task': '',
        'algorithm': 'transfer-learning + attention',
        'training_data': '',
        'metrics': meta['metrics'],
        'limitations': '',
        'artifact_path': meta['artifact_path'],
    }
    (out_dir / f'{meta["name"]}-{meta["version"]}.card.json').write_text(
        json.dumps(card, indent=2)
    )
    print(json.dumps(meta, indent=2))


def main():
    args = parse_args()
    # 1. Load dataset (DVC-pulled from ../data)
    # 2. Build model + transforms
    # 3. Train / fine-tune (log scalars to MLflow if tracking URI set)
    # 4. Evaluate
    # 5. export_model(...) -> write_model_card(...)
    raise NotImplementedError(
        f'Implement the {args.model} training pipeline here. See notebooks/README.md.'
    )


if __name__ == '__main__':
    main()

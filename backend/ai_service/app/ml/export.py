"""ONNX export + INT8 quantization helpers.

Targets: CPU-only inference (the docker ai-service has no GPU). Export during
training (see training/train_template.py), quantize to INT8, drop the .onnx into
AI_MODEL_CACHE_DIR; serving loads it instead of the raw torch model.
"""
import logging
from pathlib import Path

logger = logging.getLogger(__name__)


def export_torch_to_onnx(model, dummy_input, path: str, opset: int = 17) -> str:
    """Export a torch model to ONNX. Requires torch installed."""
    import torch

    path = str(path)
    model.eval()
    model = model.to('cpu')
    with torch.no_grad():
        torch.onnx.export(
            model,
            dummy_input,
            path,
            opset_version=opset,
            input_names=['input'],
            output_names=['output'],
            dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}},
        )
    logger.info('Exported ONNX model to %s', path)
    return path


def quantize_onnx(model_path: str, out_path: str | None = None) -> str:
    """Dynamic INT8 quantization (weights) for CPU serving."""
    try:
        from onnxruntime.quantization import quantize_dynamic, QuantType
    except ImportError:
        logger.warning('onnxruntime not installed — skipping quantization')
        return model_path

    out_path = out_path or str(Path(model_path).with_name(Path(model_path).stem + '_int8.onnx'))
    quantize_dynamic(model_path, out_path, weight_type=QuantType.QInt8)
    logger.info('Quantized ONNX model to %s', out_path)
    return out_path

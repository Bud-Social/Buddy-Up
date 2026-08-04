# Model Card Template

Copy per trained model. Stored next to the artifact and mirrored into the Django
`apps.ai.ModelMetadata` row (which drives active-version selection + canary A/B).

```json
{
  "name": "food_classifier",
  "version": "1.2.0",
  "framework": "pytorch",
  "algorithm": "transfer-learning (ViT-B/16) + attention",
  "task": "image classification -> nutrition lookup",
  "training_data": "Food-101 (101 classes) + Nutrition5k + user-corrected logs",
  "training_steps": 0,
  "metrics": {
    "accuracy": 0.0,
    "top5_accuracy": 0.0,
    "nutrition_map_coverage": 0.0
  },
  "serving": {
    "artifact_path": "s3://buddyup-models/food_classifier/1.2.0/model_int8.onnx",
    "runtime": "onnxruntime",
    "quantization": "int8",
    "edge_path": "food_classifier.tflite"
  },
  "input_schema": {"image": "jpeg/png bytes", "top_k": 5},
  "output_schema": {"items": [{"item": "str", "confidence": 0.0, "nutrition": {"calories": 0}}]},
  "limitations": [
    "Regional/less-common dishes may fall back to keyword matching",
    "Portion size is estimated from confidence, not true volume"
  ],
  "bias_notes": "",
  "owner": "ml@buddyup.app"
}
```

"""Register (or refresh) the six banded-ensemble ModelMetadata rows.

Metrics below are the honest numbers from the real-batch verification runs
(see the executed notebooks in backend/ai_service/notebooks/): smoke/demo
scale on CPU, so treat them as pipeline-proven prototypes, not SOTA claims.
Re-run with --metrics-json to overwrite metrics after a full-scale run.
"""

import json

from django.core.management.base import BaseCommand

from apps.ai.models import ModelMetadata

BANDED = [
    {
        "name": "banded_nlp_best", "version": "1.0.0", "framework": "pytorch",
        "description": "Banded attention-NLP ensemble head (20-member protocol; "
                       "best member exported). jokes-vs-meirl domain classifier.",
        "input_schema": {"text": "str"},
        "output_schema": {"label": "jokes|meirl", "confidence": "float"},
        "metrics": {"bagged_acc": 0.963, "best_single_acc": 0.956,
                    "train_rows": 28974, "scale": "smoke", "data": "real"},
        "artifact_path": "banded_nlp_best.onnx",
    },
    {
        "name": "banded_vision_best", "version": "1.0.0", "framework": "pytorch",
        "description": "Banded ConvNet+ViT ensemble head (best member). "
                       "Neutral-vs-NSFW 32px pre-filter; escalate flags to NudeNet.",
        "input_schema": {"image": "bytes"},
        "output_schema": {"label": "Neutral|NSFW", "confidence": "float",
                          "action": "approve|flag"},
        "metrics": {"best_single_acc": 0.703, "bagged_acc": 0.649,
                    "majority_baseline": 0.604, "train_rows": 16638,
                    "scale": "demo", "data": "real"},
        "artifact_path": "banded_vision_best.onnx",
    },
    {
        "name": "multimodal_fuse", "version": "1.0.0", "framework": "pytorch",
        "description": "JEPA fused head over 5 modality towers "
                       "(image/video/audio/text/file). Per-tower probes gate bands.",
        "input_schema": {"embeddings": "(N, 320) float32"},
        "output_schema": {"top_class": "int[]", "confidence": "float[]"},
        "metrics": {"probe_text": 0.945, "probe_image": 0.672,
                    "probe_audio": 0.602, "probe_file": 0.562,
                    "scale": "smoke", "data": "real"},
        "artifact_path": "multimodal_fuse.onnx",
    },
    {
        "name": "recsys_item_emb", "version": "1.0.0", "framework": "pytorch",
        "description": "Banded two-tower item tower (32-dim) for FAISS indexing. "
                       "Pair with feed_ranker for scores.",
        "input_schema": {"item_ids": "int[]"},
        "output_schema": {"vectors": "(N, 32) float32"},
        "metrics": {"member_hr10": 0.395, "fused_hr10": 0.33,
                    "train_pairs": 273923, "scale": "demo", "data": "real"},
        "artifact_path": "recsys_item_emb.onnx",
    },
    {
        "name": "rl_nlp_policy", "version": "1.0.0", "framework": "pytorch",
        "description": "DQN+A2C banded behaviour policy over attention-encoded "
                       "text states (coaching-cue / reply actions).",
        "input_schema": {"text": "str"},
        "output_schema": {"action": "0..3", "probs": "float[4]"},
        "metrics": {"bagged_win_rate": 1.0, "note": "rule-labelled states; "
                    "re-eval on live engagement before product use",
                    "scale": "smoke", "data": "real"},
        "artifact_path": "rl_nlp_policy.onnx",
    },
    {
        "name": "rl_jepa_policy", "version": "1.0.0", "framework": "pytorch",
        "description": "Latent actor on a JEPA world model (Dreamer-style). "
                       "World model trained on real CartPole transitions.",
        "input_schema": {"obs": "float[48]"},
        "output_schema": {"action": "0..1", "probs": "float[2]"},
        "metrics": {"bagged_return": 0.48, "world_model_mse": 0.0002,
                    "scale": "smoke", "data": "real"},
        "artifact_path": "rl_jepa_policy.onnx",
    },
]


class Command(BaseCommand):
    help = "Upsert the six banded-ensemble ModelMetadata rows."

    def add_arguments(self, parser):
        parser.add_argument("--metrics-json", default="",
                            help="JSON file mapping model name -> metrics dict")

    def handle(self, *args, **options):
        overrides = {}
        if options["metrics_json"]:
            with open(options["metrics_json"]) as fh:
                overrides = json.load(fh)
        for spec in BANDED:
            metrics = dict(spec["metrics"])
            metrics.update(overrides.get(spec["name"], {}))
            _, created = ModelMetadata.objects.update_or_create(
                name=spec["name"],
                defaults={
                    "version": spec["version"],
                    "description": spec["description"],
                    "framework": spec["framework"],
                    "input_schema": spec["input_schema"],
                    "output_schema": spec["output_schema"],
                    "metrics": metrics,
                    "artifact_path": spec["artifact_path"],
                    "is_active": True,
                },
            )
            self.stdout.write(
                f"{'CREATED' if created else 'UPDATED'} {spec['name']}:{spec['version']}"
            )

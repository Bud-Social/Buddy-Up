#!/usr/bin/env bash
set -euo pipefail

ENV_DIR="${ML_ENV_DIR:-$HOME/Desktop/ml-env}"
KERNEL_NAME="buddyup-ml"
KERNEL_DISPLAY="Python 3.13 (ML)"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/backend/ai_service/requirements-training.txt"

if [[ ! -f "$MANIFEST" ]]; then
  echo "manifest not found: $MANIFEST" >&2
  exit 1
fi

if [[ ! -x "$ENV_DIR/bin/python" ]]; then
  echo "creating venv at $ENV_DIR"
  python3 -m venv "$ENV_DIR"
else
  echo "venv already present at $ENV_DIR"
fi

"$ENV_DIR/bin/pip" install --quiet --upgrade pip
"$ENV_DIR/bin/pip" install --quiet -r "$MANIFEST"
"$ENV_DIR/bin/pip" install --quiet torch torchvision --index-url https://download.pytorch.org/whl/cpu

"$ENV_DIR/bin/python" -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY"

echo "smoke test..."
"$ENV_DIR/bin/python" -c "import tensorflow as tf, torch, datasets, faiss, mlflow, sklearn, pandas, numpy; print('TF', tf.__version__, '| torch', torch.__version__, '| datasets', datasets.__version__)"

echo "done. kernel '$KERNEL_NAME' registered. pick it in VS Code: Python 3.13 (ML)"

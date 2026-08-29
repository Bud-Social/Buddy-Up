#!/usr/bin/env bash
set -euo pipefail

# Generate into a temporary file so CI verifies the live Django route/schema
# contract without committing environment-specific output.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$(mktemp)"
trap 'rm -f "$output"' EXIT
cd "$repo_root/backend"
python_bin="python"
if [[ -x "$repo_root/backend/.venv/bin/python" ]]; then
  python_bin="$repo_root/backend/.venv/bin/python"
fi
"$python_bin" manage.py spectacular --file "$output" --validate
test -s "$output"
printf 'OpenAPI contract valid: %s\n' "$output"

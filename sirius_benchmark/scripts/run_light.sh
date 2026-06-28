#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${RUN_ID:-sirius-light}"
PREDICTIONS_PATH="${PREDICTIONS_PATH:-gold}"
MAX_WORKERS="${MAX_WORKERS:-1}"
NAMESPACE="${NAMESPACE:-}"

python -m swebench.harness.run_evaluation \
  --dataset_name sirius_benchmark/datasets/light.jsonl \
  --predictions_path "${PREDICTIONS_PATH}" \
  --max_workers "${MAX_WORKERS}" \
  --run_id "${RUN_ID}" \
  --namespace "${NAMESPACE}"

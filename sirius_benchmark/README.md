# Sirius SWE-bench Light

10 simple SWE-bench Lite tasks for a fast classroom run.

## Files

- Dataset: `sirius_benchmark/datasets/light.jsonl`
- Tickets CSV: `sirius_benchmark/tickets/light_tickets.csv`
- Instance IDs: `sirius_benchmark/configs/light_instance_ids.txt`

## Run

```bash
pip install -e .
bash sirius_benchmark/scripts/run_light.sh
```

The default run uses `PREDICTIONS_PATH=gold`. To evaluate model predictions:

```bash
PREDICTIONS_PATH=predictions.jsonl bash sirius_benchmark/scripts/run_light.sh
```

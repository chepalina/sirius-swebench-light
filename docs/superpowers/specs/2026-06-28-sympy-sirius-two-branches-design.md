# SymPy Sirius Two-Branch Design

## Goal

Build a classroom-friendly SymPy fork for the 10 Sirius light bugs from `sirius_benchmark/tickets/light_tickets.csv`.

The fork must expose two branches:

- `sirius-light-buggy`: contains all 10 regressions.
- `sirius-light-golden`: contains the same Sirius tests, with the bugs fixed.

The local student workflow must be two folders and one command per folder, without requiring students to understand SWE-bench, Docker, or the full SymPy test suite.

## Repository Shape

Use one GitHub fork of `sympy/sympy` and two branches in that fork. Locally, expose the branches with `git worktree`:

```text
sympy-sirius-light/
  buggy/    # sirius-light-buggy
  golden/   # sirius-light-golden
```

This keeps GitHub history clean while giving students a simple folder-based interface.

## Test Scope

Both branches contain exactly one Sirius test module:

```text
sirius_tests/test_light_bugs.py
```

The verification command runs only that module. It does not run the native SymPy test suite.

The dataset has 10 bugs and 11 expected fail-to-pass test functions because `sympy__sympy-17655` has two checks: `test_point` and `test_point3D`.

## Branch Semantics

`sirius-light-golden` is the reference branch:

- `python -m pytest -q sirius_tests/test_light_bugs.py` passes.
- The branch may include small compatibility edits needed to make the Sirius tests run on the chosen SymPy baseline.

`sirius-light-buggy` is the exercise branch:

- It starts from `sirius-light-golden`.
- It reintroduces the 10 target regressions.
- `python -m pytest -q sirius_tests/test_light_bugs.py` fails on the Sirius checks.

## Student Commands

Each branch includes:

```text
scripts/setup_sirius.sh
scripts/run_sirius_tests.sh
SIRIUS_BUGS.md
```

Expected usage:

```bash
cd buggy
./scripts/setup_sirius.sh
./scripts/run_sirius_tests.sh

cd ../golden
./scripts/setup_sirius.sh
./scripts/run_sirius_tests.sh
```

## Source Data

Use `sirius_benchmark/datasets/light.jsonl` as the source of truth for:

- `instance_id`
- `problem_statement`
- `patch`
- `test_patch`
- `FAIL_TO_PASS`
- `base_commit`

Use `sirius_benchmark/tickets/light_tickets.csv` as the human-readable task table for `SIRIUS_BUGS.md`.

## Non-Goals

- Do not preserve one historical checkout per SWE-bench instance.
- Do not require Docker.
- Do not run all SymPy tests in the classroom workflow.
- Do not expose SWE-bench harness commands as the primary student path.

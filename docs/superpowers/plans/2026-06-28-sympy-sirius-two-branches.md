# SymPy Sirius Two-Branch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create one SymPy fork with `sirius-light-buggy` and `sirius-light-golden` branches, each runnable locally with only the Sirius light tests.

**Architecture:** Use the local Sirius benchmark repo as the source of truth and a separate SymPy clone as the deliverable. The SymPy fork gets a single `sirius_tests/test_light_bugs.py` module plus two scripts; branch behavior differs only in whether the 10 regressions are present.

**Tech Stack:** Git, GitHub fork of `sympy/sympy`, Python virtualenv, pytest, SymPy editable install.

---

## File Map

- Source data: `sirius_benchmark/datasets/light.jsonl`
- Source table: `sirius_benchmark/tickets/light_tickets.csv`
- SymPy branch file to create: `sirius_tests/test_light_bugs.py`
- SymPy branch file to create: `scripts/setup_sirius.sh`
- SymPy branch file to create: `scripts/run_sirius_tests.sh`
- SymPy branch file to create: `SIRIUS_BUGS.md`
- Local worktree root to create: `/Users/family/Documents/Сириус/sympy-sirius-light`
- Local golden checkout: `/Users/family/Documents/Сириус/sympy-sirius-light/golden`
- Local buggy checkout: `/Users/family/Documents/Сириус/sympy-sirius-light/buggy`

## Target Test Module

Create this exact test module in both SymPy branches:

```python
from sympy import (
    Abs,
    BlockDiagMatrix,
    Derivative,
    Matrix,
    MatrixSymbol,
    Max,
    Min,
    Point,
    Point3D,
    S,
    mathematica_code as mcode,
    oo,
    sin,
    solve_poly_system,
    symbols,
    zoo,
)
from sympy.combinatorics import Permutation
from sympy.core.kind import NumberKind
from sympy.core.parameters import evaluate
from sympy.core.power import power
from sympy.matrices import MatrixKind
from sympy.testing.pytest import raises, unchanged


x, y, z = symbols("x y z")


def test_issue_18618():
    A = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    assert A == Matrix(BlockDiagMatrix(A))


def test_Function():
    assert mcode(Max(x, y, z) * Min(y, z)) == "Max[x, y, z]*Min[y, z]"


def test_Derivative_kind():
    A = MatrixSymbol("A", 2, 2)
    assert Derivative(x, x).kind is NumberKind
    assert Derivative(A, x).kind is MatrixKind(NumberKind)


def test_issue_22684():
    with evaluate(False):
        Point(1, 2)


def test_Abs():
    assert unchanged(Abs, S("im(acos(-i + acosh(-g + i)))"))


def test_solve_poly_system():
    raises(NotImplementedError, lambda: solve_poly_system([x - 1], (x, y)))
    raises(NotImplementedError, lambda: solve_poly_system([y - 1], (x, y)))


def test_args():
    assert Permutation([[0, 1], [0, 2]]) == Permutation(0, 1, 2)


def test_Derivative():
    assert mcode(Derivative(sin(x), x)) == "Hold[D[Sin[x], x]]"
    assert mcode(Derivative(x, x)) == "Hold[D[x, x]]"
    assert mcode(Derivative(sin(x) * y**4, x, 2)) == "Hold[D[y^4*Sin[x], x, x]]"
    assert mcode(Derivative(sin(x) * y**4, x, y, x)) == "Hold[D[y^4*Sin[x], x, y, x]]"
    assert mcode(Derivative(sin(x) * y**4, x, y, 3, x)) == "Hold[D[y^4*Sin[x], x, y, y, y, x]]"


def test_point():
    p4 = Point(1, 1)
    assert p4 * 5 == Point(5, 5)
    assert p4 / 5 == Point(0.2, 0.2)
    assert 5 * p4 == Point(5, 5)


def test_point3D():
    p4 = Point3D(1, 1, 1)
    assert p4 * 5 == Point3D(5, 5, 5)
    assert p4 / 5 == Point3D(0.2, 0.2, 0.2)
    assert 5 * p4 == Point3D(5, 5, 5)


def test_zero():
    assert 0 ** -oo is zoo
    assert power(0, -oo) is zoo
```

## Task 1: Prepare SymPy Fork Locally

**Files:**
- Create local clone: `/Users/family/Documents/Сириус/sympy-sirius-light/repo`

- [ ] **Step 1: Clone the fork or upstream SymPy repository**

Run:

```bash
mkdir -p /Users/family/Documents/Сириус/sympy-sirius-light
cd /Users/family/Documents/Сириус/sympy-sirius-light
git clone https://github.com/sympy/sympy.git repo
```

Expected: `repo/.git` exists.

- [ ] **Step 2: Add the user's fork remote after the fork exists**

Run after creating the GitHub fork:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
git remote rename origin upstream
git remote add origin https://github.com/chepalina/sympy-sirius-light.git
git fetch upstream --tags
```

Expected: `git remote -v` shows `upstream` as `sympy/sympy` and `origin` as the fork.

- [ ] **Step 3: Pick a stable baseline**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
git checkout -b sirius-light-golden upstream/master
```

Expected: branch `sirius-light-golden` exists. Use `upstream/master` because it should already contain the historical gold fixes; if the target tests reveal a behavior drift, fix the test compatibility in `sirius_tests/test_light_bugs.py` rather than changing the scope.

## Task 2: Add Sirius Test Harness to Golden Branch

**Files:**
- Create: `sirius_tests/test_light_bugs.py`
- Create: `scripts/setup_sirius.sh`
- Create: `scripts/run_sirius_tests.sh`
- Create: `SIRIUS_BUGS.md`

- [ ] **Step 1: Create the test directory and scripts directory**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
mkdir -p sirius_tests scripts
```

Expected: both directories exist.

- [ ] **Step 2: Add `sirius_tests/test_light_bugs.py`**

Write the exact Python module from the "Target Test Module" section.

- [ ] **Step 3: Add `scripts/setup_sirius.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

python3 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e . pytest
```

- [ ] **Step 4: Add `scripts/run_sirius_tests.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ -d .venv ]; then
  . .venv/bin/activate
fi

python -m pytest -q sirius_tests/test_light_bugs.py
```

- [ ] **Step 5: Make scripts executable**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
chmod +x scripts/setup_sirius.sh scripts/run_sirius_tests.sh
```

Expected: `ls -l scripts/*sirius*.sh` shows executable bits.

- [ ] **Step 6: Add `SIRIUS_BUGS.md`**

Use this table:

````markdown
# Sirius Light Bugs

This branch is part of the Sirius classroom SymPy fork.

Run only the Sirius tests:

```bash
./scripts/run_sirius_tests.sh
```

| Instance | Check | Code area |
| --- | --- | --- |
| sympy__sympy-18621 | test_issue_18618 | sympy/matrices/expressions/blockmatrix.py |
| sympy__sympy-15345 | test_Function | sympy/printing/mathematica.py |
| sympy__sympy-21614 | test_Derivative_kind | sympy/core/function.py |
| sympy__sympy-22714 | test_issue_22684 | sympy/geometry/point.py |
| sympy__sympy-21627 | test_Abs | sympy/functions/elementary/complexes.py |
| sympy__sympy-22005 | test_solve_poly_system | sympy/solvers/polysys.py |
| sympy__sympy-12481 | test_args | sympy/combinatorics/permutations.py |
| sympy__sympy-12171 | test_Derivative | sympy/printing/mathematica.py |
| sympy__sympy-17655 | test_point, test_point3D | sympy/geometry/point.py |
| sympy__sympy-20212 | test_zero | sympy/core/power.py |
````

- [ ] **Step 7: Run golden tests**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
./scripts/setup_sirius.sh
./scripts/run_sirius_tests.sh
```

Expected: all tests in `sirius_tests/test_light_bugs.py` pass.

- [ ] **Step 8: Commit golden harness**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
git add sirius_tests/test_light_bugs.py scripts/setup_sirius.sh scripts/run_sirius_tests.sh SIRIUS_BUGS.md
git commit -m "Add Sirius light bug tests"
```

## Task 3: Create Buggy Branch and Reintroduce Regressions

**Files to modify in SymPy fork:**
- `sympy/matrices/expressions/blockmatrix.py`
- `sympy/printing/mathematica.py`
- `sympy/core/function.py`
- `sympy/geometry/point.py`
- `sympy/functions/elementary/complexes.py`
- `sympy/solvers/polysys.py`
- `sympy/combinatorics/permutations.py`
- `sympy/core/power.py`

- [ ] **Step 1: Create buggy branch from golden**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
git checkout -b sirius-light-buggy sirius-light-golden
```

Expected: branch `sirius-light-buggy` exists.

- [ ] **Step 2: Reintroduce the 10 regressions**

Apply the inverse of the 10 gold fixes from `sirius_benchmark/datasets/light.jsonl`:

```text
sympy__sympy-18621: remove evaluate=False from BlockDiagMatrix.blocks ImmutableDenseMatrix construction
sympy__sympy-15345: remove Max/Min Mathematica mappings and MinMax printer alias
sympy__sympy-21614: remove Derivative.kind property
sympy__sympy-22714: change Point imaginary-coordinate guard back to truthiness of im(a)
sympy__sympy-21627: remove Abs.eval early return for extended real args
sympy__sympy-22005: remove reduced-system basis length check
sympy__sympy-12481: reject duplicate cycle elements again in Permutation cycle input
sympy__sympy-12171: remove Mathematica Derivative printer
sympy__sympy-17655: remove Point.__rmul__
sympy__sympy-20212: remove 0 ** -oo special case returning zoo
```

- [ ] **Step 3: Run buggy tests**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
./scripts/run_sirius_tests.sh
```

Expected: the Sirius test module fails. Confirm each failure maps to one of the 10 bug rows in `SIRIUS_BUGS.md`.

- [ ] **Step 4: Commit buggy regressions**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/repo
git add sympy/matrices/expressions/blockmatrix.py sympy/printing/mathematica.py sympy/core/function.py sympy/geometry/point.py sympy/functions/elementary/complexes.py sympy/solvers/polysys.py sympy/combinatorics/permutations.py sympy/core/power.py
git commit -m "Reintroduce Sirius light regressions"
```

## Task 4: Create Two Local Student Folders

**Files:**
- Local worktree: `/Users/family/Documents/Сириус/sympy-sirius-light/golden`
- Local worktree: `/Users/family/Documents/Сириус/sympy-sirius-light/buggy`

- [ ] **Step 1: Move repo clone under hidden implementation folder**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light
mv repo .repo
```

Expected: `/Users/family/Documents/Сириус/sympy-sirius-light/.repo/.git` exists.

- [ ] **Step 2: Add golden worktree**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/.repo
git worktree add ../golden sirius-light-golden
```

Expected: `/Users/family/Documents/Сириус/sympy-sirius-light/golden/scripts/run_sirius_tests.sh` exists.

- [ ] **Step 3: Add buggy worktree**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/.repo
git worktree add ../buggy sirius-light-buggy
```

Expected: `/Users/family/Documents/Сириус/sympy-sirius-light/buggy/scripts/run_sirius_tests.sh` exists.

## Task 5: Final Verification

**Files:**
- Verify: `/Users/family/Documents/Сириус/sympy-sirius-light/golden`
- Verify: `/Users/family/Documents/Сириус/sympy-sirius-light/buggy`

- [ ] **Step 1: Verify golden branch**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/golden
./scripts/setup_sirius.sh
./scripts/run_sirius_tests.sh
```

Expected: all Sirius tests pass.

- [ ] **Step 2: Verify buggy branch**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/buggy
./scripts/setup_sirius.sh
./scripts/run_sirius_tests.sh
```

Expected: Sirius tests fail on the intended bug checks.

- [ ] **Step 3: Confirm no full SymPy suite is part of the workflow**

Run:

```bash
cd /Users/family/Documents/Сириус/sympy-sirius-light/golden
sed -n '1,80p' scripts/run_sirius_tests.sh
```

Expected: the script contains only `python -m pytest -q sirius_tests/test_light_bugs.py`.

## Self-Review Notes

- Spec coverage: the plan creates one fork, two branches, two local folders, one Sirius-only test module, and simple setup/run scripts.
- Red-flag scan: no open-ended requirement markers remain; branch baseline is fixed to `upstream/master`.
- Type consistency: branch names, script paths, and test module paths are consistent across all tasks.

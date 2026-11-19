# Part A - SLD Resolution Engine Execution Evidence

## 1. Project Information

- **Project:** SLD Resolution Tree Visualizer
- **Course:** EIF400 - Programming Paradigms
- **Group:** 04-10am
- **Instructor:** Carlos Loria-Saenz
- **Student:** Emmanuel Nunez Jimenez
- **Individual Contribution:** Part A - SLD Meta-Interpreter and Logical Resolution Engine
- **Environment:** SWI-Prolog 10.0.2 for Windows (64-bit)
- **Working Branch:** `feature/sld-meta-interpreter`
- **Execution Date:** November 19, 2026
- **Repository Baseline Commit:** `f8d5943`
- **Engine Implementation Commit:** `b0b1033`

## 2. Purpose

This directory contains execution evidence for the SLD resolution engine developed as Part A of the approved project.

The evidence demonstrates logical resolution, unification, recursion, backtracking, multiple solutions, depth control, and resolution tracing.

All results were obtained from actual executions using SWI-Prolog.

## 3. Evidence Files

| File | Description |
|---|---|
| `automated_tests.txt` | Results of the 31 automated engine and trace tests. |
| `basic_resolution.txt` | Fact resolution, unification, conjunctions, multiple solutions, and unsuccessful queries. |
| `recursion_depth.txt` | Recursive resolution, alternative branches, and configurable depth limits. |
| `sld_trace.txt` | Chronological resolution steps, clause applications, substitutions, backtracking, failures, and cutoffs. |

## 4. Automated Test Results

The engine includes two automated test suites:

- `tests/engine/sld_engine_tests.pl`: 14 tests.
- `tests/engine/sld_trace_tests.pl`: 17 tests.

The combined execution completed successfully.

**Observed result: 31/31 tests passed.**

The process returned exit code `0`.

No errors or warnings were reported in the captured output.

## 5. Basic Resolution Evidence

The file `basic_resolution.txt` contains the following observed results:

```text
Fact answers: [luis,marta]
Conjunction answers: [luis-sofia,marta-diego]
Failed fact answers: []
```

These results demonstrate:

- Resolution of facts.
- Unification.
- Shared variables in conjunctions.
- Multiple solutions through backtracking.
- Detection of queries without solutions.

## 6. Recursion and Depth-Limit Evidence

The file `recursion_depth.txt` contains:

```text
Ancestor solutions depth 4: [luis,marta,sofia,diego]
Ancestor outcomes depth 2: [success,success,cutoff,cutoff]
Endless outcomes depth 3: [cutoff]
Loop outcomes depth 3: [cutoff,success,success,success]
```

These results demonstrate:

- Recursive rule resolution.
- Multiple recursive solutions.
- Configurable resolution depth.
- Depth cutoffs.
- Successful alternatives after recursive branches reach the depth limit.

A cutoff does not imply that a logical query is false.

## 7. Resolution Trace Evidence

The file `sld_trace.txt` contains four execution scenarios:

1. A query with multiple solutions.
2. A failed query.
3. Backtracking after an unsuccessful alternative.
4. Infinite recursion controlled by a depth limit.

Each trace uses the following structure:

```prolog
step(Sequence, Path, Depth, Action, Goal, Clause, RemainingGoals, Bindings).
```

Successful solutions are represented as:

```prolog
answer(Path, Bindings).
```

The trace information includes:

- Chronological event numbers.
- Resolution paths.
- Resolution depth.
- Selected goals.
- Applied clauses.
- Remaining goals.
- Variable substitutions.
- Successful and unsuccessful branches.
- Backtracking events.
- Depth cutoffs.

## 8. Reproducing the Automated Tests

From the project root, execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -g "run_tests([sld_engine,sld_trace])" -t halt
```

The expected result for the tested version is that all 31 tests pass.

The automated tests should be repeated after any changes to the engine.

## 9. Scope of the Evidence

These files provide evidence of the individual functionality of Part A.

They do not demonstrate that Part B has already constructed an SLD tree or exported JSON.

They also do not demonstrate the graphical visualization developed by Part C.

Integration tests must be performed separately when the corresponding components are available.

## 10. Individual Responsibility

The implementation and execution evidence documented here correspond to Emmanuel Nunez Jimenez.

Part A is responsible for the SLD meta-interpreter, logical resolution, recursion, backtracking, depth control, resolution tracing, and individual testing.

Part B, developed by Roy Arias Mejia, is responsible for constructing and exporting the SLD tree.

Part C, developed by Keynell Molina Mora, is responsible for visualizing the tree in the browser.

# Part A - SLD Meta-Interpreter: Short Technical Explanation

| Field | Details |
|---|---|
| Student | Emmanuel Nunez Jimenez |
| Course | EIF400 - Programming Paradigms |
| Group | 04-10am |
| Implementation | SWI-Prolog |

## 1. Purpose and Scope

Part A implements the logical resolution engine for the approved SLD Resolution Tree Visualizer. It interprets queries over an educational subset of Prolog consisting of facts, definite Horn-clause rules, and conjunctions of goals. Its job is to compute solutions and describe how resolution proceeded; it does not draw the SLD tree.

The implementation resides in `src/prolog/engine/sld_engine.pl`.

## 2. How the Engine Works

1. The engine receives a query and represents its pending goals.
2. It selects the **leftmost** pending goal.
3. It considers matching program clauses and uses SWI-Prolog unification to apply a clause.
4. It replaces the selected goal with the clause body while preserving the remaining goals and variable substitutions.
5. It repeats this process until the goal list is empty (**success**), no applicable alternative remains (**failure**), or a configured depth boundary prevents expansion (**cutoff**).
6. Prolog backtracking explores alternative clauses and may produce multiple solutions.

For example, the query `parent(ana, X)` produces `X = luis` and `X = marta`. The recursive query `ancestor(ana, X)` produces four answers: `luis`, `marta`, `sofia`, and `diego`.

## 3. Public Predicates

| Predicate | Responsibility |
|---|---|
| `sld_solve/1` | Enumerates logical solutions without a configurable depth limit. |
| `sld_solve_limited/3` | Resolves a query with a maximum branch depth and reports `success`, `failure`, or `cutoff` outcomes. |
| `sld_trace/4` | Returns chronological resolution events and structured successful answers. |

The depth limit counts clause applications along a resolution branch. It is **not** a time limit or a global limit on the number of events. A cutoff is not proof that the query is logically false.

## 4. Information Provided to the Tree Builder

The trace interface returns records with the following shapes:

```prolog
step(Number, Path, Depth, Action, SelectedGoal, Clause, RemainingGoals, Bindings).
answer(Path, Bindings).
binding(VariableId, Value).
```

The supported actions include `start`, `apply`, `success`, `failure`, `cutoff`, and `backtrack`. The trace records branch paths, selected goals, applied clauses, pending goals, and variable-binding snapshots. It also represents the tested cases of aliased versus independent unbound query variables.

Part B, developed by Roy Arias Mejia, can use these records to construct the SLD tree and export JSON. Part C, developed by Keynell Molina Mora, is responsible for visualization. **The Part A tests do not establish that the complete three-part integration has been verified.**

## 5. Recorded Individual Verification

| Verification | Recorded result |
|---|---|
| Basic engine tests | 14/14 passed |
| Resolution trace tests | 17/17 passed |
| Variable aliasing tests | 3/3 passed |
| Structured event contract tests | 7/7 passed |
| **All automated tests** | **41/41 passed** |
| **Demonstration scenarios** | **12/12 passed** |

The recorded executions returned exit code `0`. Individual evidence is available in `docs/evidence/engine/`; reproducible commands and presentation steps are documented in `docs/ENGINE_DEMO.md`.

## 6. Main Limitations

- The supported language subset does not generally interpret cut (`!`), negation-as-failure, disjunction, arbitrary built-ins, general arithmetic, side effects, or dynamic database updates.
- Program facts and rules are obtained from the SWI-Prolog `user` module; arbitrary Prolog-module interpretation is outside the scope.
- `sld_solve/1` can loop indefinitely on a non-terminating recursive query; use the depth-limited interface for such demonstrations.
- Goals, clauses, and bindings in traces are stable textual snapshots, not live Prolog variables. Generated labels such as `V1` do not necessarily preserve source variable names.
- Aliasing is represented for the tested cases, but the trace is not a complete serialization of every possible variable relationship in arbitrary terms.
- Tree hierarchy construction, JSON export, and the graphical interface belong to Parts B and C.

## 7. Individual Demonstration

Emmanuel can demonstrate each feature separately: facts and rules (meta-interpreter), case 7 (unification and conjunctions), case 8 (failure followed by backtracking), case 9 (recursion), case 11 (depth cutoff), and the `step/8` contract tests (information supplied to Part B). The complete commands and expected results appear in `docs/ENGINE_DEMO.md`.

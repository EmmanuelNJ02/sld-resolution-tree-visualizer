# SLD Resolution Engine - Integration Contract

## Project Information

- **Project:** SLD Resolution Tree Visualizer
- **University:** National University of Costa Rica (UNA)
- **Course:** EIF400 - Programming Paradigms
- **Group:** 04-10am
- **Instructor:** Carlos Loria-Saenz
- **Part A:** Emmanuel Nunez Jimenez
- **Part B:** Roy Arias Mejia
- **Part C:** Keynell Molina Mora
- **Academic term:** Second Semester, 2026

**Status:** Part A implemented and individually tested. The integration contract is **pending final validation by Emmanuel and Roy**.

**Implementation reference:** `feature/sld-meta-interpreter`, commit `b0b1033` (November 19, 2026).

## 1. Purpose

This document defines the interface between the SLD resolution engine developed by Emmanuel (Part A) and the SLD tree construction and JSON export component developed by Roy (Part B).

Part A resolves queries over a supported subset of Prolog and produces a chronological trace of the resolution process. Part B consumes this information to construct the SLD tree. Part C, developed by Keynell, displays the JSON representation in a web browser.

The data format described below reflects the **current implementation of Part A**. It is not considered a final team-wide contract until Parts A and B validate it together.

## 2. Component Responsibilities

### Part A - SLD Meta-Interpreter and Resolution Engine

**Responsible:** Emmanuel Nunez Jimenez.

1. Resolve facts, definite Horn-clause rules, and conjunctions of goals.
2. Apply leftmost goal selection, clause selection, and unification.
3. Support recursion, backtracking, and multiple solutions.
4. Distinguish unsuccessful branches from branches stopped by the depth limit.
5. Provide a configurable maximum resolution depth.
6. Generate stable step records and answer information for Part B.
7. Develop and execute individual engine and trace tests.
8. Document and demonstrate the individual contribution.

**Main deliverables:**

- `src/prolog/engine/sld_engine.pl`
- `tests/engine/sld_engine_tests.pl`
- `tests/engine/sld_trace_tests.pl`
- `examples/programs/family.pl`
- `examples/programs/recursive_loop.pl`

Part A **does not** construct the final tree or export JSON.

### Part B - SLD Tree Builder and JSON Export

**Responsible:** Roy Arias Mejia.

1. Receive and interpret the trace produced by Part A.
2. Organize resolution events into nodes and parent-child relationships.
3. Associate goals, applied clauses, and substitutions with tree branches.
4. Distinguish success, failure, cutoff, and explored alternatives.
5. Export the constructed tree as structured JSON.
6. Develop individual tests and integration tests with Part A.

**Main deliverable:** `src/prolog/tree/sld_tree.pl`.

Part B **does not** reimplement SLD resolution.

### Part C - Web Visualizer

**Responsible:** Keynell Molina Mora.

1. Read the JSON produced by Part B.
2. Display the SLD tree with nodes and connections.
3. Show goals, clauses, and substitutions.
4. Visually distinguish successful, failed, and depth-limited branches.
5. Allow inspection of node details.
6. Develop individual visualization tests.

**Main deliverables:**

- `src/web/index.html`
- `src/web/js/visualizer.js`
- CSS styles and visualization tests.

## 3. Implemented Engine Interface

The following predicates are publicly exported by the `sld_engine` module:

```prolog
sld_solve(+Query).
sld_solve_limited(+Query, +MaxDepth, -Outcome).
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

| Predicate | Behavior |
|---|---|
| `sld_solve/1` | Resolves goals through Prolog backtracking. It has no depth limit and may not terminate for an infinite recursive branch. |
| `sld_solve_limited/3` | Enumerates a **terminal outcome per explored branch** (`success`, `failure`, or `cutoff`) through backtracking. It does not return a single global outcome. |
| `sld_trace/4` | Returns **one aggregated result** containing the complete depth-limited list of recorded steps and successful answers. It does not bind the original query variables to each answer in turn. |

### Parameters of `sld_trace/4`

- **`Query`:** A callable goal or conjunction within the supported subset. The empty goal `true` is supported.
- **`MaxDepth`:** A non-negative integer. The root has depth zero; each applied clause increases depth by one. An invalid depth currently makes the predicate fail.
- **`Steps`:** Chronologically ordered list of `step/8` records, including unsuccessful and depth-limited branches.
- **`Answers`:** List of `answer(Path, Bindings)` terms for successful branches, in the order explored.

The example program predicates are loaded into the SWI-Prolog **`user` module**. The engine looks up program clauses using `clause(user:Goal, Body)`; arbitrary module qualification or unrestricted built-ins are not supported by this contract.

## 4. Implemented Resolution Step Format

Each trace record has the following structure:

```prolog
step(Sequence, Path, Depth, Action, Goal, Clause, RemainingGoals, Bindings).
```

| Field | Implemented representation | Meaning |
|---|---|---|
| `Sequence` | Positive integer, beginning at `1` | Chronological event number. |
| `Path` | List of positive integers, root `[]` | Clause-choice positions identifying the explored resolution alternative. |
| `Depth` | Non-negative integer | Number of clause applications on that branch. |
| `Action` | Atom | One of `start`, `apply`, `success`, `failure`, `cutoff`, `backtrack`. |
| `Goal` | String or atom `none` | Stable textual snapshot of the selected goal; `none` when there is no selected goal. |
| `Clause` | String or atom `none` | Stable textual snapshot of the applied fact/rule, or `none`. |
| `RemainingGoals` | List of strings | Stable textual snapshots of goals pending at that event. |
| `Bindings` | List of `binding/2` terms | Snapshots of original query-variable substitutions. |

The recorded `step/8` structures are ground data. The string snapshots are intended for display and exchange; they are **not** references to live Prolog variables or a replacement for the original program clauses.

### Paths and depths

- `[]` is the initial path.
- Each applicable clause alternative is numbered from `1` **among the applicable alternatives for the current selected goal**.
- Applying a clause extends the current path, such as `[]` to `[1]` or `[2]`, and increases depth by one.
- A `backtrack` event uses the restored parent path and depth.
- `Path` is **not** a final tree-node ID. Part B is responsible for assigning node identifiers and building the tree hierarchy.
- The list is produced in depth-first exploration order, consistent with clause order.

## 5. Implemented Resolution Actions

| Action | When it is recorded | Relevant interpretation for Part B |
|---|---|---|
| `start` | Before resolution begins. | Root event at path `[]`, depth `0`. |
| `apply` | A clause head unifies with the selected goal and its body replaces that goal. | Record an applied-clause alternative at the extended path. |
| `success` | No unresolved goals remain. | Successful terminal branch. |
| `failure` | The selected goal has no unifiable applicable clause below the depth limit. | Failed terminal branch. |
| `cutoff` | Unresolved goals remain when the maximum depth is reached. | Depth-limited terminal branch; **not** logical falsity. |
| `backtrack` | Another applicable clause alternative remains at the parent state. | Return to the parent path before exploring the next alternative. |

**Important:** A `failure` event currently marks a **terminal goal with no applicable clause**. The absence of a successful answer in a higher-level subtree must be inferred by Part B from the recorded branch outcomes; the engine does not emit an additional failure event for every ancestor node.

## 6. Variable Substitutions and Answers

The engine uses the following representation:

```prolog
binding(VariableName, Value)
```

Both fields are strings. Original query variables are labeled `"V1"`, `"V2"`, and so on, according to their order in `term_variables/2` when the query begins.

Examples:

```prolog
binding("V1", "luis")
binding("V2", "_")
```

The value `"_"` indicates an unbound query variable. Compound terms are stored as readable Prolog text. Internally generated variable labels in goal and clause snapshots (for example `A`, `B`) are display names produced by variable numbering; they need not match the `V1`, `V2` binding labels.

Each successful branch is returned as:

```prolog
answer(Path, Bindings)
```

Example:

```prolog
answer([1], [binding("V1", "luis")])
```

The trace is generated from independent copies of each candidate resolution state. Previously recorded goals, clauses, bindings, and answers do not change when other alternatives are explored.

The original query variables supplied to `sld_trace/4` remain unbound; callers obtain solutions from `Answers`.

## 7. Supported Language Subset

The Part A engine supports:

- Facts.
- Definite Horn-clause rules.
- Single logical goals and conjunctions.
- The empty goal `true`.
- Leftmost goal selection and unification.
- Recursive rules and multiple solutions.
- Depth-first exploration and backtracking.
- Failed branches and depth cutoffs.
- Configurable non-negative integer depth limits.
- Chronological trace records and answer snapshots.

This is an educational meta-interpreter built using SWI-Prolog. It is not an independent Prolog simulator.

## 8. Scope Restrictions

The approved base scope does **not** include:

- Interpreting Prolog cuts (`!`) in user programs.
- Dynamic database modifications (`assertz/1`, `retract/1`, etc.) as user goals.
- Full support for built-in predicates, arithmetic, or side effects.
- General negation-as-failure as an interpreted goal.
- Disjunction as a separate interpreted query construct.
- Arbitrary modules or complete Prolog language compatibility.

The engine uses built-in predicates **internally** for clause inspection, copying, formatting, and control. This does not mean those built-ins are accepted as goals in the interpreted program.

## 9. Resolution Behavior

1. Convert the query or conjunction into a list of pending goals.
2. Select the leftmost goal.
3. Find clauses whose heads can unify with the selected goal, in defined order.
4. For each alternative, use an independent variable state.
5. Replace the selected goal with the selected clause body, keeping the remaining goals.
6. Record an `apply` event with the resulting substitutions and pending goals.
7. Continue recursively, increasing the depth after each clause application.
8. Record `success` if no goals remain, `failure` if the selected goal has no applicable clause, or `cutoff` if the depth limit prevents expansion.
9. Record `backtrack` before exploring the next applicable alternative.
10. Return the ordered list of steps and successful `answer/2` records.

For `sld_trace/4`, exploration is aggregated into one returned result. The depth limit applies **per branch**, not to the total number of recorded events.

## 10. Verified Illustrative Example

Given this program:

```prolog
parent(ana, luis).
parent(ana, marta).
```

Query:

```prolog
?- sld_trace(parent(ana, X), 1, Steps, Answers).
```

The observed event sequence is:

| Sequence | Path | Depth | Action | Meaning |
|---:|---|---:|---|---|
| 1 | `[]` | 0 | `start` | Begin with `parent(ana,X)`. |
| 2 | `[1]` | 1 | `apply` | Apply `parent(ana,luis)`. |
| 3 | `[1]` | 1 | `success` | First solution found. |
| 4 | `[]` | 0 | `backtrack` | Restore the parent state. |
| 5 | `[2]` | 1 | `apply` | Apply `parent(ana,marta)`. |
| 6 | `[2]` | 1 | `success` | Second solution found. |

The corresponding answers are:

```prolog
[
    answer([1], [binding("V1", "luis")]),
    answer([2], [binding("V1", "marta")])
]
```

SWI-Prolog's `writeln/1` may display string contents without visible quotes. This does not change their string representation.

Other executed examples demonstrated:

- An unsuccessful query: `parent(diego,X)` produces `start`, `failure`, and no answers.
- A zero depth limit: `parent(ana,X)` produces `start`, `cutoff`, and no answers.
- Recursion: `ancestor(ana,X)` with depth `4` finds `luis`, `marta`, `sofia`, and `diego`, with **26 recorded steps**.
- Infinite recursion control: `endless` with depth `3` produces `start`, three `apply` events, and `cutoff`.
- Combined recursion and alternatives: `loop` with depth `3` produces terminal outcomes `cutoff`, `success`, `success`, `success`.
- Conjunction with shared variables: `(parent(ana,X), parent(X,Y))` finds `luis-sofia` and `marta-diego`.

These are examples of **Part A behavior**, not evidence that Part B or Part C has already been integrated.

## 11. Integration Requirements

1. Part A must provide `Steps` and `Answers` without constructing tree nodes.
2. Part A must not export tree JSON.
3. Part B must read `step/8` events in chronological order and use `Path` to associate alternatives.
4. Part B must create node IDs and parent-child relationships independently.
5. Part B must interpret `none` as the absence of an applicable goal or clause field, as appropriate.
6. Part B must treat `Goal`, `Clause`, and items in `RemainingGoals` as string snapshots.
7. Part B must preserve the association of each `answer(Path, Bindings)` with its successful branch.
8. Part B must distinguish `failure` from `cutoff` in its tree and JSON representation.
9. Part B must handle `backtrack` as a return to an existing parent path, not as an independently applied clause.
10. Part C must visualize the JSON generated by Part B; it must not reproduce the SLD resolution logic.
11. Individual tests must be maintained, and the full integration must have separate shared tests.

The interface between Parts B and C (including the JSON schema) is **outside this engine contract** and must be documented by the responsible components.

## 12. Individual Testing and Evidence

### Part A - Executed tests

The following automated test suites were executed using **SWI-Prolog 10.0.2** on November 19, 2026:

| Test suite | File | Result |
|---|---|---|
| Basic engine | `tests/engine/sld_engine_tests.pl` | 14/14 passed |
| Resolution trace | `tests/engine/sld_trace_tests.pl` | 17/17 passed |
| **Combined** | Both suites | **31/31 passed without warnings in the final reported run** |

Command executed from the repository root:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -g "run_tests([sld_engine,sld_trace])" -t halt
```

The reported final output ended with:

```text
[31/31] sld_trace:noninteger_depth_rejected ... passed (0.000 sec)
```

The test coverage includes facts, rules, conjunctions, substitutions, multiple answers, recursion, backtracking, failures, depth limits, trace event order, independent snapshots, and invalid depth values.

### Part B - Individual tests (responsibility of Roy)

Part B must independently verify step consumption, node hierarchy, branch status, substitutions, answer association, and JSON export.

### Part C - Individual tests (responsibility of Keynell)

Part C must independently verify JSON reading, tree rendering, node connections, branch styling, and node detail inspection.

### Shared integration tests (pending)

An end-to-end test must verify that Part A trace data is consumed by Part B, exported as JSON, and then visualized by Part C. **No such integrated execution is claimed in this document.**

## 13. Pending Validation Between Parts A and B

Before this contract becomes final, Emmanuel and Roy must explicitly confirm:

1. The public signature `sld_trace/4`.
2. The exact `step/8` field types, including strings and the `none` atom.
3. The interpretation and numbering of `Path` alternatives.
4. The start-at-one chronological `Sequence` convention.
5. The stable variable labels `V1`, `V2`, etc., and the unbound marker `"_"`.
6. The `answer(Path, Bindings)` representation and association with success paths.
7. The distinction between `failure`, `cutoff`, and `backtrack`.
8. Whether the recorded information is sufficient to reconstruct all expected branches.
9. A shared test covering at least one successful, failed, and depth-limited branch.
10. Whether refinements are needed without expanding either student's assigned responsibility.

Any agreed changes must be reflected in this document and in the corresponding tests before final integration.

## 14. Current Development Status

**Part A - Implemented and individually tested:**

- Basic SLD meta-interpreter and resolution engine.
- Depth-limited resolution with `success`, `failure`, and `cutoff` outcomes.
- Aggregated resolution tracing via `sld_trace/4`.
- Stable snapshots of goals, clauses, and query-variable substitutions.
- Chronological events, alternative paths, and answer associations.
- 31 automated tests passed in the most recent reported execution.
- Implementation committed and pushed to `feature/sld-meta-interpreter` at `b0b1033`.

**Pending for Part A completion:**

- Validate the data contract with Roy.
- Execute and document a shared Part A-Part B integration test when Part B is available.
- Finish technical documentation, evidence collection, and the individual demonstration.
- Review and integrate the contribution through the project's pull-request workflow.

The current state of Part B and Part C is **not established by these Part A test results**. Their implementation and test results must be reported separately by the responsible students.

## 15. Academic Context

This project is an approved additional academic assignment for **EIF400 - Programming Paradigms** at the National University of Costa Rica.

The original SLD resolution tree visualizer proposal was accepted by instructor **Carlos Loria-Saenz on November 8, 2026**. The instructor subsequently requested a clear separation of individual contributions.

Each student is responsible for developing, understanding, testing, demonstrating, and individually defending the assigned component.

This contract supports collaboration while preserving the boundaries of the three contributions. It documents the **implemented Part A interface** but remains a draft until validated jointly by Emmanuel and Roy.
# SLD Resolution Engine - Integration Contract

## Project Information

| Field | Details |
|---|---|
| Project | SLD Resolution Tree Visualizer |
| University | National University of Costa Rica (UNA) |
| Course | EIF400 - Programming Paradigms |
| Group | 04-10am |
| Instructor | Carlos Loría-Sáenz |
| Academic term | Second Semester, 2026 |
| Part A | Emmanuel Núñez Jiménez - SLD Meta-Interpreter and Logical Resolution Engine |
| Part B | Roy Arias Mejía - SLD Tree Construction and JSON Export |
| Part C | Keynell Molina Mora - HTML/JavaScript Tree Visualization |
| Implementation language for Part A | SWI-Prolog |
| Verified environment | SWI-Prolog 10.0.2, Windows 64-bit |
| Original engine integration | Pull request #2, merge commit `d8a1117` |
| Current evidence branch | `feature/engine-demo-evidence` |
| Recorded verification date | November 19, 2026 |

### Contract Status

The public Part A interface described in this document has been implemented and individually tested.

The recorded verification results are:

| Verification | Result |
|---|---|
| Engine tests | 14/14 passed |
| Resolution trace tests | 17/17 passed |
| Variable aliasing tests | 3/3 passed |
| Structured event contract tests | 7/7 passed |
| **Total automated tests** | **41/41 passed** |
| **Demonstration cases** | **12/12 passed** |
| Automated test process exit code | 0 |
| Demonstration process exit code | 0 |

The original engine implementation was integrated into `main` through pull request #2.

Subsequent demonstration, variable-aliasing, structured-event contract tests, evidence, and documentation improvements were developed on `feature/engine-demo-evidence`.

These subsequent changes must be committed, reviewed, and merged separately.

The Part A interface is individually verified. However, integration with Roy's actual Part B implementation has not been established by the evidence presented here.

This document does not claim that the complete three-component project has already been integrated.

---

## 1. Purpose

This document defines the public interface through which the SLD logical resolution engine developed in Part A provides information to the SLD tree-building component developed in Part B.

Its objectives are to:

1. Identify the public predicates implemented by Part A.
2. Define supported inputs.
3. Define the resolution-depth convention.
4. Document the structure of resolution events.
5. Explain successful-answer representations.
6. Describe variable substitutions and aliases.
7. Define the meanings of successful, failed, and depth-limited branches.
8. Clarify what the Part B consumer can expect.
9. Establish integration verification requirements.
10. Preserve the approved distribution of individual responsibilities.

### 1.1. Part A - Logical Resolution

Part A is responsible for:

- Receiving supported Prolog queries.
- Processing goals.
- Selecting applicable clauses.
- Performing unification.
- Maintaining variable substitutions.
- Resolving definite Horn-clause rules.
- Handling recursive calls.
- Exploring alternative clauses.
- Performing backtracking.
- Finding multiple solutions.
- Recognizing unsuccessful branches.
- Applying configurable depth limits.
- Recording chronological resolution information.
- Producing structured events and answers.

### 1.2. Part B - Tree Construction

Part B is responsible for:

- Receiving real Part A resolution information.
- Constructing the SLD tree hierarchy.
- Organizing nodes and branches.
- Preserving parent-child relationships.
- Representing successful branches.
- Representing failed branches.
- Representing depth-limited branches.
- Associating goals, clauses, and bindings with tree nodes.
- Exporting the constructed tree as JSON.

### 1.3. Part C - Graphical Visualization

Part C is responsible for:

- Consuming the JSON produced by Part B.
- Implementing the HTML/JavaScript interface.
- Displaying the tree graphically.
- Showing node relationships.
- Distinguishing branch outcomes.
- Displaying goals, clauses, and variable substitutions.
- Allowing users to inspect tree-node information.

### 1.4. Responsibility Boundary

Part A does not construct the final SLD tree hierarchy.

Part A does not define or export the complete tree JSON representation.

Part A does not implement the graphical user interface.

The public interface described here contains logical-resolution information intended for Part B.

---

## 2. Public SWI-Prolog Module

The main implementation file is:

```text
src/prolog/engine/sld_engine.pl
```

The module is named:

```prolog
sld_engine
```

It exports three public predicates:

```prolog
sld_solve/1
sld_solve_limited/3
sld_trace/4
```

### 2.1. Public API Summary

| Predicate | Interface | Purpose |
|---|---|---|
| `sld_solve/1` | `sld_solve(+Query)` | Resolve a supported query and enumerate solutions through Prolog backtracking. |
| `sld_solve_limited/3` | `sld_solve_limited(+Query, +MaxDepth, -Outcome)` | Resolve a query using a configurable maximum depth and enumerate branch outcomes. |
| `sld_trace/4` | `sld_trace(+Query, +MaxDepth, -Steps, -Answers)` | Return chronological resolution events and successful-answer information. |

The first two predicates expose logical resolution directly.

The third predicate is the principal interface for the tree-building component.

---

## 3. `sld_solve/1` - Logical Resolution

### 3.1. Signature

```prolog
sld_solve(+Query).
```

### 3.2. Purpose

Resolve a supported Prolog query using the meta-interpreter.

The engine relies on logical unification and Prolog backtracking to explore applicable clauses.

### 3.3. Supported Behavior

The predicate can resolve:

- Facts.
- Definite Horn-clause rules.
- Individual goals.
- Conjunctions of goals.
- Recursive rules.
- Queries with variables.
- Queries with multiple answers.
- Queries that cannot be satisfied.

### 3.4. Example: Fact Resolution

Given:

```prolog
parent(ana, luis).
parent(ana, marta).
```

The following query can be executed:

```prolog
?- findall(
       X,
       sld_engine:sld_solve(parent(ana, X)),
       Answers
   ).
```

The verified result is:

```prolog
Answers = [luis, marta].
```

### 3.5. Example: Rule Resolution

For the supported recursive ancestor program:

```prolog
?- findall(
       X,
       sld_engine:sld_solve(ancestor(ana, X)),
       Answers
   ).
```

The verified result is:

```prolog
Answers = [luis, marta, sofia, diego].
```

### 3.6. Example: Conjunction

The following query resolves two goals that share a variable:

```prolog
?- findall(
       X-Y,
       sld_engine:sld_solve(
           (
               parent(ana, X),
               parent(X, Y)
           )
       ),
       Answers
   ).
```

The verified result is:

```prolog
Answers = [luis-sofia, marta-diego].
```

The substitution obtained from the first goal is preserved when resolving the second goal.

### 3.7. Important Limitation

The `sld_solve/1` predicate does not enforce a configurable maximum resolution depth.

A recursive program without a terminating base case may therefore continue indefinitely.

Use `sld_solve_limited/3` or `sld_trace/4` when depth control is required.

---

## 4. `sld_solve_limited/3` - Configurable Depth Control

### 4.1. Signature

```prolog
sld_solve_limited(+Query, +MaxDepth, -Outcome).
```

### 4.2. Arguments

| Argument | Direction | Description |
|---|---|---|
| `Query` | Input | Supported Prolog query. |
| `MaxDepth` | Input | Configurable non-negative integer resolution-depth limit. |
| `Outcome` | Output | Terminal result of an explored resolution branch. |

### 4.3. Supported Outcomes

The predicate may produce the following outcomes:

```prolog
success
failure
cutoff
```

| Outcome | Interpretation |
|---|---|
| `success` | All goals in the branch were resolved successfully. |
| `failure` | The explored branch cannot satisfy its selected goal. |
| `cutoff` | Exploration was stopped because the configured maximum depth was reached. |

Multiple terminal outcomes can be enumerated through Prolog backtracking.

These outcomes describe explored branches; they are not interchangeable descriptions of the complete query.

### 4.4. Failure Versus Cutoff

A logical failure occurs when the selected goal cannot be satisfied using the applicable program clauses in that branch.

A depth cutoff occurs when the configured maximum depth prevents further exploration of an unresolved branch.

A cutoff does not establish that the original query is logically false.

A branch might succeed if a greater depth limit were used.

### 4.5. Verified Depth Comparison

For the query:

```prolog
ancestor(ana, _).
```

The following outcomes were recorded.

At maximum depth 2:

```prolog
[success, success, cutoff, cutoff]
```

At maximum depth 4:

```prolog
[success, success, success, cutoff, success, cutoff]
```

The recorded output was:

```text
=== CONFIGURABLE DEPTH CONTROL ===

Maximum depth 2 : [success,success,cutoff,cutoff]
Maximum depth 4 : [success,success,success,cutoff,success,cutoff]

RESULT: PASSED
```

### 4.6. Maximum-Depth Convention

The initial query starts at:

```prolog
Depth = 0
```

Each successful application of a program clause increases the resolution depth by one.

The limit applies to an individual resolution branch.

When unresolved goals remain and the configured limit prevents another clause application, the branch is recorded as depth-limited.

A branch that has already resolved all goals is successful.

### 4.7. Important Restrictions

The depth limit does not establish:

- A maximum number of total resolution events.
- A global execution-time limit.
- A maximum memory allocation.
- A maximum returned-trace size.
- An unconditional termination guarantee for every possible program.

The current interface expects a non-negative integer maximum depth.

Invalid depth values are rejected by the implementation.

---

## 5. `sld_trace/4` - Principal Integration Interface

### 5.1. Signature

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

### 5.2. Purpose

Generate a structured description of a query's resolution process.

The predicate provides the information required by Part B to construct the SLD resolution tree.

### 5.3. Arguments

| Argument | Direction | Description |
|---|---|---|
| `Query` | Input | Supported Prolog query. |
| `MaxDepth` | Input | Non-negative integer resolution-depth limit. |
| `Steps` | Output | Chronological list of structured resolution events. |
| `Answers` | Output | List of successful answers and their variable-binding snapshots. |

### 5.4. Supported Query Forms

The educational subset includes:

- Individual callable goals.
- Conjunctions.
- Facts.
- Definite Horn-clause rules.
- The empty goal represented by `true`.

General Prolog-language constructs are not automatically supported as interpreted goals.

### 5.5. Output Characteristics

The returned `Steps` list contains structured `step/8` terms.

The returned `Answers` list contains structured `answer/2` terms.

The recorded goal, clause, and binding representations are snapshots of the resolution process.

They are intended for inspection, storage, and later tree construction.

The snapshots must not be treated as live references to internal Prolog variables.

### 5.6. Original Query Variables

Unlike ordinary use of `sld_solve/1`, the trace interface is designed to collect the substitutions associated with successful branches in the `Answers` output.

A consumer should read the returned answer records instead of expecting the original `Query` argument to enumerate all solutions by directly instantiating its variables.

### 5.7. Example Invocation

```prolog
?- sld_engine:sld_trace(
       parent(ana, X),
       1,
       Steps,
       Answers
   ).
```

The `Steps` output describes the resolution process.

The `Answers` output contains the successful substitutions.

### 5.8. Interface Stability

The public integration contract is based on:

```prolog
step/8
answer/2
binding/2
```

Changes to these structures, their field types, or their interpretation must be coordinated between Parts A and B.

The actual Part B consumer must be tested again after any incompatible change.

---

## 6. `step/8` - Resolution Event Structure

Each public resolution event has the following form:

```prolog
step(
    Sequence,
    Path,
    Depth,
    Action,
    Goal,
    Clause,
    RemainingGoals,
    Bindings
).
```

### 6.1. Field Definitions

| Field | Representation | Meaning |
|---|---|---|
| `Sequence` | Positive integer | Chronological event number. |
| `Path` | List of positive integers | Sequence of selected clause-alternative indices. |
| `Depth` | Non-negative integer | Resolution depth for the event. |
| `Action` | Atom | Type of resolution event. |
| `Goal` | String or atom `none` | Snapshot of the selected goal or relevant query. |
| `Clause` | String or atom `none` | Snapshot of the applied clause, when applicable. |
| `RemainingGoals` | List of strings | Snapshots of pending goals. |
| `Bindings` | List of `binding/2` terms | Snapshots of tracked original query-variable substitutions. |

### 6.2. Chronological Sequence

The event sequence starts at:

```prolog
1
```

The sequence increases as resolution events are recorded.

The sequence number indicates chronological order.

It is not a tree-node identifier.

### 6.3. Resolution Path

The root path is:

```prolog
[]
```

Examples of branch paths include:

```prolog
[1]
[2]
[1,1]
[1,2]
[2,1]
```

Each path records clause-alternative choices made along the current resolution branch.

A clause application extends the current path.

A backtracking event may return to a previously visited parent path.

### 6.4. Path Is Not a Node Identifier

The `Path` field is not a globally unique identifier for every recorded event.

Different events can share the same path.

For example, applying a clause and later reporting success may use the same path.

Therefore, Part B must not create one separate logical tree node for every event solely because the event has a sequence number.

Part B must interpret:

- Paths.
- Resolution actions.
- Depth.
- Applied clauses.
- Pending goals.
- Variable bindings.
- Successful answers.

These fields collectively describe the resolution process.

### 6.5. Depth

The `Depth` field records the number of clause applications along the current branch.

The initial depth is:

```prolog
0
```

An applied clause increases the depth by one.

Backtracking can restore an earlier depth.

### 6.6. Goal Snapshot

The `Goal` field identifies the selected goal or relevant query.

Examples:

```prolog
"parent(ana,A)"
"ancestor(ana,A)"
"parent(marta,diego)"
```

For events without a selected goal, the field may contain the atom:

```prolog
none
```

### 6.7. Clause Snapshot

For an `apply` event, `Clause` identifies the applied fact or rule.

Examples:

```prolog
"parent(ana,luis)"
"parent(ana,marta)"
```

For events without an applied clause, the value may be:

```prolog
none
```

### 6.8. Remaining Goals

`RemainingGoals` contains a list of textual goal snapshots.

Examples:

```prolog
[]
```

```prolog
["parent(luis,A)"]
```

```prolog
["ancestor(sofia,A)"]
```

An empty list indicates that no goals remain pending in that recorded state.

### 6.9. Binding Snapshots

The `Bindings` field contains substitutions associated with the variables tracked from the original query.

Example:

```prolog
[
    binding("V1", "luis")
]
```

For a query containing two tracked variables:

```prolog
[
    binding("V1", "luis"),
    binding("V2", "sofia")
]
```

### 6.10. Stable Textual Representation

The engine records readable textual snapshots of relevant terms.

These snapshots are stable descriptions of the recorded state.

They should not be treated as live Prolog terms that can be further unified by Part B.

The displayed variable names inside goal or clause strings may be normalized for readability.

A consumer must not infer variable identity merely because two independently generated textual snapshots display the same variable letter.

Tracked query-variable substitutions are represented explicitly in `Bindings`.

### 6.11. Atom Versus String

The atom:

```prolog
none
```

is different from the string:

```prolog
"none"
```

Part B must preserve that distinction.

Similarly, the action:

```prolog
success
```

is an atom, not a string.

---

## 7. Supported Resolution Actions

The current implementation records the following action atoms:

```prolog
start
apply
success
failure
cutoff
backtrack
```

### 7.1. Action Summary

| Action | Meaning | Tree-building interpretation |
|---|---|---|
| `start` | Resolution begins. | Initialize the logical root state. |
| `apply` | An applicable clause is selected. | Record the explored clause alternative. |
| `success` | All pending goals are resolved. | Identify a successful terminal branch. |
| `failure` | A selected goal cannot be satisfied. | Identify a failed terminal branch. |
| `cutoff` | Maximum resolution depth prevents further exploration. | Identify a depth-limited branch. |
| `backtrack` | Resolution returns to an earlier state to explore another alternative. | Associate further alternatives with the restored state. |

### 7.2. `start`

The initial event represents the beginning of resolution.

It records:

- The initial query.
- The root path.
- Depth zero.
- Initial variable bindings.

The root path is:

```prolog
[]
```

### 7.3. `apply`

An `apply` event indicates that a fact or rule has been selected and unified with the current goal.

Relevant data includes:

- Selected goal.
- Applied clause.
- New resolution path.
- New depth.
- Remaining goals.
- Current substitutions.

### 7.4. `success`

A `success` event indicates that the branch has no remaining goals to resolve.

A corresponding successful answer is also included in the returned `Answers` list.

Successful answers use:

```prolog
answer(Path, Bindings).
```

### 7.5. `failure`

A `failure` event identifies a branch that cannot satisfy its selected goal.

The implementation records terminal branch failures.

It does not necessarily create a separate failure event for every higher-level ancestor state that has no successful descendant.

Part B is responsible for interpreting the resulting branch relationships.

### 7.6. `cutoff`

A `cutoff` event indicates that unresolved goals remain when the configured depth limit prevents further exploration.

This event must not be treated as ordinary logical failure.

### 7.7. `backtrack`

A `backtrack` event indicates restoration of an earlier resolution state to explore another alternative.

It is not itself the application of a new fact or rule.

It does not represent an independent logical goal.

Part B should associate the event with the corresponding restored state.

### 7.8. Important Integration Rule

The `Action` field describes what happened during resolution.

Part B must not assume that every event corresponds to a distinct tree node.

A chronological execution trace and the final logical tree are related but different representations.

---

## 8. Variable Bindings

The engine tracks variables from the original query.

Their identifiers are generated using the order returned by:

```prolog
term_variables/2
```

The public labels include:

```text
V1
V2
V3
```

These identifiers are generated strings.

They are not necessarily the original variable names written in the query.

### 8.1. `binding/2` Structure

Variable substitutions are represented using:

```prolog
binding(VariableName, Value).
```

Examples:

```prolog
binding("V1", "luis")
binding("V2", "marta")
binding("V3", "_")
```

In the documented public representation, the variable identifier and the value snapshot are strings.

### 8.2. Concrete Values

A variable unified with a concrete value may be represented as:

```prolog
binding("V1", "luis")
```

This records a textual snapshot of the value.

### 8.3. Unbound Variables

A tracked variable that remains unbound may be represented as:

```prolog
binding("V1", "_")
```

The string `"_"` is the documented unbound-variable marker.

### 8.4. Variable Aliasing

Variable aliasing occurs when two variables become references to the same logical variable.

The two variables may remain without a concrete value while still sharing their identity.

For example:

```prolog
aliased_pair(X, X).
```

A query:

```prolog
aliased_pair(A, B).
```

can unify `A` and `B` so that both refer to the same still-unbound variable.

The verified representation is:

```prolog
[
    binding("V1", "_"),
    binding("V2", "alias(V1)")
]
```

The meaning is:

- `V1` remains unbound.
- `V2` refers to the same logical variable as `V1`.

### 8.5. Independent Variables

For a predicate such as:

```prolog
independent_pair(_, _).
```

the corresponding query variables can remain independent.

The verified representation is:

```prolog
[
    binding("V1", "_"),
    binding("V2", "_")
]
```

The two unbound variables are not recorded as aliases.

### 8.6. Binding Representation Summary

| Representation | Meaning |
|---|---|
| `binding("V1", "luis")` | V1 has the value `luis`. |
| `binding("V1", "marta")` | V1 has the value `marta`. |
| `binding("V1", "_")` | V1 remains unbound. |
| `binding("V2", "_")` | V2 remains unbound without an alias reference in the snapshot. |
| `binding("V2", "alias(V1)")` | V2 refers to the same tracked unbound variable as V1. |

### 8.7. Compatibility Requirement

The public structure remains:

```prolog
binding(VariableName, Value).
```

However, a binding value may now contain an alias reference such as:

```text
alias(V1)
```

Roy's Part B consumer must preserve and interpret this representation correctly.

The value must not be silently discarded.

An alias reference must not be presented as an ordinary concrete substitution.

### 8.8. Scope of Alias Representation

The alias notation is a textual trace representation.

It is not a new Prolog language construct.

The current implementation preserves tested alias relationships among tracked original query variables that remain unbound.

It does not claim to serialize all possible sharing relationships inside arbitrary nested Prolog terms.

---

## 9. Successful Answers - `answer/2`

### 9.1. Structure

Each successful resolution branch is represented using:

```prolog
answer(Path, Bindings).
```

### 9.2. Fields

| Field | Meaning |
|---|---|
| `Path` | Recorded clause-choice path associated with the successful branch. |
| `Bindings` | Snapshot of substitutions for the tracked query variables. |

### 9.3. Example

```prolog
answer(
    [1],
    [
        binding("V1", "luis")
    ]
).
```

The answer records:

- The successful resolution path `[1]`.
- The binding of `V1` to `luis`.

### 9.4. Multiple Answers

A query with two successful alternatives can produce:

```prolog
[
    answer(
        [1],
        [
            binding("V1", "luis")
        ]
    ),
    answer(
        [2],
        [
            binding("V1", "marta")
        ]
    )
]
```

The answer paths associate the results with their respective successful branches.

### 9.5. Failed Queries

An unsuccessful query can produce:

```prolog
Answers = []
```

The `Steps` output can still contain failure events describing why the explored branch did not succeed.

### 9.6. Depth-Limited Queries

A query may also produce:

```prolog
Answers = []
```

when its explored branches reach a depth cutoff without finding a successful answer.

In that situation, the trace may contain `cutoff` events rather than `failure` events.

A consumer must inspect the recorded events to distinguish these situations.

### 9.7. Integration Requirement

Part B must associate each `answer(Path, Bindings)` record with the corresponding successful resolution branch.

The answer list must not be treated as a list of independent tree roots.

---

## 10. Verified Trace Example

### 10.1. Example Program

Consider the facts:

```prolog
parent(ana, luis).
parent(ana, marta).
```

### 10.2. Query

```prolog
?- sld_engine:sld_trace(
       parent(ana, X),
       1,
       Steps,
       Answers
   ).
```

### 10.3. Recorded Resolution Events

The verified trace contains six events.

```prolog
step(
    1,
    [],
    0,
    start,
    "parent(ana,A)",
    none,
    ["parent(ana,A)"],
    [binding("V1","_")]
).
```

```prolog
step(
    2,
    [1],
    1,
    apply,
    "parent(ana,A)",
    "parent(ana,luis)",
    [],
    [binding("V1","luis")]
).
```

```prolog
step(
    3,
    [1],
    1,
    success,
    none,
    none,
    [],
    [binding("V1","luis")]
).
```

```prolog
step(
    4,
    [],
    0,
    backtrack,
    "parent(ana,A)",
    none,
    ["parent(ana,A)"],
    [binding("V1","_")]
).
```

```prolog
step(
    5,
    [2],
    1,
    apply,
    "parent(ana,A)",
    "parent(ana,marta)",
    [],
    [binding("V1","marta")]
).
```

```prolog
step(
    6,
    [2],
    1,
    success,
    none,
    none,
    [],
    [binding("V1","marta")]
).
```

### 10.4. Successful Answers

```prolog
answer(
    [1],
    [
        binding("V1","luis")
    ]
).
```

```prolog
answer(
    [2],
    [
        binding("V1","marta")
    ]
).
```

### 10.5. Interpretation

| Event | Path | Depth | Action | Meaning |
|---:|---|---:|---|---|
| 1 | `[]` | 0 | `start` | Begin resolution. |
| 2 | `[1]` | 1 | `apply` | Select the first matching fact. |
| 3 | `[1]` | 1 | `success` | First successful answer. |
| 4 | `[]` | 0 | `backtrack` | Restore the root state. |
| 5 | `[2]` | 1 | `apply` | Select the second matching fact. |
| 6 | `[2]` | 1 | `success` | Second successful answer. |

The trace demonstrates:

- Goal processing.
- Fact selection.
- Unification.
- Successful answers.
- Backtracking.
- Resolution paths.
- Variable-binding snapshots.

### 10.6. Recorded Evidence

```text
docs/evidence/engine/05_trace_interface.txt
docs/evidence/engine/05_step_contract_tests.txt
```

The evidence includes the complete compact `step/8` and `answer/2` representations. The separate contract-test evidence verifies initial events, applied facts and rules, remaining goals, variable bindings, logical failures, depth cutoffs, and backtracking.

---

## 11. Failure and Cutoff Examples

### 11.1. Logical Failure

The query:

```prolog
parent(diego, _).
```

was used to verify the representation of an unsuccessful branch.

The recorded event includes:

```prolog
step(
    2,
    [],
    0,
    failure,
    "parent(diego,A)",
    none,
    ["parent(diego,A)"],
    [binding("V1","_")]
).
```

This event reports a logical failure.

### 11.2. Depth Cutoff

The recursive query:

```prolog
endless.
```

was executed with a maximum depth of 3.

The recorded cutoff event includes:

```prolog
step(
    5,
    [1,1,1],
    3,
    cutoff,
    "endless",
    none,
    ["endless"],
    []
).
```

This event reports a depth cutoff.

### 11.3. Required Distinction

The following outcomes must remain distinguishable.

| Action | Meaning |
|---|---|
| `failure` | The explored branch cannot satisfy the selected goal. |
| `cutoff` | The selected depth limit prevents further exploration. |

A cutoff must not be displayed as proof that the logical query is false.

### 11.4. Recorded Evidence

```text
docs/evidence/engine/05_failure_cutoff_interface.txt
```

---

## 12. Supported Prolog Subset

The implementation supports an educational subset of Prolog.

### 12.1. Supported Features

- Facts.
- Definite Horn-clause rules.
- Individual logical goals.
- Conjunctions.
- The empty goal `true`.
- Leftmost pending-goal selection.
- Applicable-clause selection.
- Term unification.
- Shared variable substitutions.
- Tracked query-variable aliasing.
- Recursive rules.
- Multiple solutions.
- Backtracking.
- Failed resolution branches.
- Configurable depth limits.
- Depth-cutoff reporting.
- Chronological event recording.
- Structured successful answers.

### 12.2. Unsupported General Features

The following constructs are not generally supported as interpreted user-program features:

- Cut (`!`).
- General negation-as-failure.
- General arithmetic execution.
- Arbitrary built-in predicates.
- Side-effecting operations.
- General disjunction.
- Dynamic database modifications.
- Arbitrary module-qualified goals.
- Full Prolog-language compatibility.

The meta-interpreter may use SWI-Prolog built-in predicates internally.

This does not mean that arbitrary built-in predicates are supported as interpreted goals.

### 12.3. Program Clause Source

The implemented educational engine obtains the supported program clauses from the `user` module.

The meta-interpreter is not intended to reproduce the complete SWI-Prolog module system.

### 12.4. Educational Scope

These restrictions define the supported logical language subset.

They do not represent missing functionality assigned to Parts B or C.

---

## 13. Requirements for Roy's Part B Consumer

The Part B implementation must use the real information produced by:

```prolog
sld_engine:sld_trace(
    Query,
    MaxDepth,
    Steps,
    Answers
).
```

### 13.1. Input Handling

Part B must correctly handle:

1. The query being resolved.
2. The configured maximum depth.
3. The returned `Steps` list.
4. The returned `Answers` list.

### 13.2. Event Handling

Part B must correctly interpret:

1. `Sequence`.
2. `Path`.
3. `Depth`.
4. `Action`.
5. `Goal`.
6. `Clause`.
7. `RemainingGoals`.
8. `Bindings`.

### 13.3. Event Actions

The consumer must distinguish:

```prolog
start
apply
success
failure
cutoff
backtrack
```

The action meanings are part of the integration contract.

### 13.4. Path Handling

Part B must:

- Recognize the root path `[]`.
- Interpret clause-alternative choices.
- Preserve parent-child relationships.
- Handle restored paths after backtracking.
- Avoid treating each event sequence number as a tree-node identifier.

### 13.5. Binding Handling

Part B must:

- Preserve generated variable identifiers.
- Preserve concrete value snapshots.
- Recognize unbound-variable markers.
- Preserve alias references.
- Interpret values such as `alias(V1)`.
- Associate bindings with the corresponding resolution state.

### 13.6. Answer Handling

Part B must:

- Read `answer(Path, Bindings)` records.
- Associate answers with successful branches.
- Preserve successful-answer paths.
- Preserve the recorded substitutions.

### 13.7. Branch Outcomes

The tree builder must distinguish:

- Successful branches.
- Failed branches.
- Depth-limited branches.
- Alternative branches explored through backtracking.

### 13.8. JSON Responsibility

The final JSON representation of the SLD tree belongs to Part B.

Part A does not prescribe the complete JSON schema.

However, the information represented by the public trace interface must not be silently lost during tree construction.

### 13.9. No Fabricated Events

Part B must not invent logical resolution events and present them as if they had been produced by Part A.

Any additional tree metadata generated by Part B should remain distinguishable from the original resolution records.

---

## 14. Individual Part A Evidence

The engine has been verified through separate demonstrations corresponding to the six approved individual commitments.

### 14.1. Evidence Mapping

| Commitment | Evidence |
|---|---|
| 1. Meta-interpreter | `01_meta_interpreter.txt` |
| 2. Goal resolution and unification | `02_goal_unification.txt`, `02_variable_aliasing.txt`, `02_alias_tests.txt` |
| 3. Recursion and backtracking | `03_backtracking.txt`, `03_recursion.txt`, `03_failed_query.txt` |
| 4. Configurable depth control | `04_configurable_depth.txt`, `04_depth_cutoff.txt` |
| 5. Resolution information | `05_trace_interface.txt`, `05_failure_cutoff_interface.txt`, `05_step_contract_tests.txt` |
| 6. Individual tests | `automated_tests.txt`, `demo_12_cases_output.txt` |

All filenames in this table are relative to:

```text
docs/evidence/engine/
```

### 14.2. Meta-Interpreter Evidence

The recorded result includes:

```text
Facts - parent/2   : [luis,marta]
Rules - ancestor/2 : [luis,marta,sofia,diego]

RESULT: PASSED
```

### 14.3. Goal and Unification Evidence

The recorded conjunction demonstration reports:

```text
Successful answers   : 2
Backtracking events  : 1
RESULT: PASSED
```

The aliasing evidence distinguishes:

```prolog
binding("V2","alias(V1)")
```

from:

```prolog
binding("V2","_")
```

### 14.4. Backtracking Evidence

The recorded case 8 results are:

```text
Recorded steps       : 7
Successful answers   : 1
Failed branches      : 1
Backtracking events  : 1
RESULT: PASSED
```

### 14.5. Recursion Evidence

The recorded case 9 results are:

```text
Recorded steps       : 26
Successful answers   : 4
Depth cutoffs        : 2
Backtracking events  : 5
RESULT: PASSED
```

### 14.6. Failed Query Evidence

The recorded case 4 results are:

```text
Recorded steps       : 2
Successful answers   : 0
Failed branches      : 1
Depth cutoffs        : 0
RESULT: PASSED
```

### 14.7. Depth-Control Evidence

The recorded case 11 results are:

```text
Maximum depth        : 3
Successful answers   : 0
Failed branches      : 0
Depth cutoffs        : 1
RESULT: PASSED
```

### 14.8. Trace Interface Evidence

The interface evidence contains:

```prolog
step/8
answer/2
binding/2
```

It also includes explicit failure and cutoff events.

The dedicated `sld_step_contract` suite provides seven automated checks of the `step/8` interface, with independently recorded results in `05_step_contract_tests.txt`.

### 14.9. Automated Test Evidence

The recorded automated test execution completed with:

```text
41/41 tests passed
Exit code: 0
```

### 14.10. Demonstration Evidence

The recorded demonstration execution completed with:

```text
Total passed: 12 / 12
Exit code: 0
```

These results verify the demonstrated Part A behaviors.

They do not establish successful integration with Parts B and C.

---

## 15. Automated Test Suites

The implementation contains four PLUnit test suites.

| Suite | File | Tests | Recorded result |
|---|---|---:|---|
| Basic SLD engine | `tests/engine/sld_engine_tests.pl` | 14 | 14/14 passed |
| Resolution traces | `tests/engine/sld_trace_tests.pl` | 17 | 17/17 passed |
| Variable aliasing | `tests/engine/sld_alias_tests.pl` | 3 | 3/3 passed |
| Structured event contract | `tests/engine/sld_step_contract_tests.pl` | 7 | 7/7 passed |
| **Total** | **Four test suites** | **41** | **41/41 passed** |

### 15.1. Execute All Automated Tests

From the repository root, run:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt
```

### 15.2. Check the Exit Code

Immediately execute:

```cmd
echo %ERRORLEVEL%
```

The recorded successful execution returned:

```text
0
```

### 15.3. Save the Test Evidence

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt > docs\evidence\engine\automated_tests.txt 2>&1
```

### 15.4. Verify the Final Test

```cmd
findstr /L /C:"[41/41]" docs\evidence\engine\automated_tests.txt
```

### 15.5. Read the Saved Output

```cmd
type docs\evidence\engine\automated_tests.txt
```

The output file records the actual execution performed by SWI-Prolog.

The tests should be repeated after relevant engine or interface modifications.

### 15.6. Independently Verify the Structured Event Contract

Run the seven tests for the interface consumed by Part B:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_step_contract_tests.pl -g "run_tests([sld_step_contract])" -t halt > docs\evidence\engine\05_step_contract_tests.txt 2>&1
```

Check the exit code immediately, then inspect the saved evidence:

```cmd
echo %ERRORLEVEL%
type docs\evidence\engine\05_step_contract_tests.txt
```

---

## 16. Twelve Demonstration Cases

The demonstration cases are defined in:

```text
examples/queries/sld_demo_cases.pl
```

The demonstration runner is implemented in:

```text
examples/queries/sld_demo_runner.pl
```

### 16.1. Verified Scenarios

| No. | Scenario | Expected | Observed | Result |
|---:|---|---:|---:|---|
| 1 | Multiple solutions from facts | 2 | 2 | PASSED |
| 2 | Single fact solution - Luis | 1 | 1 | PASSED |
| 3 | Single fact solution - Marta | 1 | 1 | PASSED |
| 4 | Failed fact query | 0 | 0 | PASSED |
| 5 | Successful ground query | 1 | 1 | PASSED |
| 6 | Failed ground query | 0 | 0 | PASSED |
| 7 | Conjunction and shared variables | 2 | 2 | PASSED |
| 8 | Backtracking after a failed alternative | 1 | 1 | PASSED |
| 9 | Recursive ancestor resolution | 4 | 4 | PASSED |
| 10 | Recursive predicate with one solution | 1 | 1 | PASSED |
| 11 | Infinite recursion stopped by depth limit | 0 | 0 | PASSED |
| 12 | Left recursion with successful alternatives | 3 | 3 | PASSED |

### 16.2. `run_case(N)` - Detailed Demonstration

Use:

```prolog
sld_demo_runner:run_case(N).
```

This mode displays a detailed report for one selected case.

The report includes:

- Case information.
- Query.
- Configured depth.
- Expected and observed answer counts.
- Chronological resolution trace.
- Applied clauses.
- Pending goals.
- Variable bindings.
- Successful answers.
- Execution summary.
- Final PASS/FAIL result.

### 16.3. `run_all` - Compact Summary

Use:

```prolog
sld_demo_runner:run_all.
```

This mode executes all twelve cases and displays a summary table.

The summary contains:

- Case number.
- Scenario description.
- Expected answer count.
- Observed answer count.
- Result.

The current `run_all` mode does not display twelve complete detailed traces.

Use `run_case(N)` to inspect a particular case in detail.

### 16.4. Execute One Case

For example, run case 7:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(7)" -t halt
```

### 16.5. Execute All Cases

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt
```

### 16.6. Save the Summary Evidence

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt > docs\evidence\engine\demo_12_cases_output.txt 2>&1
```

### 16.7. Check the Exit Code

```cmd
echo %ERRORLEVEL%
```

### 16.8. Verify the Overall Result

```cmd
findstr /C:"Total passed:" docs\evidence\engine\demo_12_cases_output.txt
```

The recorded result is:

```text
Total passed: 12 / 12
```

### 16.9. Inspect the Saved Output

```cmd
type docs\evidence\engine\demo_12_cases_output.txt
```

### 16.10. Verification Scope

Each demonstration case verifies its expected number of successful answers and their variable bindings. The runner also checks chronological step numbering, successful-event counts, and scenario-specific trace events, including logical failure, recursion, backtracking, and depth cutoff.

The four automated test suites and individual trace-evidence files provide additional verification of engine behavior and the full structured-event contract.

These tests cover the documented educational subset and demonstration scenarios. They do not prove correctness for arbitrary Prolog programs or establish integration with Parts B and C.

---

## 17. Integration Verification Checklist

The following checks must be performed with Roy's actual Part B implementation before claiming successful integration.

### 17.1. Public Interface

- [ ] Part B invokes or receives actual `sld_trace/4` output.
- [ ] Supported input queries are handled correctly.
- [ ] The configured maximum depth is preserved.
- [ ] The returned `Steps` list is consumed correctly.
- [ ] The returned `Answers` list is consumed correctly.

### 17.2. Resolution Events

- [ ] All eight `step/8` fields are processed.
- [ ] Chronological sequence numbers are preserved.
- [ ] The root path `[]` is interpreted correctly.
- [ ] Clause-choice paths are interpreted correctly.
- [ ] Resolution depth is interpreted correctly.
- [ ] `start` is handled correctly.
- [ ] `apply` is handled correctly.
- [ ] `success` is handled correctly.
- [ ] `failure` is handled correctly.
- [ ] `cutoff` is handled correctly.
- [ ] `backtrack` is handled correctly.

### 17.3. Variables and Answers

- [ ] Generated variable identifiers are preserved.
- [ ] Concrete substitutions are preserved.
- [ ] Unbound-variable markers are recognized.
- [ ] Alias references are recognized.
- [ ] Values such as `alias(V1)` are preserved.
- [ ] Binding snapshots are associated with the proper states.
- [ ] Successful answers are associated with their recorded paths.

### 17.4. Tree Construction

- [ ] Parent-child relationships are constructed correctly.
- [ ] Alternative clauses are represented correctly.
- [ ] Successful terminal branches are identified.
- [ ] Failed terminal branches are identified.
- [ ] Depth-limited branches are identified.
- [ ] Backtracking does not create incorrect logical nodes.
- [ ] The actual SLD tree is constructed.
- [ ] The resulting tree can be exported as JSON.

### 17.5. Integration Evidence

- [ ] Run a successful query through Parts A and B.
- [ ] Run an unsuccessful query through Parts A and B.
- [ ] Run a recursive query through Parts A and B.
- [ ] Verify a depth cutoff through Parts A and B.
- [ ] Verify multiple solutions.
- [ ] Verify variable substitutions.
- [ ] Verify variable aliasing.
- [ ] Verify the generated tree hierarchy.
- [ ] Verify the resulting JSON.
- [ ] Record reproducible integration-test evidence.

These items remain pending until they are checked using the real Part B implementation.

---

## 18. Approved Individual Responsibilities

### 18.1. Part A - Emmanuel Núñez Jiménez

Emmanuel's approved contribution includes six responsibilities:

1. Implement the SLD meta-interpreter.
2. Resolve goals and perform unification.
3. Handle recursion and backtracking.
4. Implement configurable depth control.
5. Generate resolution information for the tree-building component.
6. Develop individual engine tests.

His deliverables include:

- The SWI-Prolog meta-interpreter module.
- Resolution predicates.
- Test cases and execution evidence.
- Technical explanation of design, operation, and limitations.
- Individual demonstration of the engine and its public resolution information.

### 18.2. Part B - Roy Arias Mejía

Roy constructs the SLD tree from Part A's resolution information.

Roy also implements the corresponding JSON export.

### 18.3. Part C - Keynell Molina Mora

Keynell develops the graphical interface and uses the JSON produced by Part B to visualize the tree.

### 18.4. Individual Defense

Emmanuel must be able to explain and demonstrate his implementation independently.

He should be able to identify:

- The purpose of a meta-interpreter.
- The supported logical language subset.
- Goal selection.
- Clause selection.
- Unification.
- Variable substitutions.
- Recursion.
- Backtracking.
- Multiple solutions.
- Logical failure.
- Depth cutoff.
- Resolution event structures.
- Successful-answer structures.
- Integration data provided to Part B.
- The limitations of his module.

He must distinguish implemented Part A behavior from integration work that has not yet been verified.

---

## 19. Development and Verification Status

| Area | Status |
|---|---|
| SLD meta-interpreter | Implemented and individually tested |
| Fact resolution | Verified |
| Rule resolution | Verified |
| Conjunctions | Verified |
| Goal selection | Verified by Part A tests and traces |
| Unification | Verified |
| Shared variable substitutions | Verified |
| Variable aliasing | Verified |
| Independent unbound variables | Verified |
| Recursive resolution | Verified |
| Backtracking | Verified |
| Multiple solutions | Verified |
| Unsuccessful queries | Verified |
| Configurable depth control | Verified |
| Logical failure events | Verified |
| Depth-cutoff events | Verified |
| Chronological event generation | Verified |
| `sld_solve/1` | Implemented |
| `sld_solve_limited/3` | Implemented |
| `sld_trace/4` | Implemented |
| `step/8` | Implemented |
| `answer/2` | Implemented |
| `binding/2` | Implemented |
| Structured event contract tests | **7/7 passed** |
| Automated tests | **41/41 passed** |
| Demonstration cases | **12/12 passed** |
| Automated test exit code | **0** |
| Demonstration exit code | **0** |
| Detailed console demonstration | Verified |
| Compact twelve-case summary | Verified |
| Original engine implementation in `main` | Merged through pull request #2 |
| Additional evidence-branch changes | Locally verified; separate integration into `main` not established here |
| Actual Part A-B integration | Pending verification |
| Part B tree construction | Roy's responsibility |
| Part B JSON export | Roy's responsibility |
| Part C graphical visualization | Keynell's responsibility |

---

## 20. Final Integration Contract

The SLD resolution engine developed by Emmanuel Núñez Jiménez provides three public predicates:

```prolog
sld_solve/1
sld_solve_limited/3
sld_trace/4
```

The principal integration interface is:

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

Each recorded resolution event uses:

```prolog
step(
    Sequence,
    Path,
    Depth,
    Action,
    Goal,
    Clause,
    RemainingGoals,
    Bindings
).
```

Each successful answer uses:

```prolog
answer(Path, Bindings).
```

Variable substitutions use:

```prolog
binding(VariableName, Value).
```

The supported event actions are:

```prolog
start
apply
success
failure
cutoff
backtrack
```

The binding representation supports:

- Concrete value snapshots.
- Unbound-variable markers.
- Alias references between tracked unbound query variables.

The recorded individual verification results are:

```text
Automated tests: 41/41 passed
Demonstration cases: 12/12 passed
Execution exit codes: 0
```

These results support the tested functionality of the Part A logical resolution engine.

They do not establish that the complete SLD Resolution Tree Visualizer has already been integrated.

Before claiming complete integration, Emmanuel and Roy must verify the actual interaction between the Part A trace producer and the Part B tree-building component.

Keynell's graphical visualization remains a separate Part C responsibility.

The integration process must preserve the individual contribution boundaries approved by instructor Carlos Loría-Sáenz.

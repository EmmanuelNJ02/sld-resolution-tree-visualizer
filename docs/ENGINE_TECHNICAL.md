# Individual Technical Documentation - SLD Resolution Engine

## 1. Academic and Development Information

| Field | Details |
|---|---|
| Project | SLD Resolution Tree Visualizer |
| University | National University of Costa Rica (UNA) |
| School | School of Informatics |
| Course | EIF400 - Programming Paradigms |
| Group | 04-10am |
| Instructor | Carlos Loría-Sáenz |
| Student | Emmanuel Núñez Jiménez |
| Individual contribution | Part A - SLD Meta-Interpreter and Logical Resolution Engine |
| Implementation language | SWI-Prolog |
| Verified environment | SWI-Prolog 10.0.2, Windows 64-bit |
| Original engine integration | Pull request #2, merge commit `d8a1117` |
| Current development branch | `feature/engine-demo-evidence` |
| Recorded individual verification | November 19, 2026 |

### 1.1. Verification Summary

The Part A SLD meta-interpreter, depth-limited resolution mechanism, and structured resolution tracing have been implemented and individually tested.

The recorded results are:

| Verification | Result |
|---|---|
| Basic SLD engine tests | 14/14 passed |
| Resolution trace tests | 17/17 passed |
| Variable aliasing tests | 3/3 passed |
| Structured event contract tests | 7/7 passed |
| **Total automated tests** | **41/41 passed** |
| **Demonstration cases** | **12/12 passed** |
| Automated test exit code | 0 |
| Demonstration exit code | 0 |

The variable-aliasing and structured-event contract tests passed together with the original engine and trace test suites.

The current development branch also contains demonstration files, individual execution evidence, and documentation improvements.

These additional changes have not been assumed to be merged into `main`.

The actual integration between Part A and Roy's tree-building component still requires verification using the real Part B implementation.

---

## 2. Purpose of the Individual Contribution

The purpose of Part A is to implement an educational SLD meta-interpreter in SWI-Prolog.

The engine processes logical queries over a defined subset of Prolog consisting primarily of facts and definite Horn-clause rules.

The implementation uses SWI-Prolog's own mechanisms for:

- Clause inspection.
- Term unification.
- Logical variable substitutions.
- Recursive execution.
- Backtracking.

It also explicitly records relevant information about the resolution process.

This makes it possible for another component to construct a representation of the corresponding SLD resolution tree.

### 2.1. Approved Functional Responsibilities

Emmanuel's approved individual contribution contains six responsibilities:

1. Implement an SLD meta-interpreter in SWI-Prolog.
2. Resolve goals and perform unification.
3. Handle recursion and backtracking.
4. Implement configurable depth control.
5. Generate resolution information for the tree-building component.
6. Develop individual automated tests.

These responsibilities define the technical scope of Part A.

### 2.2. Required Deliverables

The approved individual deliverables are:

1. A SWI-Prolog meta-interpreter module.
2. Predicates required for logical resolution.
3. Test cases and execution evidence.
4. A technical explanation of the module's design, operation, and limitations.
5. An individual demonstration of the engine and the information provided to the tree-building component.

This document supports the fourth deliverable and provides technical background for the fifth.

### 2.3. Responsibility Boundaries

#### Part A - Emmanuel Núñez Jiménez

Responsible for:

- Logical SLD resolution.
- The meta-interpreter.
- Goal selection.
- Clause selection.
- Unification.
- Variable substitutions.
- Recursion.
- Backtracking.
- Multiple solutions.
- Failed queries.
- Configurable depth limits.
- Structured resolution events.
- Automated tests.
- Execution evidence.
- Technical documentation.
- Individual demonstration.

#### Part B - Roy Arias Mejía

Responsible for:

- Consuming the resolution information produced by Part A.
- Constructing the SLD tree hierarchy.
- Creating nodes and branches.
- Preserving parent-child relationships.
- Representing branch outcomes.
- Associating clauses and substitutions with nodes.
- Exporting the completed SLD tree as JSON.
- Testing the tree-building component.

#### Part C - Keynell Molina Mora

Responsible for:

- Reading the JSON produced by Part B.
- Implementing the HTML/JavaScript interface.
- Displaying the SLD tree graphically.
- Showing nodes and their relationships.
- Distinguishing branch outcomes.
- Displaying goals, clauses, and substitutions.
- Providing information about individual nodes.
- Testing the graphical visualization.

The console demonstration created for Part A does not replace the tree builder or the web visualizer.

---

## 3. SLD Resolution Fundamentals

### 3.1. Definition

SLD stands for:

**Selective Linear Definite Clause Resolution.**

SLD resolution is a proof procedure used to resolve logical goals using definite Horn clauses.

A definite Horn clause can be a fact or a rule.

The meta-interpreter follows a goal-directed resolution process.

### 3.2. General Resolution Process

The main operations are:

1. Receive a query.
2. Identify its pending goals.
3. Select the leftmost pending goal.
4. Find an applicable program clause.
5. Unify the selected goal with the clause head.
6. Replace the selected goal with the clause body.
7. Continue resolving the resulting goals.
8. Explore alternative clauses through backtracking.
9. Record success, failure, or a depth cutoff when appropriate.

A resolution branch succeeds when no goals remain.

A branch fails when its selected goal cannot be satisfied.

When depth control is enabled, an unresolved branch may be stopped at the configured maximum depth.

### 3.3. Facts

A fact represents a relation that holds.

Example:

```prolog
parent(ana, luis).
```

This fact states that Ana is a parent of Luis.

A compatible query can succeed by unifying with this fact.

### 3.4. Rules

A definite Horn-clause rule derives a conclusion from other logical goals.

Example:

```prolog
ancestor(X, Y) :-
    parent(X, Y).
```

This rule states that X is an ancestor of Y if X is a parent of Y.

Its components are:

| Component | Example |
|---|---|
| Head | `ancestor(X, Y)` |
| Body | `parent(X, Y)` |

### 3.5. Recursive Rules

A recursive rule refers to the same predicate in its body.

Example:

```prolog
ancestor(X, Y) :-
    parent(X, Z),
    ancestor(Z, Y).
```

The recursive call allows the engine to explore ancestor relationships involving more than one generation.

### 3.6. Queries

A query requests the resolution of one or more logical goals.

Example:

```prolog
parent(ana, X)
```

Given:

```prolog
parent(ana, luis).
parent(ana, marta).
```

the query has two solutions:

```prolog
X = luis
X = marta
```

### 3.7. Conjunctions

A conjunction requires several goals to succeed.

Example:

```prolog
(parent(ana, X), parent(X, Y))
```

The first goal finds a child of Ana.

The second goal uses that child to find another person.

Both goals must succeed for the conjunction to produce a solution.

### 3.8. Leftmost Goal Selection

The engine selects the leftmost pending goal.

For:

```prolog
(parent(ana, X), parent(X, Y))
```

the first goal selected is:

```prolog
parent(ana, X)
```

If it unifies with:

```prolog
parent(ana, luis)
```

the substitution is:

```prolog
X = luis
```

The remaining goal becomes:

```prolog
parent(luis, Y)
```

This demonstrates how substitutions are propagated between goals.

---

## 4. Unification

### 4.1. Definition

Unification is the process of making two compatible Prolog terms identical through variable substitutions.

The SLD resolution engine relies on SWI-Prolog's native unification mechanism.

It does not implement a separate general-purpose unification algorithm.

### 4.2. Example

Consider the selected goal:

```prolog
parent(ana, X)
```

and the fact:

```prolog
parent(ana, luis)
```

They unify with:

```prolog
X = luis
```

The selected goal can then be resolved using that fact.

### 4.3. Shared Variables

Variables can appear in multiple goals.

Example:

```prolog
(parent(ana, X), parent(X, Y))
```

The value assigned to `X` while resolving the first goal is shared with the second goal.

The recorded solutions are:

```prolog
[
    luis-sofia,
    marta-diego
]
```

The first solution corresponds to:

```prolog
X = luis,
Y = sofia.
```

The second solution corresponds to:

```prolog
X = marta,
Y = diego.
```

### 4.4. Logical Variable Identity

Unification does not always assign a concrete value.

Two variables can become references to the same logical variable while remaining unbound.

This situation is called variable aliasing.

The tracing mechanism distinguishes variable aliasing from independent unbound variables.

### 4.5. Native SWI-Prolog Unification

The meta-interpreter uses Prolog's own logical operations when matching a selected goal with a clause head.

This is consistent with the approved educational objective: implementing a meta-interpreter using Prolog's logical resolution mechanisms.

---

## 5. Main Implementation Files

### 5.1. SLD Resolution Engine

```text
src/prolog/engine/sld_engine.pl
```

This file contains the meta-interpreter and its public resolution predicates.

### 5.2. Automated Tests

| File | Purpose |
|---|---|
| `tests/engine/sld_engine_tests.pl` | Tests of basic logical resolution. |
| `tests/engine/sld_trace_tests.pl` | Tests of resolution events and trace behavior. |
| `tests/engine/sld_alias_tests.pl` | Tests of unification and variable-alias representation. |
| `tests/engine/sld_step_contract_tests.pl` | Verifies the eight-field `step/8` contract, including facts, rules, pending goals, substitutions, failure, cutoff, and backtracking. |

### 5.3. Example Programs

| File | Purpose |
|---|---|
| `examples/programs/family.pl` | Family facts and recursive rules. |
| `examples/programs/recursive_loop.pl` | Recursive examples for depth-limit and alternative-exploration tests. |
| `examples/programs/alias_demo.pl` | Examples of aliased and independent variables. |

### 5.4. Demonstration Files

| File | Purpose |
|---|---|
| `examples/queries/sld_demo_cases.pl` | Defines the twelve demonstration cases. |
| `examples/queries/sld_demo_runner.pl` | Executes the cases and displays organized console reports. |

### 5.5. Documentation

| File | Purpose |
|---|---|
| `docs/ENGINE_TECHNICAL.md` | Technical design and implementation explanation. |
| `docs/ENGINE_INTERFACE.md` | Public predicates and integration contract. |
| `docs/ENGINE_DEMO.md` | Individual demonstration procedure. |
| `docs/evidence/engine/README.md` | Execution-evidence inventory and explanation. |

### 5.6. Program Clause Source

The supported example programs are loaded into the SWI-Prolog `user` module.

The meta-interpreter obtains applicable program clauses through SWI-Prolog's clause-inspection mechanisms.

The implementation is not intended to interpret the complete Prolog module system.

---

## 6. Public Engine Interface

The main module exports:

```prolog
:- module(sld_engine, [
    sld_solve/1,
    sld_solve_limited/3,
    sld_trace/4
]).
```

### 6.1. API Summary

| Predicate | Purpose |
|---|---|
| `sld_solve/1` | Resolve supported queries without a configurable depth limit. |
| `sld_solve_limited/3` | Explore resolution branches with a configurable maximum depth. |
| `sld_trace/4` | Generate chronological resolution events and successful answers. |

These predicates provide the main functionality of Part A.

---

## 7. Basic Resolution - `sld_solve/1`

### 7.1. Signature

```prolog
sld_solve(+Query).
```

### 7.2. Purpose

Resolve a supported query using logical resolution.

Prolog backtracking is used to enumerate additional solutions.

### 7.3. Example: Facts

```prolog
?- findall(
       X,
       sld_engine:sld_solve(parent(ana, X)),
       Answers
   ).
```

Verified result:

```prolog
Answers = [luis, marta].
```

### 7.4. Example: Rules

```prolog
?- findall(
       X,
       sld_engine:sld_solve(ancestor(ana, X)),
       Answers
   ).
```

Verified result:

```prolog
Answers = [luis, marta, sofia, diego].
```

### 7.5. Example: Conjunctions

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

Verified result:

```prolog
Answers = [luis-sofia, marta-diego].
```

### 7.6. Important Limitation

The `sld_solve/1` predicate does not impose a configurable maximum depth.

A recursive query without a terminating base case may continue indefinitely.

Depth-controlled demonstrations should use the limited-resolution or tracing interface.

---

## 8. Configurable Depth Control - `sld_solve_limited/3`

### 8.1. Signature

```prolog
sld_solve_limited(+Query, +MaxDepth, -Outcome).
```

### 8.2. Purpose

Explore supported resolution branches using a configurable maximum depth.

### 8.3. Arguments

| Argument | Description |
|---|---|
| `Query` | Supported logical query. |
| `MaxDepth` | Non-negative integer resolution-depth limit. |
| `Outcome` | Terminal outcome of an explored branch. |

### 8.4. Terminal Outcomes

The documented terminal outcomes are:

```prolog
success
failure
cutoff
```

| Outcome | Meaning |
|---|---|
| `success` | All pending goals in the branch have been resolved. |
| `failure` | The selected goal cannot be satisfied in the explored branch. |
| `cutoff` | The configured depth limit prevents further exploration. |

The predicate can enumerate multiple branch outcomes through Prolog backtracking.

### 8.5. Depth Convention

The initial query begins at:

```prolog
Depth = 0
```

Each application of a program clause increases the resolution depth by one.

A branch can succeed when no pending goals remain.

If unresolved goals remain and the maximum depth prevents another clause application, a cutoff is recorded.

### 8.6. Verified Configurable Depth Example

Query:

```prolog
ancestor(ana, _).
```

Maximum depth 2:

```prolog
[success, success, cutoff, cutoff]
```

Maximum depth 4:

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

### 8.7. Failure Versus Cutoff

A logical failure and a depth cutoff have different meanings.

A failure means that the selected goal cannot be satisfied in the explored branch.

A cutoff means that further exploration was prevented by the configured depth limit.

A cutoff does not establish that the original query is false.

### 8.8. Depth-Control Limitations

The maximum depth restricts individual resolution branches.

It is not:

- A global execution-time limit.
- A maximum memory limit.
- A maximum number of generated events.
- A complete termination guarantee for every possible program.

The implementation expects a valid non-negative integer maximum depth.

---

## 9. Internal Meta-Interpreter Design

### 9.1. Pending Goals

The meta-interpreter processes queries as sequences of pending goals.

A conjunction such as:

```prolog
(parent(ana, X), parent(X, Y))
```

is conceptually represented as:

```prolog
[
    parent(ana, X),
    parent(X, Y)
]
```

The special empty goal:

```prolog
true
```

corresponds to an empty pending-goal sequence.

### 9.2. Leftmost Selection

For a nonempty goal list:

```prolog
[Goal | RemainingGoals]
```

the engine selects `Goal` first.

The remaining goals are retained for later resolution.

### 9.3. Clause Selection

The engine finds program clauses whose heads are applicable to the selected goal.

A clause can be a fact:

```prolog
parent(ana, luis).
```

or a rule:

```prolog
ancestor(X, Y) :-
    parent(X, Y).
```

### 9.4. Clause Application

For a selected rule:

```prolog
Head :- Body.
```

the engine:

1. Unifies the selected goal with `Head`.
2. Converts `Body` into pending goals.
3. Places those goals before the remaining query goals.
4. Continues resolution.

### 9.5. Conceptual Resolution Algorithm

The following pseudocode describes the general resolution strategy.

```text
RESOLVE(PendingGoals):

    IF PendingGoals is empty:
        Report success.

    OTHERWISE:
        Select the leftmost goal.

        FOR each applicable program clause:
            Unify the selected goal with the clause head.

            Replace the selected goal
            with the clause body.

            Continue resolving the new goal list.

        Use backtracking to explore alternatives.
```

The actual implementation uses SWI-Prolog predicates and logical control flow.

This pseudocode is an explanation of the algorithm, not a replacement for the source code.

### 9.6. Resolution State

A resolution state conceptually includes:

- Pending goals.
- Current substitutions.
- Resolution depth.
- Clause-choice path.
- Available alternatives.

The trace generator additionally records stable snapshots of relevant state information.

### 9.7. Independent Alternatives

Different clause alternatives must be explored without allowing substitutions from one branch to corrupt another branch's recorded information.

The trace implementation uses Prolog's logical mechanisms together with term copying and collected alternatives where needed.

Earlier recorded event snapshots remain stable when later alternatives are explored.

---

## 10. Recursive Resolution

### 10.1. Recursive Ancestor Rules

Consider:

```prolog
ancestor(X, Y) :-
    parent(X, Y).

ancestor(X, Y) :-
    parent(X, Z),
    ancestor(Z, Y).
```

The first rule handles direct parent relationships.

The second rule handles ancestor relationships that require additional generations.

### 10.2. Example Query

```prolog
ancestor(ana, X).
```

The query can obtain:

```text
luis
marta
sofia
diego
```

### 10.3. Recursive Execution

When the recursive rule is selected, the engine introduces another `ancestor/2` goal.

That goal is resolved using the same meta-interpretation process.

The resolution continues until the branch:

1. Succeeds.
2. Fails.
3. Reaches a configured depth cutoff.

### 10.4. Verified Recursion Demonstration

Demonstration case 9 produced:

| Metric | Recorded result |
|---|---:|
| Resolution events | 26 |
| Successful answers | 4 |
| Depth cutoffs | 2 |
| Backtracking events | 5 |
| Final result | PASSED |

### 10.5. Interpretation of Cutoffs

The presence of depth cutoffs does not invalidate successful solutions obtained in other branches.

It indicates that additional recursive exploration was prevented in the depth-limited branches.

---

## 11. Backtracking

### 11.1. Definition

Backtracking allows Prolog to explore alternative clauses when searching for solutions.

If one resolution branch fails, another applicable alternative may still succeed.

Backtracking is also used to obtain additional successful solutions.

### 11.2. Multiple Solutions

Given:

```prolog
parent(ana, luis).
parent(ana, marta).
```

the query:

```prolog
parent(ana, X).
```

can produce:

```prolog
X = luis ;
X = marta.
```

The first successful answer does not prevent Prolog from exploring another applicable fact.

### 11.3. Backtracking After Failure

Consider:

```prolog
(parent(ana, X), parent(X, diego)).
```

The first alternative can bind:

```prolog
X = luis.
```

The remaining goal becomes:

```prolog
parent(luis, diego).
```

This fails.

The engine then explores another alternative:

```prolog
X = marta.
```

The remaining goal becomes:

```prolog
parent(marta, diego).
```

This succeeds.

### 11.4. Verified Backtracking Results

Demonstration case 8 produced:

| Metric | Recorded result |
|---|---:|
| Resolution events | 7 |
| Successful answers | 1 |
| Failed branches | 1 |
| Backtracking events | 1 |
| Final result | PASSED |

### 11.5. Backtracking in the Trace

The tracing mechanism records backtracking using the action:

```prolog
backtrack
```

A backtracking event identifies a return to an earlier resolution state.

It is not a newly applied clause.

---

## 12. Structured Resolution Tracing

### 12.1. Public Interface

The principal tracing predicate is:

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

It collects chronological resolution information and successful answers.

### 12.2. Purpose

The trace provides information required by the component responsible for constructing the SLD tree.

It records:

- Selected goals.
- Applied clauses.
- Remaining goals.
- Resolution depth.
- Clause-choice paths.
- Variable substitutions.
- Successful branches.
- Failed branches.
- Depth cutoffs.
- Backtracking.

### 12.3. Output Arguments

| Argument | Meaning |
|---|---|
| `Steps` | Chronological list of resolution events. |
| `Answers` | Successful answers and their recorded bindings. |

The trace is an aggregated description of the explored resolution process.

### 12.4. Stable Snapshots

The engine generates stable representations of relevant resolution states.

This is important because Prolog variables can receive different substitutions in different branches.

Without stable snapshots, later unification or backtracking could make previously recorded information misleading.

The trace therefore records textual representations of relevant terms and substitutions.

### 12.5. Original Query Variables

Variables from the original query are tracked for answer reporting.

The implementation generates labels such as:

```text
V1
V2
V3
```

The labels identify tracked variables in the trace.

They do not necessarily preserve the original source-level variable names.

### 12.6. Internal Mechanisms

The implementation relies on SWI-Prolog mechanisms for tasks such as:

- Inspecting program clauses.
- Unifying terms.
- Enumerating alternatives.
- Copying terms.
- Inspecting variables.
- Formatting stable term snapshots.
- Combining pending goals.

These are internal implementation mechanisms.

Their use does not imply that arbitrary built-in predicates are supported as interpreted user goals.

---

## 13. `step/8` Event Structure

Each resolution event has the form:

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

### 13.1. Event Fields

| Field | Representation | Meaning |
|---|---|---|
| `Sequence` | Positive integer | Chronological event number. |
| `Path` | List of positive integers | Clause-alternative choices along the branch. |
| `Depth` | Non-negative integer | Resolution depth of the event. |
| `Action` | Atom | Type of resolution event. |
| `Goal` | String or atom `none` | Selected goal or relevant query snapshot. |
| `Clause` | String or atom `none` | Applied clause snapshot, when applicable. |
| `RemainingGoals` | List of strings | Pending-goal snapshots. |
| `Bindings` | List of `binding/2` terms | Tracked original query-variable substitutions. |

### 13.2. Chronological Sequence

The event sequence starts at:

```prolog
1
```

The sequence numbers record event order.

They are not tree-node identifiers.

### 13.3. Resolution Paths

The root path is:

```prolog
[]
```

Example paths include:

```prolog
[1]
[2]
[1,1]
[1,2]
[2,1]
```

The path represents selected clause alternatives along the resolution branch.

### 13.4. Path Interpretation

A resolution path is not necessarily a unique identifier for every recorded event.

Several events can share the same path.

For example, a clause application and its resulting success can share a path.

Part B must use the event information to construct the logical tree.

### 13.5. Depth

The initial depth is:

```prolog
0
```

Each applied clause increases the depth by one.

Backtracking may restore an earlier depth.

### 13.6. Goal and Clause Snapshots

Examples:

```prolog
"parent(ana,A)"
"parent(ana,luis)"
"ancestor(ana,A)"
```

These values are textual snapshots.

They are not live references to internal Prolog variables.

### 13.7. The `none` Atom

For events without a selected goal or applied clause, the corresponding field may contain:

```prolog
none
```

The atom `none` is different from the string `"none"`.

The consumer must preserve this distinction.

### 13.8. Pending Goals

The `RemainingGoals` field contains a list of textual goal snapshots.

Examples:

```prolog
[]
```

```prolog
["parent(luis,A)"]
```

An empty list indicates that no goals remain pending in that recorded state.

---

## 14. Supported Resolution Actions

The engine records the following actions:

```prolog
start
apply
success
failure
cutoff
backtrack
```

### 14.1. Action Summary

| Action | Meaning |
|---|---|
| `start` | Initial resolution state. |
| `apply` | Application of an applicable program clause. |
| `success` | Successful completion of a resolution branch. |
| `failure` | An explored branch cannot satisfy the selected goal. |
| `cutoff` | The maximum resolution depth prevents further exploration. |
| `backtrack` | Return to an earlier resolution state to explore another alternative. |

### 14.2. `start`

The initial event records:

- The original query.
- Root path.
- Depth zero.
- Initial variable bindings.

### 14.3. `apply`

An `apply` event records an explored clause alternative.

It can contain:

- Selected goal.
- Applied clause.
- Updated path.
- Updated depth.
- Remaining goals.
- Variable bindings.

### 14.4. `success`

A `success` event indicates that all pending goals have been resolved.

The corresponding answer is included in the `Answers` output.

### 14.5. `failure`

A `failure` event identifies a terminal unsuccessful branch.

The engine does not necessarily create a separate failure event for every ancestor state whose descendants fail.

The tree builder must determine higher-level branch relationships from the recorded events.

### 14.6. `cutoff`

A `cutoff` event identifies a branch stopped by the configured maximum depth.

It must not be interpreted as proof of logical falsity.

### 14.7. `backtrack`

A `backtrack` event indicates restoration of an earlier resolution state.

It does not represent a new fact or rule application.

### 14.8. Trace Versus Tree

The chronological resolution trace is not identical to the final graphical SLD tree.

The trace records events that occur during resolution.

Part B uses these events to construct nodes, branches, and their relationships.

---

## 15. Variable Substitution Snapshots

### 15.1. Binding Structure

The engine represents tracked variable substitutions using:

```prolog
binding(VariableName, Value).
```

Examples:

```prolog
binding("V1", "luis")
binding("V2", "marta")
binding("V3", "_")
```

### 15.2. Generated Variable Identifiers

The tracing mechanism uses generated identifiers such as:

```text
V1
V2
V3
```

These identifiers correspond to variables tracked from the original query.

They are generated for tracing purposes.

### 15.3. Concrete Substitutions

A variable with a concrete value can be represented as:

```prolog
binding("V1", "luis")
```

### 15.4. Unbound Variables

An unbound tracked variable can be represented as:

```prolog
binding("V1", "_")
```

The string `"_"` is the unbound-variable marker.

### 15.5. Stable Binding Snapshots

The bindings recorded for an event describe the substitutions associated with that event.

They are not live mutable references to the internal resolution variables.

This allows earlier events to retain their recorded meaning after backtracking.

---

## 16. Variable Aliasing

### 16.1. Definition

Variable aliasing occurs when two variables refer to the same logical variable.

The variables may remain unbound even though their identities have become shared.

### 16.2. Original Representation Limitation

A simple textual representation of all unbound variables as:

```prolog
"_"
```

cannot distinguish two situations:

1. Two independent unbound variables.
2. Two variables that have become aliases.

The logical unification may be correct while the recorded trace omits the relationship.

### 16.3. Improved Representation

The trace now distinguishes these situations using an alias reference.

For example:

```prolog
[
    binding("V1", "_"),
    binding("V2", "alias(V1)")
]
```

This indicates that `V2` refers to the same still-unbound logical variable as `V1`.

### 16.4. Independent Variables

Two independent unbound variables are represented as:

```prolog
[
    binding("V1", "_"),
    binding("V2", "_")
]
```

### 16.5. Technical Principle

Prolog term identity can determine whether two tracked variables refer to the same logical variable.

The identity comparison operator is:

```prolog
==
```

For tracked unbound variables, an identity comparison can distinguish aliases from independent variables.

The snapshot-generation logic can then refer to an earlier tracked variable using its stable label.

### 16.6. Example: Aliased Variables

Example fact:

```prolog
aliased_pair(X, X).
```

Query:

```prolog
aliased_pair(A, B).
```

Verified answer representation:

```prolog
answer(
    [1],
    [
        binding("V1", "_"),
        binding("V2", "alias(V1)")
    ]
).
```

### 16.7. Example: Independent Variables

Example fact:

```prolog
independent_pair(_, _).
```

Query:

```prolog
independent_pair(A, B).
```

Verified answer representation:

```prolog
answer(
    [1],
    [
        binding("V1", "_"),
        binding("V2", "_")
    ]
).
```

### 16.8. Interface Compatibility

The structure remains:

```prolog
binding(VariableName, Value).
```

However, the value may contain:

```text
alias(V1)
```

Roy's tree-building component must preserve and interpret this information correctly.

### 16.9. Representation Limitation

The alias notation is a textual representation used by the tracing interface.

It is not a new Prolog language construct.

It preserves the tested alias relationships among tracked original query variables that remain unbound.

It is not a complete serialization of all possible variable-sharing relationships inside arbitrary nested terms.

---

## 17. Successful Answer Representation

### 17.1. Structure

Successful resolution branches are represented using:

```prolog
answer(Path, Bindings).
```

### 17.2. Fields

| Field | Meaning |
|---|---|
| `Path` | Recorded resolution path associated with the successful branch. |
| `Bindings` | Snapshot of substitutions for tracked original query variables. |

### 17.3. Example

```prolog
answer(
    [1],
    [
        binding("V1", "luis")
    ]
).
```

### 17.4. Multiple Answers

A query can produce:

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

### 17.5. Failed Queries

If no explored branch succeeds, the answer list is empty:

```prolog
Answers = []
```

The trace events are needed to distinguish logical failures from depth cutoffs.

### 17.6. Integration Purpose

Part B uses the path and bindings to associate successful answers with the corresponding branches of the constructed SLD tree.

---

## 18. Verified Resolution Trace Example

### 18.1. Example Query

```prolog
parent(ana, X).
```

Maximum depth:

```text
1
```

### 18.2. Recorded Events

```prolog
step(1,[],0,start,"parent(ana,A)",none,["parent(ana,A)"],[binding("V1","_")])
```

```prolog
step(2,[1],1,apply,"parent(ana,A)","parent(ana,luis)",[],[binding("V1","luis")])
```

```prolog
step(3,[1],1,success,none,none,[],[binding("V1","luis")])
```

```prolog
step(4,[],0,backtrack,"parent(ana,A)",none,["parent(ana,A)"],[binding("V1","_")])
```

```prolog
step(5,[2],1,apply,"parent(ana,A)","parent(ana,marta)",[],[binding("V1","marta")])
```

```prolog
step(6,[2],1,success,none,none,[],[binding("V1","marta")])
```

### 18.3. Successful Answers

```prolog
answer([1],[binding("V1","luis")])
```

```prolog
answer([2],[binding("V1","marta")])
```

### 18.4. Interpretation

| Event | Path | Action | Meaning |
|---:|---|---|---|
| 1 | `[]` | `start` | Start the query. |
| 2 | `[1]` | `apply` | Apply the first matching fact. |
| 3 | `[1]` | `success` | First successful answer. |
| 4 | `[]` | `backtrack` | Restore the root state. |
| 5 | `[2]` | `apply` | Apply the second matching fact. |
| 6 | `[2]` | `success` | Second successful answer. |

### 18.5. Technical Significance

This example demonstrates:

- Fact selection.
- Unification.
- Backtracking.
- Multiple solutions.
- Resolution paths.
- Chronological event numbering.
- Binding snapshots.
- Successful-answer records.

The structured information can be consumed by Part B.

---

## 19. Logical Failure and Depth-Cutoff Events

### 19.1. Logical Failure

Example query:

```prolog
parent(diego, X).
```

The example program contains no applicable fact satisfying this query.

The recorded failure event includes:

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

### 19.2. Depth Cutoff

Example query:

```prolog
endless.
```

Maximum depth:

```text
3
```

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

### 19.3. Comparison

| Event | Meaning |
|---|---|
| `failure` | The selected goal cannot be satisfied in the explored branch. |
| `cutoff` | The configured maximum depth prevents additional exploration. |

### 19.4. Importance for the Tree Builder

Part B must preserve the distinction between these terminal outcomes.

A depth-limited branch must not be misrepresented as an ordinary logical failure.

---

## 20. Twelve Demonstration Cases

The demonstration definitions are located in:

```text
examples/queries/sld_demo_cases.pl
```

The runner is located in:

```text
examples/queries/sld_demo_runner.pl
```

### 20.1. Verified Scenarios

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

### 20.2. Overall Result

The recorded execution completed with:

```text
Total passed: 12 / 12
Exit code: 0
```

### 20.3. Individual Demonstration Mode

The runner provides:

```prolog
sld_demo_runner:run_case(N).
```

This mode displays the detailed execution of one selected case.

The output includes:

- Case identification.
- Query.
- Maximum depth.
- Expected and observed answer counts.
- Chronological resolution trace.
- Applied clauses.
- Pending goals.
- Variable bindings.
- Successful answers.
- Execution summary.
- Final PASS/FAIL result.

### 20.4. Combined Demonstration Mode

The runner also provides:

```prolog
sld_demo_runner:run_all.
```

This mode executes all twelve cases.

It displays a compact summary table containing:

- Case number.
- Scenario description.
- Expected answers.
- Observed answers.
- Final result.

The current `run_all` output does not display twelve complete detailed traces.

To inspect a case's detailed resolution process, use `run_case(N)`.

### 20.5. Verification Scope

Each demonstration verifies its expected number of successful answers and variable bindings. The runner additionally checks chronological step numbering, the number of successful events, and required trace events for failure, recursion, backtracking, and depth cutoff.

The four automated test suites and separate execution-evidence files provide further checks, including seven direct tests of the structured `step/8` event contract.

These results cover the documented educational subset and demonstration scenarios; they do not prove correctness for arbitrary Prolog programs or establish integration with Parts B and C.

---

## 21. Automated Test Suites

The implementation includes four automated test suites.

| Suite | File | Tests | Recorded result |
|---|---|---:|---|
| Basic SLD engine | `tests/engine/sld_engine_tests.pl` | 14 | 14/14 passed |
| Resolution traces | `tests/engine/sld_trace_tests.pl` | 17 | 17/17 passed |
| Variable aliasing | `tests/engine/sld_alias_tests.pl` | 3 | 3/3 passed |
| Structured event contract | `tests/engine/sld_step_contract_tests.pl` | 7 | 7/7 passed |
| **Total** | **Four suites** | **41** | **41/41 passed** |

### 21.1. Basic Engine Tests

These tests cover the supported logical-resolution behavior.

Relevant scenarios include:

- Facts.
- Rules.
- Successful queries.
- Unsuccessful queries.
- Conjunctions.
- Recursion.
- Multiple solutions.
- Backtracking.
- Depth limits.

### 21.2. Trace Tests

These tests verify the structured resolution information.

Relevant scenarios include:

- Event generation.
- Resolution paths.
- Successful answers.
- Variable substitutions.
- Failed branches.
- Backtracking.
- Depth cutoffs.
- Invalid depth values.

### 21.3. Variable Aliasing Tests

The additional tests are:

```text
logical_unification
aliased_variables_in_trace
independent_variables_in_trace
```

Their purpose is to verify:

1. Logical unification.
2. Aliased unbound variables.
3. Independent unbound variables.

### 21.4. Structured Event Contract Tests

The seven tests in `tests/engine/sld_step_contract_tests.pl` verify that the public `step/8` interface records:

1. The initial resolution event and its variable bindings.
2. A selected fact and its applied clause.
3. Remaining goals after unification.
4. Applied rule clauses, including pending body goals.
5. Logical failure events.
6. Depth-cutoff events.
7. Backtracking events and restored parent-state bindings.

Their independent execution is recorded in `docs/evidence/engine/05_step_contract_tests.txt`.

### 21.5. Recorded Test Result

```text
41/41 tests passed
Exit code: 0
```

### 21.6. Automated Test Evidence

```text
docs/evidence/engine/automated_tests.txt
```

---

## 22. Individual Execution Evidence

The evidence files are located in:

```text
docs/evidence/engine/
```

### 22.1. Evidence for the Six Approved Commitments

| Commitment | Evidence files |
|---|---|
| 1. Meta-interpreter | `01_meta_interpreter.txt` |
| 2. Goal resolution and unification | `02_goal_unification.txt`, `02_variable_aliasing.txt`, `02_alias_tests.txt` |
| 3. Recursion and backtracking | `03_backtracking.txt`, `03_recursion.txt`, `03_failed_query.txt` |
| 4. Configurable depth control | `04_configurable_depth.txt`, `04_depth_cutoff.txt` |
| 5. Resolution information | `05_trace_interface.txt`, `05_failure_cutoff_interface.txt`, `05_step_contract_tests.txt` |
| 6. Individual tests | `automated_tests.txt`, `demo_12_cases_output.txt` |

### 22.2. Additional General Evidence

The directory also contains:

```text
basic_resolution.txt
recursion_depth.txt
sld_trace.txt
```

These files provide earlier verification of logical resolution, recursion, depth control, and resolution tracing.

### 22.3. Evidence Inventory

The complete file inventory and explanation are documented in:

```text
docs/evidence/engine/README.md
```

### 22.4. Evidence Interpretation

The individual evidence files demonstrate specific functional requirements.

The automated tests verify additional behavior.

The twelve-case summary records expected and observed answer counts; the updated runner also validates the corresponding variable bindings and required scenario events.

These evidence types complement each other.

They should not be treated as interchangeable.

---

## 23. Reproducing the Automated Tests

Open Windows CMD in the repository root.

### 23.1. Execute All Tests

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt
```

### 23.2. Check the Exit Code

Immediately execute:

```cmd
echo %ERRORLEVEL%
```

The recorded successful execution returned:

```text
0
```

### 23.3. Save the Test Output

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt > docs\evidence\engine\automated_tests.txt 2>&1
```

### 23.4. Verify the Final Test

```cmd
findstr /L /C:"[41/41]" docs\evidence\engine\automated_tests.txt
```

### 23.5. Inspect the Evidence

```cmd
type docs\evidence\engine\automated_tests.txt
```

The test output should be regenerated after relevant modifications to the engine.

### 23.6. Reproduce the Structured Event Contract Tests

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_step_contract_tests.pl -g "run_tests([sld_step_contract])" -t halt > docs\evidence\engine\05_step_contract_tests.txt 2>&1
```

Verify the exit code and inspect the seven-test evidence:

```cmd
echo %ERRORLEVEL%
type docs\evidence\engine\05_step_contract_tests.txt
```

---

## 24. Reproducing the Demonstrations

### 24.1. Execute Case 7

This case demonstrates conjunctions and shared variables.

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(7)" -t halt
```

### 24.2. Execute Case 8

This case demonstrates backtracking after a failed alternative.

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(8)" -t halt
```

### 24.3. Execute Case 9

This case demonstrates recursive ancestor resolution.

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(9)" -t halt
```

### 24.4. Execute Case 11

This case demonstrates a configurable depth cutoff.

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(11)" -t halt
```

### 24.5. Execute All Twelve Cases

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt
```

### 24.6. Save the Summary Output

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt > docs\evidence\engine\demo_12_cases_output.txt 2>&1
```

### 24.7. Check the Exit Code

```cmd
echo %ERRORLEVEL%
```

### 24.8. Verify the Summary

```cmd
findstr /C:"Total passed:" docs\evidence\engine\demo_12_cases_output.txt
```

Recorded result:

```text
Total passed: 12 / 12
```

### 24.9. Inspect the Output

```cmd
type docs\evidence\engine\demo_12_cases_output.txt
```

---

## 25. Known Technical Limitations

The meta-interpreter supports a defined educational subset of Prolog.

It is not a complete implementation of the Prolog language.

### 25.1. Language Subset

General support is not provided for:

- Cut (`!`).
- Negation-as-failure.
- Disjunction.
- Arbitrary built-in predicates.
- General arithmetic evaluation.
- Side-effecting operations.
- Dynamic database modifications.
- Complete module-system behavior.

### 25.2. Clause Source

The supported program clauses are obtained from the SWI-Prolog `user` module.

The engine is not designed to interpret arbitrary Prolog modules.

### 25.3. Unrestricted Resolution

The predicate:

```prolog
sld_solve/1
```

does not impose a configurable depth limit.

A recursive program without a terminating base case may therefore continue indefinitely.

### 25.4. Depth Limits

A configured maximum depth restricts the expansion of individual resolution branches.

It is not a global execution-time limit.

It does not establish a maximum number of trace events.

### 25.5. Cutoff Semantics

A depth cutoff means that further exploration was prevented by the configured limit.

It does not establish that the original query is logically false.

### 25.6. Variable Labels

The trace uses generated identifiers such as:

```text
V1
V2
V3
```

These identifiers do not necessarily preserve the original source-level variable names.

### 25.7. Textual Snapshots

The trace contains stable textual representations of goals, clauses, and variable values.

These snapshots are not live Prolog variables.

The displayed variable names inside separately generated text snapshots should not be treated as globally unique variable identities.

### 25.8. Variable Aliasing

The trace distinguishes the tested cases of aliased and independent unbound query variables.

It does not provide a complete serialization of every possible shared-variable relationship in arbitrary nested Prolog terms.

### 25.9. Tree Construction

Part A does not construct the final SLD tree hierarchy.

This responsibility belongs to Part B.

### 25.10. JSON Export

Part A does not export the completed tree as JSON.

This responsibility belongs to Part B.

### 25.11. Graphical Visualization

Part A does not implement the browser-based visualization.

This responsibility belongs to Part C.

---

## 26. Integration with Part B

The principal public interface is:

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

It provides:

- Chronological resolution events.
- Resolution paths.
- Depth information.
- Selected goals.
- Applied clauses.
- Pending goals.
- Variable substitutions.
- Variable aliases.
- Successful answers.
- Failed branches.
- Depth cutoffs.
- Backtracking events.

### 26.1. Integration Requirements

Roy's component must correctly handle:

1. `step/8` event fields.
2. `answer/2` records.
3. `binding/2` records.
4. Chronological event ordering.
5. Root and branch paths.
6. Resolution depth.
7. Applied clauses.
8. Remaining goals.
9. Successful outcomes.
10. Failed outcomes.
11. Depth cutoffs.
12. Backtracking.
13. Concrete substitutions.
14. Unbound-variable markers.
15. Alias references.

### 26.2. Alias Compatibility

The binding structure remains:

```prolog
binding(VariableName, Value).
```

The value may include:

```text
alias(V1)
```

Roy's consumer must preserve that information.

### 26.3. Tree Construction

Part B is responsible for using the recorded information to construct:

- Tree nodes.
- Parent-child relationships.
- Alternative branches.
- Terminal branches.
- Node metadata.

### 26.4. JSON Export

Part B is responsible for exporting the constructed tree as JSON.

The complete JSON schema is not defined by Part A.

### 26.5. Integration Verification

The actual integration must be tested using Roy's implementation.

The individual Part A tests do not establish that this integration has already been completed.

---

## 27. Individual Technical Demonstration

Emmanuel must be able to explain and demonstrate his own component independently.

### 27.1. Concepts to Explain

1. What a meta-interpreter is.
2. What SLD resolution means.
3. What facts and rules are.
4. How leftmost-goal selection works.
5. How clauses are selected.
6. How unification works.
7. How variable substitutions propagate.
8. How conjunctions are resolved.
9. How recursive rules are processed.
10. How backtracking explores alternatives.
11. How multiple solutions are produced.
12. How unsuccessful queries are recognized.
13. How configurable depth limits work.
14. Why failure and cutoff are different.
15. How variable aliasing is represented.
16. How resolution events are generated.
17. What `step/8` contains.
18. What `answer/2` contains.
19. What information is provided to Part B.
20. What limitations the engine has.

### 27.2. Recommended Demonstration Scenarios

| Demonstration | Main concept |
|---|---|
| Meta-interpreter evidence | Facts and rules. |
| Case 7 | Conjunctions and shared variables. |
| Aliasing evidence | Shared unbound variables. |
| Case 8 | Backtracking after failure. |
| Case 9 | Recursive resolution. |
| Case 4 | Unsuccessful query. |
| Case 11 | Configurable depth control. |
| Trace evidence | Structured resolution events. |
| 41 automated tests | Regression verification across four suites. |
| Seven `step/8` contract tests | Selected goals, applied clauses, pending goals, bindings, failure, cutoff, and backtracking. |
| 12 demonstration cases | Complete demonstration summary. |

### 27.3. Expected Technical Questions

#### What does the meta-interpreter do?

It resolves supported Prolog queries by selecting goals, applying facts or rules, performing unification, and exploring alternatives.

#### What is unification?

Unification makes two compatible Prolog terms identical through variable substitutions.

#### How does the engine select goals?

It selects the leftmost pending goal.

#### How are rules resolved?

The selected goal is unified with a rule head, and the rule body replaces that goal.

#### What is backtracking?

Backtracking allows Prolog to return to an earlier state and explore another applicable clause.

#### How does the engine obtain multiple solutions?

It explores alternative resolution branches through Prolog backtracking.

#### What is a depth cutoff?

It indicates that the configured depth limit prevented further exploration of an unresolved branch.

#### Is a cutoff the same as logical failure?

No. A cutoff does not prove that the query is false.

#### How does the engine represent variable aliasing?

It records an alias reference such as `alias(V1)` when tracked unbound query variables refer to the same logical variable.

#### What information does Part B receive?

Part B receives chronological `step/8` events and successful `answer/2` records through `sld_trace/4`.

#### What is Emmanuel's individual contribution?

The SLD logical resolution engine, its tests, documentation, execution evidence, and individual demonstration.

### 27.4. Demonstration Guide

The complete practical demonstration procedure is documented in:

```text
docs/ENGINE_DEMO.md
```

---

## 28. Current Verification Status

### 28.1. Verified Functionality

| Functionality | Recorded status |
|---|---|
| SLD meta-interpreter | Implemented and tested |
| Fact resolution | Verified |
| Rule resolution | Verified |
| Leftmost-goal selection | Verified through Part A tests and traces |
| Unification | Verified |
| Conjunctions | Verified |
| Shared substitutions | Verified |
| Variable aliasing | Verified |
| Independent unbound variables | Verified |
| Recursive resolution | Verified |
| Backtracking | Verified |
| Multiple solutions | Verified |
| Unsuccessful queries | Verified |
| Configurable depth control | Verified |
| Depth cutoffs | Verified |
| Structured resolution events | Verified |
| Successful-answer records | Verified |
| Failure events | Verified |
| Cutoff events | Verified |
| Structured event contract tests | **7/7 passed** |
| Automated tests | **41/41 passed** |
| Demonstration cases | **12/12 passed** |
| Automated test exit code | **0** |
| Demonstration exit code | **0** |
| Organized console output | Verified |
| Individual execution evidence | Generated |

### 28.2. Repository Status

The original engine implementation was integrated into `main` through:

```text
Pull request #2
Merge commit: d8a1117
```

The additional evidence and demonstration improvements were developed on:

```text
feature/engine-demo-evidence
```

The original merge does not establish that all subsequent changes have already been integrated into `main`.

### 28.3. Remaining Verification

The following activities remain relevant before declaring the individual contribution fully ready for final delivery:

1. Review consistency between the source code and updated documentation.
2. Review the final demonstration instructions.
3. Review the main project README.
4. Confirm that all required execution-evidence files are included.
5. Verify the final staged Git changes.
6. Commit and publish the validated changes.
7. Prepare the individual technical explanation.
8. Practice the individual demonstration.
9. Verify the actual Part A-B integration when Roy's component is available.

The SLD tree hierarchy and JSON export remain Roy's responsibility.

The browser visualization remains Keynell's responsibility.

---

## 29. Final Technical Statement

The SLD meta-interpreter developed by Emmanuel Núñez Jiménez implements logical resolution for a defined educational subset of Prolog.

The engine:

- Processes facts and rules.
- Selects pending goals.
- Performs unification.
- Maintains variable substitutions.
- Resolves conjunctions.
- Handles recursive rules.
- Explores alternatives through backtracking.
- Produces multiple successful answers.
- Recognizes unsuccessful queries.
- Applies configurable resolution-depth limits.
- Records structured resolution events.
- Preserves the tested alias relationships between tracked unbound query variables.
- Provides successful-answer information for the tree-building component.

The recorded automated verification completed with:

```text
41/41 tests passed
Exit code: 0
```

The recorded demonstration verification completed with:

```text
12/12 demonstration cases passed
Exit code: 0
```

Separate execution-evidence files support the six approved individual commitments.

The implementation and documentation provide the technical foundation for Emmanuel's individual demonstration and defense.

These results do not establish that the complete three-component SLD Resolution Tree Visualizer has already been integrated.

The integration must preserve the approved individual responsibilities of Emmanuel Núñez Jiménez, Roy Arias Mejía, and Keynell Molina Mora.

The development and verification presented here correspond specifically to Emmanuel's approved Part A contribution.

# Individual Technical Documentation - SLD Resolution Engine

## 1. Project Information

- **Project:** SLD Resolution Tree Visualizer
- **Course:** EIF400 - Programming Paradigms
- **University:** National University of Costa Rica (UNA)
- **Group:** 04-10am
- **Instructor:** Carlos Loria-Saenz
- **Student:** Emmanuel Nunez Jimenez
- **Individual Contribution:** Part A - SLD Meta-Interpreter and Logical Resolution Engine in SWI-Prolog
- **Development Environment:** SWI-Prolog 10.0.2 for Windows (64-bit)
- **Working Branch:** `feature/sld-meta-interpreter`
- **Latest Confirmed Commit:** `900033a`
- **Engine Implementation Reference:** `b0b1033`

**Current Status:** The SLD resolution engine has been implemented and individually tested. Integration with Part B remains pending validation.

## 2. Purpose and Scope

The purpose of Part A is to implement an SLD resolution engine capable of processing queries over a defined subset of Prolog.

SLD stands for *Selective Linear Definite Clause Resolution*. It is a logical resolution strategy used to execute queries against definite Horn clauses.

The engine supports:

- Facts.
- Definite Horn-clause rules.
- Logical queries.
- Conjunctions of goals.
- Unification.
- Recursive resolution.
- Backtracking.
- Multiple solutions.
- Failed queries.
- Configurable resolution depth.
- Resolution trace generation.

The engine also generates information about the resolution process, allowing another component to construct an SLD resolution tree.

### Individual Responsibility

Part A is developed by Emmanuel Nunez Jimenez.

Its responsibilities are:

1. Implement the SLD meta-interpreter.
2. Select and resolve goals.
3. Apply unification.
4. Execute facts and rules.
5. Handle recursion.
6. Explore alternatives through backtracking.
7. Produce multiple solutions.
8. Identify unsuccessful resolution attempts.
9. Control recursive searches using a depth limit.
10. Generate resolution events and variable substitutions.
11. Implement individual tests.
12. Document and demonstrate the engine.

Part A does not construct the final graphical tree or export JSON.

Those responsibilities belong to Part B, developed by Roy Arias Mejia.

The web visualization component belongs to Part C, developed by Keynell Molina Mora.

## 3. Project Files

The main files associated with Part A are:

| File | Purpose |
|---|---|
| `src/prolog/engine/sld_engine.pl` | Main SLD meta-interpreter and resolution engine. |
| `tests/engine/sld_engine_tests.pl` | Automated tests for logical resolution. |
| `tests/engine/sld_trace_tests.pl` | Automated tests for resolution traces. |
| `examples/programs/family.pl` | Example program containing family relationships and recursive rules. |
| `examples/programs/recursive_loop.pl` | Example program for testing recursive searches and depth limits. |
| `docs/ENGINE_INTERFACE.md` | Proposed integration contract between Parts A and B. |
| `docs/ENGINE_TECHNICAL.md` | Individual technical documentation for Part A. |

The example programs are loaded into the SWI-Prolog `user` module.

The resolution engine inspects their clauses using:

```prolog
clause(user:Goal, Body)
```

This allows the meta-interpreter to select applicable facts and rules.

## 4. Fundamentals of SLD Resolution

SLD resolution is based on the repeated selection and resolution of logical goals.

A query may contain a single goal:

```prolog
parent(ana, X)
```

Or a conjunction of goals:

```prolog
(parent(ana, X), parent(X, Y))
```

The engine processes these goals using a leftmost selection strategy.

### 4.1. Goal Selection

The leftmost pending goal is selected first.

For example:

```prolog
(parent(ana, X), parent(X, Y))
```

The first selected goal is:

```prolog
parent(ana, X)
```

If this goal succeeds with:

```prolog
X = luis
```

The remaining goal becomes:

```prolog
parent(luis, Y)
```

The engine then attempts to resolve that goal.

### 4.2. Unification

Unification determines whether two Prolog terms can be made identical through variable substitutions.

Consider:

```prolog
parent(ana, X)
```

And the fact:

```prolog
parent(ana, luis).
```

These terms unify with the substitution:

```prolog
X = luis
```

The engine uses Prolog's native unification mechanism when selecting applicable clauses.

### 4.3. Clause Resolution

When a goal matches a fact, the selected goal can be removed from the pending goals.

When a goal matches a rule, the rule body replaces the selected goal.

For example:

```prolog
ancestor(X, Y) :-
    parent(X, Y).
```

A query such as:

```prolog
ancestor(ana, X)
```

can be resolved by replacing the selected goal with:

```prolog
parent(ana, X)
```

Resolution continues until all goals are satisfied or the branch cannot proceed.

### 4.4. Resolution Outcomes

The depth-limited engine distinguishes three terminal outcomes:

| Outcome | Meaning |
|---|---|
| `success` | All pending goals have been satisfied. |
| `failure` | The selected goal has no applicable unifiable clause. |
| `cutoff` | The configured depth limit prevents further resolution. |

A cutoff does not necessarily indicate that a query is logically false.

It only indicates that the branch was not explored beyond the configured limit.

## 5. Public Engine Interface

The main module is declared as:

```prolog
:- module(sld_engine, [
    sld_solve/1,
    sld_solve_limited/3,
    sld_trace/4
]).
```

It exports three public predicates.

### 5.1. Basic Meta-Interpreter: `sld_solve/1`

Signature:

```prolog
sld_solve(+Query).
```

This predicate resolves logical queries using SLD resolution.

It supports:

- Facts.
- Rules.
- Conjunctions.
- Unification.
- Recursive goals.
- Backtracking.
- Multiple solutions.

The basic meta-interpreter does not impose a depth limit.

Example:

```prolog
?- sld_engine:sld_solve(parent(ana, X)).
```

The expected solutions are:

```prolog
X = luis ;
X = marta.
```

The predicate uses Prolog's backtracking mechanism to explore alternative clauses.

**Limitation:** Queries involving infinite recursion may not terminate when this predicate is used without a depth limit.

### 5.2. Depth-Limited Resolution: `sld_solve_limited/3`

Signature:

```prolog
sld_solve_limited(+Query, +MaxDepth, -Outcome).
```

Parameters:

- `Query`: The logical query to resolve.
- `MaxDepth`: A non-negative integer specifying the maximum resolution depth.
- `Outcome`: The terminal result of an explored branch.

The possible outcomes are:

```prolog
success
failure
cutoff
```

The predicate explores alternative branches through backtracking.

Therefore, a single query may produce multiple terminal outcomes.

#### Example: Successful Resolution

```prolog
?- findall(
       Status,
       sld_engine:sld_solve_limited(parent(ana, _), 1, Status),
       Statuses
   ).
```

Observed result:

```prolog
Statuses = [success, success].
```

Both parent facts are successfully resolved.

#### Example: Depth Cutoff

```prolog
?- findall(
       Status,
       sld_engine:sld_solve_limited(parent(ana, _), 0, Status),
       Statuses
   ).
```

Observed result:

```prolog
Statuses = [cutoff].
```

The selected goal cannot be expanded because the maximum depth is zero.

#### Example: Failed Resolution

```prolog
?- findall(
       Status,
       sld_engine:sld_solve_limited(parent(diego, _), 1, Status),
       Statuses
   ).
```

Observed result:

```prolog
Statuses = [failure].
```

No applicable fact or rule can satisfy the selected goal.

### 5.3. Resolution Tracing: `sld_trace/4`

Signature:

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

This predicate performs depth-limited resolution and records the resolution process.

Parameters:

**Query**

The Prolog query to resolve.

**MaxDepth**

A non-negative integer defining the maximum number of clause applications along a branch.

**Steps**

An ordered list containing the resolution events.

**Answers**

A list containing the successful solutions and their variable substitutions.

The trace predicate returns an aggregated representation of the explored resolution process.

Unlike `sld_solve/1`, it does not instantiate the original query variables separately for each solution.

Instead, solutions are returned through `Answers`.

This behavior allows the engine to preserve information about successful, failed, and depth-limited branches.

## 6. Internal Engine Design

### 6.1. Converting Goals into Lists

The internal predicate:

```prolog
goals_to_list(+Query, -Goals)
```

converts a query into a list of pending goals.

For example:

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

The special goal:

```prolog
true
```

is converted into an empty goal list:

```prolog
[]
```

This representation simplifies goal selection and resolution.

### 6.2. Basic Goal Resolution

The internal predicate:

```prolog
resolve_goals(+Goals)
```

processes the pending goals.

The algorithm follows these steps:

1. Check whether the goal list is empty.
2. If it is empty, resolution succeeds.
3. Otherwise, select the leftmost goal.
4. Search for an applicable clause.
5. Unify the selected goal with the clause head.
6. Convert the clause body into a list of goals.
7. Replace the selected goal with the body goals.
8. Continue resolving the remaining goals.

The engine uses:

```prolog
clause(user:Goal, Body)
```

to select applicable clauses.

It also uses:

```prolog
append/3
```

to combine the clause body goals with the remaining goals.

### 6.3. Depth-Limited Resolution

The internal predicate:

```prolog
resolve_limited(+Goals, +Depth, +MaxDepth, -Outcome)
```

extends the basic resolution process with a configurable depth limit.

The initial depth is zero.

Every applied clause increases the depth by one.

The resolution process follows three main conditions:

**Success**

If no goals remain:

```prolog
Outcome = success
```

**Cutoff**

If unresolved goals remain and the maximum depth has been reached:

```prolog
Outcome = cutoff
```

**Failure**

If the selected goal has no applicable clause:

```prolog
Outcome = failure
```

When an applicable clause exists and the depth limit allows further expansion, resolution continues recursively.

### 6.4. Recursive Resolution

Recursive rules are processed using the same goal-resolution mechanism.

Consider:

```prolog
ancestor(X, Y) :-
    parent(X, Y).

ancestor(X, Y) :-
    parent(X, Z),
    ancestor(Z, Y).
```

The second rule contains a recursive call to `ancestor/2`.

The engine replaces the selected goal with the rule body and continues resolving the resulting goals.

The depth limit prevents an individual recursive branch from expanding indefinitely.

### 6.5. Backtracking

Backtracking allows the engine to explore alternative clauses.

For example:

```prolog
parent(ana, luis).
parent(ana, marta).
```

The query:

```prolog
parent(ana, X)
```

has two possible resolutions.

The engine first explores:

```prolog
X = luis
```

It then explores the second applicable fact:

```prolog
X = marta
```

In the trace generator, alternative resolution states are collected independently.

The implementation uses:

```prolog
findall/3
```

to collect applicable clause alternatives and:

```prolog
copy_term/2
```

to create independent copies of resolution states.

The internal predicate:

```prolog
trace_choices/10
```

explores the alternatives and records backtracking events when another applicable alternative remains.

This design prevents substitutions from one branch from modifying previously recorded information.

## 7. Resolution Trace Representation

The engine generates stable information about the resolution process.

This information is intended for the SLD tree construction module developed by Roy.

### 7.1. Resolution Snapshots

The implementation includes predicates for recording stable representations of resolution data.

**`snapshot_term/2`**

Creates a stable textual representation of a Prolog term.

**`snapshot_goals/2`**

Creates textual snapshots of the remaining goals while preserving variable relationships within the copied goal list.

**`snapshot_bindings/2`**

Records the substitutions associated with the original query variables.

**`number_trace_events/3`**

Converts internal resolution events into public step records with chronological sequence numbers.

The implementation uses Prolog mechanisms such as:

```prolog
copy_term/2
numbervars/3
term_string/3
term_variables/2
findall/3
append/3
```

These predicates support the internal operation of the engine.

They are not interpreted as arbitrary user-program goals.

### 7.2. Resolution Step Structure

Each resolution step has the following structure:

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

The fields are defined as follows:

| Field | Description |
|---|---|
| `Sequence` | Chronological event number, starting at 1. |
| `Path` | List identifying the explored clause alternatives. |
| `Depth` | Number of clause applications along the current branch. |
| `Action` | Type of resolution event. |
| `Goal` | Stable textual representation of the selected goal, or `none`. |
| `Clause` | Stable textual representation of the applied clause, or `none`. |
| `RemainingGoals` | List of textual representations of pending goals. |
| `Bindings` | Current substitutions for the original query variables. |

The initial path is:

```prolog
[]
```

When a clause alternative is selected, its position is added to the path.

Examples:

```prolog
[1]
[2]
[1,1]
[1,2]
```

The paths identify resolution alternatives.

They are not final graphical tree-node identifiers.

### 7.3. Resolution Actions

The engine supports the following actions:

| Action | Meaning |
|---|---|
| `start` | Resolution begins. |
| `apply` | An applicable clause is selected and applied. |
| `success` | All pending goals have been satisfied. |
| `failure` | No applicable clause can resolve the selected goal. |
| `cutoff` | The configured depth limit prevents further expansion. |
| `backtrack` | Resolution returns to a parent state to explore another applicable alternative. |

The distinction between `failure` and `cutoff` is essential.

A branch stopped by the depth limit must not automatically be classified as logically false.

The engine does not necessarily generate a separate failure event for every ancestor of a failed branch.

Part B must interpret the recorded paths and terminal events when constructing the complete tree.

### 7.4. Variable Substitutions

Variable substitutions are represented using:

```prolog
binding(VariableName, Value)
```

Example:

```prolog
binding("V1", "luis")
```

Original query variables receive stable names:

```prolog
V1
V2
V3
```

These names are assigned according to the order of the original query variables.

An unbound variable is represented by:

```prolog
binding("V2", "_")
```

Both the variable name and its recorded value are strings.

The engine uses stable snapshots so that previously recorded substitutions do not change during backtracking.

### 7.5. Successful Answers

Successful resolutions are represented as:

```prolog
answer(Path, Bindings)
```

Example:

```prolog
answer(
    [1],
    [binding("V1", "luis")]
)
```

The path identifies the successful resolution alternative.

The bindings contain the corresponding substitutions for the original query variables.

This representation allows the tree construction module to associate each answer with its successful branch.

## 8. Execution Examples and Observed Results

The following examples were executed using SWI-Prolog 10.0.2 on Windows.

All commands must be executed from the root directory of the project.

### 8.1. Query with Multiple Solutions

Command:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(parent(ana,X),1,Steps,Answers),writeln(Steps),writeln(Answers),halt."
```

The expected logical solutions are:

```prolog
X = luis
X = marta
```

The observed answers correspond to:

```prolog
[
    answer([1], [binding("V1", "luis")]),
    answer([2], [binding("V1", "marta")])
]
```

The resolution actions are:

```prolog
[
    start,
    apply,
    success,
    backtrack,
    apply,
    success
]
```

This example demonstrates:

- Fact resolution.
- Unification.
- Multiple solutions.
- Backtracking.
- Resolution tracing.
- Variable substitutions.

**Note:** SWI-Prolog's `writeln/1` may display string contents without visible quotation marks. This does not change their string representation.

### 8.2. Failed Query

Command:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(parent(diego,X),2,Steps,Answers),writeln(Steps),writeln(Answers),halt."
```

The observed resolution actions are:

```prolog
[
    start,
    failure
]
```

The answer list is:

```prolog
[]
```

The selected goal cannot be satisfied by an applicable clause.

### 8.3. Zero Depth Limit

Command:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(parent(ana,X),0,Steps,Answers),writeln(Steps),writeln(Answers),halt."
```

The observed resolution actions are:

```prolog
[
    start,
    cutoff
]
```

The answer list is:

```prolog
[]
```

This example demonstrates that no clause can be applied when the maximum depth is zero and unresolved goals remain.

### 8.4. Recursive Ancestor Query

Command:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(ancestor(ana,X),4,Steps,Answers),writeln(Answers),length(Steps,N),format('Total steps: \~w\~n',[N]),halt."
```

The observed logical solutions are:

```prolog
X = luis
X = marta
X = sofia
X = diego
```

The corresponding successful answers are:

```prolog
[
    answer([1,1], [binding("V1", "luis")]),
    answer([1,2], [binding("V1", "marta")]),
    answer([2,1,1,1], [binding("V1", "sofia")]),
    answer([2,2,1,1], [binding("V1", "diego")])
]
```

The observed total number of resolution steps is:

```text
Total steps: 26
```

This example demonstrates:

- Rule resolution.
- Recursion.
- Unification.
- Multiple solutions.
- Backtracking.
- Chronological resolution tracing.

### 8.5. Infinite Recursion with Depth Control

Command:

```cmd
swipl -q -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(endless,3,Steps,Answers),findall(A,member(step(_,_,_,A,_,_,_,_),Steps),Actions),writeln(Actions),writeln(Answers),halt."
```

Observed actions:

```prolog
[
    start,
    apply,
    apply,
    apply,
    cutoff
]
```

Observed answers:

```prolog
[]
```

The resolution branch is stopped when it reaches the configured maximum depth.

This prevents the individual recursive branch from expanding indefinitely.

### 8.6. Conjunction with Shared Variables

Command:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace((parent(ana,X),parent(X,Y)),2,Steps,Answers),writeln(Answers),halt."
```

The observed logical solutions are:

```prolog
X = luis,
Y = sofia
```

And:

```prolog
X = marta,
Y = diego
```

This example demonstrates that variable substitutions are preserved between consecutive goals within a conjunction.

## 9. Automated Testing

Two automated test suites were developed for Part A.

| Test Suite | File | Result |
|---|---|---|
| Basic SLD Engine | `tests/engine/sld_engine_tests.pl` | 14/14 passed |
| SLD Resolution Trace | `tests/engine/sld_trace_tests.pl` | 17/17 passed |
| **Total** | Both test suites | **31/31 passed** |

### 9.1. Test Execution Command

The following command executes both test suites:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -g "run_tests([sld_engine,sld_trace])" -t halt
```

### 9.2. Observed Test Result

The last reported execution completed successfully.

The output ended with:

```text
[31/31] sld_trace:noninteger_depth_rejected ... passed (0.000 sec)
```

All 31 automated tests passed.

The final reported execution did not contain the singleton-variable or residual-choicepoint warnings encountered during earlier test revisions.

### 9.3. Tested Functionalities

The individual tests cover:

1. Successful fact queries.
2. Failed fact queries.
3. Rule resolution.
4. Unification.
5. Variable substitutions.
6. Conjunctions of goals.
7. Recursive resolution.
8. Multiple solutions.
9. Backtracking.
10. Depth-limit control.
11. Successful terminal outcomes.
12. Failed terminal outcomes.
13. Depth cutoffs.
14. Resolution step generation.
15. Chronological event ordering.
16. Independent alternative bindings.
17. Stable resolution snapshots.
18. Invalid depth values.

### 9.4. Scope of Testing

These tests verify the individual functionality of Part A.

They do not establish that the tree construction module developed by Roy or the web visualizer developed by Keynell has already been integrated.

Separate integration tests must be executed when the corresponding components become available.

## 10. Known Limitations

The SLD resolution engine is designed for an educational subset of Prolog.

It is not intended to implement the complete Prolog language.

The following restrictions apply:

### 10.1. Supported Clause Types

The engine supports facts and definite Horn-clause rules.

It does not provide complete support for all Prolog constructs.

### 10.2. Unsupported Language Features

The initial implementation does not support:

- Prolog cut (`!`) as an interpreted goal.
- General negation-as-failure.
- Disjunction as a separate interpreted query construct.
- Arbitrary built-in predicates.
- General arithmetic evaluation.
- Dynamic database modifications.
- Arbitrary side-effecting operations.
- Complete module-system interpretation.

### 10.3. Program Module Restriction

The engine inspects clauses in the `user` module.

It does not provide a general interface for interpreting arbitrary Prolog modules.

### 10.4. Unlimited Basic Resolution

The predicate:

```prolog
sld_solve/1
```

does not enforce a depth limit.

An infinitely recursive branch may therefore prevent termination.

### 10.5. Depth-Limit Behavior

The configurable depth limit restricts the expansion of individual resolution branches.

It does not impose a global execution-time limit or a maximum number of generated events.

A program with many alternatives may still generate a large resolution trace.

### 10.6. Cutoff Interpretation

The result:

```prolog
cutoff
```

does not mean that the logical query is false.

It means that unresolved goals remain and further expansion was prevented by the depth limit.

### 10.7. Variable Naming

Original query variables are represented using stable labels such as:

```prolog
V1
V2
V3
```

These labels do not automatically preserve the original variable names written by the user.

### 10.8. Resolution Tree Construction

Part A generates resolution information but does not construct the final tree hierarchy.

The graphical tree structure and JSON export belong to Part B.

## 11. Integration with Part B

The interface proposed for integration is:

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

Part A provides:

1. Chronological resolution steps.
2. Explored clause alternatives.
3. Selected goals.
4. Applied clauses.
5. Remaining goals.
6. Variable substitutions.
7. Successful answers.
8. Failed branches.
9. Depth-limited branches.
10. Backtracking events.

### 11.1. Responsibilities of Part B

Roy's module will consume the information generated by Part A.

It will be responsible for:

- Constructing the SLD tree hierarchy.
- Creating node identifiers.
- Establishing parent-child relationships.
- Associating clauses and substitutions with nodes.
- Representing successful, failed, and depth-limited branches.
- Exporting the resulting tree to JSON.

Part B must not reimplement the logical resolution performed by Part A.

### 11.2. Responsibilities of Part C

Keynell's module will consume the JSON generated by Part B.

It will be responsible for:

- Rendering the SLD tree in the browser.
- Displaying nodes and connections.
- Showing goals and applied clauses.
- Displaying substitutions.
- Distinguishing successful and failed branches.
- Supporting node-detail inspection.

### 11.3. Pending Integration Validation

Before the integration contract is considered final, Emmanuel and Roy must validate:

1. The public `sld_trace/4` signature.
2. The exact `step/8` representation.
3. The interpretation of resolution paths.
4. Chronological event numbering.
5. Variable substitutions.
6. The `answer(Path, Bindings)` representation.
7. Success, failure, cutoff, and backtracking behavior.
8. The information required to reconstruct the resolution tree.
9. A shared integration test.

The proposed contract is documented in:

```text
docs/ENGINE_INTERFACE.md
```

Once Part B is available, the team must execute and document a real integration test.

No completed integration with Part B or Part C is claimed at this stage.

## 12. Individual Demonstration Guide

The following sequence is recommended for Emmanuel's individual demonstration.

### Step 1. Introduce the Contribution

Explain that Part A implements the logical resolution engine.

Clarify that tree construction and graphical visualization belong to the other team members.

### Step 2. Present the Public Predicates

Show:

```prolog
sld_solve/1
sld_solve_limited/3
sld_trace/4
```

Explain the purpose of each predicate.

### Step 3. Demonstrate Fact Resolution

Execute:

```prolog
parent(ana, X)
```

Explain why the query has two solutions.

### Step 4. Demonstrate Failed Resolution

Execute:

```prolog
parent(diego, X)
```

Explain why no applicable clause satisfies the query.

### Step 5. Demonstrate Recursive Resolution

Execute:

```prolog
ancestor(ana, X)
```

Explain how recursive rules generate additional solutions.

### Step 6. Demonstrate Depth Control

Execute:

```prolog
endless
```

using a configured depth limit.

Explain why the branch produces `cutoff` instead of running indefinitely.

### Step 7. Demonstrate Variable Substitutions

Execute:

```prolog
(parent(ana, X), parent(X, Y))
```

Explain how substitutions are shared between the goals.

### Step 8. Demonstrate Resolution Tracing

Show the generated:

```prolog
step/8
```

and:

```prolog
answer/2
```

structures.

Explain how the information can be consumed by Roy's tree construction module.

### Step 9. Execute Automated Tests

Run the complete test command and explain the results obtained during the demonstration.

The test output should be preserved as execution evidence.

## 13. Current Status and Remaining Deliverables

### 13.1. Completed Work

The following elements of Part A have been implemented:

- Basic SLD meta-interpreter.
- Resolution of facts.
- Resolution of definite Horn-clause rules.
- Leftmost goal selection.
- Unification.
- Conjunction handling.
- Recursive resolution.
- Backtracking.
- Multiple solutions.
- Failed resolution detection.
- Configurable depth limit.
- Success, failure, and cutoff outcomes.
- Chronological resolution trace generation.
- Stable variable substitutions.
- Clause alternative tracking.
- Answer-path association.
- Automated engine tests.
- Automated trace tests.
- Proposed integration contract.

The latest reported test execution completed successfully with:

```text
31/31 tests passed
```

The implementation and tests have been committed and pushed to:

```text
feature/sld-meta-interpreter
```

### 13.2. Remaining Work

Before Part A is considered fully completed, the following activities remain:

1. Verify this technical documentation against the final engine implementation.
2. Collect and organize reproducible execution evidence.
3. Prepare the individual technical demonstration.
4. Validate the integration interface with Roy.
5. Execute shared integration tests when Part B is available.
6. Repeat the automated tests before final integration.
7. Review the final changes through the project's pull-request workflow.

### 13.3. Final Responsibility Statement

This document describes the individual contribution of Emmanuel Nunez Jimenez to the approved SLD Resolution Tree Visualizer project.

The contribution focuses on implementing the SLD meta-interpreter and logical resolution engine in SWI-Prolog.

It includes goal resolution, unification, recursion, backtracking, depth control, resolution tracing, and individual testing.

The construction and JSON export of the SLD resolution tree belong to Roy Arias Mejia.

The graphical visualization belongs to Keynell Molina Mora.

This separation preserves the individual responsibilities established in the proposal approved by instructor Carlos Loria-Saenz.

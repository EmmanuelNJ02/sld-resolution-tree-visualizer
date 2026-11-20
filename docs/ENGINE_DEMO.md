# SLD Resolution Engine - Individual Demonstration Guide

## 1. Academic and Technical Information

| Field | Details |
|---|---|
| Project | SLD Resolution Tree Visualizer |
| University | National University of Costa Rica (UNA) |
| Course | EIF400 - Programming Paradigms |
| Group | 04-10am |
| Instructor | Carlos Loría-Sáenz |
| Student | Emmanuel Núñez Jiménez |
| Individual contribution | Part A - SLD Meta-Interpreter and Logical Resolution Engine |
| Implementation language | SWI-Prolog |
| Verified environment | SWI-Prolog 10.0.2, Windows 64-bit |
| Recorded verification date | November 19, 2026 |
| Original engine integration | Pull request #2, merge commit `d8a1117` |
| Evidence development branch | `feature/engine-demo-evidence` |

### 1.1. Recorded Verification Results

| Verification | Result |
|---|---|
| Basic engine tests | 14/14 passed |
| Resolution trace tests | 17/17 passed |
| Variable aliasing tests | 3/3 passed |
| Structured event contract tests | 7/7 passed |
| **Total automated tests** | **41/41 passed** |
| **Demonstration cases** | **12/12 passed** |
| Automated test exit code | 0 |
| Demonstration exit code | 0 |

These results were obtained during the recorded individual verification of Part A.

The original engine implementation was integrated into `main` through pull request #2.

Additional demonstration files, variable-aliasing improvements, tests, evidence, and documentation updates were developed on `feature/engine-demo-evidence`.

These subsequent changes must be reviewed and merged separately.

The recorded Part A results do not establish that the complete three-component application has already been integrated.

---

## 2. Purpose of the Individual Demonstration

This guide explains how Emmanuel Núñez Jiménez can execute, demonstrate, and defend his approved individual contribution.

The demonstration must provide clear evidence of the six functionalities promised to instructor Carlos Loría-Sáenz.

The six commitments are:

1. Implementation of an SLD meta-interpreter in SWI-Prolog.
2. Goal resolution and unification.
3. Recursion and backtracking.
4. Configurable depth control.
5. Structured resolution information for the tree-building component.
6. Individual automated tests.

The demonstration also supports the five promised deliverables:

1. The implemented SWI-Prolog meta-interpreter module.
2. The predicates required for logical resolution.
3. Test cases and execution evidence.
4. A technical explanation of design, operation, and limitations.
5. An individual demonstration of the engine and its public resolution information.

### 2.1. Demonstration Strategy

The recommended presentation follows this order:

1. Introduce Part A and its responsibility.
2. Explain the three public predicates.
3. Demonstrate the six approved commitments individually.
4. Explain the most important resolution events.
5. Execute the 41 automated tests.
6. Execute the twelve-case summary.
7. Present the saved evidence files.
8. Explain the engine's technical limitations.
9. Explain how Part B consumes the resolution information.
10. Conclude with the approved responsibility boundaries.

This presentation uses separate commands to demonstrate specific functionality.

The combined test commands are additional verification, not a replacement for the individual demonstrations.

### 2.2. Responsibility Boundaries

Part A is Emmanuel's logical resolution engine.

Part B, developed by Roy Arias Mejía, constructs the SLD tree and exports JSON.

Part C, developed by Keynell Molina Mora, displays the tree using HTML and JavaScript.

Part A's organized console reports support the individual demonstration.

They do not replace Part B's tree hierarchy or Part C's browser visualization.

---

## 3. Required Source Files

### 3.1. Resolution Engine

```text
src/prolog/engine/sld_engine.pl
```

### 3.2. Example Programs

```text
examples/programs/family.pl
examples/programs/recursive_loop.pl
examples/programs/alias_demo.pl
```

### 3.3. Demonstration Files

```text
examples/queries/sld_demo_cases.pl
examples/queries/sld_demo_runner.pl
```

### 3.4. Automated Tests

```text
tests/engine/sld_engine_tests.pl
tests/engine/sld_trace_tests.pl
tests/engine/sld_alias_tests.pl
tests/engine/sld_step_contract_tests.pl
```

### 3.5. Technical Documentation

```text
docs/ENGINE_TECHNICAL.md
docs/ENGINE_INTERFACE.md
docs/ENGINE_DEMO.md
docs/evidence/engine/README.md
```

### 3.6. Execution Evidence

```text
docs/evidence/engine/
```

This directory contains the recorded outputs associated with the six individual commitments.

---

## 4. Prepare the Demonstration Environment

### 4.1. Open Windows CMD

Open Command Prompt.

Go to the repository:

```cmd
cd C:\Users\Emmanuel\Documents\sld-resolution-tree-visualizer
```

All subsequent commands assume that CMD is located at the repository root.

### 4.2. Verify SWI-Prolog

```cmd
swipl --version
```

The recorded verification environment used SWI-Prolog 10.0.2.

### 4.3. Verify the Git Branch

```cmd
git status -sb
```

The development branch used for the individual evidence is:

```text
feature/engine-demo-evidence
```

### 4.4. Verify the Main Implementation File

```cmd
dir src\prolog\engine\sld_engine.pl
```

### 4.5. Verify the Demonstration Runner

```cmd
dir examples\queries\sld_demo_runner.pl
```

### 4.6. Verify the Evidence Directory

```cmd
dir docs\evidence\engine
```

The source files, tests, and demonstration runner must be available before executing the demonstration.

---

## 5. Public Interface Overview

The `sld_engine` module exports three public predicates:

```prolog
sld_solve/1
sld_solve_limited/3
sld_trace/4
```

### 5.1. `sld_solve/1`

```prolog
sld_solve(+Query).
```

Resolves supported logical queries.

It uses Prolog's unification and backtracking mechanisms.

It does not impose a configurable maximum depth.

### 5.2. `sld_solve_limited/3`

```prolog
sld_solve_limited(+Query, +MaxDepth, -Outcome).
```

Explores supported resolution branches using a configurable maximum depth.

The documented terminal outcomes are:

```prolog
success
failure
cutoff
```

### 5.3. `sld_trace/4`

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

Generates the chronological resolution trace and successful-answer information.

Resolution events use:

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

Successful answers use:

```prolog
answer(Path, Bindings).
```

Variable substitutions use:

```prolog
binding(VariableName, Value).
```

The principal integration interface for Part B is `sld_trace/4`.

---

# INDIVIDUAL FUNCTIONAL DEMONSTRATIONS

## 6. Commitment 1 - SLD Meta-Interpreter

### 6.1. Approved Objective

Implement a meta-interpreter in SWI-Prolog capable of executing supported queries over facts and definite Horn-clause rules.

### 6.2. What This Demonstration Verifies

This demonstration verifies:

- Fact resolution.
- Rule resolution.
- Recursive rule execution.
- Multiple successful solutions.
- The use of the `sld_solve/1` predicate.

### 6.3. Demonstration Command

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X,sld_engine:sld_solve(parent(ana,X)),Facts),findall(Y,sld_engine:sld_solve(ancestor(ana,Y)),Rules),format('~n=== PART A: META-INTERPRETER ===~n~nFacts - parent/2   : ~q~nRules - ancestor/2 : ~q~n~n',[Facts,Rules]),Facts==[luis,marta],Rules==[luis,marta,sofia,diego],format('RESULT: PASSED~n',[])" -t halt
```

### 6.4. Verified Output

```text
=== PART A: META-INTERPRETER ===

Facts - parent/2   : [luis,marta]
Rules - ancestor/2 : [luis,marta,sofia,diego]

RESULT: PASSED
```

### 6.5. Interpretation

The first query resolves facts using:

```prolog
parent(ana, X)
```

It finds:

```prolog
X = luis
X = marta
```

The second query resolves rules using:

```prolog
ancestor(ana, X)
```

It finds four successful solutions.

### 6.6. What Emmanuel Should Explain

The meta-interpreter resolves queries using the program's facts and rules.

It selects goals, finds applicable clauses, and uses Prolog unification to obtain substitutions.

When several alternatives are available, Prolog backtracking allows additional solutions to be found.

### 6.7. Saved Evidence

```text
docs/evidence/engine/01_meta_interpreter.txt
```

### 6.8. Verification Status

```text
RESULT: PASSED
Exit code: 0
```

---

## 7. Commitment 2 - Goal Resolution and Unification

### 7.1. Approved Objective

Process queries goal by goal, select applicable clauses, and use unification to determine successful substitutions.

### 7.2. What This Demonstration Verifies

This demonstration verifies:

- Leftmost goal selection.
- Conjunctions.
- Clause application.
- Term unification.
- Shared variable substitutions.
- Multiple successful answers.
- Variable aliasing.

### 7.3. Demonstration A - Conjunction and Shared Variables

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(7)" -t halt
```

### 7.4. Query

```prolog
(parent(ana, X), parent(X, Y))
```

### 7.5. Verified Results

| Metric | Recorded result |
|---|---:|
| Expected answers | 2 |
| Observed answers | 2 |
| Resolution events | 8 |
| Backtracking events | 1 |
| Final result | PASSED |

### 7.6. Successful Solutions

```prolog
X = luis,
Y = sofia.
```

```prolog
X = marta,
Y = diego.
```

### 7.7. Explanation

The engine first resolves:

```prolog
parent(ana, X)
```

It can unify with:

```prolog
parent(ana, luis)
```

The substitution is:

```prolog
X = luis
```

The remaining goal becomes:

```prolog
parent(luis, Y)
```

This produces:

```prolog
Y = sofia
```

Through backtracking, the engine also explores:

```prolog
X = marta
```

The second goal then produces:

```prolog
Y = diego
```

This demonstrates that substitutions obtained from one goal are preserved within the same resolution branch.

### 7.8. Saved Evidence

```text
docs/evidence/engine/02_goal_unification.txt
```

### 7.9. Demonstration B - Variable Aliasing

The engine also distinguishes aliased variables from independent variables.

Execute:

```cmd
swipl -q -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(aliased_pair(_,_),1,_,[answer(_,Aliased)]),sld_engine:sld_trace(independent_pair(_,_),1,_,[answer(_,Independent)]),format('~n=== VARIABLE UNIFICATION ===~n~nAliased variables     : ~q~nIndependent variables : ~q~n',[Aliased,Independent])" -t halt
```

### 7.10. Verified Output

```text
=== VARIABLE UNIFICATION ===

Aliased variables     : [binding("V1","_"),binding("V2","alias(V1)")]
Independent variables : [binding("V1","_"),binding("V2","_")]
```

### 7.11. Aliasing Explanation

An alias occurs when two variables refer to the same logical variable.

For example:

```prolog
aliased_pair(X, X).
```

The query variables become aliases even if neither receives a concrete value.

The trace uses:

```prolog
binding("V2", "alias(V1)")
```

to record that relationship.

### 7.12. Independent Variables

The representation:

```prolog
[
    binding("V1", "_"),
    binding("V2", "_")
]
```

indicates that both tracked variables remain unbound without an alias relationship recorded between them.

### 7.13. Saved Aliasing Evidence

```text
docs/evidence/engine/02_variable_aliasing.txt
docs/evidence/engine/02_alias_tests.txt
```

### 7.14. What Emmanuel Should Explain

Unification can assign concrete values or establish relationships between variables.

The trace must distinguish independent unbound variables from variables that have become aliases.

This matters because the tree-building component needs accurate substitution information.

### 7.15. Verification Status

The conjunction demonstration passed.

The aliasing output was verified.

The three automated aliasing tests also passed.

---

## 8. Commitment 3 - Recursion and Backtracking

### 8.1. Approved Objective

Resolve recursive queries, explore alternatives through backtracking, obtain multiple solutions, and recognize unsuccessful queries.

This commitment is demonstrated through three separate scenarios.

---

### 8.2. Demonstration A - Backtracking After Failure

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(8)" -t halt
```

### 8.3. Query

```prolog
(parent(ana, X), parent(X, diego))
```

### 8.4. Verified Results

| Metric | Recorded result |
|---|---:|
| Resolution events | 7 |
| Successful answers | 1 |
| Failed branches | 1 |
| Backtracking events | 1 |
| Final result | PASSED |

### 8.5. Explanation

The first alternative produces:

```prolog
X = luis
```

The remaining goal is:

```prolog
parent(luis, diego)
```

This fails.

The engine then backtracks and explores another alternative:

```prolog
X = marta
```

The remaining goal becomes:

```prolog
parent(marta, diego)
```

This succeeds.

### 8.6. Saved Evidence

```text
docs/evidence/engine/03_backtracking.txt
```

---

### 8.7. Demonstration B - Recursive Resolution

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(9)" -t halt
```

### 8.8. Query

```prolog
ancestor(ana, X)
```

### 8.9. Verified Results

| Metric | Recorded result |
|---|---:|
| Resolution events | 26 |
| Successful answers | 4 |
| Depth cutoffs | 2 |
| Backtracking events | 5 |
| Final result | PASSED |

### 8.10. Successful Answers

```text
luis
marta
sofia
diego
```

### 8.11. Explanation

The engine resolves the recursive ancestor rules.

It explores direct ancestor relationships and additional generations.

Backtracking allows alternative clauses and recursive branches to be explored.

### 8.12. Saved Evidence

```text
docs/evidence/engine/03_recursion.txt
```

---

### 8.13. Demonstration C - Failed Query

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(4)" -t halt
```

### 8.14. Verified Results

| Metric | Recorded result |
|---|---:|
| Resolution events | 2 |
| Successful answers | 0 |
| Failed branches | 1 |
| Depth cutoffs | 0 |
| Final result | PASSED |

### 8.15. Explanation

The selected goal cannot be satisfied using the available applicable clauses.

The engine records a logical failure.

There are no successful answers.

No depth cutoff occurs in this case.

### 8.16. Saved Evidence

```text
docs/evidence/engine/03_failed_query.txt
```

### 8.17. What Emmanuel Should Explain

Recursion allows the engine to process rules that introduce additional goals of the same predicate.

Backtracking allows the engine to explore alternative clauses.

A failed branch does not necessarily mean that all alternatives fail.

The engine can continue exploring and may find another successful branch.

---

## 9. Commitment 4 - Configurable Depth Control

### 9.1. Approved Objective

Implement a configurable depth limit to control recursive searches and prevent individual branches from expanding indefinitely.

### 9.2. Demonstration A - Depth Cutoff

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(11)" -t halt
```

### 9.3. Verified Results

| Metric | Recorded result |
|---|---:|
| Maximum depth | 3 |
| Successful answers | 0 |
| Failed branches | 0 |
| Depth cutoffs | 1 |
| Final result | PASSED |

### 9.4. Explanation

The recursive predicate continues expanding.

The engine stops the unresolved branch when the configured maximum depth is reached.

The terminal result is a cutoff.

### 9.5. Saved Evidence

```text
docs/evidence/engine/04_depth_cutoff.txt
```

---

### 9.6. Demonstration B - Different Maximum Depths

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(O,sld_engine:sld_solve_limited(ancestor(ana,_),2,O),D2),findall(O,sld_engine:sld_solve_limited(ancestor(ana,_),4,O),D4),format('~n=== CONFIGURABLE DEPTH CONTROL ===~n~nMaximum depth 2 : ~q~nMaximum depth 4 : ~q~n~n',[D2,D4]),D2==[success,success,cutoff,cutoff],D4==[success,success,success,cutoff,success,cutoff],format('RESULT: PASSED~n',[])" -t halt
```

### 9.7. Verified Output

```text
=== CONFIGURABLE DEPTH CONTROL ===

Maximum depth 2 : [success,success,cutoff,cutoff]
Maximum depth 4 : [success,success,success,cutoff,success,cutoff]

RESULT: PASSED
```

### 9.8. Explanation

A greater depth limit permits additional recursive exploration.

The returned outcomes show successful branches and branches stopped by the depth limit.

### 9.9. Failure Versus Cutoff

| Outcome | Meaning |
|---|---|
| `failure` | The selected goal cannot be satisfied in the explored branch. |
| `cutoff` | Further exploration is prevented by the configured maximum depth. |

A cutoff does not prove that a query is logically false.

A query that is unresolved at one depth may succeed at a greater depth.

### 9.10. Important Limitation

A configurable depth limit is not a global time limit.

It limits the number of clause applications along an individual resolution branch.

### 9.11. Saved Evidence

```text
docs/evidence/engine/04_configurable_depth.txt
```

### 9.12. What Emmanuel Should Explain

Depth control is useful when working with recursive rules.

It prevents a branch from exceeding the configured resolution depth.

The engine distinguishes a branch that logically fails from one that was not explored further because the depth limit was reached.

---

## 10. Commitment 5 - Structured Resolution Information

### 10.1. Approved Objective

Generate the information required for another component to record the resolution process and construct the SLD tree.

### 10.2. Public Interface

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

### 10.3. Resolution Event Structure

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

### 10.4. Event Fields

| Field | Meaning |
|---|---|
| `Sequence` | Chronological event number. |
| `Path` | Clause-alternative path. |
| `Depth` | Resolution depth. |
| `Action` | Resolution action. |
| `Goal` | Selected goal or relevant query snapshot. |
| `Clause` | Applied fact or rule snapshot. |
| `RemainingGoals` | Pending-goal snapshots. |
| `Bindings` | Tracked query-variable substitutions. |

### 10.5. Supported Actions

```prolog
start
apply
success
failure
cutoff
backtrack
```

### 10.6. Demonstration A - Structured Events and Answers

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(parent(ana,_),1,Steps,Answers),length(Steps,6),length(Answers,2),member(step(_,_,_,apply,_,_,_,_),Steps),member(step(_,_,_,backtrack,_,_,_,_),Steps),format('~n=== STRUCTURED SLD EVENTS (step/8) ===~n',[]),forall(member(E,Steps),format('~q~n',[E])),format('~n=== SOLUTIONS (answer/2) ===~n',[]),forall(member(A,Answers),format('~q~n',[A])),format('~nRESULT: PASSED~n',[])" -t halt
```

### 10.7. Verified Events

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

### 10.8. Verified Answers

```prolog
answer([1],[binding("V1","luis")])
```

```prolog
answer([2],[binding("V1","marta")])
```

### 10.9. Interpretation

The trace contains:

- Six chronological resolution events.
- Two successful answers.
- Applied clauses.
- Resolution paths.
- Variable-binding snapshots.
- A backtracking event.

### 10.10. Saved Evidence

```text
docs/evidence/engine/05_trace_interface.txt
```

---

### 10.11. Demonstration B - Failure and Cutoff Events

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(parent(diego,_),1,FS,FA),sld_engine:sld_trace(endless,3,CS,CA),FA==[],CA==[],member(F,FS),F=step(_,_,_,failure,_,_,_,_),member(C,CS),C=step(_,_,_,cutoff,_,_,_,_),format('~n=== LOGICAL FAILURE EVENT ===~n~q~n~n=== DEPTH CUTOFF EVENT ===~n~q~n~nRESULT: PASSED~n',[F,C])" -t halt
```

### 10.12. Verified Failure Event

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

### 10.13. Verified Cutoff Event

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

### 10.14. Saved Evidence

```text
docs/evidence/engine/05_failure_cutoff_interface.txt
```

### 10.15. Verify the Structured Event Contract

Execute the seven independent tests of the public `step/8` record:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_step_contract_tests.pl -g "run_tests([sld_step_contract])" -t halt
```

The recorded execution passed seven out of seven tests with exit code `0`. It verifies the initial event, applied fact and rule clauses, remaining goals, bindings, logical failure, depth cutoff, and backtracking.

The corresponding evidence is stored in:

```text
docs/evidence/engine/05_step_contract_tests.txt
```

### 10.16. What Emmanuel Should Explain

The resolution engine does not construct the tree directly.

It produces events and successful-answer records describing the resolution process.

Roy's component is responsible for transforming those records into a tree hierarchy.

The existence of this interface does not establish that the actual Part B integration has already been tested successfully.

---

## 11. Commitment 6 - Individual Automated Tests

### 11.1. Approved Objective

Develop tests verifying the meta-interpreter with facts, rules, successful queries, unsuccessful queries, recursion, and multiple solutions.

### 11.2. Automated Test Suites

| Suite | File | Tests | Recorded result |
|---|---|---:|---|
| Basic SLD engine | `tests/engine/sld_engine_tests.pl` | 14 | 14/14 passed |
| Resolution tracing | `tests/engine/sld_trace_tests.pl` | 17 | 17/17 passed |
| Variable aliasing | `tests/engine/sld_alias_tests.pl` | 3 | 3/3 passed |
| Structured event contract | `tests/engine/sld_step_contract_tests.pl` | 7 | 7/7 passed |
| **Total** | **Four suites** | **41** | **41/41 passed** |

### 11.3. Execute All Automated Tests

Run:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt
```

### 11.4. Check the Exit Code

Immediately execute:

```cmd
echo %ERRORLEVEL%
```

### 11.5. Recorded Result

```text
41/41 tests passed
Exit code: 0
```

### 11.6. Test Coverage

The test suites verify behaviors associated with:

- Facts.
- Rules.
- Successful queries.
- Unsuccessful queries.
- Conjunctions.
- Unification.
- Shared substitutions.
- Recursive resolution.
- Backtracking.
- Multiple solutions.
- Configurable depth limits.
- Trace generation.
- Successful answers.
- Failed branches.
- Depth cutoffs.
- Variable aliasing.
- Independent unbound variables.
- Structured `step/8` events, including fact and rule applications, remaining goals, failures, cutoffs, and backtracking.

### 11.7. Saved Evidence

```text
docs/evidence/engine/automated_tests.txt
docs/evidence/engine/05_step_contract_tests.txt
```

### 11.8. What Emmanuel Should Explain

The automated tests provide repeatable verification of the logical-resolution engine.

They supplement the individual demonstrations.

The twelve demonstration cases verify answer counts and expected variable bindings, plus scenario-specific resolution events and chronological steps.

The four PLUnit suites provide additional independent checks, including seven direct tests of the public `step/8` contract.

---

# GENERAL DEMONSTRATION AND EVIDENCE

## 12. All Twelve Demonstration Cases

### 12.1. Purpose

The combined demonstration verifies answer counts, expected variable bindings, and required resolution events for twelve predefined scenarios.

### 12.2. Command

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt
```

### 12.3. Recorded Results

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

### 12.4. Overall Result

```text
Total passed: 12 / 12
```

The recorded process returned:

```text
Exit code: 0
```

### 12.5. Important Interpretation

The `run_all` command prints the compact summary of all twelve cases.

It does not print twelve complete detailed resolution traces.

The detailed execution of a particular case is obtained with:

```prolog
sld_demo_runner:run_case(N).
```

### 12.6. Verification Scope

The combined demonstration verifies expected answer counts, variable bindings, chronological step numbering, and required events for specific scenarios, including logical failure, recursion, backtracking, and depth cutoff.

The seven dedicated `step/8` contract tests and the other PLUnit suites provide further independent checks of individual event fields.

These checks cover the supported educational subset and demonstration scenarios; they do not prove correctness for arbitrary Prolog programs or establish integration with Parts B and C.

---

## 13. Organized Console Output

### 13.1. Detailed Case Mode

The command:

```prolog
sld_demo_runner:run_case(N).
```

displays a detailed report divided into readable sections.

### 13.2. Case Information

The report identifies:

- Case number.
- Scenario description.
- Query.
- Maximum depth.
- Expected answers.
- Observed answers.

### 13.3. Resolution Trace

The trace presents each recorded event separately.

Relevant information includes:

- Step number.
- Resolution action.
- Path.
- Depth.
- Selected goal.
- Applied clause.
- Remaining goals.
- Variable bindings.

### 13.4. Successful Answers

The answers are presented in a table containing:

- Answer number.
- Resolution path.
- Variable bindings.

### 13.5. Execution Summary

The summary includes:

- Recorded steps.
- Successful answers.
- Successful branches.
- Failed branches.
- Depth cutoffs.
- Backtracking events.

### 13.6. Final Result

The final section reports whether the expected and observed answer counts, variable bindings, chronological steps, and required scenario events all pass verification.

Example:

```text
RESULT: PASSED
```

### 13.7. Combined Summary Mode

The command:

```prolog
sld_demo_runner:run_all.
```

uses a compact table for the twelve cases.

It avoids printing every detailed trace during the combined demonstration.

### 13.8. Presentation Benefit

The organized reports help explain logical resolution without requiring the audience to interpret raw Prolog terms throughout the entire presentation.

They remain console reports for Part A.

They are not the graphical SLD tree visualizer.

---

## 14. Saved Evidence Files

All files in this section are located under:

```text
docs/evidence/engine/
```

### 14.1. Evidence by Approved Commitment

| Commitment | Evidence |
|---|---|
| 1. Meta-interpreter | `01_meta_interpreter.txt` |
| 2. Goal resolution and unification | `02_goal_unification.txt`, `02_variable_aliasing.txt`, `02_alias_tests.txt` |
| 3. Recursion and backtracking | `03_backtracking.txt`, `03_recursion.txt`, `03_failed_query.txt` |
| 4. Configurable depth control | `04_configurable_depth.txt`, `04_depth_cutoff.txt` |
| 5. Resolution information | `05_trace_interface.txt`, `05_failure_cutoff_interface.txt`, `05_step_contract_tests.txt` |
| 6. Individual tests | `automated_tests.txt`, `demo_12_cases_output.txt` |

### 14.2. Additional Evidence

The directory also contains:

```text
basic_resolution.txt
recursion_depth.txt
sld_trace.txt
```

These files provide earlier evidence of basic resolution, recursion, depth control, and tracing.

### 14.3. Evidence Inventory

For descriptions of the complete evidence directory, consult:

```text
docs/evidence/engine/README.md
```

### 14.4. Important Evidence Rule

Saved logs are records of previous executions.

They should be regenerated when relevant source code or demonstration behavior changes.

A saved PASS result should not replace testing the actual current implementation before the final presentation.

---

## 15. Save and Verify Automated Test Evidence

### 15.1. Save the Test Output

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt > docs\evidence\engine\automated_tests.txt 2>&1
```

### 15.2. Check the Exit Code

Immediately execute:

```cmd
echo %ERRORLEVEL%
```

### 15.3. Verify the Final Test

```cmd
findstr /L /C:"[41/41]" docs\evidence\engine\automated_tests.txt
```

### 15.4. Inspect the Complete Evidence

```cmd
type docs\evidence\engine\automated_tests.txt
```

The recorded successful execution completed all 41 tests.

---

## 16. Save and Verify the Twelve-Case Summary

### 16.1. Save the Output

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt > docs\evidence\engine\demo_12_cases_output.txt 2>&1
```

### 16.2. Check the Exit Code

Immediately execute:

```cmd
echo %ERRORLEVEL%
```

### 16.3. Verify the Overall Result

```cmd
findstr /C:"Total passed:" docs\evidence\engine\demo_12_cases_output.txt
```

The recorded result is:

```text
Total passed: 12 / 12
```

### 16.4. Inspect the Saved Output

```cmd
type docs\evidence\engine\demo_12_cases_output.txt
```

### 16.5. Important Note

The current saved `run_all` output contains the compact twelve-case summary.

The detailed individual traces are provided by `run_case(N)` and the corresponding individual evidence files.

---

## 17. Technical Explanation of the Meta-Interpreter

The following steps summarize how the logical resolution engine works.

### Step 1 - Receive the Query

The engine receives a supported Prolog query.

Example:

```prolog
parent(ana, X)
```

### Step 2 - Prepare Pending Goals

The query is represented as a sequence of goals.

A conjunction contains several pending goals.

### Step 3 - Select the Leftmost Goal

The engine selects the first pending goal.

This follows the leftmost selection strategy.

### Step 4 - Find Applicable Clauses

The engine searches for facts or rules compatible with the selected goal.

### Step 5 - Perform Unification

The selected goal is unified with a compatible clause head.

SWI-Prolog computes the corresponding substitutions.

### Step 6 - Process the Clause Body

If a rule is applied, its body goals replace the selected goal.

The remaining query goals are preserved.

### Step 7 - Continue Resolution

The engine recursively processes the resulting pending goals.

### Step 8 - Explore Alternatives

When several applicable clauses exist, the engine can explore them through Prolog backtracking.

### Step 9 - Apply Depth Control

When a maximum depth is configured, further clause applications are prevented once the limit is reached.

An unresolved branch can be reported as a cutoff.

### Step 10 - Record Resolution Events

The trace mechanism records the relevant resolution information.

### Step 11 - Record Successful Answers

Successful branches generate:

```prolog
answer(Path, Bindings).
```

### Step 12 - Provide the Information to Part B

The `sld_trace/4` predicate returns the events and answers.

Roy's component is responsible for using them to construct the SLD tree.

---

## 18. Known Limitations

The engine supports an educational subset of Prolog.

It does not provide general interpretation of:

- Cuts (`!`).
- Negation-as-failure.
- General disjunction.
- Arbitrary built-in predicates.
- General arithmetic evaluation.
- Side-effecting operations.
- Dynamic database modifications.
- The complete Prolog module system.

Additional limitations include:

1. Supported program clauses are obtained from the `user` module.
2. `sld_solve/1` does not enforce a configurable maximum depth.
3. An unrestricted recursive query may fail to terminate.
4. Depth-limited resolution is not a global execution-time limit.
5. A depth limit does not impose a maximum total trace size.
6. A cutoff does not establish logical falsity.
7. Trace variable names are generated identifiers.
8. Goal and clause representations are textual snapshots.
9. Alias representation focuses on tracked original query variables that remain unbound.
10. The trace does not serialize every possible shared-variable relationship in arbitrary nested terms.
11. Part A does not construct the final tree hierarchy.
12. Part A does not export the tree as JSON.
13. Part A does not implement the browser-based graphical visualizer.

These limitations define the approved educational scope.

---

## 19. Hand-Off to Part B

### 19.1. Integration Interface

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

### 19.2. Resolution Events

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

### 19.3. Successful Answers

```prolog
answer(Path, Bindings).
```

### 19.4. Variable Substitutions

```prolog
binding(VariableName, Value).
```

### 19.5. Information Provided by Part A

The engine provides:

1. Chronological resolution events.
2. Resolution paths.
3. Resolution depth.
4. Selected goals.
5. Applied clauses.
6. Remaining goals.
7. Variable-binding snapshots.
8. Alias references.
9. Successful answers.
10. Failed branches.
11. Depth cutoffs.
12. Backtracking events.

### 19.6. Roy's Responsibility

Roy must:

1. Consume the real resolution information.
2. Construct the logical tree hierarchy.
3. Preserve parent-child relationships.
4. Identify alternative branches.
5. Represent successful and failed branches.
6. Represent depth-limited branches.
7. Preserve substitutions.
8. Preserve alias information.
9. Associate successful answers with the appropriate branches.
10. Export the completed tree as JSON.

### 19.7. Keynell's Responsibility

Keynell must consume the JSON generated by Roy and display the resulting tree using HTML and JavaScript.

### 19.8. Current Integration Status

Part A's individual tests and demonstrations passed in the recorded verification.

A real integration test using Roy's actual Part B implementation is still required before claiming completed Part A-B integration.

---

## 20. Suggested Individual Defense - Spanish

This section provides a suggested oral explanation for Emmanuel's individual academic presentation.

The technical documentation remains in English, while this optional oral script is provided in Spanish.

### 20.1. Introduction

> Mi aporte individual es la Parte A del proyecto: el metaintérprete y motor lógico de resolución SLD desarrollado en SWI-Prolog.
>
> Su función es resolver consultas sobre hechos y reglas utilizando los mecanismos de resolución lógica, unificación, recursión y backtracking de Prolog.
>
> Además, el motor registra los acontecimientos de la resolución para que posteriormente el componente de Roy pueda construir el árbol SLD.

### 20.2. Meta-Interpreter

> El metaintérprete recibe una consulta y procesa las metas que debe resolver.
>
> Selecciona la primera meta pendiente y busca un hecho o una regla que pueda unificarse con ella.
>
> Si encuentra una regla, incorpora las metas de su cuerpo y continúa el proceso.

### 20.3. Unification

> La unificación permite relacionar la meta seleccionada con el encabezado de un hecho o una regla.
>
> Por ejemplo, al consultar los hijos de Ana, el motor encuentra a Luis y Marta.
>
> Cuando varias metas comparten variables, las sustituciones obtenidas se utilizan en las metas siguientes de la misma rama.

### 20.4. Recursion and Backtracking

> La recursión permite resolver reglas que vuelven a utilizar el mismo predicado, como ocurre con los antepasados.
>
> El backtracking permite regresar a una decisión anterior y explorar otra cláusula.
>
> Esto es útil cuando una alternativa falla o cuando queremos encontrar más soluciones.

### 20.5. Depth Control

> Implementé un límite de profundidad configurable para controlar la expansión de las ramas recursivas.
>
> El motor distingue entre un fallo lógico y un corte por profundidad.
>
> Un fallo indica que la meta no se pudo satisfacer en la rama explorada.
>
> Un corte significa que se alcanzó el límite configurado y no se continuó explorando esa rama.

### 20.6. Variable Aliasing

> También mejoré la representación de las variables que se unifican entre sí.
>
> El motor ahora distingue dos variables independientes de dos variables que hacen referencia a la misma variable lógica.
>
> Para representar esa relación utiliza una referencia como `alias(V1)` dentro de las sustituciones registradas.

### 20.7. Resolution Events

> El motor genera un registro estructurado de los acontecimientos de resolución.
>
> Cada evento incluye información como la meta seleccionada, la cláusula aplicada, la profundidad, la ruta y las sustituciones de variables.
>
> Esta información se obtiene mediante `sld_trace/4`.
>
> Roy utilizará esos datos para construir la estructura del árbol SLD y exportarla a JSON.

### 20.8. Tests and Evidence

> Para verificar mi aporte ejecuté 41 pruebas automatizadas y 12 casos de demostración.
>
> Todas las pruebas y demostraciones pasaron en las ejecuciones registradas.
>
> También preparé evidencias individuales para demostrar cada uno de los seis puntos que me corresponden.
>
> Las salidas se muestran de manera organizada para facilitar la explicación de cada proceso.

### 20.9. Responsibility Boundaries

> Mi responsabilidad corresponde al motor lógico SLD y a la información que genera.
>
> La construcción del árbol y su exportación a JSON le corresponden a Roy.
>
> La visualización gráfica mediante HTML y JavaScript le corresponde a Keynell.
>
> Por eso, mi componente prepara los datos lógicos necesarios, pero no implementa directamente esas otras partes.

### 20.10. Closing Statement

> En resumen, desarrollé un metaintérprete en SWI-Prolog que resuelve consultas, maneja unificación, recursión y backtracking, controla la profundidad y registra el proceso de resolución.
>
> Su funcionamiento fue verificado mediante pruebas automatizadas y demostraciones reproducibles.
>
> Esta información constituye la base lógica que necesita el componente encargado de construir el árbol SLD.

This script is a preparation aid.

Emmanuel should understand the actual implementation and be able to answer technical questions independently.

---

## 21. Final Individual Demonstration Checklist

### 21.1. Environment

- [ ] SWI-Prolog is installed.
- [ ] The repository directory is correct.
- [ ] The current branch is identified.
- [ ] The required source files are available.
- [ ] The demonstration runner is available.

### 21.2. Commitment 1

- [ ] Demonstrate fact resolution.
- [ ] Demonstrate rule resolution.
- [ ] Explain `sld_solve/1`.
- [ ] Show the recorded meta-interpreter evidence.

### 21.3. Commitment 2

- [ ] Demonstrate a conjunction.
- [ ] Explain leftmost goal selection.
- [ ] Explain unification.
- [ ] Explain shared substitutions.
- [ ] Demonstrate variable aliasing.
- [ ] Distinguish independent variables from aliases.

### 21.4. Commitment 3

- [ ] Demonstrate backtracking after failure.
- [ ] Demonstrate recursive resolution.
- [ ] Demonstrate an unsuccessful query.
- [ ] Explain multiple solutions.

### 21.5. Commitment 4

- [ ] Demonstrate a depth cutoff.
- [ ] Compare different depth limits.
- [ ] Distinguish failure from cutoff.
- [ ] Explain the limitations of depth control.

### 21.6. Commitment 5

- [ ] Explain `sld_trace/4`.
- [ ] Explain `step/8`.
- [ ] Explain `answer/2`.
- [ ] Explain `binding/2`.
- [ ] Demonstrate structured events.
- [ ] Demonstrate failure and cutoff events.
- [ ] Execute and explain the seven `step/8` contract tests.
- [ ] Explain what information Roy receives.

### 21.7. Commitment 6

- [ ] Execute all 41 automated tests.
- [ ] Check the process exit code.
- [ ] Execute all twelve demonstration cases.
- [ ] Verify `Total passed: 12 / 12`.
- [ ] Explain the saved evidence.

### 21.8. Required Deliverables

- [ ] Present the meta-interpreter module.
- [ ] Present the public resolution predicates.
- [ ] Present the test cases.
- [ ] Present the execution evidence.
- [ ] Explain the technical design.
- [ ] Explain the known limitations.
- [ ] Demonstrate the engine individually.
- [ ] Explain the interface provided to Part B.

### 21.9. Integration Boundary

- [ ] Clearly identify Emmanuel's Part A.
- [ ] Clearly identify Roy's Part B.
- [ ] Clearly identify Keynell's Part C.
- [ ] Do not claim unverified integration.
- [ ] Perform joint integration tests when the actual Part B component is available.

---

## 22. Recorded Verification Summary

| Item | Recorded status |
|---|---|
| SLD meta-interpreter | Implemented and individually tested |
| Fact resolution | Verified |
| Rule resolution | Verified |
| Conjunctions | Verified |
| Unification | Verified |
| Variable substitutions | Verified |
| Variable aliasing | Verified |
| Independent unbound variables | Verified |
| Recursive resolution | Verified |
| Backtracking | Verified |
| Multiple solutions | Verified |
| Failed queries | Verified |
| Configurable depth control | Verified |
| Depth cutoffs | Verified |
| Structured resolution events | Verified |
| Successful-answer records | Verified |
| Failure and cutoff events | Verified |
| Structured event contract tests | **7/7 passed** |
| Automated tests | **41/41 passed** |
| Demonstration cases | **12/12 passed** |
| Automated test exit code | **0** |
| Demonstration exit code | **0** |
| Organized console output | Verified |
| Individual evidence files | Generated |
| Original engine integration into `main` | PR #2, merge commit `d8a1117` |
| Additional evidence-branch changes | Locally verified; separate merge not established |
| Actual Part A-B integration | Not yet verified by the recorded Part A evidence |
| Part B tree construction | Roy's responsibility |
| Part C graphical visualization | Keynell's responsibility |

---

## 23. Final Demonstration Statement

The Part A SLD meta-interpreter developed by Emmanuel Núñez Jiménez implements logical resolution for a defined educational subset of Prolog.

The engine:

- Resolves facts and definite Horn-clause rules.
- Processes queries goal by goal.
- Selects applicable clauses.
- Performs unification.
- Preserves variable substitutions.
- Handles recursive resolution.
- Explores alternatives through backtracking.
- Produces multiple successful answers.
- Recognizes unsuccessful queries.
- Applies configurable resolution-depth limits.
- Distinguishes logical failures from depth cutoffs.
- Records structured resolution events.
- Represents successful answers.
- Preserves tested alias relationships between tracked unbound query variables.

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

These results provide the foundation for Emmanuel's individual explanation and demonstration.

They do not establish that the complete three-component SLD Resolution Tree Visualizer has already been integrated.

The remaining integration work must preserve the approved responsibilities of Emmanuel Núñez Jiménez, Roy Arias Mejía, and Keynell Molina Mora.

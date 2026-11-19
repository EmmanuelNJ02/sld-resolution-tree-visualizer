# SLD Resolution Engine - Individual Demonstration Guide

## 1. Project Information

- Project: SLD Resolution Tree Visualizer
- Course: EIF400 - Programming Paradigms
- Group: 04-10am
- Instructor: Carlos Loria-Saenz
- Student: Emmanuel Nunez Jimenez
- Individual Contribution: Part A - SLD Meta-Interpreter and Logical Resolution Engine
- Programming Language: SWI-Prolog
- Tested Version: SWI-Prolog 10.0.2
- Working Branch: feature/sld-meta-interpreter
- Latest Confirmed Commit: b9637fe

## 2. Demonstration Objective

The purpose of this demonstration is to verify and explain the individual implementation of the SLD resolution engine.

The demonstration covers:

1. Resolution of facts.
2. Resolution of definite Horn-clause rules.
3. Leftmost goal selection.
4. Unification and variable substitutions.
5. Conjunctions of goals.
6. Recursive resolution.
7. Backtracking and multiple solutions.
8. Failed queries.
9. Configurable depth limits.
10. Resolution trace generation.
11. Automated engine tests.

The implementation is limited to Part A.

SLD tree construction, JSON export, and graphical visualization belong to Parts B and C.

## 3. Public Engine Predicates

The module exports three public predicates:

    sld_solve/1
    sld_solve_limited/3
    sld_trace/4

### 3.1. sld_solve/1

Resolves queries using SLD resolution.

It supports facts, rules, conjunctions, recursion, unification, and backtracking.

It does not enforce a depth limit.

### 3.2. sld_solve_limited/3

Resolves queries using a configurable maximum depth.

Possible terminal outcomes:

    success
    failure
    cutoff

The predicate can produce multiple outcomes through backtracking.

### 3.3. sld_trace/4

Generates chronological information about the resolution process.

Its interface is:

    sld_trace(+Query, +MaxDepth, -Steps, -Answers).

Steps contains resolution events.

Answers contains successful solutions and their variable substitutions.

## 4. Demonstration 1 - Facts and Multiple Solutions

### Objective

Demonstrate fact resolution, unification, and backtracking.

### Command

    swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X,sld_engine:sld_solve(parent(ana,X)),Xs),writeln(Xs),halt."

### Expected Result

    [luis,marta]

### Explanation

The query searches for the children of ana.

Two facts satisfy the selected goal.

The engine first obtains luis and then explores another applicable fact through backtracking.

This demonstrates multiple solutions and variable unification.

## 5. Demonstration 2 - Conjunction and Unification

### Objective

Demonstrate leftmost goal selection and shared variable substitutions.

### Command

    swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X-Y,sld_engine:sld_solve((parent(ana,X),parent(X,Y))),Pairs),writeln(Pairs),halt."

### Expected Result

    [luis-sofia,marta-diego]

### Explanation

The query contains two connected goals.

The engine resolves the leftmost goal first.

The substitution obtained for X is used when evaluating the second goal.

Two successful combinations are found:

    X = luis, Y = sofia
    X = marta, Y = diego

This demonstrates conjunction handling and unification between goals.

## 6. Demonstration 3 - Failed Query

### Objective

Demonstrate the detection of a query without solutions.

### Command

    swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X,sld_engine:sld_solve(parent(diego,X)),Xs),writeln(Xs),halt."

### Expected Result

    []

### Explanation

The query searches for children of diego.

No applicable clause satisfies the selected goal.

Therefore, the engine does not produce any successful solution.

## 7. Demonstration 4 - Recursive Resolution

### Objective

Demonstrate recursive rule resolution and multiple answers.

### Command

    swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X,sld_engine:sld_solve_limited(ancestor(ana,X),4,success),Xs),writeln(Xs),halt."

### Expected Result

    [luis,marta,sofia,diego]

### Explanation

The ancestor predicate includes recursive rules.

The engine resolves direct family relationships and continues exploring recursive alternatives.

The configurable depth limit allows recursive resolution while restricting branch expansion.

Four successful answers are obtained.

## 8. Demonstration 5 - Depth-Limit Control

### Objective

Demonstrate that an infinitely recursive branch can be stopped.

### Command

    swipl -q -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -g "findall(Status,sld_engine:sld_solve_limited(endless,3,Status),Statuses),writeln(Statuses),halt."

### Expected Result

    [cutoff]

### Explanation

The endless predicate calls itself recursively.

Without a depth limit, this branch could continue indefinitely.

With a maximum depth of three clause applications, the engine stops expanding the branch.

The result is cutoff.

A cutoff is different from a logical failure because the query was not explored beyond the configured limit.

## 9. Demonstration 6 - Resolution Tracing and Backtracking

### Objective

Demonstrate how the engine records the resolution process for Part B.

### Command

    swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace((parent(ana,X),parent(X,diego)),2,Steps,Answers),findall(Action,member(step(_,_,_,Action,_,_,_,_),Steps),Actions),writeln(Actions),writeln(Answers),halt."

### Expected Actions

    [start,apply,failure,backtrack,apply,apply,success]

### Expected Answer

    [answer([2,1],[binding(V1,marta)])]

### Explanation

The engine first selects a clause that produces X = luis.

The remaining goal cannot be satisfied.

The branch reports failure.

The engine then returns to the previous state through backtracking.

It explores another applicable clause and obtains X = marta.

The second branch succeeds.

The trace records the resolution actions and the successful variable substitution.

The resulting information can be consumed by Roy's tree construction module.

## 10. Resolution Step Structure

The engine generates resolution events using:

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

### Fields

- Sequence: Chronological event number.
- Path: Explored clause-choice positions.
- Depth: Number of clause applications.
- Action: Resolution event type.
- Goal: Selected goal.
- Clause: Applied fact or rule.
- RemainingGoals: Pending goals after the event.
- Bindings: Substitutions for the original query variables.

### Supported Actions

- start
- apply
- success
- failure
- cutoff
- backtrack

### Answer Format

Successful answers are represented using:

    answer(Path, Bindings)

For example:

    answer([1], [binding("V1", "luis")])

This information allows Part B to identify successful resolution branches and their associated substitutions.

## 11. Demonstration 7 - Automated Tests

### Objective

Verify the functionality of the engine and its resolution tracing interface.

### Command

    swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -g "run_tests([sld_engine,sld_trace])" -t halt

### Last Observed Result

    31/31 tests passed

### Test Distribution

- Basic SLD engine: 14 tests.
- SLD resolution tracing: 17 tests.

### Explanation

The tests verify:

- Successful queries.
- Failed queries.
- Facts and rules.
- Unification.
- Conjunctions.
- Recursion.
- Backtracking.
- Multiple solutions.
- Depth limits.
- Resolution outcomes.
- Chronological trace events.
- Variable substitutions.
- Independent alternative bindings.
- Invalid depth values.

The latest recorded execution completed with exit code 0 and without reported warnings.

## 12. Brief Technical Explanation

The SLD resolution engine is a meta-interpreter implemented in SWI-Prolog.

It processes queries by selecting the leftmost pending goal and searching for a fact or rule whose head can unify with that goal.

When a rule is applied, its body replaces the selected goal.

The engine continues resolving the remaining goals recursively.

Prolog's backtracking mechanism allows alternative clauses to be explored and multiple solutions to be obtained.

A configurable depth limit prevents individual recursive branches from expanding indefinitely.

Additionally, the trace generator records the selected goals, applied clauses, variable substitutions, resolution paths, and terminal outcomes.

This information is provided to Part B so that the corresponding module can construct the SLD resolution tree.

## 13. Known Limitations

The engine supports an educational subset of Prolog.

The current implementation does not provide general support for:

- Prolog cut.
- Negation-as-failure.
- Arbitrary built-in predicates.
- General arithmetic evaluation.
- Dynamic database modifications.
- Disjunction as a separate query construct.
- Complete Prolog language interpretation.

The basic sld_solve/1 predicate does not enforce a depth limit.

A depth cutoff does not imply logical falsity.

The engine does not construct the final tree or export JSON.

## 14. Integration Responsibilities

### Part A - Emmanuel Nunez Jimenez

Responsible for:

- SLD logical resolution.
- Unification.
- Recursive resolution.
- Backtracking.
- Depth-limit control.
- Resolution tracing.
- Individual tests and documentation.

### Part B - Roy Arias Mejia

Responsible for:

- Constructing the SLD tree.
- Registering node relationships.
- Representing successful and failed branches.
- Associating substitutions with branches.
- Exporting the tree as JSON.

### Part C - Keynell Molina Mora

Responsible for:

- Reading the JSON generated by Part B.
- Rendering the tree in the browser.
- Displaying nodes and connections.
- Showing goals, clauses, and substitutions.
- Supporting node inspection.

## 15. Demonstration Checklist

Before the individual demonstration:

1. Confirm that SWI-Prolog is installed.
2. Confirm that the example programs are available.
3. Confirm that sld_engine.pl loads correctly.
4. Execute the fact-resolution example.
5. Execute the conjunction example.
6. Execute the failed-query example.
7. Execute the recursive-resolution example.
8. Execute the depth-limit example.
9. Execute the resolution-tracing example.
10. Run the automated tests.
11. Explain the supported language subset.
12. Explain the separation of responsibilities between Parts A, B, and C.

## 16. Current Status

The individual SLD engine implementation and its automated tests have been completed.

The latest reported execution passed all 31 automated tests.

The technical documentation and execution evidence have been committed and pushed to the feature/sld-meta-interpreter branch.

The integration contract with Roy remains pending final validation.

A shared integration test must be executed once Part B is available.

The graphical visualization developed by Part C must be verified separately.

This demonstration guide supports the individual presentation and technical defense of Emmanuel Nunez Jimenez's contribution.

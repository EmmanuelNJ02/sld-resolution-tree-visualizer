# SLD Resolution Tree Visualizer

An educational **SLD (Selective Linear Definite Clause) Resolution Tree Visualizer**, developed as an instructor-approved additional academic project for the Programming Paradigms course (EIF400) at the National University of Costa Rica (UNA).

The project is designed to demonstrate how Prolog resolves logical queries using:

- Goal selection.
- Clause application.
- Term unification.
- Variable substitutions.
- Recursive rules.
- Backtracking.
- Multiple solutions.
- Failed resolution branches.
- Configurable depth limits.

The complete project is organized into three individually developed components:

1. An SLD meta-interpreter and logical resolution engine in SWI-Prolog.
2. An SLD tree-building component with JSON export.
3. A web-based graphical tree visualizer.

## Current Development Status

The original Part A resolution engine was integrated into `main` through pull request #2, merge commit `d8a1117`.

**Part B status:** Roy's SLD tree construction and JSON-export contribution was implemented and merged into `main` through pull request #3, merge commit `af0a610`. Its technical documentation is available in `docs/TREE_TECHNICAL.md` and `docs/TREE_JSON_FORMAT.md`.

Additional improvements were developed on:

```text
feature/engine-demo-evidence
```

These improvements include:

- Variable-aliasing representation.
- Additional variable-aliasing tests.
- Twelve demonstration cases.
- Organized console reports.
- Individual execution evidence.
- Structured `step/8` event-contract tests.
- Updated technical documentation.

The recorded individual verification of this development version completed successfully.

| Verification | Recorded result |
|---|---|
| Basic SLD engine tests | 14/14 passed |
| Resolution trace tests | 17/17 passed |
| Variable aliasing tests | 3/3 passed |
| Structured event contract tests | 7/7 passed |
| **Total automated tests** | **41/41 passed** |
| **Demonstration cases** | **12/12 passed** |
| Automated test exit code | **0** |
| Demonstration exit code | **0** |

**Recorded verification date:** November 19, 2026.

The additional Part A evidence-branch changes were committed as `458f96c` and pushed to `feature/engine-demo-evidence`. Their pull request still requires review and merging into `main`.

Integration with the actual Part B tree builder and Part C web visualizer has not been established by the recorded Part A evidence.

The project must not be considered fully integrated solely because the Part A tests passed.

---

## 1. Academic Information

| Field | Details |
|---|---|
| University | National University of Costa Rica (UNA) |
| School | School of Informatics |
| Course | EIF400 - Programming Paradigms |
| Academic term | Second Semester, 2026 |
| Group | 04-10am |
| Instructor | Carlos Loría-Sáenz |
| Project | Instructor-approved additional academic project |
| Main logical programming language | SWI-Prolog |
| Verified Part A environment | SWI-Prolog 10.0.2, Windows 64-bit |

---

## 2. Project Objective

The objective is to develop an educational visualizer that demonstrates the SLD resolution process used by Prolog.

The intended complete application will:

1. Receive supported Prolog programs and logical queries.
2. Resolve queries through an SLD meta-interpreter.
3. Record goal selection and clause application.
4. Preserve variable substitutions.
5. Record recursion and backtracking.
6. Identify successful branches.
7. Identify unsuccessful branches.
8. Identify depth-limited branches.
9. Construct the corresponding SLD resolution tree.
10. Export the tree as JSON.
11. Display the tree graphically in a web browser.
12. Support independent and reproducible verification.

The implementation is divided into three individual contributions.

Each student must be able to develop, test, explain, and defend the assigned component independently.

---

## 3. Approved Educational Scope

The Part A meta-interpreter uses SWI-Prolog's own logical mechanisms.

It does not implement a separate simulator of the complete Prolog language.

### 3.1. Supported Features

The educational resolution engine supports:

- Facts.
- Definite Horn-clause rules.
- Individual query goals.
- Conjunctions.
- The empty goal `true`.
- Leftmost goal selection.
- Applicable-clause selection.
- Term unification.
- Variable substitutions.
- Tracked query-variable aliasing.
- Recursive resolution.
- Backtracking.
- Multiple successful answers.
- Unsuccessful queries.
- Configurable resolution-depth limits.
- Explicit depth cutoffs.
- Chronological resolution events.
- Structured successful answers.

### 3.2. Outside the Supported Base Subset

The meta-interpreter does not generally support arbitrary interpreted use of:

- The cut operator (`!`).
- General negation-as-failure.
- General disjunction.
- Arbitrary built-in predicates.
- General arithmetic execution.
- Side-effecting operations.
- Dynamic database modifications.
- The complete Prolog module system.
- Full Prolog-language compatibility.

SWI-Prolog built-in predicates are used internally by the engine.

This does not mean that arbitrary built-in predicates are supported as goals in interpreted programs.

---

## 4. Team and Individual Responsibilities

The approved project is divided into three components with clearly defined responsibilities.

### 4.1. Part A - SLD Meta-Interpreter and Logical Resolution Engine

**Responsible: Emmanuel Núñez Jiménez**

Implementation language:

```text
SWI-Prolog
```

Main module:

```text
src/prolog/engine/sld_engine.pl
```

Emmanuel's individual responsibilities are:

1. Implement the SLD meta-interpreter.
2. Process queries goal by goal.
3. Select the leftmost pending goal.
4. Find applicable facts and rules.
5. Perform term unification.
6. Maintain variable substitutions.
7. Resolve conjunctions.
8. Handle recursive rules.
9. Explore alternatives through backtracking.
10. Produce multiple successful answers.
11. Recognize unsuccessful queries.
12. Enforce configurable depth limits.
13. Distinguish logical failure from depth cutoff.
14. Generate chronological resolution events.
15. Provide structured information to the tree builder.
16. Develop automated tests.
17. Generate reproducible execution evidence.
18. Document and defend the individual implementation.

#### Public Predicates

```prolog
sld_solve/1
sld_solve_limited/3
sld_trace/4
```

#### Recorded Verification

```text
Automated tests: 41/41 passed
Demonstration cases: 12/12 passed
Exit codes: 0
```

**Responsibility boundary:** Part A performs logical resolution and produces resolution information.

It does not construct the final SLD tree hierarchy, export the completed tree as JSON, or implement the graphical browser interface.

### 4.2. Part B - SLD Tree Construction and JSON Export

**Responsible: Roy Arias Mejía**

Part B is responsible for:

1. Consuming real resolution information produced by Part A.
2. Constructing the SLD tree hierarchy.
3. Organizing nodes and branches.
4. Preserving parent-child relationships.
5. Associating goals and clauses with tree nodes.
6. Recording variable substitutions.
7. Representing successful branches.
8. Representing failed branches.
9. Representing depth-limited branches.
10. Representing alternatives explored through backtracking.
11. Exporting the completed tree as JSON.
12. Developing independent tests and documentation.
13. Demonstrating and defending the component.

**Implementation status:** Part B was merged into `main` in pull request #3 (`af0a610`), including its own tree-construction, JSON-export, and integration-test files.

**Integration status:** The recorded Part A tests alone do not establish compatibility between Roy's merged implementation and the newer Part A evidence-branch changes. The combined tests must be executed before declaring the current two components integrated.

### 4.3. Part C - Web-Based SLD Tree Visualization

**Responsible: Keynell Molina Mora**

Part C is responsible for:

1. Consuming the JSON produced by Part B.
2. Implementing the web interface.
3. Displaying the complete SLD resolution tree.
4. Showing nodes and their connections.
5. Distinguishing successful and failed branches visually.
6. Displaying goals and selected clauses.
7. Displaying variable substitutions.
8. Providing information about individual nodes.
9. Developing visualization tests.
10. Demonstrating and defending the component.

**Implementation and browser verification:** The initial visualizer is available in `src/web/`. It loaded all six bundled Part B JSON examples in a browser; node counts, status labels, tree connections, and node-detail selection were checked. Start a local server from the repository root with `python -m http.server 8000`, then open `http://localhost:8000/src/web/`. See [docs/WEB_VISUALIZER.md](docs/WEB_VISUALIZER.md) for usage and limitations.

**Integration status:** This verifies the browser UI against the bundled JSON fixtures, not a fresh export from the newest Part A engine through Part B.

### 4.4. Individual Contribution Boundaries

| Component | Responsible student | Main deliverable |
|---|---|---|
| Part A | Emmanuel Núñez Jiménez | Logical SLD resolution engine and trace information |
| Part B | Roy Arias Mejía | SLD tree hierarchy and JSON export |
| Part C | Keynell Molina Mora | Graphical browser visualization |

Each contribution must remain individually identifiable and defensible.

---

## 5. Intended System Architecture

The complete project follows this logical data flow:

1. A Prolog program and query are provided.
2. Part A resolves the query.
3. Part A generates structured events and successful answers.
4. Part B consumes the resolution information.
5. Part B constructs the SLD tree.
6. Part B exports the tree as JSON.
7. Part C reads the JSON.
8. Part C displays the tree graphically.

### Component Interfaces

| Producer | Output | Consumer |
|---|---|---|
| Prolog program and query | Facts, rules, and logical goals | Part A |
| Part A | Resolution events and answers | Part B |
| Part B | JSON tree representation | Part C |
| Part C | Interactive graphical representation | User |

The public Part A interface is implemented and individually tested.

The actual integration between these components must be verified separately.

---

## 6. Part A Public API

The `sld_engine` module exports three predicates.

### 6.1. `sld_solve/1`

```prolog
sld_solve(+Query).
```

Resolves a supported query.

Prolog backtracking allows additional successful answers to be enumerated.

This predicate does not impose a configurable maximum depth.

### 6.2. `sld_solve_limited/3`

```prolog
sld_solve_limited(+Query, +MaxDepth, -Outcome).
```

Resolves a supported query using a configurable maximum depth.

Documented terminal outcomes include:

```prolog
success
failure
cutoff
```

A depth cutoff means that the configured limit prevented further exploration.

It does not prove that the original query is logically false.

### 6.3. `sld_trace/4`

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

This predicate is the principal public integration interface.

It produces:

- Chronological resolution events.
- Successful-answer records.
- Variable-substitution snapshots.
- Resolution paths.
- Branch-outcome information.

The returned information is intended for Part B.

---

## 7. Structured Resolution Events

Each recorded event uses:

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

### 7.1. Event Fields

| Field | Meaning |
|---|---|
| `Sequence` | Chronological event number. |
| `Path` | Clause-alternative path. |
| `Depth` | Resolution depth. |
| `Action` | Type of resolution event. |
| `Goal` | Selected goal or relevant query snapshot. |
| `Clause` | Applied fact or rule snapshot. |
| `RemainingGoals` | Pending-goal snapshots. |
| `Bindings` | Tracked original query-variable substitutions. |

### 7.2. Supported Actions

```prolog
start
apply
success
failure
cutoff
backtrack
```

| Action | Meaning |
|---|---|
| `start` | Begin resolution. |
| `apply` | Apply an applicable fact or rule. |
| `success` | Complete a successful branch. |
| `failure` | Record an unsuccessful branch. |
| `cutoff` | Stop an unresolved branch at the depth limit. |
| `backtrack` | Restore an earlier state to explore another alternative. |

### 7.3. Resolution Paths

The root path is:

```prolog
[]
```

Examples of alternative paths include:

```prolog
[1]
[2]
[1,1]
[1,2]
[2,1]
```

Paths represent clause choices made during resolution.

A path is not automatically a unique graphical tree-node identifier.

Part B is responsible for constructing the actual tree hierarchy.

---

## 8. Successful Answers and Variable Bindings

### 8.1. Successful Answers

Successful answers use:

```prolog
answer(Path, Bindings).
```

Example:

```prolog
answer(
    [1],
    [
        binding("V1", "luis")
    ]
).
```

### 8.2. Variable Bindings

The engine represents tracked substitutions using:

```prolog
binding(VariableName, Value).
```

Examples:

```prolog
binding("V1", "luis")
binding("V2", "marta")
binding("V3", "_")
```

Generated labels such as `V1` and `V2` correspond to variables tracked from the original query.

They do not necessarily preserve the original source-level variable names.

### 8.3. Variable Aliasing

Two variables can become references to the same logical variable while remaining unbound.

The engine can represent this relationship using:

```prolog
[
    binding("V1", "_"),
    binding("V2", "alias(V1)")
]
```

Independent unbound variables are represented as:

```prolog
[
    binding("V1", "_"),
    binding("V2", "_")
]
```

The distinction is relevant to the tree-building component.

### 8.4. Aliasing Limitation

The alias notation is a textual trace representation.

It preserves the tested relationships among tracked unbound query variables.

It is not a complete serialization of all possible variable-sharing relationships inside arbitrary nested terms.

### 8.5. Integration Requirement

Part B must preserve and correctly interpret the binding information generated by Part A.

This includes alias references such as:

```text
alias(V1)
```

The detailed contract is documented in:

[Part A Integration Interface](docs/ENGINE_INTERFACE.md)

---

## 9. Relevant Repository Structure

The following files are relevant to the verified Part A development work.

```text
sld-resolution-tree-visualizer/
|
|-- README.md
|
|-- docs/
|   |-- ENGINE_DEMO.md
|   |-- ENGINE_INTERFACE.md
|   |-- ENGINE_TECHNICAL.md
|   `-- evidence/
|       `-- engine/
|           |-- README.md
|           |-- 01_meta_interpreter.txt
|           |-- 02_alias_tests.txt
|           |-- 02_goal_unification.txt
|           |-- 02_variable_aliasing.txt
|           |-- 03_backtracking.txt
|           |-- 03_failed_query.txt
|           |-- 03_recursion.txt
|           |-- 04_configurable_depth.txt
|           |-- 04_depth_cutoff.txt
|           |-- 05_failure_cutoff_interface.txt
|           |-- 05_step_contract_tests.txt
|           |-- 05_trace_interface.txt
|           |-- automated_tests.txt
|           |-- basic_resolution.txt
|           |-- demo_12_cases_output.txt
|           |-- recursion_depth.txt
|           `-- sld_trace.txt
|
|-- examples/
|   |-- programs/
|   |   |-- alias_demo.pl
|   |   |-- family.pl
|   |   `-- recursive_loop.pl
|   `-- queries/
|       |-- sld_demo_cases.pl
|       `-- sld_demo_runner.pl
|
|-- src/
|   `-- prolog/
|       `-- engine/
|           `-- sld_engine.pl
|
`-- tests/
    `-- engine/
        |-- sld_alias_tests.pl
        |-- sld_engine_tests.pl
        |-- sld_step_contract_tests.pl
        `-- sld_trace_tests.pl
```

This listing focuses on the files used for Part A.

It is not intended to establish the existence or completion of all Part B, Part C, or shared integration files.

### 9.1. Part A Directory Responsibilities

| Directory | Purpose |
|---|---|
| `src/prolog/engine/` | SLD resolution engine. |
| `tests/engine/` | Automated engine, trace, aliasing, and structured-event contract tests. |
| `examples/programs/` | Supported Prolog example programs. |
| `examples/queries/` | Demonstration definitions and runner. |
| `docs/` | Technical documentation. |
| `docs/evidence/engine/` | Recorded execution evidence. |

---

## 10. Technologies and Prerequisites

### 10.1. Main Technologies

The intended project uses:

- SWI-Prolog for logical resolution.
- Git and GitHub for version control.
- JSON for tree-data interchange.
- HTML for the browser interface.
- CSS for visual styling.
- JavaScript for graphical visualization.

### 10.2. Verified Part A Environment

```text
SWI-Prolog 10.0.2
Windows 64-bit
```

### 10.3. Requirements for Executing Part A

A working SWI-Prolog installation is required.

The example programs, resolution engine, demonstration runner, and test files must be available.

The commands below are written for Windows CMD.

---

## 11. Getting Started

### 11.1. Open the Repository

For an existing local checkout:

```cmd
cd C:\Users\Emmanuel\Documents\sld-resolution-tree-visualizer
```

### 11.2. Verify SWI-Prolog

```cmd
swipl --version
```

### 11.3. Verify the Current Branch

```cmd
git status -sb
```

The additional Part A evidence was developed on:

```text
feature/engine-demo-evidence
```

A checkout containing these changes is required to execute the newer demonstration and aliasing-test commands.

A checkout of `main` may not contain the newer files until the corresponding changes have been merged.

---

## 12. Execute Basic Logical Resolution

### 12.1. Fact Resolution

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X,sld_engine:sld_solve(parent(ana,X)),Answers),writeln(Answers)" -t halt
```

The recorded result is:

```text
[luis,marta]
```

This demonstrates:

- Fact resolution.
- Unification.
- Multiple successful answers.
- Backtracking.

### 12.2. Recursive Rule Resolution

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X,sld_engine:sld_solve(ancestor(ana,X)),Answers),writeln(Answers)" -t halt
```

The recorded result is:

```text
[luis,marta,sofia,diego]
```

This demonstrates recursive rule resolution.

### 12.3. Conjunctions

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s src/prolog/engine/sld_engine.pl -g "findall(X-Y,sld_engine:sld_solve((parent(ana,X),parent(X,Y))),Answers),writeln(Answers)" -t halt
```

The recorded result is:

```text
[luis-sofia,marta-diego]
```

This demonstrates substitutions shared across consecutive goals.

---

## 13. Execute Individual Demonstration Cases

The console runner displays detailed resolution information for one selected case.

### 13.1. Demonstrate Conjunctions and Unification

Execute case 7:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(7)" -t halt
```

Recorded results:

| Metric | Value |
|---|---:|
| Resolution events | 8 |
| Successful answers | 2 |
| Backtracking events | 1 |
| Final result | PASSED |

### 13.2. Demonstrate Backtracking After Failure

Execute case 8:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(8)" -t halt
```

Recorded results:

| Metric | Value |
|---|---:|
| Resolution events | 7 |
| Successful answers | 1 |
| Failed branches | 1 |
| Backtracking events | 1 |
| Final result | PASSED |

### 13.3. Demonstrate Recursion

Execute case 9:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(9)" -t halt
```

Recorded results:

| Metric | Value |
|---|---:|
| Resolution events | 26 |
| Successful answers | 4 |
| Depth cutoffs | 2 |
| Backtracking events | 5 |
| Final result | PASSED |

### 13.4. Demonstrate an Unsuccessful Query

Execute case 4:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(4)" -t halt
```

Recorded results:

| Metric | Value |
|---|---:|
| Resolution events | 2 |
| Successful answers | 0 |
| Failed branches | 1 |
| Depth cutoffs | 0 |
| Final result | PASSED |

### 13.5. Demonstrate a Depth Cutoff

Execute case 11:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_case(11)" -t halt
```

Recorded results:

| Metric | Value |
|---|---:|
| Maximum depth | 3 |
| Successful answers | 0 |
| Failed branches | 0 |
| Depth cutoffs | 1 |
| Final result | PASSED |

A depth cutoff must not be interpreted as logical failure.

---

## 14. Execute All Twelve Demonstrations

### 14.1. Command

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt
```

### 14.2. Recorded Results

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

### 14.3. Overall Result

The recorded execution reported:

```text
Total passed: 12 / 12
```

The process returned exit code:

```text
0
```

### 14.4. Important Difference Between Runner Modes

The runner provides two modes.

#### `run_case(N)`

Displays a detailed report for one selected case.

The report includes resolution events, applied clauses, variable bindings, successful answers, and an execution summary.

#### `run_all`

Executes all twelve cases and displays a compact summary table.

The current `run_all` output does not print twelve complete detailed traces.

### 14.5. Verification Scope

The enhanced demonstration runner checks successful-answer counts, expected variable bindings, chronological trace steps, and scenario-specific resolution events. It checks more than the displayed summary table alone.

The automated tests and separate trace-evidence files independently verify engine and event-contract behavior. The complete verification remains limited to the supported educational Prolog subset.

---

## 15. Execute All Automated Tests

The implementation contains four automated test suites.

| Test suite | Tests | Recorded result |
|---|---:|---|
| Basic SLD engine | 14 | 14/14 passed |
| Resolution tracing | 17 | 17/17 passed |
| Variable aliasing | 3 | 3/3 passed |
| Structured event contract | 7 | 7/7 passed |
| **Total** | **41** | **41/41 passed** |

### 15.1. Test Command

Execute:

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

### 15.3. Test Coverage

The automated tests cover the supported engine functionality, including:

- Fact resolution.
- Rule resolution.
- Successful queries.
- Failed queries.
- Conjunctions.
- Unification.
- Variable substitutions.
- Recursion.
- Backtracking.
- Multiple solutions.
- Configurable depth limits.
- Resolution traces.
- Successful answers.
- Failed branches.
- Depth cutoffs.
- Variable aliasing.
- Independent unbound variables.
- Structured `step/8` records for fact and rule applications, remaining goals, failure, cutoff, and backtracking.

### 15.4. Important Note

The 41 automated tests provide independent verification of Part A, including seven event-contract tests.

They do not replace the integration tests required for Parts B and C.

### 15.5. Execute the Structured Event Contract Tests Separately

To demonstrate the resolution-information interface independently, run:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_step_contract_tests.pl -g "run_tests([sld_step_contract])" -t halt
```

The recorded execution completed **7/7 tests** with exit code **0**. Its saved output is `docs/evidence/engine/05_step_contract_tests.txt`. These tests verify the shape and meaning of the chronological resolution events consumed by Part B; they do not prove integration with Roy's implementation.

---

## 16. Demonstrate Variable Aliasing

### 16.1. Aliased Variables

Execute:

```cmd
swipl -q -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(aliased_pair(_,_),1,_,Answers),format('~q~n',[Answers])" -t halt
```

The recorded representation is:

```prolog
[answer([1],[binding("V1","_"),binding("V2","alias(V1)")])]
```

### 16.2. Independent Variables

Execute:

```cmd
swipl -q -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -g "sld_engine:sld_trace(independent_pair(_,_),1,_,Answers),format('~q~n',[Answers])" -t halt
```

The recorded representation is:

```prolog
[answer([1],[binding("V1","_"),binding("V2","_")])]
```

### 16.3. Technical Interpretation

| Situation | Representation |
|---|---|
| Concrete value | `V1=luis` |
| Unbound variable | `V1=_` |
| Independent unbound variables | `V1=_`, `V2=_` |
| Aliased unbound variables | `V1=_`, `V2=alias(V1)` |

This distinction is part of the information provided to the tree-building component.

---

## 17. Execution Evidence

The execution-evidence directory is:

```text
docs/evidence/engine/
```

### 17.1. Evidence by Approved Part A Commitment

| Commitment | Evidence |
|---|---|
| 1. Meta-interpreter | `01_meta_interpreter.txt` |
| 2. Goal resolution and unification | `02_goal_unification.txt`, `02_variable_aliasing.txt`, `02_alias_tests.txt` |
| 3. Recursion and backtracking | `03_backtracking.txt`, `03_recursion.txt`, `03_failed_query.txt` |
| 4. Configurable depth control | `04_configurable_depth.txt`, `04_depth_cutoff.txt` |
| 5. Structured resolution information | `05_trace_interface.txt`, `05_failure_cutoff_interface.txt`, `05_step_contract_tests.txt` |
| 6. Individual tests | `automated_tests.txt`, `demo_12_cases_output.txt` |

### 17.2. Additional General Evidence

```text
basic_resolution.txt
recursion_depth.txt
sld_trace.txt
```

### 17.3. Complete Evidence Inventory

See:

[Engine Execution Evidence](docs/evidence/engine/README.md)

The evidence files record actual command outputs.

They should be regenerated if relevant engine or demonstration behavior changes.

---

## 18. Save Automated Test Evidence

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/programs/alias_demo.pl -s src/prolog/engine/sld_engine.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/engine/sld_alias_tests.pl -s tests/engine/sld_step_contract_tests.pl -g run_tests -t halt > docs\evidence\engine\automated_tests.txt 2>&1
```

Immediately check:

```cmd
echo %ERRORLEVEL%
```

Verify the final recorded test:

```cmd
findstr /L /C:"[41/41]" docs\evidence\engine\automated_tests.txt
```

Inspect the complete output:

```cmd
type docs\evidence\engine\automated_tests.txt
```

---

## 19. Save the Twelve-Case Demonstration Summary

Execute:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/queries/sld_demo_runner.pl -g "sld_demo_runner:run_all" -t halt > docs\evidence\engine\demo_12_cases_output.txt 2>&1
```

Immediately check:

```cmd
echo %ERRORLEVEL%
```

Verify the overall result:

```cmd
findstr /C:"Total passed:" docs\evidence\engine\demo_12_cases_output.txt
```

The recorded successful execution reports:

```text
Total passed: 12 / 12
```

Inspect the complete summary:

```cmd
type docs\evidence\engine\demo_12_cases_output.txt
```

---

## 20. Technical Documentation

The Part A technical documentation is organized into separate files.

### 20.1. Technical Design

[Engine Technical Documentation](docs/ENGINE_TECHNICAL.md)

Explains:

- SLD resolution.
- The meta-interpreter.
- Goal selection.
- Unification.
- Recursion.
- Backtracking.
- Depth control.
- Trace generation.
- Variable aliasing.
- Technical limitations.

### 20.2. Public Integration Contract

[Engine Interface Documentation](docs/ENGINE_INTERFACE.md)

Explains:

- Public predicates.
- `sld_trace/4`.
- `step/8`.
- `answer/2`.
- `binding/2`.
- Resolution actions.
- Variable representations.
- Requirements for Part B.

### 20.3. Individual Demonstration

[Individual Demonstration Guide](docs/ENGINE_DEMO.md)

Provides:

- Separate demonstrations of the six commitments.
- Runnable CMD commands.
- Recorded expected outputs.
- Explanations of the results.
- Automated test instructions.
- Individual presentation preparation.

### 20.4. Evidence Documentation

[Execution Evidence Inventory](docs/evidence/engine/README.md)

Documents the saved execution results.

---

## 21. Known Limitations of Part A

Part A implements an educational subset of Prolog.

It is not a complete Prolog interpreter.

Known limitations include:

1. General interpretation of cuts (`!`) is not provided.
2. General negation-as-failure is not supported.
3. General disjunction is not supported.
4. Arbitrary built-in predicates are not generally interpreted.
5. General arithmetic execution is outside the supported subset.
6. Dynamic database modification is outside the supported subset.
7. Supported clause lookup focuses on the `user` module.
8. `sld_solve/1` does not impose a depth limit.
9. An unrestricted recursive query may not terminate.
10. Configurable depth control is not a global execution-time limit.
11. A depth cutoff is not proof of logical failure.
12. Trace variable labels are generated identifiers.
13. Goal and clause representations are textual snapshots.
14. Alias representation focuses on tracked unbound query variables.
15. The trace does not serialize every possible variable-sharing relationship.
16. Part A does not construct the final SLD tree hierarchy.
17. Part A does not export the tree as JSON.
18. Part A does not implement the graphical browser visualizer.

These limitations define the supported educational scope and the boundaries of the individual contribution.

---

## 22. Collaboration and Integration

The project follows these principles:

1. Each student develops the assigned component.
2. Individual contributions remain identifiable in Git history.
3. Development changes are reviewed before integration.
4. Each component has its own tests.
5. Public interfaces are documented.
6. Integration testing uses the actual implementations.
7. Unverified functionality is not described as completed.
8. Each student must understand and defend the individual contribution.

### 22.1. Part A-B Integration Requirements

The actual Part B implementation must correctly consume:

```prolog
sld_trace(+Query, +MaxDepth, -Steps, -Answers).
```

It must interpret:

- Chronological resolution events.
- Clause-choice paths.
- Resolution depth.
- Selected goals.
- Applied clauses.
- Remaining goals.
- Variable substitutions.
- Alias references.
- Successful answers.
- Failed branches.
- Depth cutoffs.
- Backtracking events.

### 22.2. Integration Status

The Part A interface is implemented and individually tested.

Its integration with Roy's actual tree-building component must still be verified.

Part C integration must also be verified using the JSON generated by Part B.

These checks are separate from the recorded 41 automated tests and twelve Part A demonstrations.

---

## 23. Approved Individual Deliverables

Emmanuel's Part A contribution includes five deliverables.

| No. | Deliverable | Corresponding files |
|---:|---|---|
| 1 | SWI-Prolog meta-interpreter module | `src/prolog/engine/sld_engine.pl` |
| 2 | Predicates for logical resolution | `sld_solve/1`, `sld_solve_limited/3`, `sld_trace/4` |
| 3 | Test cases and execution evidence | `tests/engine/`, `examples/queries/`, `docs/evidence/engine/` |
| 4 | Technical explanation and limitations | `docs/ENGINE_TECHNICAL.md`, `docs/ENGINE_INTERFACE.md` |
| 5 | Individual execution demonstration | `docs/ENGINE_DEMO.md`, demonstration runner, and saved traces |

The files provide the implementation and materials needed for Emmanuel's individual explanation and demonstration.

A final presentation rehearsal and code-to-documentation consistency review are still required before declaring the contribution fully prepared for academic delivery.

---

## 24. Development Status Checklist

### 24.1. Part A - Emmanuel Núñez Jiménez

- [x] SLD meta-interpreter implemented.
- [x] Fact and rule resolution implemented.
- [x] Leftmost goal selection implemented.
- [x] Unification implemented.
- [x] Conjunctions implemented.
- [x] Variable substitutions recorded.
- [x] Variable aliasing represented.
- [x] Recursive resolution implemented.
- [x] Backtracking implemented.
- [x] Multiple solutions supported.
- [x] Unsuccessful queries recognized.
- [x] Configurable depth control implemented.
- [x] Depth cutoffs represented.
- [x] Chronological resolution events generated.
- [x] Public trace interface implemented.
- [x] Original engine integrated through pull request #2.
- [x] Automated tests executed successfully: 41/41.
- [x] Structured resolution-event contract tests executed successfully: 7/7.
- [x] Demonstration cases executed successfully: 12/12.
- [x] Individual execution evidence generated.
- [x] Organized console reports implemented.
- [x] Technical documentation prepared.
- [ ] Final code-to-documentation consistency review completed.
- [x] Additional evidence-branch changes committed (`458f96c`).
- [ ] Additional evidence-branch changes reviewed and merged.
- [ ] Individual presentation rehearsed.
- [ ] Actual Part A-B integration verified.

### 24.2. Part B - Roy Arias Mejía

- [ ] Actual tree-building implementation verified in the available evidence.
- [ ] JSON export verified in the available evidence.
- [ ] Actual Part A-B integration verified.

### 24.3. Part C - Keynell Molina Mora

- [x] Browser visualizer loads all six bundled JSON examples; node counts, status labels, connections, and node-detail selection were manually verified.
- [ ] Actual Part B-C integration verified.

### 24.4. Complete Project

- [ ] End-to-end integration verified.
- [ ] Complete graphical SLD tree verified.
- [ ] Final group demonstration completed.

Unchecked items associated with Parts B and C indicate that they are not verified by the evidence reviewed for Part A.

They do not establish that the corresponding students have or have not completed their individual work.

---

## 25. Academic Purpose

This project reinforces concepts studied in EIF400:

- Logic programming.
- Declarative programming.
- SLD resolution.
- Logical inference.
- Facts and Horn-clause rules.
- Term unification.
- Variable substitutions.
- Recursion.
- Backtracking.
- Depth-limited search.

The project is organized into individually developed and defensible contributions.

The Part A implementation provides the logical resolution foundation for the intended SLD Resolution Tree Visualizer.

---

## 26. Final Statement

The Part A SLD meta-interpreter developed by Emmanuel Núñez Jiménez resolves supported Prolog queries using facts and definite Horn-clause rules.

It performs:

- Goal selection.
- Clause application.
- Unification.
- Variable substitutions.
- Recursive resolution.
- Backtracking.
- Multiple-solution enumeration.
- Recognition of unsuccessful queries.
- Configurable depth control.
- Structured resolution tracing.
- Successful-answer recording.
- Variable-alias representation.

The recorded individual verification results are:

```text
Automated tests: 41/41 passed
Demonstration cases: 12/12 passed
Execution exit codes: 0
```

Separate evidence files document the six approved Part A commitments.

The implementation, tests, technical documentation, and demonstration guide support Emmanuel's individual contribution.

These results do not establish that the complete three-component SLD Resolution Tree Visualizer has already been integrated.

The complete project still requires verified integration of the newer Part A changes with the merged Part B implementation and the corresponding Part C visualization.

The individual responsibility boundaries approved by instructor Carlos Loría-Sáenz must be preserved.

---

**National University of Costa Rica (UNA)**
**School of Informatics**
**EIF400 - Programming Paradigms**
**Group 04-10am | Second Semester, 2026**


# SLD Resolution Tree Visualizer

An educational visualizer of **SLD (Selective Linear Definite Clause) resolution in Prolog**, developed as an approved additional project for the Programming Paradigms course (EIF400) at the National University of Costa Rica.

The project will illustrate how Prolog resolves queries through clause selection, unification, variable substitutions, recursion, and backtracking. The resolution process will be recorded in SWI-Prolog, converted into a structured tree, exported as JSON, and displayed in a web browser.

> **Development status:** Initial project setup. The components described below are planned and have not yet been implemented.

## Academic Information

| Field | Details |
| --- | --- |
| University | National University of Costa Rica (UNA) |
| School | School of Informatics |
| Course | EIF400 - Programming Paradigms |
| Academic term | Second Semester, 2026 |
| Group | 04-10am |
| Instructor | Carlos Loría-Sáenz |
| Project | Approved additional academic project |

## Objectives

1. Implement an SLD meta-interpreter in SWI-Prolog.
2. Resolve queries against a defined subset of Prolog facts and rules.
3. Demonstrate goal selection, clause application, and unification.
4. Support recursion, backtracking, multiple solutions, and failed queries.
5. Enforce a configurable depth limit on resolution searches.
6. Record the goals, clauses, substitutions, and outcomes involved in resolution.
7. Construct a corresponding SLD resolution tree.
8. Export the tree as JSON and render it using HTML, CSS, and JavaScript.

## Approved Scope

The project uses a **meta-interpreter written in Prolog**, not a separate Prolog simulator. The meta-interpreter will rely on SWI-Prolog's own logical mechanisms to select clauses and unify terms while recording the resolution process.

The initial supported subset focuses on:

- Facts and rules.
- Queries and conjunctions of goals.
- Clause selection and term unification.
- Variable bindings and substitutions.
- Recursive resolution and backtracking.
- Multiple solutions, successful branches, and failed branches.
- Configurable depth control, distinguishing a depth cutoff from a logical failure.

The following are **outside the approved base scope**:

- The cut operator (`!`).
- Dynamic database modifications, such as `assert/1` and `retract/1`.
- A complete implementation of Prolog or support for every built-in predicate.
- Prolog-native graphical rendering through XPCE.

The **base visualization** will show the full resolution tree, including goals, variable substitutions, and successful and failed branches. Expanding and collapsing branches is an **optional enhancement**, subject to available time.

## Team and Individual Contributions

### Part A - SLD Meta-Interpreter and Resolution Engine

**Responsible: Emmanuel Núñez Jiménez**

The SWI-Prolog resolution engine will:

1. Process a query goal by goal.
2. Find applicable facts and rules.
3. Perform unification and track variable substitutions.
4. Explore alternative clauses through backtracking.
5. Support recursive rules and multiple solutions.
6. Report failed searches and depth-limit cutoffs.
7. Produce resolution information for the tree-building component.
8. Include independent tests, execution evidence, and technical documentation.

This contribution is limited to the **logical resolution engine**; construction and rendering of the tree belong to Parts B and C.

### Part B - SLD Tree Construction and JSON Export

**Responsible: Roy Arias Mejía**

This component will:

- Receive the resolution information produced by Part A.
- Construct the SLD tree and preserve parent-child relationships.
- Record goals, selected clauses, substitutions, and branch outcomes.
- Export the tree into a documented JSON representation.
- Include independent tests and documentation.

### Part C - Web-Based SLD Tree Visualization

**Responsible: Keynell Molina Mora**

This component will:

- Read the JSON representation produced by Part B.
- Display the tree in a web browser using HTML, CSS, and JavaScript.
- Make goals, substitutions, and branch outcomes easy to distinguish.
- Provide clear visual presentation and independent tests.
- Optionally add interactive branch expansion and collapse.

## Planned Architecture

```text
Prolog program + query
          |
          v
SLD meta-interpreter (Emmanuel)
          |
          v
Resolution events / substitutions
          |
          v
SLD tree builder (Roy)
          |
          v
JSON tree export
          |
          v
Browser visualizer (Keynell)
```

The data contract between the resolution engine and the tree builder will be documented before integration. Its exact event fields and JSON structure are not finalized yet.

## Repository Structure

```text
sld-resolution-tree-visualizer/
|-- docs/
|-- examples/
|   |-- programs/
|   `-- queries/
|-- src/
|   |-- prolog/
|   |   |-- engine/
|   |   `-- tree/
|   `-- web/
|       |-- css/
|       `-- js/
|-- tests/
|   |-- engine/
|   |-- tree/
|   |-- web/
|   `-- integration/
|-- .gitignore
`-- README.md
```

| Directory | Purpose |
| --- | --- |
| `src/prolog/engine/` | Emmanuel's SLD meta-interpreter and resolution engine |
| `src/prolog/tree/` | Roy's tree builder and JSON export |
| `src/web/` | Keynell's browser-based visualization |
| `tests/engine/` | Resolution engine tests |
| `tests/tree/` | Tree construction and export tests |
| `tests/web/` | Visualization tests |
| `tests/integration/` | End-to-end integration tests |
| `examples/programs/` | Sample Prolog knowledge bases |
| `examples/queries/` | Demonstration queries |
| `docs/` | Technical design, interfaces, setup instructions, and evidence |

## Technologies and Prerequisites

- **SWI-Prolog** for logical resolution and tree-data generation.
- **JSON** for exchanging structured tree data.
- **HTML5, CSS3, and JavaScript** for browser-based visualization.
- **Git and GitHub** for collaboration and version control.

Development requires a working SWI-Prolog installation, Git, and a modern web browser. Additional setup instructions will be documented when the implementation is available.

## Testing Plan

The project will test the following scenarios:

1. Successful fact queries.
2. Queries with no solutions.
3. Rule resolution and conjunctions of goals.
4. Unification and variable substitutions.
5. Multiple solutions from alternative clauses.
6. Backtracking after successful and failed branches.
7. Recursive rules.
8. Configurable depth limits and distinct cutoff outcomes.
9. Resolution information passed from Part A to Part B.
10. JSON export and browser visualization.

Only **actual, reproducible test executions** will be reported as verified results. Test cases, commands, and evidence will be added alongside the implementation.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/EmmanuelNJ02/sld-resolution-tree-visualizer.git
cd sld-resolution-tree-visualizer
```

Check the SWI-Prolog installation:

```bash
swipl --version
```

> The application is not executable yet. Commands for running the engine, exporting JSON, and viewing the tree will be added when those components are implemented and tested.

## Collaboration Workflow

- Each contributor develops their assigned component on a separate feature branch.
- Changes are integrated into `main` using pull requests.
- Individual contributions remain identifiable in Git history.
- Shared interfaces are documented before integration.
- Each contributor prepares tests and can explain and defend their implementation independently.

## Current Status

- [x] Project scope approved by the instructor.
- [x] Individual responsibilities defined.
- [x] GitHub repository created.
- [x] Initial directory structure prepared locally.
- [ ] Initial project scaffold committed and merged.
- [ ] Part A implemented and tested.
- [x] Part B implemented and tested (see `docs/TREE_TECHNICAL.md` and `docs/TREE_JSON_FORMAT.md`).
- [ ] Part C implemented and tested.
- [ ] Integration tests completed.
- [ ] Final documentation and demonstration completed.

## Academic Purpose

This project reinforces logic programming concepts studied in EIF400: **SLD resolution, unification, recursion, backtracking, logical inference, and declarative programming**.

Each team member is responsible for understanding, testing, documenting, and individually defending their contribution.

---

National University of Costa Rica · School of Informatics

EIF400 - Programming Paradigms · Group 04-10am · 2026

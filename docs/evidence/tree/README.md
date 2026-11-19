# Part B - SLD Tree Construction and JSON Export Execution Evidence

## 1. Project Information

- **Project:** SLD Resolution Tree Visualizer
- **Course:** EIF400 - Programming Paradigms
- **Group:** 04-10am
- **Instructor:** Carlos Loria-Saenz
- **Student:** Roy Arias Mejia
- **Individual Contribution:** Part B - SLD Tree Construction, Registration and JSON Export
- **Environment:** SWI-Prolog 11.0.0 for Windows (64-bit)
- **Working Branch:** `feature/sld-tree-builder`

## 2. Purpose

This directory contains execution evidence for the SLD tree builder and JSON exporter developed as Part B.

All results were obtained from actual executions using SWI-Prolog.

## 3. Evidence Files

| File | Description |
|---|---|
| `automated_tests.txt` | Combined execution of the Part A, Part B and integration test suites. |
| `tree_construction.txt` | `node/9` lists built by `build_tree/2` for success, failure, backtracking, recursion, cutoff and mixed queries. |
| `../../../examples/json/*.json` | JSON trees exported by `export_tree_json/3` for the same six cases. |

## 4. Automated Test Results

| Suite | File | Tests |
|---|---|---:|
| Part A - engine | `tests/engine/sld_engine_tests.pl` | 14 |
| Part A - trace | `tests/engine/sld_trace_tests.pl` | 17 |
| Part B - tree and JSON | `tests/tree/sld_tree_tests.pl` | 18 |
| Integration A + B | `tests/integration/sld_integration_tests.pl` | 5 |

**Observed result: 54/54 tests passed.**

Command (from the repository root):

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s tests/engine/sld_engine_tests.pl -s tests/engine/sld_trace_tests.pl -s tests/tree/sld_tree_tests.pl -s tests/integration/sld_integration_tests.pl -g "run_tests([sld_engine,sld_trace,sld_tree,sld_integration])" -t halt
```

## 5. Tree Construction Evidence

Observed for `(parent(ana, X), parent(X, diego))` with depth 3:

```prolog
node(n0,none,[],0,"parent(ana,A),parent(A,diego)",none,["parent(ana,A)","parent(A,diego)"],[binding("V1","_")],success)
node(n1,n0,[1],1,"parent(ana,A)","parent(ana,luis)",["parent(luis,diego)"],[binding("V1","luis")],failure)
node(n2,n0,[2],1,"parent(ana,A)","parent(ana,marta)",["parent(marta,diego)"],[binding("V1","marta")],success)
node(n3,n2,[2,1],2,"parent(marta,diego)","parent(marta,diego)",[],[binding("V1","marta")],success)
```

Observed for `endless` with depth 3 (cutoff is not reported as failure):

```prolog
node(n0,none,[],0,"endless",none,["endless"],[],cutoff)
node(n1,n0,[1],1,"endless","endless:-endless",["endless"],[],cutoff)
node(n2,n1,[1,1],2,"endless","endless:-endless",["endless"],[],cutoff)
node(n3,n2,[1,1,1],3,"endless","endless:-endless",["endless"],[],cutoff)
```

These results demonstrate:

- Node creation only from `start` and `apply` steps.
- Correct parent identifiers derived from the paths.
- Inferred status of inner nodes (`n0` and `n2` are `success` because a descendant succeeded).
- Distinction between `failure` and `cutoff`.

## 6. JSON Export Evidence

The six files in `examples/json/` were generated with:

```cmd
swipl -q -s examples/programs/family.pl -s examples/programs/recursive_loop.pl -s examples/generate_json_examples.pl -g generate_examples -t halt
```

Their validity is checked by the integration tests, which read each exported file back with `json_read_dict/2`.

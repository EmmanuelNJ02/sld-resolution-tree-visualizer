% ============================================================
% SLD Resolution Tree Visualizer
% Part B - JSON example generator
%
% Author: Roy Arias Mejia
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Run from the repository root:
%
% swipl -q -s examples/programs/family.pl
%          -s examples/programs/recursive_loop.pl
%          -s examples/generate_json_examples.pl
%          -g generate_examples -t halt
% ============================================================

:- use_module('../src/prolog/tree/sld_tree.pl').


% example(Name, Query, MaxDepth)

example(multiple_solutions, parent(ana, _),                   3).
example(failure,            parent(diego, _),                 3).
example(backtracking,       (parent(ana, X), parent(X, diego)), 3).
example(recursion,          ancestor(ana, _),                 4).
example(cutoff,             endless,                          3).
example(mixed,              loop,                             3).


generate_examples :-
    forall(
        example(Name, Query, MaxDepth),
        (   format(atom(File), 'examples/json/~w.json', [Name]),
            export_tree_json(Query, MaxDepth, File),
            format("Generated ~w~n", [File])
        )
    ).
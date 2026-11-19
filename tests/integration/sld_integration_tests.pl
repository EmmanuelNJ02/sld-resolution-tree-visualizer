% ============================================================
% SLD Resolution Tree Visualizer
% Integration Tests: Part A (engine) + Part B (tree and JSON)
%
% Author: Roy Arias Mejia
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Required example programs:
% - examples/programs/family.pl
% - examples/programs/recursive_loop.pl
%
% The exported JSON is read back with json_read_dict/2
% (library(http/json)) as an independent validity check.
% ============================================================

:- use_module(library(plunit)).
:- use_module(library(http/json)).

:- use_module('../../src/prolog/engine/sld_engine.pl').
:- use_module('../../src/prolog/tree/sld_tree.pl').


% ------------------------------------------------------------
% Helpers
% ------------------------------------------------------------

% export_and_read(+Query, +MaxDepth, -Dict)
%
% Exports the tree to a temporary file and reads it back.

export_and_read(Query, MaxDepth, Dict) :-
    tmp_file_stream(text, File, Tmp),
    close(Tmp),
    export_tree_json(Query, MaxDepth, File),
    open(File, read, In, [encoding(utf8)]),
    json_read_dict(In, Dict),
    close(In),
    delete_file(File).

% text_of(+Value, -String)   atom or string -> string

text_of(Value, String) :-
    atom_string(Value, String).

% node_statuses(+Dict, -Statuses)

node_statuses(Dict, Statuses) :-
    get_dict(nodes, Dict, Nodes),
    findall(
        S,
        (   member(N, Nodes),
            get_dict(status, N, S0),
            text_of(S0, S)
        ),
        Statuses
    ).


% ============================================================
% INTEGRATION TEST SUITE
% ============================================================

:- begin_tests(sld_integration).


% ------------------------------------------------------------
% Full chain with success, failure and backtracking.
% ------------------------------------------------------------

test(end_to_end_backtracking) :-
    export_and_read((parent(ana, X), parent(X, diego)), 3, Dict),
    get_dict(nodes, Dict, Nodes),
    length(Nodes, 4),
    node_statuses(Dict, Statuses),
    assertion(Statuses == ["success", "failure", "success", "success"]),
    Nodes = [Root | _],
    get_dict(parent, Root, RootParent),
    assertion(RootParent == null),
    get_dict(answers, Dict, [Answer]),
    get_dict(node, Answer, AnswerNode),
    text_of(AnswerNode, AnswerText),
    assertion(AnswerText == "n3").


% ------------------------------------------------------------
% Recursive query: four answers, all pointing to nodes.
% ------------------------------------------------------------

test(end_to_end_recursion) :-
    export_and_read(ancestor(ana, _), 4, Dict),
    get_dict(answers, Dict, Answers),
    length(Answers, 4),
    get_dict(nodes, Dict, Nodes),
    findall(Id, (member(N, Nodes), get_dict(id, N, Id0), text_of(Id0, Id)), Ids),
    forall(
        member(A, Answers),
        (   get_dict(node, A, Node0),
            text_of(Node0, Node),
            assertion(memberchk(Node, Ids))
        )
    ).


% ------------------------------------------------------------
% Depth cutoff is exported as cutoff, not as failure.
% ------------------------------------------------------------

test(end_to_end_cutoff) :-
    export_and_read(endless, 3, Dict),
    node_statuses(Dict, Statuses),
    assertion(Statuses == ["cutoff", "cutoff", "cutoff", "cutoff"]),
    get_dict(answers, Dict, Answers),
    assertion(Answers == []).


% ------------------------------------------------------------
% A failed query produces a valid JSON with no answers.
% ------------------------------------------------------------

test(end_to_end_failure) :-
    export_and_read(parent(diego, _), 3, Dict),
    node_statuses(Dict, Statuses),
    assertion(Statuses == ["failure"]),
    get_dict(answers, Dict, Answers),
    assertion(Answers == []).


% ------------------------------------------------------------
% Mixed recursion and alternatives.
% ------------------------------------------------------------

test(end_to_end_mixed) :-
    export_and_read(loop, 3, Dict),
    get_dict(answers, Dict, Answers),
    length(Answers, 3),
    node_statuses(Dict, Statuses),
    assertion(memberchk("cutoff", Statuses)),
    assertion(Statuses = ["success" | _]).

:- end_tests(sld_integration).
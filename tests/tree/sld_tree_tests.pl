% ============================================================
% SLD Resolution Tree Visualizer
% Part B - Automated Tree Construction and JSON Export Tests
%
% Author: Roy Arias Mejia
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Required example programs:
% - examples/programs/family.pl
% - examples/programs/recursive_loop.pl
%
% ============================================================

:- use_module(library(plunit)).

:- use_module('../../src/prolog/tree/sld_tree.pl').
:- use_module('../../src/prolog/engine/sld_engine.pl').


% ------------------------------------------------------------
% Test helpers
% ------------------------------------------------------------

% tree_of(+Query, +MaxDepth, -Nodes, -Answers)

tree_of(Query, MaxDepth, Nodes, Answers) :-
    sld_trace(Query, MaxDepth, Steps, Answers),
    build_tree(Steps, Nodes).

% statuses(+Nodes, -Statuses)

statuses(Nodes, Statuses) :-
    findall(S, member(node(_, _, _, _, _, _, _, _, S), Nodes), Statuses).

% parents(+Nodes, -Pairs)   Pairs: Id-ParentId

parents(Nodes, Pairs) :-
    findall(Id-P, member(node(Id, P, _, _, _, _, _, _, _), Nodes), Pairs).

% json_of(+Query, +MaxDepth, -Json)   JSON as a string

json_of(Query, MaxDepth, Json) :-
    tree_of(Query, MaxDepth, Nodes, Answers),
    with_output_to(
        string(Json),
        (   current_output(Out),
            write_tree_json(Out, MaxDepth, Nodes, Answers)
        )
    ).


% ============================================================
% SLD TREE TEST SUITE
% ============================================================

:- begin_tests(sld_tree).


% ------------------------------------------------------------
% Paths
% ------------------------------------------------------------

test(parent_path_of_child) :-
    sld_tree:parent_path([2, 1], P),
    assertion(P == [2]).

test(parent_path_of_root_child) :-
    sld_tree:parent_path([2], P),
    assertion(P == []).

test(parent_path_of_root_fails, [fail]) :-
    sld_tree:parent_path([], _).


% ------------------------------------------------------------
% Tree structure
% ------------------------------------------------------------

test(backtracking_parent_relations) :-
    tree_of((parent(ana, X), parent(X, diego)), 3, Nodes, _),
    parents(Nodes, Pairs),
    assertion(Pairs == [n0-none, n1-n0, n2-n0, n3-n2]).

test(every_parent_exists) :-
    tree_of(ancestor(ana, _), 4, Nodes, _),
    forall(
        (   member(node(_, P, _, _, _, _, _, _, _), Nodes),
            P \== none
        ),
        assertion(member(node(P, _, _, _, _, _, _, _, _), Nodes))
    ).

test(single_root) :-
    tree_of(ancestor(ana, _), 4, Nodes, _),
    findall(Id, member(node(Id, none, _, _, _, _, _, _, _), Nodes), Roots),
    assertion(Roots == [n0]).


% ------------------------------------------------------------
% Branch status
% ------------------------------------------------------------

test(backtracking_status) :-
    tree_of((parent(ana, X), parent(X, diego)), 3, Nodes, _),
    statuses(Nodes, S),
    assertion(S == [success, failure, success, success]).

test(multiple_solutions_status) :-
    tree_of(parent(ana, _), 3, Nodes, _),
    statuses(Nodes, S),
    assertion(S == [success, success, success]).

test(root_failure) :-
    tree_of(parent(diego, _), 3, Nodes, _),
    statuses(Nodes, S),
    assertion(S == [failure]).

test(cutoff_is_not_failure) :-
    tree_of(endless, 3, Nodes, _),
    statuses(Nodes, S),
    assertion(S == [cutoff, cutoff, cutoff, cutoff]).

test(zero_depth_cutoff) :-
    tree_of(parent(ana, _), 0, Nodes, _),
    statuses(Nodes, S),
    assertion(S == [cutoff]).

test(mixed_cutoff_and_success) :-
    tree_of(loop, 3, Nodes, _),
    statuses(Nodes, S),
    assertion(S == [success, success, success, cutoff, success, success, success]).

test(answers_point_to_success_nodes) :-
    tree_of(ancestor(ana, _), 4, Nodes, Answers),
    length(Answers, 4),
    forall(
        member(answer(Path, _), Answers),
        assertion(member(node(_, _, Path, _, _, _, _, _, success), Nodes))
    ).


% ------------------------------------------------------------
% JSON output
% ------------------------------------------------------------

test(json_text_null) :-
    with_output_to(string(S), (current_output(Out), sld_tree:json_text(Out, none))),
    assertion(S == "null").

test(json_text_escapes_quotes) :-
    with_output_to(string(S), (current_output(Out), sld_tree:json_text(Out, "a\"b"))),
    assertion(S == "\"a\\\"b\"").

test(json_contains_children) :-
    json_of((parent(ana, X), parent(X, diego)), 3, Json),
    assertion(sub_string(Json, _, _, _, "\"children\": [\"n1\", \"n2\"]")).

test(json_answer_points_to_node) :-
    json_of((parent(ana, X), parent(X, diego)), 3, Json),
    assertion(sub_string(Json, _, _, _, "{\"node\": \"n3\"")).

test(json_root_parent_is_null) :-
    json_of(parent(ana, _), 3, Json),
    assertion(sub_string(Json, _, _, _, "{\"id\": \"n0\", \"parent\": null")).

:- end_tests(sld_tree).
% ============================================================
% SLD Resolution Tree Visualizer
% Part B - SLD Tree Construction and JSON Export
%
% Author: Roy Arias Mejia
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
% Instructor: Carlos Loria-Saenz
% ============================================================
%
% Input:
%   Steps produced by sld_trace/4 (Part A), as step/8 terms.
%
% Output:
%   A list of node/9 terms and its JSON representation
%   for the web visualizer (Part C).
%
% ============================================================

:- module(sld_tree, [
    build_tree/2
]).


% ============================================================
% 1. PATH HELPERS
% ============================================================

% ------------------------------------------------------------
% parent_path(+Path, -ParentPath)
%
% The parent path is the path without its last position.
%
% Examples:
%   [2, 1] -> [2]
%   [2]    -> []
%   []     -> fails (the root has no parent)
% ------------------------------------------------------------

parent_path(Path, ParentPath) :-
    append(ParentPath, [_], Path).


% ============================================================
% 2. NODE CREATION
% ============================================================

% ------------------------------------------------------------
% creates_node(+Step)
%
% Only start (the root) and apply (a clause application)
% create tree nodes.
% ------------------------------------------------------------




creates_node(step(_, _, _, start, _, _, _, _)).
creates_node(step(_, _, _, apply, _, _, _, _)).




% ------------------------------------------------------------
% number_nodes(+NodeSteps, +N, -RawNodes)
%
% Assigns identifiers n0, n1, n2, ... in chronological order.
%
% raw(Id, Path, Depth, Goal, Clause, Pending, Bindings)
% ------------------------------------------------------------



number_nodes([], _, []).

number_nodes(
    [step(_, Path, Depth, _, Goal, Clause, Pending, Bindings) | Rest],
    N,
    [raw(Id, Path, Depth, Goal, Clause, Pending, Bindings) | Raws]
) :-
    atom_concat(n, N, Id),
    N1 is N + 1,
    number_nodes(Rest, N1, Raws).


% ------------------------------------------------------------
% raw_nodes(+Steps, -RawNodes)
% ------------------------------------------------------------

raw_nodes(Steps, RawNodes) :-
    include(creates_node, Steps, NodeSteps),
    number_nodes(NodeSteps, 0, RawNodes).



% ============================================================
% 3. PARENT-CHILD RELATIONSHIPS
% ============================================================

% ------------------------------------------------------------
% find_parent_id(+Path, +RawNodes, -ParentId)
%
% The root has no parent.
% Any other node: find the node whose path is the parent path.
% ------------------------------------------------------------

find_parent_id([], _, none) :- !.

find_parent_id(Path, RawNodes, ParentId) :-
    parent_path(Path, ParentPath),
    member(raw(ParentId, ParentPath, _, _, _, _, _), RawNodes).


% ------------------------------------------------------------
% link_node(+RawNodes, +Raw, -Linked)
%
% Adds the parent identifier to one raw node.
% ------------------------------------------------------------

link_node(
    RawNodes,
    raw(Id, Path, Depth, Goal, Clause, Pending, Bindings),
    linked(Id, ParentId, Path, Depth, Goal, Clause, Pending, Bindings)
) :-
    find_parent_id(Path, RawNodes, ParentId).


% ------------------------------------------------------------
% link_nodes(+RawNodes, -LinkedNodes)
% ------------------------------------------------------------

link_nodes(RawNodes, LinkedNodes) :-
    maplist(link_node(RawNodes), RawNodes, LinkedNodes).

% ============================================================
% 4. BRANCH STATUS
% ============================================================

% ------------------------------------------------------------
% terminal_action(?Action)
%
% Actions that end a branch.
% ------------------------------------------------------------

terminal_action(success).
terminal_action(failure).
terminal_action(cutoff).


% ------------------------------------------------------------
% terminal_outcome(+Path, +Steps, -Outcome)
%
% Outcome reported by Part A for a leaf node,
% or none if the node is not a leaf.
% ------------------------------------------------------------

terminal_outcome(Path, Steps, Outcome) :-
    member(step(_, Path, _, Outcome, _, _, _, _), Steps),
    terminal_action(Outcome),
    !.

terminal_outcome(_, _, none).


% ------------------------------------------------------------
% combine_status(+ChildStatuses, -Status)
%
% success > cutoff > failure
% ------------------------------------------------------------

combine_status(Statuses, success) :- member(success, Statuses), !.
combine_status(Statuses, cutoff)  :- member(cutoff, Statuses), !.
combine_status(_, failure).


% ------------------------------------------------------------
% branch_status(+Id, +Path, +LinkedNodes, +Steps, -Status)
%
% Leaf: its terminal outcome.
% Inner node: combination of the status of its children.
% ------------------------------------------------------------

branch_status(Id, Path, Linked, Steps, Status) :-
    terminal_outcome(Path, Steps, Outcome),
    (   Outcome \== none
    ->  Status = Outcome
    ;   findall(
            ChildStatus,
            (   member(linked(ChildId, Id, ChildPath, _, _, _, _, _), Linked),
                branch_status(ChildId, ChildPath, Linked, Steps, ChildStatus)
            ),
            ChildStatuses
        ),
        combine_status(ChildStatuses, Status)
    ).

% ============================================================
% 5. TREE CONSTRUCTION
% ============================================================

% ------------------------------------------------------------
% complete_node(+LinkedNodes, +Steps, +Linked, -Node)
%
% Adds the branch status to one linked node.
%
% node(Id, ParentId, Path, Depth, Goal, Clause,
%      Pending, Bindings, Status)
% ------------------------------------------------------------

complete_node(
    Linked,
    Steps,
    linked(Id, ParentId, Path, Depth, Goal, Clause, Pending, Bindings),
    node(Id, ParentId, Path, Depth, Goal, Clause, Pending, Bindings, Status)
) :-
    branch_status(Id, Path, Linked, Steps, Status).


% ------------------------------------------------------------
% build_tree(+Steps, -Nodes)
%
% Main predicate of Part B.
% Builds the SLD tree from the steps produced by sld_trace/4.
% ------------------------------------------------------------

build_tree(Steps, Nodes) :-
    raw_nodes(Steps, RawNodes),
    link_nodes(RawNodes, Linked),
    maplist(complete_node(Linked, Steps), Linked, Nodes).

    
% ============================================================
% SLD Resolution Tree Visualizer
% Part A - Structured Resolution Event Contract Tests
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Purpose:
% Verify the structured information produced by sld_trace/4.
%
% These tests validate the step/8 representation consumed
% by the SLD tree construction component (Part B).
%
% Required example programs:
% - examples/programs/family.pl
% - examples/programs/recursive_loop.pl
% ============================================================

:- use_module(library(plunit)).

:- use_module(library(lists), [
    member/2,
    memberchk/2
]).

:- use_module('../../src/prolog/engine/sld_engine.pl').


% ============================================================
% STRUCTURED EVENT CONTRACT TEST SUITE
% ============================================================

:- begin_tests(sld_step_contract).


% ------------------------------------------------------------
% Test 1: Initial resolution event.
%
% Verify:
% - Chronological sequence number
% - Initial resolution path
% - Initial depth
% - Selected query
% - Pending goals
% - Initial variable bindings
% ------------------------------------------------------------

test(initial_event_contract) :-

    sld_engine:sld_trace(
        parent(ana, _X),
        1,
        Steps,
        _Answers
    ),

    Expected = step(
        1,
        [],
        0,
        start,
        "parent(ana,A)",
        none,
        ["parent(ana,A)"],
        [binding("V1", "_")]
    ),

    Steps = [FirstStep | _],

    assertion(
        FirstStep == Expected
    ).


% ------------------------------------------------------------
% Test 2: Applied fact clause.
%
% Verify that the engine records the selected goal,
% the applied fact, the resulting path and bindings.
% ------------------------------------------------------------

test(applied_fact_clause_contract) :-

    sld_engine:sld_trace(
        parent(ana, _X),
        1,
        Steps,
        _Answers
    ),

    Expected = step(
        2,
        [1],
        1,
        apply,
        "parent(ana,A)",
        "parent(ana,luis)",
        [],
        [binding("V1", "luis")]
    ),

    assertion(
        memberchk(Expected, Steps)
    ).


% ------------------------------------------------------------
% Test 3: Remaining goals after unification.
%
% Verify that the engine preserves pending goals
% and substitutions after applying a clause.
% ------------------------------------------------------------

test(remaining_goals_contract) :-

    sld_engine:sld_trace(
        (
            parent(ana, X),
            parent(X, _Y)
        ),
        2,
        Steps,
        _Answers
    ),

    Expected = step(
        2,
        [1],
        1,
        apply,
        "parent(ana,A)",
        "parent(ana,luis)",
        ["parent(luis,A)"],
        [
            binding("V1", "luis"),
            binding("V2", "_")
        ]
    ),

    assertion(
        memberchk(Expected, Steps)
    ).


% ------------------------------------------------------------
% Test 4: Applied rule clause.
%
% Verify that the trace records the use of a Prolog rule,
% not only facts.
%
% The clause must contain a rule body and produce
% at least one pending parent goal.
% ------------------------------------------------------------

test(applied_rule_clause_contract) :-

    sld_engine:sld_trace(
        ancestor(luis, _X),
        2,
        Steps,
        _Answers
    ),

    once(
        (
            member(
                step(
                    _,
                    _,
                    _,
                    apply,
                    SelectedGoal,
                    AppliedClause,
                    RemainingGoals,
                    _
                ),
                Steps
            ),

            sub_string(
                SelectedGoal,
                0,
                8,
                _,
                "ancestor"
            ),

            sub_string(
                AppliedClause,
                _,
                _,
                _,
                ":-"
            ),

            member(
                RemainingGoal,
                RemainingGoals
            ),

            sub_string(
                RemainingGoal,
                0,
                6,
                _,
                "parent"
            )
        )
    ).


% ------------------------------------------------------------
% Test 5: Logical failure event.
%
% Verify that an unsatisfied goal is recorded as failure,
% including its resolution path and pending goal.
% ------------------------------------------------------------

test(logical_failure_event_contract) :-

    sld_engine:sld_trace(
        parent(diego, _X),
        1,
        Steps,
        Answers
    ),

    assertion(
        Answers == []
    ),

    Expected = step(
        2,
        [],
        0,
        failure,
        "parent(diego,A)",
        none,
        ["parent(diego,A)"],
        [binding("V1", "_")]
    ),

    assertion(
        memberchk(Expected, Steps)
    ).


% ------------------------------------------------------------
% Test 6: Depth cutoff event.
%
% Verify that potentially infinite recursion is recorded
% as cutoff at the configured maximum depth.
% ------------------------------------------------------------

test(depth_cutoff_event_contract) :-

    sld_engine:sld_trace(
        endless,
        3,
        Steps,
        Answers
    ),

    assertion(
        Answers == []
    ),

    Expected = step(
        5,
        [1, 1, 1],
        3,
        cutoff,
        "endless",
        none,
        ["endless"],
        []
    ),

    assertion(
        memberchk(Expected, Steps)
    ).


% ------------------------------------------------------------
% Test 7: Backtracking event.
%
% Verify that the engine records the restoration of
% the parent state before exploring another alternative.
% ------------------------------------------------------------

test(backtracking_event_contract) :-

    sld_engine:sld_trace(
        parent(ana, _X),
        1,
        Steps,
        _Answers
    ),

    Expected = step(
        4,
        [],
        0,
        backtrack,
        "parent(ana,A)",
        none,
        ["parent(ana,A)"],
        [binding("V1", "_")]
    ),

    assertion(
        memberchk(Expected, Steps)
    ).


:- end_tests(sld_step_contract).


% ============================================================
% END OF STRUCTURED EVENT CONTRACT TESTS
% ============================================================
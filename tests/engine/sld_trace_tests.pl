% ============================================================
% SLD Resolution Tree Visualizer
% Part A - Automated Resolution Trace Tests
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Required example programs:
% - examples/programs/family.pl
% - examples/programs/recursive_loop.pl
%
% ============================================================

:- use_module(library(plunit)).

:- use_module(library(lists), [
    member/2,
    memberchk/2
]).

:- use_module('../../src/prolog/engine/sld_engine.pl').


% ============================================================
% SLD RESOLUTION TRACE TEST SUITE
% ============================================================

:- begin_tests(sld_trace).


% ------------------------------------------------------------
% Test 1: Fact query with multiple solutions.
% ------------------------------------------------------------

test(fact_multiple_solutions) :-

    sld_trace(
        parent(ana, _X),
        1,
        _Steps,
        Answers
    ),

    assertion(
        Answers == [
            answer(
                [1],
                [binding("V1", "luis")]
            ),
            answer(
                [2],
                [binding("V1", "marta")]
            )
        ]
    ).


% ------------------------------------------------------------
% Test 2: Expected actions for fact resolution.
% ------------------------------------------------------------

test(fact_resolution_actions) :-

    sld_trace(
        parent(ana, _X),
        1,
        Steps,
        _Answers
    ),

    findall(
        Action,
        member(
            step(_, _, _, Action, _, _, _, _),
            Steps
        ),
        Actions
    ),

    assertion(
        Actions == [
            start,
            apply,
            success,
            backtrack,
            apply,
            success
        ]
    ).


% ------------------------------------------------------------
% Test 3: Chronological sequence numbering.
% ------------------------------------------------------------

test(chronological_step_numbers) :-

    sld_trace(
        parent(ana, _X),
        1,
        Steps,
        _Answers
    ),

    findall(
        Sequence,
        member(
            step(Sequence, _, _, _, _, _, _, _),
            Steps
        ),
        Sequences
    ),

    assertion(
        Sequences == [1, 2, 3, 4, 5, 6]
    ).


% ------------------------------------------------------------
% Test 4: Failed fact query.
% ------------------------------------------------------------

test(failed_fact_query) :-

    sld_trace(
        parent(diego, _X),
        2,
        Steps,
        Answers
    ),

    findall(
        Action,
        member(
            step(_, _, _, Action, _, _, _, _),
            Steps
        ),
        Actions
    ),

    assertion(
        Actions == [start, failure]
    ),

    assertion(
        Answers == []
    ).


% ------------------------------------------------------------
% Test 5: Depth limit zero.
% ------------------------------------------------------------

test(depth_limit_zero) :-

    sld_trace(
        parent(ana, _X),
        0,
        Steps,
        Answers
    ),

    findall(
        Action,
        member(
            step(_, _, _, Action, _, _, _, _),
            Steps
        ),
        Actions
    ),

    assertion(
        Actions == [start, cutoff]
    ),

    assertion(
        Answers == []
    ).


% ------------------------------------------------------------
% Test 6: Empty goal at depth zero.
% ------------------------------------------------------------

test(true_goal_at_depth_zero) :-

    sld_trace(
        true,
        0,
        Steps,
        Answers
    ),

    findall(
        Action,
        member(
            step(_, _, _, Action, _, _, _, _),
            Steps
        ),
        Actions
    ),

    assertion(
        Actions == [start, success]
    ),

    assertion(
        Answers == [answer([], [])]
    ).


% ------------------------------------------------------------
% Test 7: Conjunction with shared variables.
% ------------------------------------------------------------

test(conjunction_shared_variables) :-

    sld_trace(
        (
            parent(ana, X),
            parent(X, _Y)
        ),
        2,
        _Steps,
        Answers
    ),

    assertion(
        Answers == [
            answer(
                [1, 1],
                [
                    binding("V1", "luis"),
                    binding("V2", "sofia")
                ]
            ),
            answer(
                [2, 1],
                [
                    binding("V1", "marta"),
                    binding("V2", "diego")
                ]
            )
        ]
    ).


% ------------------------------------------------------------
% Test 8: Backtracking after a failed alternative.
% ------------------------------------------------------------

test(backtracking_after_failure) :-

    sld_trace(
        (
            parent(ana, X),
            parent(X, diego)
        ),
        2,
        Steps,
        Answers
    ),

    findall(
        Action,
        member(
            step(_, _, _, Action, _, _, _, _),
            Steps
        ),
        Actions
    ),

    assertion(
        Actions == [
            start,
            apply,
            failure,
            backtrack,
            apply,
            apply,
            success
        ]
    ),

    assertion(
        Answers == [
            answer(
                [2, 1],
                [binding("V1", "marta")]
            )
        ]
    ).


% ------------------------------------------------------------
% Test 9: Recursive ancestor solutions.
% ------------------------------------------------------------

test(recursive_ancestor_solutions) :-

    sld_trace(
        ancestor(ana, _X),
        4,
        _Steps,
        Answers
    ),

    assertion(
        Answers == [
            answer(
                [1, 1],
                [binding("V1", "luis")]
            ),
            answer(
                [1, 2],
                [binding("V1", "marta")]
            ),
            answer(
                [2, 1, 1, 1],
                [binding("V1", "sofia")]
            ),
            answer(
                [2, 2, 1, 1],
                [binding("V1", "diego")]
            )
        ]
    ).


% ------------------------------------------------------------
% Test 10: Recursive resolution step count.
% ------------------------------------------------------------

test(recursive_ancestor_step_count) :-

    sld_trace(
        ancestor(ana, _X),
        4,
        Steps,
        _Answers
    ),

    length(Steps, Count),

    assertion(
        Count == 26
    ).


% ------------------------------------------------------------
% Test 11: Infinite recursion cutoff.
% ------------------------------------------------------------

test(infinite_recursion_cutoff) :-

    sld_trace(
        endless,
        3,
        Steps,
        Answers
    ),

    findall(
        Action,
        member(
            step(_, _, _, Action, _, _, _, _),
            Steps
        ),
        Actions
    ),

    assertion(
        Actions == [
            start,
            apply,
            apply,
            apply,
            cutoff
        ]
    ),

    assertion(
        Answers == []
    ).


% ------------------------------------------------------------
% Test 12: Recursion with successful alternatives.
% ------------------------------------------------------------

test(recursion_with_successful_alternatives) :-

    sld_trace(
        loop,
        3,
        Steps,
        Answers
    ),

    findall(
        Action,
        (
            member(
                step(_, _, _, Action, _, _, _, _),
                Steps
            ),
            member(
                Action,
                [success, cutoff]
            )
        ),
        TerminalActions
    ),

    assertion(
        TerminalActions == [
            cutoff,
            success,
            success,
            success
        ]
    ),

    assertion(
        Answers == [
            answer([1, 1, 2], []),
            answer([1, 2], []),
            answer([2], [])
        ]
    ).


% ------------------------------------------------------------
% Test 13: Recorded steps must be ground.
% ------------------------------------------------------------

test(recorded_steps_are_ground) :-

    sld_trace(
        ancestor(ana, _X),
        4,
        Steps,
        _Answers
    ),

    forall(
        member(Step, Steps),
        assertion(ground(Step))
    ).


% ------------------------------------------------------------
% Test 14: Original query variables remain unbound.
% ------------------------------------------------------------

test(original_query_remains_unbound) :-

    sld_trace(
        parent(ana, X),
        1,
        _Steps,
        _Answers
    ),

    assertion(
        var(X)
    ).


% ------------------------------------------------------------
% Test 15: Alternative bindings remain independent.
%
% memberchk/2 checks membership without leaving
% unnecessary choicepoints.
% ------------------------------------------------------------

test(independent_alternative_bindings) :-

    sld_trace(
        parent(ana, _X),
        1,
        Steps,
        _Answers
    ),

    memberchk(
        step(
            _,
            [1],
            1,
            apply,
            _,
            _,
            _,
            [binding("V1", "luis")]
        ),
        Steps
    ),

    memberchk(
        step(
            _,
            [2],
            1,
            apply,
            _,
            _,
            _,
            [binding("V1", "marta")]
        ),
        Steps
    ).


% ------------------------------------------------------------
% Test 16: Negative depth limits are rejected.
% ------------------------------------------------------------

test(negative_depth_rejected, [fail]) :-

    sld_trace(
        parent(ana, _X),
        -1,
        _Steps,
        _Answers
    ).


% ------------------------------------------------------------
% Test 17: Non-integer depth limits are rejected.
% ------------------------------------------------------------

test(noninteger_depth_rejected, [fail]) :-

    sld_trace(
        parent(ana, _X),
        1.5,
        _Steps,
        _Answers
    ).


:- end_tests(sld_trace).


% ============================================================
% END OF AUTOMATED RESOLUTION TRACE TESTS
% ============================================================
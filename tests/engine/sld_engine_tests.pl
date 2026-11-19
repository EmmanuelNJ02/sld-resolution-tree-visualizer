% ============================================================
% SLD Resolution Tree Visualizer
% Part A - Individual Engine Tests
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
% ============================================================

:- use_module(library(plunit)).
:- use_module('../../src/prolog/engine/sld_engine.pl').

:- begin_tests(sld_engine).


% ------------------------------------------------------------
% 1. Facts and basic resolution
% ------------------------------------------------------------

test(fact_multiple_solutions) :-
    findall(
        X,
        sld_engine:sld_solve(parent(ana, X)),
        Results
    ),
    assertion(Results == [luis, marta]).


test(fact_failure, [fail]) :-
    sld_engine:sld_solve(parent(diego, _)).


% ------------------------------------------------------------
% 2. Conjunctions and unification
% ------------------------------------------------------------

test(conjunction_and_unification) :-
    findall(
        X-Y,
        sld_engine:sld_solve((
            parent(ana, X),
            parent(X, Y)
        )),
        Results
    ),
    assertion(Results == [luis-sofia, marta-diego]).


% ------------------------------------------------------------
% 3. Recursion and backtracking
% ------------------------------------------------------------

test(recursive_resolution) :-
    findall(
        X,
        sld_engine:sld_solve(ancestor(ana, X)),
        Results
    ),
    assertion(Results == [luis, marta, sofia, diego]).


test(backtracking_after_failed_alternative) :-
    findall(
        X,
        sld_engine:sld_solve((
            parent(ana, X),
            parent(X, diego)
        )),
        Results
    ),
    assertion(Results == [marta]).


% ------------------------------------------------------------
% 4. Empty goal
% ------------------------------------------------------------

test(empty_goal_success) :-
    findall(
        ok,
        sld_engine:sld_solve(true),
        Results
    ),
    assertion(Results == [ok]).


% ------------------------------------------------------------
% 5. Depth-limited resolution
% ------------------------------------------------------------

test(depth_limited_success) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            parent(ana, _), 1, Status
        ),
        Results
    ),
    assertion(Results == [success, success]).


test(depth_limit_cutoff) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            parent(ana, _), 0, Status
        ),
        Results
    ),
    assertion(Results == [cutoff]).


test(depth_limited_failure) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            parent(diego, _), 1, Status
        ),
        Results
    ),
    assertion(Results == [failure]).


% ------------------------------------------------------------
% 6. Recursive depth limits
% ------------------------------------------------------------

test(recursive_mixed_outcomes) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            ancestor(ana, _), 2, Status
        ),
        Results
    ),
    assertion(
        Results == [success, success, cutoff, cutoff]
    ).


test(recursive_solutions_with_sufficient_depth) :-
    findall(
        X,
        sld_engine:sld_solve_limited(
            ancestor(ana, X), 4, success
        ),
        Results
    ),
    assertion(
        Results == [luis, marta, sofia, diego]
    ).


test(empty_goal_with_zero_depth) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            true, 0, Status
        ),
        Results
    ),
    assertion(Results == [success]).


% ------------------------------------------------------------
% 7. Potentially infinite recursion
% ------------------------------------------------------------

test(infinite_recursion_cutoff) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            endless, 5, Status
        ),
        Results
    ),
    assertion(Results == [cutoff]).


test(left_recursion_with_base_alternative) :-
    findall(
        Status,
        sld_engine:sld_solve_limited(
            loop, 3, Status
        ),
        Results
    ),
    assertion(
        Results == [cutoff, success, success, success]
    ).


:- end_tests(sld_engine).
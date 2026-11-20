% ============================================================
% SLD Resolution Tree Visualizer
% Part A - Variable Aliasing Tests
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Required example program:
% - examples/programs/alias_demo.pl
%
% ============================================================

:- use_module(library(plunit)).

:- use_module('../../src/prolog/engine/sld_engine.pl').


% ============================================================
% VARIABLE ALIASING TEST SUITE
% ============================================================

:- begin_tests(sld_alias).


% ------------------------------------------------------------
% Test 1: Logical variable unification.
%
% Verify that aliased_pair/2 unifies both arguments
% without assigning a concrete value.
%
% Both arguments must remain unbound and represent
% the same logical variable.
%
% once/1 ensures deterministic test execution.
% ------------------------------------------------------------

test(logical_unification) :-

    once(
        sld_engine:sld_solve(
            aliased_pair(A, B)
        )
    ),

    assertion(
        var(A)
    ),

    assertion(
        var(B)
    ),

    assertion(
        A == B
    ).


% ------------------------------------------------------------
% Test 2: Aliased variables in the resolution trace.
%
% Verify that the trace preserves the relationship
% between two unified but still-unbound variables.
%
% Expected bindings:
%
% V1 = _
% V2 = alias(V1)
%
% The binding/2 representation must remain compatible
% with the SLD tree construction component (Part B).
% ------------------------------------------------------------

test(aliased_variables_in_trace) :-

    sld_engine:sld_trace(
        aliased_pair(_A, _B),
        1,
        _Steps,
        Answers
    ),

    Expected = [
        answer(
            [1],
            [
                binding("V1", "_"),
                binding("V2", "alias(V1)")
            ]
        )
    ],

    assertion(
        Answers == Expected
    ).


% ------------------------------------------------------------
% Test 3: Independent variables in the resolution trace.
%
% Verify that two independent unbound variables
% are not incorrectly represented as aliases.
%
% Expected bindings:
%
% V1 = _
% V2 = _
% ------------------------------------------------------------

test(independent_variables_in_trace) :-

    sld_engine:sld_trace(
        independent_pair(_A, _B),
        1,
        _Steps,
        Answers
    ),

    Expected = [
        answer(
            [1],
            [
                binding("V1", "_"),
                binding("V2", "_")
            ]
        )
    ],

    assertion(
        Answers == Expected
    ).


:- end_tests(sld_alias).


% ============================================================
% END OF VARIABLE ALIASING TESTS
% ============================================================
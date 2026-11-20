% ============================================================
% SLD Resolution Tree Visualizer
% Part A - SLD Engine Demonstration Cases
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Purpose:
% Define reproducible demonstration queries for the SLD engine.
%
% Each case specifies:
% - Case identifier
% - Scenario description
% - Prolog query
% - Maximum resolution depth
% - Expected number of successful answers
%
% These cases cover:
% - Facts
% - Rules
% - Unification
% - Conjunctions
% - Multiple solutions
% - Failed queries
% - Recursion
% - Backtracking
% - Depth limits
% ============================================================

:- module(sld_demo_cases, [
    demo_case/5
]).


% ============================================================
% DEMONSTRATION CASE FORMAT
% ============================================================

% demo_case(
%     +Id,
%     +Description,
%     -Query,
%     +MaxDepth,
%     +ExpectedAnswers
% ).
%
% Id:
%   Unique demonstration case identifier.
%
% Description:
%   Scenario being demonstrated.
%
% Query:
%   Prolog query to be resolved by the SLD engine.
%
% MaxDepth:
%   Maximum number of clause applications per branch.
%
% ExpectedAnswers:
%   Expected number of successful solutions.
%
% Note:
%   An expected answer count of zero may represent
%   either failure or depth cutoff.
%   These outcomes must be distinguished using
%   the resolution trace.
% ============================================================


% ============================================================
% 1. FACTS AND MULTIPLE SOLUTIONS
% ============================================================

demo_case(
    1,
    'Multiple solutions from facts',
    parent(ana, _Child),
    1,
    2
).


% ============================================================
% 2. SINGLE FACT SOLUTION
% ============================================================

demo_case(
    2,
    'Single fact solution - Luis',
    parent(luis, _Child),
    1,
    1
).


% ============================================================
% 3. ANOTHER SINGLE FACT SOLUTION
% ============================================================

demo_case(
    3,
    'Single fact solution - Marta',
    parent(marta, _Child),
    1,
    1
).


% ============================================================
% 4. FAILED FACT QUERY
% ============================================================

demo_case(
    4,
    'Failed fact query',
    parent(diego, _Child),
    1,
    0
).


% ============================================================
% 5. SUCCESSFUL GROUND QUERY
% ============================================================

demo_case(
    5,
    'Successful ground query',
    parent(ana, luis),
    1,
    1
).


% ============================================================
% 6. FAILED GROUND QUERY
% ============================================================

demo_case(
    6,
    'Failed ground query',
    parent(ana, sofia),
    1,
    0
).


% ============================================================
% 7. CONJUNCTION AND SHARED VARIABLES
% ============================================================

demo_case(
    7,
    'Conjunction and shared variables',
    (
        parent(ana, X),
        parent(X, _Y)
    ),
    2,
    2
).


% ============================================================
% 8. BACKTRACKING AFTER FAILURE
% ============================================================

demo_case(
    8,
    'Backtracking after a failed alternative',
    (
        parent(ana, X),
        parent(X, diego)
    ),
    2,
    1
).


% ============================================================
% 9. RECURSIVE RESOLUTION
% ============================================================

demo_case(
    9,
    'Recursive ancestor resolution',
    ancestor(ana, _Descendant),
    4,
    4
).


% ============================================================
% 10. RECURSIVE RULE WITH ONE SOLUTION
% ============================================================

demo_case(
    10,
    'Recursive predicate with one solution',
    ancestor(luis, _Descendant),
    2,
    1
).


% ============================================================
% 11. INFINITE RECURSION CONTROL
% ============================================================

demo_case(
    11,
    'Infinite recursion stopped by depth limit',
    endless,
    3,
    0
).


% ============================================================
% 12. RECURSION WITH SUCCESSFUL ALTERNATIVES
% ============================================================

demo_case(
    12,
    'Left recursion with successful alternatives',
    loop,
    3,
    3
).


% ============================================================
% END OF DEMONSTRATION CASES
% ============================================================
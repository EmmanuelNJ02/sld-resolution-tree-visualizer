% ============================================================
% SLD Resolution Tree Visualizer
% Part A - SLD Meta-Interpreter and Resolution Engine
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
% ============================================================
%
% Implemented:
% - Facts and definite Horn-clause rules
% - Leftmost goal selection
% - Unification
% - Recursive resolution
% - Backtracking
% - Multiple solutions
% - Configurable depth limit
% - Success, failure, and cutoff outcomes
%
% Pending:
% - Resolution step generation
% - Complete automated tests
% - Integration with Part B
% ============================================================

:- module(sld_engine, [
    sld_solve/1,
    sld_solve_limited/3
]).

:- use_module(library(lists), [append/3]).


% ============================================================
% 1. BASIC SLD META-INTERPRETER
% ============================================================

% ------------------------------------------------------------
% sld_solve(+Query)
%
% Resolves a query using SLD resolution.
% This initial predicate does not enforce a depth limit.
% ------------------------------------------------------------

sld_solve(Query) :-
    goals_to_list(Query, Goals),
    resolve_goals(Goals).


% ------------------------------------------------------------
% goals_to_list(+Query, -Goals)
%
% Converts a conjunction into a list of goals.
% ------------------------------------------------------------

goals_to_list(true, []).

goals_to_list((Left, Right), Goals) :-
    goals_to_list(Left, LeftGoals),
    goals_to_list(Right, RightGoals),
    append(LeftGoals, RightGoals, Goals).

goals_to_list(Goal, [Goal]) :-
    callable(Goal),
    Goal \== true,
    Goal \= (_, _).


% ------------------------------------------------------------
% resolve_goals(+Goals)
%
% Resolves the pending goals using leftmost selection.
% ------------------------------------------------------------

% Success: no pending goals.

resolve_goals([]).

% Resolve the leftmost goal.

resolve_goals([Goal | PendingGoals]) :-
    clause(user:Goal, Body),
    goals_to_list(Body, BodyGoals),
    append(BodyGoals, PendingGoals, NextGoals),
    resolve_goals(NextGoals).


% ============================================================
% 2. DEPTH-LIMITED SLD RESOLUTION
% ============================================================

% ------------------------------------------------------------
% sld_solve_limited(+Query, +MaxDepth, -Outcome)
%
% Resolves a query with a configurable depth limit.
%
% The predicate explores alternatives through backtracking
% and reports terminal outcomes for individual branches.
%
% Possible outcomes:
%
% success - All goals have been satisfied.
% failure - No applicable clause exists for a selected goal.
% cutoff  - The depth limit prevents further expansion.
% ------------------------------------------------------------

sld_solve_limited(Query, MaxDepth, Outcome) :-
    integer(MaxDepth),
    MaxDepth >= 0,
    goals_to_list(Query, Goals),
    resolve_limited(Goals, 0, MaxDepth, Outcome).


% ------------------------------------------------------------
% resolve_limited(+Goals, +Depth, +MaxDepth, -Outcome)
%
% Performs depth-limited SLD resolution.
% ------------------------------------------------------------

% Case 1:
% All goals have been satisfied.

resolve_limited([], _, _, success).


% Case 2:
% The maximum depth has been reached while goals remain.

resolve_limited([_ | _], Depth, MaxDepth, cutoff) :-
    Depth >= MaxDepth.


% Case 3:
% Select an applicable clause and continue resolution.

resolve_limited([Goal | PendingGoals], Depth, MaxDepth, Outcome) :-
    Depth < MaxDepth,

    % Select and unify an applicable clause.
    clause(user:Goal, Body),

    % Obtain the goals from the clause body.
    goals_to_list(Body, BodyGoals),

    % Replace the selected goal with the clause body.
    append(BodyGoals, PendingGoals, NextGoals),

    % Increase the resolution depth.
    NextDepth is Depth + 1,

    % Continue resolving the remaining goals.
    resolve_limited(NextGoals, NextDepth, MaxDepth, Outcome).


% Case 4:
% No clause can be unified with the selected goal.

resolve_limited([Goal | _], Depth, MaxDepth, failure) :-
    Depth < MaxDepth,
    \+ clause(user:Goal, _).
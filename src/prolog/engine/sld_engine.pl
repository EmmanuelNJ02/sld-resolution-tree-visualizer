% ============================================================
% SLD Resolution Tree Visualizer
% Part A - SLD Meta-Interpreter and Resolution Engine
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
% ============================================================
%
% Initial implementation:
% - Facts and definite Horn-clause rules
% - Leftmost goal selection
% - Unification
% - Recursive resolution
% - Prolog backtracking
%
% Pending:
% - Configurable depth limit
% - Resolution step generation
% - Complete individual tests
% ============================================================

:- module(sld_engine, [
    sld_solve/1
]).

:- use_module(library(lists), [append/3]).

% ------------------------------------------------------------
% sld_solve(+Query)
%
% Entry point for the initial SLD meta-interpreter.
%
% Query is a logical goal or a conjunction of goals.
% ------------------------------------------------------------

sld_solve(Query) :-
    goals_to_list(Query, Goals),
    resolve_goals(Goals).


% ------------------------------------------------------------
% goals_to_list(+Query, -Goals)
%
% Converts a goal or conjunction into a list of goals.
% ------------------------------------------------------------

% The empty goal succeeds.

goals_to_list(true, []).

% A conjunction is converted into a list.

goals_to_list((Left, Right), Goals) :-
    goals_to_list(Left, LeftGoals),
    goals_to_list(Right, RightGoals),
    append(LeftGoals, RightGoals, Goals).

% An individual goal becomes a one-element list.

goals_to_list(Goal, [Goal]) :-
    callable(Goal),
    Goal \== true,
    Goal \= (_, _).


% ------------------------------------------------------------
% resolve_goals(+Goals)
%
% Resolves the pending goals using SLD resolution.
% ------------------------------------------------------------

% Success: no goals remain to be resolved.

resolve_goals([]).

% Select the leftmost goal and resolve it.

resolve_goals([Goal | PendingGoals]) :-

    % Select an applicable clause from the user program.
    % Unification is performed by Prolog.
    clause(user:Goal, Body),

    % Convert the clause body into a list of goals.
    goals_to_list(Body, BodyGoals),

    % Replace the selected goal with the clause body.
    append(BodyGoals, PendingGoals, NextGoals),

    % Continue resolving the remaining goals.
    resolve_goals(NextGoals).
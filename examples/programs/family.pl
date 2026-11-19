% ============================================================
% SLD Resolution Tree Visualizer
% Example Program: Family Relationships
% EIF400 - Programming Paradigms
% Autor: Emmanuel Nunez Jimenez
% Group 04-10am
% ============================================================

% Facts

parent(ana, luis).
parent(ana, marta).
parent(luis, sofia).
parent(marta, diego).

% Rules

% Base case
ancestor(X, Y) :-
    parent(X, Y).

% Recursive case
ancestor(X, Y) :-
    parent(X, Z),
    ancestor(Z, Y).
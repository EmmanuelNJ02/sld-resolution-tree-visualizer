% ============================================================
% SLD Resolution Tree Visualizer
% Example Program: Recursive Loops
%
% EIF400 - Programming Paradigms
% Author: Emmanuel Nunez Jimenez
% Group 04-10am
% ============================================================
%
% These predicates demonstrate potentially infinite recursion.
%
% IMPORTANT:
% Test them only with the depth-limited meta-interpreter.
% ============================================================

% ------------------------------------------------------------
% Example 1: Infinite recursion without a base case
% ------------------------------------------------------------

endless :-
    endless.


% ------------------------------------------------------------
% Example 2: Left recursion with an alternative base fact
% ------------------------------------------------------------

loop :-
    loop.

loop.
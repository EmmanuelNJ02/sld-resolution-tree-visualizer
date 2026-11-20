% ============================================================
% SLD Resolution Tree Visualizer
% Variable Unification Diagnostic
% Part A - Emmanuel Nunez Jimenez
% ============================================================

% Both arguments refer to the same logical variable.
aliased_pair(X, X).

% Both arguments are independent variables.
independent_pair(_, _).
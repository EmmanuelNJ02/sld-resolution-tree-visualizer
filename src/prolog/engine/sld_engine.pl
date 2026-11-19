% ============================================================
% SLD Resolution Tree Visualizer
% Part A - SLD Meta-Interpreter and Resolution Engine
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
% Instructor: Carlos Loria-Saenz
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
% - Stable resolution snapshots
% - Resolution event generation
% - Clause alternative tracking
% - Chronological trace numbering
% - Aggregated resolution traces
%
% Pending:
% - Final regression verification
% - Integration contract validation with Part B
% - Technical documentation and demonstration
%
% Supported language subset:
% - Facts
% - Definite Horn-clause rules
% - Conjunctions of goals
% - Recursive predicates
% - Variable unification
%
% Not supported:
% - Prolog cut (!) in interpreted programs
% - Dynamic database modifications
% - General built-in predicates
% - Negation-as-failure in interpreted programs
% - Disjunction as a separate query construct
% - Complete Prolog language interpretation
%
% ============================================================


:- module(sld_engine, [
    sld_solve/1,
    sld_solve_limited/3,
    sld_trace/4
]).

:- use_module(library(lists), [append/3]).


% ============================================================
% 1. BASIC SLD META-INTERPRETER
% ============================================================

% ------------------------------------------------------------
% sld_solve(+Query)
%
% Resolves a Prolog query using SLD resolution.
%
% Supports facts, rules, conjunctions, recursion,
% backtracking and multiple solutions.
%
% This predicate does not enforce a depth limit.
%
% WARNING:
% Infinite recursive branches may not terminate.
% ------------------------------------------------------------

sld_solve(Query) :-
    goals_to_list(Query, Goals),
    resolve_goals(Goals).


% ------------------------------------------------------------
% goals_to_list(+Query, -Goals)
%
% Converts a conjunction into a list of goals.
%
% Examples:
%
% true
%   -> []
%
% parent(ana, X)
%   -> [parent(ana, X)]
%
% (parent(ana, X), parent(X, Y))
%   -> [parent(ana, X), parent(X, Y)]
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
% Resolves pending goals using leftmost selection.
% ------------------------------------------------------------

% Success: no pending goals remain.

resolve_goals([]).


% Select and resolve the leftmost goal.

resolve_goals([Goal | PendingGoals]) :-

    % Select and unify an applicable clause.
    clause(user:Goal, Body),

    % Convert the clause body into goals.
    goals_to_list(Body, BodyGoals),

    % Replace the selected goal with its body goals.
    append(
        BodyGoals,
        PendingGoals,
        NextGoals
    ),

    % Continue resolution.
    resolve_goals(NextGoals).


% ============================================================
% 2. DEPTH-LIMITED SLD RESOLUTION
% ============================================================

% ------------------------------------------------------------
% sld_solve_limited(+Query, +MaxDepth, -Outcome)
%
% Performs depth-limited SLD resolution.
%
% Each terminal branch produces an outcome:
%
% success - All pending goals have been satisfied.
% failure - No applicable clause exists.
% cutoff  - The depth limit prevents further resolution.
%
% Outcomes are explored through backtracking.
%
% A cutoff does not imply logical failure.
% ------------------------------------------------------------

sld_solve_limited(Query, MaxDepth, Outcome) :-

    % Validate the depth limit.
    integer(MaxDepth),
    MaxDepth >= 0,

    % Convert the query into goals.
    goals_to_list(Query, Goals),

    % Start at depth zero.
    resolve_limited(
        Goals,
        0,
        MaxDepth,
        Outcome
    ).


% ------------------------------------------------------------
% resolve_limited(+Goals, +Depth, +MaxDepth, -Outcome)
%
% Depth counts the number of applied clauses.
% ------------------------------------------------------------

% Case 1: Success.

resolve_limited([], _, _, success).


% Case 2: Depth cutoff.

resolve_limited([_ | _], Depth, MaxDepth, cutoff) :-
    Depth >= MaxDepth.


% Case 3: Apply an applicable clause.

resolve_limited(
    [Goal | PendingGoals],
    Depth,
    MaxDepth,
    Outcome
) :-

    Depth < MaxDepth,

    % Select an applicable clause.
    clause(user:Goal, Body),

    % Obtain its body goals.
    goals_to_list(Body, BodyGoals),

    % Replace the selected goal.
    append(
        BodyGoals,
        PendingGoals,
        NextGoals
    ),

    % Increase depth.
    NextDepth is Depth + 1,

    % Continue resolution.
    resolve_limited(
        NextGoals,
        NextDepth,
        MaxDepth,
        Outcome
    ).


% Case 4: No applicable clause exists.

resolve_limited(
    [Goal | _],
    Depth,
    MaxDepth,
    failure
) :-

    Depth < MaxDepth,

    \+ clause(user:Goal, _).


% ============================================================
% 3. RESOLUTION SNAPSHOT HELPERS
% ============================================================

% ------------------------------------------------------------
% snapshot_term(+Term, -Text)
%
% Creates a stable textual representation of a term.
%
% The original term is not modified.
% ------------------------------------------------------------

snapshot_term(Term, Text) :-

    % Copy the original term.
    copy_term(Term, Copy),

    % Assign readable identifiers to unbound variables.
    numbervars(Copy, 0, _),

    % Convert the copied term into text.
    term_string(
        Copy,
        Text,
        [
            quoted(true),
            numbervars(true)
        ]
    ).


% ------------------------------------------------------------
% snapshot_goals(+Goals, -Snapshots)
%
% Creates stable textual snapshots of pending goals.
%
% The complete list is copied together to preserve
% variable sharing between different goals.
% ------------------------------------------------------------

snapshot_goals(Goals, Snapshots) :-

    copy_term(Goals, CopiedGoals),

    numbervars(CopiedGoals, 0, _),

    snapshot_numbered_goals(
        CopiedGoals,
        Snapshots
    ).


% ------------------------------------------------------------
% snapshot_numbered_goals(+Goals, -Snapshots)
%
% Converts already-numbered goals into strings.
% ------------------------------------------------------------

snapshot_numbered_goals([], []).

snapshot_numbered_goals(
    [Goal | Rest],
    [Text | Snapshots]
) :-

    term_string(
        Goal,
        Text,
        [
            quoted(true),
            numbervars(true)
        ]
    ),

    snapshot_numbered_goals(
        Rest,
        Snapshots
    ).


% ------------------------------------------------------------
% snapshot_bindings(+Variables, -Bindings)
%
% Creates stable bindings for the original query variables.
%
% Variables are identified as:
%
% V1, V2, V3, ...
%
% Unbound variables are represented by "_".
%
% Example:
%
% [
%   binding("V1", "luis"),
%   binding("V2", "_")
% ]
% ------------------------------------------------------------

snapshot_bindings(Variables, Bindings) :-

    snapshot_bindings(
        Variables,
        1,
        Bindings
    ).


% ------------------------------------------------------------
% snapshot_bindings(+Variables, +Index, -Bindings)
%
% Auxiliary predicate.
% ------------------------------------------------------------

snapshot_bindings([], _, []).

snapshot_bindings(
    [Variable | Rest],
    Index,
    [binding(Name, Value) | Bindings]
) :-

    % Generate a stable variable identifier.
    format(
        string(Name),
        'V~d',
        [Index]
    ),

    % Capture the current variable value.
    (
        var(Variable)
    ->
        Value = "_"
    ;
        snapshot_term(Variable, Value)
    ),

    % Continue with the next variable.
    NextIndex is Index + 1,

    snapshot_bindings(
        Rest,
        NextIndex,
        Bindings
    ).


% ============================================================
% 4. SLD RESOLUTION TRACE
% ============================================================

% ------------------------------------------------------------
% sld_trace(+Query, +MaxDepth, -Steps, -Answers)
%
% Public interface for SLD resolution tracing.
%
% Steps:
%   Chronologically ordered list of step/8 terms.
%
% Answers:
%   Successful solutions represented as:
%
%   answer(Path, Bindings)
%
% Supported trace actions:
%
% start
% apply
% success
% failure
% cutoff
% backtrack
%
% This predicate returns one aggregated result.
%
% The internal exploration records all alternatives
% before returning the complete trace.
% ------------------------------------------------------------

sld_trace(Query, MaxDepth, Steps, Answers) :-

    once(
        sld_trace_collect(
            Query,
            MaxDepth,
            Steps,
            Answers
        )
    ).


% ------------------------------------------------------------
% sld_trace_collect(+Query, +MaxDepth, -Steps, -Answers)
%
% Collects the complete depth-limited resolution trace.
%
% This auxiliary predicate performs the actual exploration.
%
% The public interface sld_trace/4 commits to the completed
% result after all alternatives have been collected.
% ------------------------------------------------------------

sld_trace_collect(Query, MaxDepth, Steps, Answers) :-

    % Validate the depth limit.
    integer(MaxDepth),
    MaxDepth >= 0,

    % Convert the query into a list of goals.
    goals_to_list(Query, Goals),

    % Identify the original query variables.
    term_variables(Query, Variables),

    % Capture the initial query.
    snapshot_term(Query, QueryText),

    % Capture initial pending goals.
    snapshot_goals(
        Goals,
        InitialGoals
    ),

    % Capture initial variable bindings.
    snapshot_bindings(
        Variables,
        InitialBindings
    ),

    % Record the initial resolution event.
    StartEvent = event(
        [],
        0,
        start,
        QueryText,
        none,
        InitialGoals,
        InitialBindings
    ),

    % Explore all depth-limited resolution branches.
    trace_resolve(
        Goals,
        Variables,
        0,
        MaxDepth,
        [],
        ResolutionEvents,
        Answers
    ),

    % Include the initial event.
    Events = [StartEvent | ResolutionEvents],

    % Assign chronological sequence numbers.
    number_trace_events(
        Events,
        1,
        Steps
    ).


% ============================================================
% 5. RESOLUTION TRACE EXPLORATION
% ============================================================

% ------------------------------------------------------------
% trace_resolve(
%     +Goals,
%     +Variables,
%     +Depth,
%     +MaxDepth,
%     +Path,
%     -Events,
%     -Answers
% )
%
% Explores resolution branches using independent states.
% ------------------------------------------------------------


% ------------------------------------------------------------
% Case 1: Success.
%
% All pending goals have been satisfied.
% ------------------------------------------------------------

trace_resolve(
    [],
    Variables,
    Depth,
    _,
    Path,
    [
        event(
            Path,
            Depth,
            success,
            none,
            none,
            [],
            Bindings
        )
    ],
    [
        answer(
            Path,
            Bindings
        )
    ]
) :-

    snapshot_bindings(
        Variables,
        Bindings
    ).


% ------------------------------------------------------------
% Case 2: Depth cutoff.
%
% Unresolved goals remain at the maximum depth.
% ------------------------------------------------------------

trace_resolve(
    [Goal | PendingGoals],
    Variables,
    Depth,
    MaxDepth,
    Path,
    [
        event(
            Path,
            Depth,
            cutoff,
            GoalText,
            none,
            RemainingGoals,
            Bindings
        )
    ],
    []
) :-

    Depth >= MaxDepth,

    snapshot_term(
        Goal,
        GoalText
    ),

    snapshot_goals(
        [Goal | PendingGoals],
        RemainingGoals
    ),

    snapshot_bindings(
        Variables,
        Bindings
    ).


% ------------------------------------------------------------
% Case 3: Explore applicable clauses.
% ------------------------------------------------------------

trace_resolve(
    [Goal | PendingGoals],
    Variables,
    Depth,
    MaxDepth,
    Path,
    Events,
    Answers
) :-

    Depth < MaxDepth,

    Goals = [Goal | PendingGoals],

    snapshot_term(
        Goal,
        GoalText
    ),

    % Collect all applicable clauses.
    findall(
        choice(
            NextGoals,
            CopiedVariables,
            ClauseText,
            RemainingSnapshot,
            AppliedBindings
        ),
        (
            % Create an independent resolution state.
            copy_term(
                (Goals, Variables),
                (CopiedGoals, CopiedVariables)
            ),

            % Select the leftmost goal.
            CopiedGoals = [
                CopiedGoal | CopiedPending
            ],

            % Select and unify an applicable clause.
            clause(user:CopiedGoal, Body),

            % Represent the selected fact or rule.
            (
                Body == true
            ->
                ClauseTerm = CopiedGoal
            ;
                ClauseTerm = (CopiedGoal :- Body)
            ),

            snapshot_term(
                ClauseTerm,
                ClauseText
            ),

            % Convert the clause body into goals.
            goals_to_list(
                Body,
                BodyGoals
            ),

            % Replace the selected goal.
            append(
                BodyGoals,
                CopiedPending,
                NextGoals
            ),

            % Capture the remaining goals.
            snapshot_goals(
                NextGoals,
                RemainingSnapshot
            ),

            % Capture updated variable bindings.
            snapshot_bindings(
                CopiedVariables,
                AppliedBindings
            )
        ),
        Choices
    ),

    % Check whether applicable clauses were found.
    (
        Choices = []
    ->
        % No applicable clause: failure.
        snapshot_goals(
            Goals,
            RemainingGoals
        ),

        snapshot_bindings(
            Variables,
            Bindings
        ),

        Events = [
            event(
                Path,
                Depth,
                failure,
                GoalText,
                none,
                RemainingGoals,
                Bindings
            )
        ],

        Answers = []

    ;
        % Explore all applicable alternatives.
        trace_choices(
            Choices,
            GoalText,
            Goals,
            Variables,
            Depth,
            MaxDepth,
            Path,
            1,
            Events,
            Answers
        )
    ).


% ============================================================
% 6. CLAUSE ALTERNATIVES AND BACKTRACKING
% ============================================================

% ------------------------------------------------------------
% trace_choices(
%     +Choices,
%     +GoalText,
%     +OriginalGoals,
%     +OriginalVariables,
%     +Depth,
%     +MaxDepth,
%     +Path,
%     +ChoiceIndex,
%     -Events,
%     -Answers
% )
%
% Explores applicable clauses in their defined order.
%
% Each alternative receives a distinct resolution path.
%
% A backtrack event is recorded when another applicable
% alternative remains to be explored.
% ------------------------------------------------------------

trace_choices(
    [
        choice(
            NextGoals,
            ChoiceVariables,
            ClauseText,
            RemainingSnapshot,
            AppliedBindings
        )
        | OtherChoices
    ],
    GoalText,
    OriginalGoals,
    OriginalVariables,
    Depth,
    MaxDepth,
    Path,
    ChoiceIndex,
    Events,
    Answers
) :-

    % Extend the path with the selected clause position.
    append(
        Path,
        [ChoiceIndex],
        ChildPath
    ),

    % A clause application increases the depth.
    ChildDepth is Depth + 1,

    % Record the clause application.
    ApplyEvent = event(
        ChildPath,
        ChildDepth,
        apply,
        GoalText,
        ClauseText,
        RemainingSnapshot,
        AppliedBindings
    ),

    % Explore this alternative.
    trace_resolve(
        NextGoals,
        ChoiceVariables,
        ChildDepth,
        MaxDepth,
        ChildPath,
        BranchEvents,
        BranchAnswers
    ),

    % Explore remaining alternatives, if any.
    (
        OtherChoices = []
    ->
        LaterEvents = [],
        LaterAnswers = []

    ;
        % Restore the parent-state snapshots.
        snapshot_goals(
            OriginalGoals,
            OriginalSnapshot
        ),

        snapshot_bindings(
            OriginalVariables,
            OriginalBindings
        ),

        % Record the return to the parent alternative.
        BacktrackEvent = event(
            Path,
            Depth,
            backtrack,
            GoalText,
            none,
            OriginalSnapshot,
            OriginalBindings
        ),

        % Move to the next clause alternative.
        NextChoiceIndex is ChoiceIndex + 1,

        trace_choices(
            OtherChoices,
            GoalText,
            OriginalGoals,
            OriginalVariables,
            Depth,
            MaxDepth,
            Path,
            NextChoiceIndex,
            NextEvents,
            LaterAnswers
        ),

        LaterEvents = [
            BacktrackEvent | NextEvents
        ]
    ),

    % Preserve chronological event order.
    append(
        [ApplyEvent | BranchEvents],
        LaterEvents,
        Events
    ),

    % Collect successful answers.
    append(
        BranchAnswers,
        LaterAnswers,
        Answers
    ).


% ============================================================
% 7. CHRONOLOGICAL EVENT NUMBERING
% ============================================================

% ------------------------------------------------------------
% number_trace_events(+Events, +Sequence, -Steps)
%
% Converts internal event/7 terms into public step/8 terms.
%
% Sequence numbers begin at one.
% ------------------------------------------------------------

number_trace_events([], _, []).

number_trace_events(
    [
        event(
            Path,
            Depth,
            Action,
            Goal,
            Clause,
            RemainingGoals,
            Bindings
        )
        | Rest
    ],
    Sequence,
    [
        step(
            Sequence,
            Path,
            Depth,
            Action,
            Goal,
            Clause,
            RemainingGoals,
            Bindings
        )
        | Steps
    ]
) :-

    NextSequence is Sequence + 1,

    number_trace_events(
        Rest,
        NextSequence,
        Steps
    ).


% ============================================================
% 8. INTEGRATION CONTRACT
% ============================================================
%
% Public interface:
%
% sld_trace(+Query, +MaxDepth, -Steps, -Answers)
%
% Resolution step:
%
% step(
%     Sequence,
%     Path,
%     Depth,
%     Action,
%     Goal,
%     Clause,
%     RemainingGoals,
%     Bindings
% )
%
% Field definitions:
%
% Sequence:
%   Positive integer indicating chronological order.
%
% Path:
%   List of clause-choice positions.
%   Root path: [].
%
% Depth:
%   Number of clause applications on the current branch.
%
% Action:
%   start, apply, success, failure, cutoff, backtrack.
%
% Goal:
%   Stable textual representation or none.
%
% Clause:
%   Stable textual representation or none.
%
% RemainingGoals:
%   List of stable textual goal representations.
%
% Bindings:
%   List of binding(VariableName, Value) terms.
%
% Answers:
%   List of answer(Path, Bindings) terms.
%
% Part A:
%   Produces resolution information.
%
% Part B:
%   Constructs the SLD tree and exports JSON.
%
% Part C:
%   Visualizes the JSON in a web browser.
%
% The interface must be validated with Roy before
% final integration.
%
% ============================================================
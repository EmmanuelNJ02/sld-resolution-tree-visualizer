% ============================================================
% SLD Resolution Tree Visualizer
% Part A - SLD Engine Demonstration Runner
%
% Author: Emmanuel Nunez Jimenez
% Course: EIF400 - Programming Paradigms
% Group: 04-10am
%
% Purpose:
% Execute and verify reproducible SLD engine demonstrations.
%
% Public predicates:
%
%   run_all/0
%   run_case/1
%
% Verification includes:
%
% - Expected number of answers
% - Expected variable bindings
% - Chronological resolution events
% - Successful resolution events
% - Logical failure events
% - Backtracking events
% - Recursive resolution
% - Depth cutoff events
%
% This module displays and verifies resolution information.
% Logical resolution is implemented by sld_engine.pl.
% ============================================================

:- module(sld_demo_runner, [
    run_all/0,
    run_case/1
]).

:- use_module('sld_demo_cases.pl', [
    demo_case/5
]).

:- use_module('../../src/prolog/engine/sld_engine.pl', [
    sld_trace/4
]).

:- use_module(library(lists), [
    member/2,
    memberchk/2
]).

:- use_module(library(apply), [
    maplist/2,
    include/3
]).


% ============================================================
% 1. DISPLAY UTILITIES
% ============================================================

print_divider :-
    format(
        '======================================================================~n',
        []
    ).


print_short_divider :-
    format(
        '  --------------------------------------------------------------------~n',
        []
    ).


print_section(Title) :-
    format('~n', []),
    print_divider,
    format('  ~w~n', [Title]),
    print_divider.


% ============================================================
% 2. COMPLETE DEMONSTRATION SUMMARY
% ============================================================

% ------------------------------------------------------------
% run_all/0
%
% Executes all registered demonstration cases.
%
% Every case is verified using:
%
% - Answer count
% - Expected variable bindings
% - Resolution trace structure
% - Required resolution events
%
% All results are displayed before the final summary.
%
% The predicate raises an error if any case fails.
% ------------------------------------------------------------

run_all :-

    findall(
        Id,
        demo_case(Id, _, _, _, _),
        Ids
    ),

    length(Ids, Total),

    print_section(
        'PART A - DEMONSTRATION SUMMARY'
    ),

    format(
        '~n  Total demonstration cases: ~d~n~n',
        [Total]
    ),

    padded_cell(
        'Scenario',
        48,
        ScenarioHeader
    ),

    format(
        ' No.  | ~s | Exp. | Got  | Result~n',
        [ScenarioHeader]
    ),

    format(
        '------+--------------------------------------------------+------+------+----------------~n',
        []
    ),

    maplist(
        run_summary_case,
        Ids,
        Results
    ),

    include(
        ==(passed),
        Results,
        PassedResults
    ),

    length(
        PassedResults,
        Passed
    ),

    format('~n', []),

    print_divider,

    format(
        '  Total passed: ~d / ~d~n',
        [Passed, Total]
    ),

    print_divider,

    (
        Passed =:= Total
    ->
        true
    ;
        throw(
            error(
                demonstration_suite_failed(
                    Passed,
                    Total
                ),
                _
            )
        )
    ).


% ------------------------------------------------------------
% run_summary_case(+Id, -Result)
%
% Executes and verifies one demonstration case.
% ------------------------------------------------------------

run_summary_case(Id, Result) :-

    once(
        demo_case(
            Id,
            Description,
            Query,
            MaxDepth,
            Expected
        )
    ),

    sld_trace(
        Query,
        MaxDepth,
        Steps,
        Answers
    ),

    length(
        Answers,
        Actual
    ),

    verify_case(
        Id,
        Expected,
        Steps,
        Answers,
        Result
    ),

    padded_cell(
        Id,
        4,
        IdCell
    ),

    padded_cell(
        Description,
        48,
        DescriptionCell
    ),

    padded_cell(
        Expected,
        4,
        ExpectedCell
    ),

    padded_cell(
        Actual,
        4,
        ActualCell
    ),

    result_text(
        Result,
        ResultText
    ),

    format(
        ' ~s | ~s | ~s | ~s | RESULT: ~w~n',
        [
            IdCell,
            DescriptionCell,
            ExpectedCell,
            ActualCell,
            ResultText
        ]
    ).


% ============================================================
% 3. INDIVIDUAL DEMONSTRATION
% ============================================================

% ------------------------------------------------------------
% run_case(+Id)
%
% Displays the complete resolution process for one case.
%
% Includes:
%
% - Query information
% - Resolution events
% - Applied clauses
% - Remaining goals
% - Variable bindings
% - Successful answers
% - Execution statistics
% - Verification result
% ------------------------------------------------------------

run_case(Id) :-

    once(
        demo_case(
            Id,
            Description,
            Query,
            MaxDepth,
            Expected
        )
    ),

    query_text(
        Query,
        QueryText
    ),

    sld_trace(
        Query,
        MaxDepth,
        Steps,
        Answers
    ),

    length(
        Answers,
        Actual
    ),

    verify_case(
        Id,
        Expected,
        Steps,
        Answers,
        Result
    ),

    print_case_header(
        Id,
        Description,
        QueryText,
        MaxDepth,
        Expected,
        Actual
    ),

    print_steps(
        Steps
    ),

    print_answers(
        Answers
    ),

    print_summary(
        Steps,
        Answers
    ),

    print_case_result(
        Id,
        Expected,
        Actual,
        Result
    ).


% ============================================================
% 4. DEMONSTRATION VERIFICATION
% ============================================================

% ------------------------------------------------------------
% verify_case(+Id, +Expected, +Steps, +Answers, -Result)
%
% A demonstration passes only when all verification
% requirements are satisfied.
% ------------------------------------------------------------

verify_case(
    Id,
    Expected,
    Steps,
    Answers,
    passed
) :-

    length(
        Answers,
        Expected
    ),

    ground(
        Steps
    ),

    ground(
        Answers
    ),

    numbered_steps(
        Steps,
        1
    ),

    count_action(
        Steps,
        success,
        SuccessfulEvents
    ),

    SuccessfulEvents =:= Expected,

    expected_bindings(
        Id,
        ExpectedBindings
    ),

    findall(
        Bindings,
        member(
            answer(_, Bindings),
            Answers
        ),
        ActualBindings
    ),

    ActualBindings == ExpectedBindings,

    case_events_valid(
        Id,
        Steps
    ),

    !.


verify_case(
    _,
    _,
    _,
    _,
    failed
).


% ------------------------------------------------------------
% numbered_steps(+Steps, +ExpectedNumber)
%
% Verifies chronological numbering.
% ------------------------------------------------------------

numbered_steps([], _).


numbered_steps(
    [
        step(
            Sequence,
            _,
            _,
            _,
            _,
            _,
            _,
            _
        )
        |
        Rest
    ],
    ExpectedNumber
) :-

    Sequence =:= ExpectedNumber,

    NextNumber is ExpectedNumber + 1,

    numbered_steps(
        Rest,
        NextNumber
    ).


% ============================================================
% 5. EXPECTED VARIABLE BINDINGS
% ============================================================

% ------------------------------------------------------------
% These expectations verify the actual solutions.
%
% Checking only the answer count is insufficient:
% the values obtained by unification must also match.
% ------------------------------------------------------------

expected_bindings(
    1,
    [
        [binding("V1", "luis")],
        [binding("V1", "marta")]
    ]
).


expected_bindings(
    2,
    [
        [binding("V1", "sofia")]
    ]
).


expected_bindings(
    3,
    [
        [binding("V1", "diego")]
    ]
).


expected_bindings(
    4,
    []
).


expected_bindings(
    5,
    [
        []
    ]
).


expected_bindings(
    6,
    []
).


expected_bindings(
    7,
    [
        [
            binding("V1", "luis"),
            binding("V2", "sofia")
        ],
        [
            binding("V1", "marta"),
            binding("V2", "diego")
        ]
    ]
).


expected_bindings(
    8,
    [
        [
            binding("V1", "marta")
        ]
    ]
).


expected_bindings(
    9,
    [
        [binding("V1", "luis")],
        [binding("V1", "marta")],
        [binding("V1", "sofia")],
        [binding("V1", "diego")]
    ]
).


expected_bindings(
    10,
    [
        [binding("V1", "sofia")]
    ]
).


expected_bindings(
    11,
    []
).


expected_bindings(
    12,
    [
        [],
        [],
        []
    ]
).


% ============================================================
% 6. REQUIRED RESOLUTION EVENTS
% ============================================================

% ------------------------------------------------------------
% Cases 4 and 6:
%
% A failed query must produce a logical failure.
% It must not be confused with a depth cutoff.
% ------------------------------------------------------------

case_events_valid(Id, Steps) :-

    memberchk(
        Id,
        [4, 6]
    ),

    !,

    count_action(
        Steps,
        failure,
        Failures
    ),

    Failures > 0,

    count_action(
        Steps,
        cutoff,
        0
    ).


% ------------------------------------------------------------
% Case 8:
%
% The engine must record a failed alternative and
% a backtracking event before finding the solution.
% ------------------------------------------------------------

case_events_valid(8, Steps) :-

    !,

    count_action(
        Steps,
        failure,
        Failures
    ),

    Failures > 0,

    count_action(
        Steps,
        backtrack,
        Backtracks
    ),

    Backtracks > 0.


% ------------------------------------------------------------
% Case 9:
%
% Verify that the recursive ancestor rule is applied.
%
% A recursive rule application must leave another
% ancestor goal in the list of pending goals.
% ------------------------------------------------------------

case_events_valid(9, Steps) :-

    !,

    member(
        step(
            _,
            _,
            _,
            apply,
            SelectedGoal,
            _,
            RemainingGoals,
            _
        ),
        Steps
    ),

    sub_string(
        SelectedGoal,
        0,
        8,
        _,
        "ancestor"
    ),

    member(
        RemainingGoal,
        RemainingGoals
    ),

    sub_string(
        RemainingGoal,
        0,
        8,
        _,
        "ancestor"
    ).


% ------------------------------------------------------------
% Case 11:
%
% Infinite recursion must stop because of a depth cutoff.
% No successful or logically failed branch is expected.
% ------------------------------------------------------------

case_events_valid(11, Steps) :-

    !,

    count_action(
        Steps,
        cutoff,
        Cutoffs
    ),

    Cutoffs > 0,

    count_action(
        Steps,
        failure,
        0
    ).


% ------------------------------------------------------------
% Case 12:
%
% Left recursion must produce a cutoff while its
% alternative base clauses produce three successes.
% ------------------------------------------------------------

case_events_valid(12, Steps) :-

    !,

    count_action(
        Steps,
        cutoff,
        Cutoffs
    ),

    Cutoffs > 0,

    count_action(
        Steps,
        success,
        3
    ).


% ------------------------------------------------------------
% Other cases:
%
% Their expected bindings and successful event counts
% are verified by verify_case/5.
% ------------------------------------------------------------

case_events_valid(_, _).


% ============================================================
% 7. DISPLAY CASE INFORMATION
% ============================================================

print_case_header(
    Id,
    Description,
    QueryText,
    MaxDepth,
    Expected,
    Actual
) :-

    print_section(
        'SLD RESOLUTION ENGINE - PART A'
    ),

    format(
        '~n  CASE ~d: ~w~n~n',
        [Id, Description]
    ),

    format(
        '  Query          : ~w~n',
        [QueryText]
    ),

    format(
        '  Maximum depth  : ~d~n',
        [MaxDepth]
    ),

    format(
        '  Expected       : ~d solution(s)~n',
        [Expected]
    ),

    format(
        '  Actual         : ~d solution(s)~n',
        [Actual]
    ).


% ============================================================
% 8. QUERY REPRESENTATION
% ============================================================

query_text(Query, Text) :-

    copy_term(
        Query,
        Copy
    ),

    numbervars(
        Copy,
        0,
        _
    ),

    term_string(
        Copy,
        Text,
        [
            quoted(true),
            numbervars(true)
        ]
    ).


% ============================================================
% 9. RESOLUTION TRACE DISPLAY
% ============================================================

print_steps(Steps) :-

    print_section(
        'RESOLUTION TRACE'
    ),

    length(
        Steps,
        Total
    ),

    format(
        '~n  Total recorded events: ~d~n',
        [Total]
    ),

    maplist(
        print_step,
        Steps
    ).


print_step(
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
) :-

    bindings_text(
        Bindings,
        BindingsText
    ),

    format('~n', []),

    format(
        '  STEP ~d | ~w~n',
        [Sequence, Action]
    ),

    print_short_divider,

    format(
        '  Path           : ~w~n',
        [Path]
    ),

    format(
        '  Depth          : ~d~n',
        [Depth]
    ),

    format(
        '  Selected goal  : ~w~n',
        [Goal]
    ),

    print_step_details(
        Action,
        Clause,
        RemainingGoals
    ),

    format(
        '  Bindings       : ~w~n',
        [BindingsText]
    ).


% ============================================================
% 10. EVENT DETAILS
% ============================================================

print_step_details(
    apply,
    Clause,
    RemainingGoals
) :-

    !,

    format(
        '  Applied clause : ~w~n',
        [Clause]
    ),

    format(
        '  Remaining goals: ~w~n',
        [RemainingGoals]
    ).


print_step_details(
    failure,
    _,
    RemainingGoals
) :-

    !,

    format(
        '  Failed goals   : ~w~n',
        [RemainingGoals]
    ).


print_step_details(
    cutoff,
    _,
    RemainingGoals
) :-

    !,

    format(
        '  Pending goals  : ~w~n',
        [RemainingGoals]
    ).


print_step_details(
    _,
    _,
    _
).


% ============================================================
% 11. SUCCESSFUL ANSWERS
% ============================================================

print_answers([]) :-

    !,

    print_section(
        'SUCCESSFUL ANSWERS'
    ),

    format(
        '~n  No successful answers were found.~n',
        []
    ),

    format(
        '  Review the resolution trace to distinguish~n',
        []
    ),

    format(
        '  logical failure from depth cutoff.~n',
        []
    ).


print_answers(Answers) :-

    print_section(
        'SUCCESSFUL ANSWERS'
    ),

    format('~n', []),

    format(
        ' No. | Path           | Variable bindings~n',
        []
    ),

    format(
        '-----+----------------+------------------------------------------~n',
        []
    ),

    print_answer_rows(
        Answers,
        1
    ).


print_answer_rows([], _).


print_answer_rows(
    [
        answer(Path, Bindings)
        |
        Rest
    ],
    Index
) :-

    bindings_text(
        Bindings,
        BindingsText
    ),

    padded_cell(
        Index,
        3,
        IndexCell
    ),

    padded_cell(
        Path,
        14,
        PathCell
    ),

    format(
        ' ~s | ~s | ~w~n',
        [
            IndexCell,
            PathCell,
            BindingsText
        ]
    ),

    NextIndex is Index + 1,

    print_answer_rows(
        Rest,
        NextIndex
    ).


% ============================================================
% 12. EXECUTION SUMMARY
% ============================================================

print_summary(
    Steps,
    Answers
) :-

    length(
        Steps,
        TotalSteps
    ),

    length(
        Answers,
        TotalAnswers
    ),

    count_action(
        Steps,
        success,
        Successes
    ),

    count_action(
        Steps,
        failure,
        Failures
    ),

    count_action(
        Steps,
        cutoff,
        Cutoffs
    ),

    count_action(
        Steps,
        backtrack,
        Backtracks
    ),

    print_section(
        'EXECUTION SUMMARY'
    ),

    format('~n', []),

    format(
        '  Recorded steps       : ~d~n',
        [TotalSteps]
    ),

    format(
        '  Successful answers   : ~d~n',
        [TotalAnswers]
    ),

    format(
        '  Successful branches  : ~d~n',
        [Successes]
    ),

    format(
        '  Failed branches      : ~d~n',
        [Failures]
    ),

    format(
        '  Depth cutoffs        : ~d~n',
        [Cutoffs]
    ),

    format(
        '  Backtracking events  : ~d~n',
        [Backtracks]
    ).


% ============================================================
% 13. FINAL RESULT
% ============================================================

print_case_result(
    _,
    _,
    _,
    passed
) :-

    !,

    print_section(
        'FINAL RESULT'
    ),

    format(
        '~n  RESULT: PASSED~n~n',
        []
    ).


print_case_result(
    Id,
    Expected,
    Actual,
    failed
) :-

    print_section(
        'FINAL RESULT'
    ),

    format(
        '~n  RESULT: FAILED~n',
        []
    ),

    format(
        '  Expected answers : ~d~n',
        [Expected]
    ),

    format(
        '  Actual answers   : ~d~n',
        [Actual]
    ),

    format(
        '  Answer bindings or trace events did not match.~n~n',
        []
    ),

    throw(
        error(
            demonstration_case_failed(
                Id
            ),
            _
        )
    ).


result_text(
    passed,
    'PASSED'
).


result_text(
    failed,
    'FAILED'
).


% ============================================================
% 14. COUNT RESOLUTION EVENTS
% ============================================================

count_action(
    Steps,
    Action,
    Count
) :-

    include(
        step_has_action(Action),
        Steps,
        MatchingSteps
    ),

    length(
        MatchingSteps,
        Count
    ).


step_has_action(
    Action,
    step(
        _,
        _,
        _,
        Action,
        _,
        _,
        _,
        _
    )
).


% ============================================================
% 15. FORMAT VARIABLE BINDINGS
% ============================================================

bindings_text([], "-") :-

    !.


bindings_text(
    Bindings,
    Text
) :-

    findall(
        Item,
        (
            member(
                binding(Name, Value),
                Bindings
            ),

            format(
                string(Item),
                '~w=~w',
                [Name, Value]
            )
        ),
        Items
    ),

    atomics_to_string(
        Items,
        ', ',
        Text
    ).


% ============================================================
% 16. FORMAT TABLE CELLS
% ============================================================

padded_cell(
    Value,
    Width,
    Padded
) :-

    value_text(
        Value,
        Original
    ),

    string_length(
        Original,
        Length
    ),

    (
        Length =< Width
    ->
        Visible = Original
    ;
        PrefixLength is max(
            0,
            Width - 3
        ),

        sub_string(
            Original,
            0,
            PrefixLength,
            _,
            Prefix
        ),

        string_concat(
            Prefix,
            "...",
            Visible
        )
    ),

    string_length(
        Visible,
        VisibleLength
    ),

    PaddingLength is
        Width - VisibleLength,

    make_spaces(
        PaddingLength,
        Spaces
    ),

    string_concat(
        Visible,
        Spaces,
        Padded
    ).


value_text(
    none,
    "-"
) :-

    !.


value_text(
    Value,
    Text
) :-

    format(
        string(Text),
        '~w',
        [Value]
    ).


% ============================================================
% 17. GENERATE PADDING SPACES
% ============================================================

make_spaces(
    0,
    ""
) :-

    !.


make_spaces(
    Count,
    Spaces
) :-

    Count > 0,

    NextCount is Count - 1,

    make_spaces(
        NextCount,
        Remaining
    ),

    string_concat(
        " ",
        Remaining,
        Spaces
    ).


% ============================================================
% END OF SLD DEMONSTRATION RUNNER
% ============================================================
/** <module> JSON manipulation.
 *
 *  JSON document manipulation and conversion to-and-from bytes.
 *
 *  @see <http://jsonspec.org/>
 */

:- module(_,
    [
    ]).

:- include(json(include/common)).

%%  version(?Version) is semidet.
%
%   True if Version is a list representing the major, minor
%   and patch version numbers of this library.

version([1,0,0]).

doc_json(Doc, Json) :-
    core:atom_chars(Json, JsonChars),
    phrase(parse_object(Doc), JsonChars, _JsonCharsRest).

parse_object(Doc) -->
    ws,
    ['{'],
    parse_members(Doc),
    !,
    ['}'],
    ws.
parse_object([]) -->
    ws,
    ['{'],
    ws,
    ['}'],
    ws.

parse_members([Key-Value|Pairs]) -->
    parse_pair(Key-Value),
    [','],
    !,
    parse_members(Pairs).
parse_members([Key-Value]) -->
    parse_pair(Key-Value).

parse_pair(Key-Value) -->
    ws,
    parse_key(Key),
    ws,
    [':'],
    ws,
    parse_value(Value),
    ws.

parse_key(Key) -->
    ['"'],
    parse_chars(Key),
    ['"'].

parse_value(Value) -->
    ['"'],
    !,
    parse_chars(Value),
    ['"'].
parse_value(Value) -->
    parse_integer(Value).

parse_integer(Integer) -->
    parse_digit_nonzero(FirstDigit),
    !,
    parse_digits(Digits),
    { core:atom_chars(Atom, [FirstDigit|Digits]) },
    { core:atom_number(Atom, Integer) }.
parse_integer(Integer) -->
    parse_digit(Digit),
    { core:atom_number(Digit, Integer) }.

parse_digit_nonzero(Digit) -->
    parse_digit(Digit),
    { Digit \== '0' }.

parse_digits([Digit|Digits]) -->
    parse_digit(Digit),
    !,
    parse_digits(Digits).
parse_digits([]) --> [].

parse_digit(Digit) -->
    [Digit],
    { core:char_type(Digit, digit) }.

parse_chars(Atom) -->
    parse_chars_aux(Chars),
    { core:atom_chars(Atom, Chars) }.

parse_chars_aux([Char|Chars]) -->
    parse_char(Char),
    !,
    parse_chars_aux(Chars).
parse_chars_aux([]) --> [].

parse_char(Char) -->
    [Char],
    { valid_char(Char) }.

valid_char(Char) :-
    \+ lists:memberchk(Char, ['"']).

ws -->
    ws_char,
    !,
    ws.
ws --> [].

ws_char -->
    [Char],
    { core:char_type(Char, space) }.

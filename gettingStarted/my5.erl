-module(my5).
-export([format_temps/1]).

format_temps([])->
    ok;
format_temps([Head|Rest]) ->
    print_temp(convert_to_celsius(Head)),
    format_temps(Rest).

convert_to_celsius({City,{c,Temp}}) ->
    {City,{c,Temp}};

convert_to_celsius({City,{f,Temp}}) ->
    {City,{c,(Temp-32)*5/9}}.

print_temp({City, {c, Temp}}) ->
    io:format("~-15w ~w c~n", [City, Temp]).

-module(tut5_001).
-export([format_temps/1]).

%% input:
%% tut5:format temps([{moscow,{c, -10},{cape town,{f, 70},{stockholm,{c, -4},{paris,{f, 28},{london,{f, 36}])
%% output:
%% moscow     -10 c
%% cape town  21.1111 c
%% stockholm  -4 c
%% paris      -2.22222 c
%% london     2.22222 c


format_temps ([City | Rest]) ->
  convert_to_celsius(City),
  format_temps(Rest);

format_temps ([]) ->
  ok.

convert_to_celsius({CityName,{c, Temp}}) ->
  io:format("~w ~w c~n",[CityName,Temp]);

convert_to_celsius({CityName,{f, Temp}}) ->
  CTemp = (Temp - 32) * 5 / 9,
  io:format("~-15w ~w c~n",[CityName,CTemp]).

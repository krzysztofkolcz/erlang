-module(tut7_001).
-export([convert_list_to_c/1]).
%% input:
%% tut7_001:convert_list_to_c([{moscow,{c, -10}},{cape_town,{f, 70}},{stockholm,{c, -4}},{paris,{f, 28}},{london,{f, 36}}]).
%% output:
%% [{moscow,{c, -10},{cape town,{c, 70},{stockholm,{c, -4},{paris,{c, 28},{london,{c, 36}]

convert_list_to_c([Head|Rest]) ->
  convert_list_to_c([Head|Rest],[]). 

convert_list_to_c([Head|Rest],ConvertedList) ->
  ConvertedHead = convert_to_c(Head),
  convert_list_to_c(Rest,[ConvertedHead|ConvertedList]); 

convert_list_to_c([],ConvertedList) ->
  ConvertedList.

convert_to_c({City,{c,Temp}})->
    {City,{c,Temp}};

convert_to_c({City,{f,Temp}})->
    CTemp = (Temp - 32)*5/9,
    {City,{c,CTemp}}.

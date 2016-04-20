-module(find_max).
-export([find_max/1]).

find_max([Head|Rest]) ->
    find_max(Rest, Head).

find_max([],Max) ->
    Max;

find_max([Head|Rest],Max) when Max < Head ->
    find_max(Rest,Head);

find_max([Head|Rest],Max) ->
    find_max(Rest,Max).

    
    

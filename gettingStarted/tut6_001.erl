-module(tut6_001).
-export([list_max/1]).

list_max([Head | Rest]) ->
  list_max(Rest, Head).


list_max([Head | Rest], CurrentMax) when Head > CurrentMax ->
    list_max( Rest, Head);

list_max([Head | Rest], CurrentMax) ->
    list_max( Rest, CurrentMax);

list_max([], CurrentMax) ->
    CurrentMax.

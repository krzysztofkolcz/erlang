%%%-------------------------------------------------------------------
%% @doc test001 public API
%% @end
%%%-------------------------------------------------------------------

-module(test001_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, ping/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    test001_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

ping() ->
  Res = test001_serv:ping(),
  io:format("~p~n",[Res]).

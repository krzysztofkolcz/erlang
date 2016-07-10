%%%-------------------------------------------------------------------
%% @doc rabbit002 public API
%% @end
%%%-------------------------------------------------------------------

-module(rabbit002_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([add/1, display/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    rabbit002_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
  case whereis(rabbit002_sup) of
      P when is_pid(P) ->
          exit(P, kill);
      _ -> ok
  end.
%%====================================================================
%% Internal functions
%%====================================================================

add(Element) ->
    Res = rabbit002_serv:add(Element),
    io:format("~p~n",[Res]).

display() ->
    rabbit002_serv:display().
    

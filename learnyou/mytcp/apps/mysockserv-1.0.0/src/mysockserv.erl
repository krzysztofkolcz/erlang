-module(mysockserv).
-behaviour(application).
-export([ start/2, stop/1 ]).

start(Type, StartArgs) ->
  case mysockserv_sup:start_link() of
    {ok, Pid} ->
      {ok, Pid};
    Error ->
      Error
  end.

stop(State) ->
  ok.


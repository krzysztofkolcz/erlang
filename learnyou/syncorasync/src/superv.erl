-module(superv).
-behaviour(supervisor).
-export([start_link/2, init/1]).

start_link(Supname,[Time,N])->
  io:format("supervisor start_link start~n"),
  supervisor:start_link({local,Supname},?MODULE,[Time,N]),
  io:format("supervisor start_link finish~n").


init([Time,N])->
  %% io:format("supervisor init start with params time:~p, n:~p ~n",[Time,N]),
  RestartStrategy = one_for_one,
  MaxRestart = 5,
  MaxTime = 3600,
  ChildSpec = {workpid, {workwork,start_link,[Time,N]}, permanent, 5000, worker, [workwork]}, 
  {ok, {{RestartStrategy, MaxRestart, MaxTime},[ChildSpec]}}.


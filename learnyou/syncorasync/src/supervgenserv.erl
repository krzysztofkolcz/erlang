-module(supervgenserv).
-behaviour(supervisor).
-export([start_link/1,  init/1]).

%% start_link([Name,Time,N])->
start_link(Supname)->
  %% io:format("supervisor start_link start~n"),
  %% supervisor:start_link({local,?MODULE},?MODULE,[Name,Time,N]).
  supervisor:start_link({local,Supname},?MODULE,[start]).
  %% io:format("supervisor start_link finish~n").


%% init([Name,Time,N])->
init([start])->
  %% io:format("supervisor init start with params time:~p, n:~p ~n",[Time,N]),
  RestartStrategy = one_for_one, %% Problem ze startem był przez RestartStrategy - simple_one_for_one, ale czemu?????
  MaxRestart = 5,
  MaxTime = 3600,
  %% ChildSpec = {workpid, {workworkgenserv,start_link,[Time,N,Name]}, permanent, 1000, worker, [workworkgenserv]}, 
  %% ChildSpec = {workpid, {workworkgenserv,start_link,[1000,10,singer]}, permanent, 1000, worker, [workworkgenserv]}, 
  %% {ok, {{RestartStrategy, MaxRestart, MaxTime},[ChildSpec]}}.
  {ok, {{RestartStrategy, MaxRestart, MaxTime}, [ {singer, {workworkgenserv, start_link, [1000,10,singer]}, permanent, 1000, worker, [workworkgenserv]} ]}}.
  %% tmp({one_for_one, 1, 60}).

tmp({RestartStrategy, MaxRestart, MaxTime}) ->
    {ok, {{RestartStrategy, MaxRestart, MaxTime}, [{singer, {workworkgenserv, start_link, [1000,10,singer]}, permanent, 1000, worker, [workworkgenserv]}]}}.

%% tmp({RestartStrategy, MaxRestart, MaxTime}) ->
%%     {ok, {{RestartStrategy, MaxRestart, MaxTime},
%%         [{singer,
%%         {workworkgenserv, start_link, [1000,10,singer]},
%%         permanent, 1000, worker, [workworkgenserv]},
%%         {bass,
%%         {workworkgenserv, start_link, [2000,5,bass]},
%%         temporary, 1000, worker, [workworkgenserv]},
%%         {drum,
%%         {workworkgenserv, start_link, [500,30,drum]},
%%         transient, 1000, worker, [workworkgenserv]},
%%         {keytar,
%%         {workworkgenserv, start_link, [800,50,keytar]},
%%         transient, 1000, worker, [workworkgenserv]}
%%         ]}}.

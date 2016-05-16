-module(workwork).
-export([init/2,loop/2,start_link/2]).

start_link(Time,N)->
  spawn(?MODULE,init,[Time,N]). 

init(Time,N)->
  io:format("worker init start~n").
  %% loop(Time,N).
  %% io:format("worker init finish~n").


loop(Time,N) when N > 0->
  %% io:format("worker loop ~p start ~n",[N]),
  timer:sleep(Time),
  %% io:format("worker loop ~p finish ~n",[N]),
  loop(Time,N-1);
loop(Time,0)->
  ok.

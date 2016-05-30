-module(mysockserv_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

start_link()->
  supervisor:start_link({local,?MODULE},?MODULE,[]).

init([]) ->
  %% {ok, Port} = application:get_env(port),
  Port = 8085,
  io:format("Supervisor started!~n"),
  {ok, ListenSocket} = gen_tcp:listen(Port,[{active,once},{packet,line}]),
  spawn_link(fun create_childs/0),
  Server = {socket,{mysockserv_serv,start_link, [ListenSocket]}, temporary,1000,worker,[mysockserv_serv]},
  {ok,{{simple_one_for_one,60,3600}, [Server]}}.

create_child()->
  io:format("Create child~n",[]),
  supervisor:start_child(?MODULE,[]).

create_childs()->
  [create_child() || _  <- lists:seq(1,20)],
  ok.



-module(mysockserv_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

-define(SERVER,?MODULE).

start_link()->
  supervisor:start_link({local,?MODULE},?MODULE,[]).

init([]) ->
  Server = {mysockserv_serv,{mysockserv_serv,start_link, []}, permanent,2000,worker,[mysockserv_serv]},
  {ok,{{one_for_one,0,1}, [Server]}}.



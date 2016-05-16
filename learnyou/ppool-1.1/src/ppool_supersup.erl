-module(ppool_supersup).
-behaviour(supervisor).
-export([start_link/1, stop/0, start_pool/3,stop_pool/1]).
-export([init/1]).

start_link()->
  supervisor:start_link({local,ppool},?MODULE,[]).

init()->
  %% {ok, {{RestartStrategy, MaxRestart, MaxTime},[ChildSpecs]}}
  {ok,{{one_for_one,6,3600},[]}}.

%% technically, a supervisor can not be killed in an easy way.
%% Let's do it brutally!
%% Można to zrobić inaczej, ale na późniejszym etapie edukacji
stop() ->
  case whereis(ppool) of
      P when is_pid(P) ->
          exit(P, kill);
      _ -> ok
  end.

%% tutaj startuje ppool supervisor, który będzie utrzymywał ppool_serv, oraz worker_sup
%% czyli już tutaj muszę przekazywać: Nazwę  ppool_sup, 
start_pool(Name, Limit, MFA)->
  ChildSpec = {
    Name, %% nazwa ppool_sup
    {ppool_sup, start_link, [Name,Limit,MFA]}, %% start function, czyli parametry przekazane do init ppool_sup. Nie do końca rozumiem, czemu przekazane jest Name, oraz czym mają być MFA. Czyżby workery były tylko jednego typu?
                                                   %% tak jak myślę, Name i Limit będą przekazane do ppool_serv, aby utrzymywał liczbę wątków, a MFA bedą specyfikacją workerów
    permanent, 10500, supervisor, [ppool_sup]
  }
  supervisor:start_child(ppool,ChildSpec). %%ppool - usawiane w linii 7


%% zatrzymanie ppool_sup, a co za tym idzie zatrzymanie całego poola
stop_pool(Name) ->
  supervisor:terminate_child(ppool, Name),
  supervisor:delete_child(ppool, Name).

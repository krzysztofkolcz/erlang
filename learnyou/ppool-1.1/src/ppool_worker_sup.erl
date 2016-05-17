-module(ppool_worker_sup).
-export([start_link/1, init/1]).
-behaviour(supervisor).

start_link(MFA={_,_,_})->
  supervisor:start_link(?MODULE,MFA).


init({M,F,A})->
  RestartStrategy = simple_one_for_one,
  MaxRestart = 5,
  MaxTime = 3600,
  ChildSpec = {ppool_worker, {M,F,A}, temporary, 5000, worker, [M]}, %% Nie rozumiem, od razu odpala jakiegoś workera???? %% 
                                                                     %% Odp.: Nie, simple_one_for_one nie odpala workera. Woker jest odpalany przez start_child, tu jest tylko przekazany typ workera.
  {ok, {{RestartStrategy, MaxRestart, MaxTime},[ChildSpec]}}.


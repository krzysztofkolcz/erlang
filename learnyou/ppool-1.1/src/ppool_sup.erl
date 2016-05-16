-module(ppool_sup).
-export([start_link/3, init/1]).
-behaviour(supervisor).
 
start_link(Name, Limit, MFA) ->
    supervisor:start_link(?MODULE, {Name, Limit, MFA}).
 
init({Name, Limit, MFA}) ->
    MaxRestart = 1,
    MaxTime = 3600,
    %% czyli jeden ppool_sup startuje jeden ppool_serv
    {ok, {{one_for_all, MaxRestart, MaxTime},
        [{serv, %% ChildId
            {ppool_serv, start_link, [Name, Limit, self(), MFA]}, %% Start function, czyli ppool_serv otrzymuje pid ppool_sup - w celu uruchomienia pod tym samym supervisorem worker_sup
            permanent,
            5000, % Shutdown time
            worker,
            [ppool_serv]}]}}.

%% czyli pewnie będzie to wyglądało w ten sposób:
%% supervisor:start_child({ppool_sup_pid,[worker_sup, {worker_sup, start_link, []}, permanent, 5000, supervisor, [worker_sup]})

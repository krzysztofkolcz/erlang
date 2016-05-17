-module(ppool_serv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record{state,
        {proc_working, proc_waiting,limit,worker_sup_pid}}.

-record{worker,
        {pid}}.

-record{waiting_worker,
        {mfa}}.

init([Name, Limit, SupervisorPid, MFA])->
  supervisor:start_child(SupervisorPid,{ppool_worker_sup,start_link,[MFA]),
  {ok,{#state{proc_working=[],proc_waiting=[],limit=Limit}.

  
%% start new task in pool
start(PpoolServerPid,MFA)->
  gen_server:call({PpoolServerPid,MFA})


%% dodanie nowego procesu workera
  %% jeżęli jest miejsce - odpalenie, i dodanie pid do supervisora
  %% pytanie - w jaki sposób dowiedzieć się, żę proces się skończył (naturalnie, lub przez error) - co i w jaki sposób zwróci supervisor?
handle_call(Msg,From,State)->
  %% if Limit < proc_working.count()
  {ok,WorkerPid} = supervisor:start_child(State#state.worker_sup_pid,[MFA]),
  {reply,started,{State#state(proc_working=[WorkerPid|State#state.proc_working)}},
  %% true ->
  {ok,notstarted,{State#state(proc_waiting=[waiting_worker(mfa=MFA)|State#state.proc_waiting)}}.


%% Tutaj, jeżeli zadanie się skończy - jakie Msg? Czy to zwraca supervisor?
handle_info({stopped,StoppedPid},From,State(#state(proc_waiting=[Head|Tail],proc_working=ProcWorking,worker_sup_pid=WorkerSupPid)))->
  %% usunięcie z listy procesów pracujących Pid skończonwgo proceu
  %% TODO
  %% sprawdzenie, czy są czekające procesy
  %% jeżeli tak, to pobranie ostatniego z kolejki (czyli pierwszego, który do niej wszedł - najstarszego)
  %% a następnie uruchomienie go, usunięcie 
  {ok,WorkerPid} = supervisor:start_child(WorkerSupPid,[Head.mfa]),
  {noreply,State(#state(proc_waiting=Tail,proc_working=[WorkerSupPid|ProcWorking])}.



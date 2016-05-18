-module(ppool_serv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/4, start_link/4, run/2, sync_queue/2, async_queue/2, stop/1]).

%% -record{state,
%%         {proc_working, proc_waiting,limit,worker_sup_pid}}.

-record(state, 
           {refs,queue=queue:new(),limit=0,sup}).

%% -record{worker,
%%         {pid}}.

%% -record{waiting_worker,
%%         {mfa}}.
%%

%% The friendly supervisor is started dynamically!
-define(SPEC(MFA),
        {worker_sup,
          {ppool_worker_sup, start_link, [MFA]},
            temporary,
            10000,
            supervisor,
            [ppool_worker_sup]}).

%%%%%%%%% API %%%%%%%%%%%%%%
start(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
    gen_server:start({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).
 
start_link(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
    gen_server:start_link({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).
 
run(Name, Args) ->
    gen_server:call(Name, {run, Args}).
 
sync_queue(Name, Args) ->
    gen_server:call(Name, {sync, Args}, infinity).
 
async_queue(Name, Args) ->
    gen_server:cast(Name, {async, Args}).
 
stop(Name) ->
    gen_server:call(Name, stop).



%% init([Name, Limit, SupervisorPid, MFA])->
%%   supervisor:start_child(SupervisorPid,{ppool_worker_sup,start_link,[MFA]),
%%   {ok,{#state{proc_working=[],proc_waiting=[],limit=Limit}.

%% Takie coś tworzy deadlock - superwisor ppool_sup startuje ppool_serv wywołuje init synchronicznie (czeka na wynik)
%% a tutaj jest z kolei wywołanie start_child tego supervisora, które również jest synchroniczne, więc init będzie czekać na wynik tej funkcji
%% init({Limit, MFA, Sup}) ->
%%   {ok, Pid} = supervisor:start_child(Sup, ?SPEC(MFA)), %% otrzymuje Pid supervisora workerów
%%   link(Pid),
%%   {ok, #state{limit=Limit, refs=gb_sets:empty()}}.

init({Limit, MFA, Sup}) ->
  %% We need to find the Pid of the worker supervisor from here,
  %% %% but alas, this would be calling the supervisor while it waits for us!
  self() ! {start_worker_supervisor, Sup, MFA},  %% Takie coś jest przetwarzane przez handle_info
  {ok, #state{limit=Limit, refs=gb_sets:empty()}}.

  
%% start new task in pool
%% start(PpoolServerPid,MFA)->
%%   gen_server:call({PpoolServerPid,MFA})


%% dodanie nowego procesu workera
  %% jeżęli jest miejsce - odpalenie, i dodanie pid do supervisora
  %% pytanie - w jaki sposób dowiedzieć się, żę proces się skończył (naturalnie, lub przez error) - co i w jaki sposób zwróci supervisor?
  %% odp. Ref = erlang:monitor(process, Pid), następnie trzymam na liście pracujących procesów Ref i Pid,
  %% następnie handle_info({'DOWN', Ref, process, _Pid, _}, S = #state{refs=Refs}) ->
%% handle_call(Msg,From,State)->
  %% if Limit < proc_working.count()
  %% {ok,WorkerPid} = supervisor:start_child(State#state.worker_sup_pid,[MFA]),
  %% {reply,started,{State#state(proc_working=[WorkerPid|State#state.proc_working)}},
  %% true ->
  %% {ok,notstarted,{State#state(proc_waiting=[waiting_worker(mfa=MFA)|State#state.proc_waiting)}}.


%% Tutaj, jeżeli zadanie się skończy - jakie Msg? Czy to zwraca supervisor?
%% handle_info({stopped,StoppedPid},From,State(#state(proc_waiting=[Head|Tail],proc_working=ProcWorking,worker_sup_pid=WorkerSupPid)))->
  %% usunięcie z listy procesów pracujących Pid skończonwgo proceu
  %% TODO
  %% sprawdzenie, czy są czekające procesy
  %% jeżeli tak, to pobranie ostatniego z kolejki (czyli pierwszego, który do niej wszedł - najstarszego)
  %% a następnie uruchomienie go, usunięcie 
  %% {ok,WorkerPid} = supervisor:start_child(WorkerSupPid,[Head.mfa]),
  %% {noreply,State(#state(proc_waiting=Tail,proc_working=[WorkerSupPid|ProcWorking])}.

handle_down_worker(Ref, S = #state{refs=Refs, limit=N, sup=Sup}) ->
limit=N+1
%%remove Ref from Refs
%% check if queue empty, if not take next process, and start it



handle_info({'DOWN', Ref, process, _Pid, _}, S = #state{refs=Refs}) ->
  io:format("received down msg~n"),
  case gb_sets:is_element(Ref, Refs) of
    true ->
      handle_down_worker(Ref, S);
    false -> %% Not our responsibility
      {noreply, S}
  end;
handle_info({start_worker_supervisor, Sup, MFA}, S = #state{}) ->
  {ok, Pid} = supervisor:start_child(Sup, ?SPEC(MFA)),
  link(Pid),
  {noreply, S#state{sup=Pid}};
handle_info(Msg, State) ->
  io:format("Unknown msg: ~p~n", [Msg]),
  {noreply, State}.

%% ok, rozumiem różnicę pomiędzy run a sync - run nie dodaje do kolejki procesów oczekujących
handle_call({run, Args}, _From, S = #state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, Args),
    Ref = erlang:monitor(process, Pid),
    {reply, {ok,Pid}, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
handle_call({run, _Args}, _From, S=#state{limit=N}) when N =< 0 ->
    {reply, noalloc, S};
handle_call({sync, Args}, _From, S = #state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, Args),
    Ref = erlang:monitor(process, Pid),
    {reply, {ok,Pid}, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
handle_call({sync, Args},  From, S = #state{queue=Q}) ->
    {noreply, S#state{queue=queue:in({From, Args}, Q)}}; %% Czy to nie zawiesza procesu wywołującego?
handle_call(stop, _From, State) ->
  {stop, normal, ok, State};
handle_call(_Msg, _From, State) ->
  {noreply, State}.


handle_cast({async, Args}, S=#state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, Args),
    Ref = erlang:monitor(process, Pid),
    {noreply, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
handle_cast({async, Args}, S=#state{limit=N, queue=Q}) when N =< 0 ->
    {noreply, S#state{queue=queue:in(Args,Q)}};
%% Not going to explain this one!
handle_cast(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(normal, State) ->
  io:format("terminate~n",[]),
  ok.


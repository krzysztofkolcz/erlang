-module(run).
-export([example/0]).

-define(JOB_SUP, job_sup).

example() ->
   JobSpec = 
   {parallel,[{pm_exec_retry,{exp,{pm_exec_delegate_job_ttl,#{method => 'unix.quota.set',
        method_args => [{<<"target_host">>,<<"server0">>},
         {<<"unix_username">>,<<"server0">>},
         {<<"quota">>,<<"10MB">>},
         {<<"type">>,<<"system_account">>}],
        retry_after_ttl => true,
        ticket_id => 1,
        ttl_ms => 30000}}}},
   {pm_exec_retry,{exp,{pm_exec_delegate_job_ttl,#{method => 'unix.quota.set',
        method_args => [{<<"target_host">>,<<"server0">>},
         {<<"unix_username">>,<<"server0">>},
         {<<"quota">>,<<"10MB">>},
         {<<"type">>,<<"total-mysql">>}],
        retry_after_ttl => true,
        ticket_id => 1,
        ttl_ms => 30000}}}},
   {pm_exec_retry,{exp,{pm_exec_delegate_job_ttl,#{method => 'unix.quota.set',
        method_args => [{<<"target_host">>,<<"server0">>},
         {<<"unix_username">>,<<"server0">>},
         {<<"quota">>,<<"10MB">>},
         {<<"type">>,<<"total-mail">>}],
        retry_after_ttl => true,
        ticket_id => 1,
        ttl_ms => 30000}}}}]},
  run(JobSpec).


%% pm_exec_common/src/job.erl
run({sequence, ListOfJobs}) ->
    run_sequence_imp(ListOfJobs);
run({parallel, ListOfJobs}) ->
    run_parallel_imp(ListOfJobs);
run({sleep, {Time, Job}}) ->
    lager:debug("Job ~p sleeping for ~p", [self(), Time]),
    ok = timer:sleep(Time),
    lager:debug("Job ~p finished sleeping", [self()]),
    run(Job);
run({Job, Arg}) ->
    case run_async(Job, Arg, self()) of
        {ok, Ref, _Pid} ->
            receive {job_result, Ref, Result} ->
                    Result
            end;
        {error, Reason} ->
            {error, Reason}
    end.
run(Job, Arg) ->
    run({Job, Arg}).

%% @private
run_parallel_imp(ListOfJobs) ->
    run_parallel_imp(ListOfJobs, 1, []). 

%% @private
run_parallel_imp([Job|Rest], N, Tokens) ->
    Self = self(),
    Ref = make_ref(),
    Token = {N, Ref},
    proc_lib:spawn_link(
      fun() ->
              Result = run_single_job(Job),
              Self ! {job_token, N, Ref, Result}
      end),
    run_parallel_imp(Rest, N + 1, [Token|Tokens]);
run_parallel_imp([], _N, Tokens) ->
    wait_for_tokens(lists:reverse(Tokens), []). 


%% @private
wait_for_tokens([], Answers) ->
    Type = case lists:any(fun({_, {error, _}}) -> true;
                             (_) -> false
                          end, Answers) of
               true -> error;
               false -> ok
           end,
    {Type, lists:keysort(1, Answers)};
wait_for_tokens(Tokens, Answers) ->
    receive {job_token, N, Ref, Answer} = Message ->
            case utils:member_delete({N, Ref}, Tokens) of
                {true, NewTokens} ->
                    wait_for_tokens(NewTokens, [{N, Answer}|Answers]);
                {false, _} ->
                    lager:warning("possible programming error: unexpected message while waiting for jobs, message: ~p", [Message]),
                    wait_for_tokens(Tokens, Answers)
            end
    end.


run_single_job(Fun) when is_function(Fun) ->
    try Fun() of
        {ok, _} = Tuple ->
            Tuple;
        {error, _} = Tuple ->
            Tuple
    catch
        Class:Reason ->
            {error, {Class, Reason}}
    end;
run_single_job({ModuleOrMethod, Arguments}) ->
    job:run(ModuleOrMethod, Arguments).



run_async(Job0, Arg, ReportTo) ->
    Job1 = utils:to_atom(Job0),
    Job = utils:sanitize_job_module(Job1),
    Ref = make_ref(),
    %% wycięta sekcja z mockami
    case supervisor:start_child(?JOB_SUP, [ReportTo, Ref, Job, Arg]) of
        {ok, JobPid} ->
            {ok, Ref, JobPid};
        {error, Reason} ->
            {error, Reason}
    end


%% run({parallel, ListOfJobs}) ->
%%    run_parallel_imp(ListOfJobs);
%% ListOfJobs = [{pm_exec_retry,{...}},{pm_exec_retry,{...}},{pm_exec_retry,{...}}]

%% run_parallel_imp([Job|Rest], N, Tokens) ->
%% spawnuje każde z zadań, oraz w funkcji wait_for_tokens czeka na wiadomości zwrotne
%% w zasadzie interesuje mnie funkcja run_single_job
%% Result = run_single_job(Job),
%% Job = {pm_exec_retry,{...}}

%% run_single_job({ModuleOrMethod, Arguments}) ->
%%     job:run(ModuleOrMethod, Arguments).

%% ModuleOrMethod = pm_exec_retry
%% Arguments = {exp,{pm_exec_delegate_job_ttl,#{method => 'unix.quota.set',
%%        method_args => [{<<"target_host">>,<<"server0">>},
%%         {<<"unix_username">>,<<"server0">>},
%%         {<<"quota">>,<<"10M">>},
%%         {<<"type">>,<<"system_account">>}],
%%        retry_after_ttl => true,
%%        ticket_id => 1,
%%        ttl_ms => 30000}}}


%% job:run(ModuleOrMethod, Arguments).

%% run(Job, Arg) ->
%%     run({Job, Arg}).

%% run({Job, Arg}) ->
%%     case run_async(Job, Arg, self()) of
%%         {ok, Ref, _Pid} ->
%%             receive {job_result, Ref, Result} ->
%%                     Result
%%             end;
%%         {error, Reason} ->
%%             {error, Reason}
%%     end.


%% run_async(Job, Arg, self())

%% run_async(Job0, Arg, ReportTo) ->
%% Job0 = ModuleOrMethod = pm_exec_retry
%% Arg = Arguments = {exp,{pm_exec_delegate_job_ttl,#{...}}}
%% ReportTo = self() %% czyli proces wywołujący runa

%% Job1 = utils:to_atom(Job0),
%% Job1 = pm_exec_retry

%% Job = utils:sanitize_job_module(Job1),
%% Job = pm_exec_retry

%% case supervisor:start_child(?JOB_SUP, [ReportTo, Ref, Job, Arg]) of
%% -define(JOB_SUP, job_sup).
%% supervisor:start_child(?JOB_SUP, [ReportTo, Ref, Job, Arg])

%% job_sup.erl
%% Supervisor job_sup dodaje childa do istniejącej listy childów
%% Inicjalizacja job_sup
init([]) ->
  JobSpec = {job, {job, start_link, []}, temporary, 5000, worker, [job]},
  {ok, { {simple_one_for_one, 5, 10}, [JobSpec]} }.

%% ChildSpec zgodnie z dokumentacją:
%% {ChildId, StartFunc, Restart, Shutdown, Type, Modules}.

%% czyli odpalana jest funkcja start_link dla job

%% Wracam do job.erl
start_link(ReportTo, Ref, Job, Arg) ->
    gen_server:start_link(?MODULE, [ReportTo, Ref, Job, Arg], []).
%% Job = Job0 = ModuleOrMethod = pm_exec_retry
%% Arg = Arg = Arguments = {exp,{pm_exec_delegate_job_ttl,#{...}}}

init([ReportTo, ReportRef, Job, Arg]) ->
    process_flag(trap_exit, true),
    case (catch job_worm:start_link(Job, self(), Arg)) of
        {ok, Pid} ->
            {ok, #state{report_to = ReportTo, report_ref = ReportRef, wpid = Pid, job = Job, arg = Arg}};
        {error, Reason} ->
            {stop, Reason}
    end.


%% job_worm:start_link(Job, self(), Arg)

%% job_worm.erl
start_link(Job, ResultTo, Arg) ->
    gen_fsm:start_link(?MODULE, [Job, ResultTo, Arg], []).

init([Module, ResultTo, Arg]) ->
    %% process dict is used to simplify job:set_result and
    %% job:report_progress implementations.
    %% assumption: these are static, therefore acceptable
    put(my_job_server, ResultTo),
    case lists:member({method, 0}, Module:module_info(exports)) of
        true ->
            put(my_method, Module:method());
        false -> ok
    end,
    put(my_arg, Arg),

    State = #state{ module = Module, result_to = ResultTo, arg = Arg },

    case lists:member({init, 1}, Module:module_info(exports)) of
        true ->
            InitReturned = Module:init(Arg);
        false ->
            InitReturned = {continue, Arg}
    end,

    case InitReturned of
        {continue, Plan, JobState} -> % ticket special case, TODO move this somewhere onto ticket conceptual plane
            lager:info("Started ticket ~p(~p)", [Module, Arg]),
            pm_exec_ticket:put_job_plan_onto_mq(Plan),
            {ok, pre_check, State#state {job_state = JobState }, 0}; 
        {continue, JobState} ->
            lager:info("Started job ~p(~p)", [Module, Arg]),
            job:report_progress("accepted", Module),
            {ok, pre_check, State#state{ job_state = JobState }, 0}; 
        {error, Reason} ->
            lager:error("Failed to init job ~p(~p), reason: ~p", [Module, Arg, Reason]),
            {stop, Reason}
    end.


%%  InitReturned = Module:init(Arg);

%%  InitReturned = pm_exec_retry:init(Arg);
%%  Arg = {exp,{pm_exec_delegate_job_ttl,#{...}}}

%% pm_exec_retry.erl

init({exp, {Job, JobArg}}) ->
    init({{exp, 30000}, {Job, JobArg}});

init({{exp, StartDelay}, {Job, JobArg}}) ->
    State = #state{ retry_delay = StartDelay,
                    job = Job,
                    job_arg = JobArg,
                    exp_delay_growth = true },
    {continue, State};

init({RetryDelay, {Job, JobArg}}) ->
    State = #state{ retry_delay = RetryDelay,
                    job = Job,
                    job_arg = JobArg },
    {continue, State}.


%% init({exp, {Job, JobArg}}) 
%%    Job = pm_exec_delegate_job_ttl
%%    JobArg = #{method => 'unix.quota.set',
%%        method_args => [{<<"target_host">>,<<"server0">>},
%%         {<<"unix_username">>,<<"server0">>},
%%         {<<"quota">>,<<"10MB">>},
%%         {<<"type">>,<<"system_account">>}],
%%        retry_after_ttl => true,
%%        ticket_id => 1,
%%        ttl_ms => 30000}

%% init({{exp, 30000}, {Job, JobArg}});
%% Zwraca:
%% State = #state{ retry_delay = 30000,
%%                 job = pm_exec_delegate_job_ttl,
%%                 job_arg = #{method => 'unix.quota.set',
%%                           method_args => [{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"system_account">>}],
%%                           retry_after_ttl => true,
%%                           ticket_id => 1,
%%                           ttl_ms => 30000},
%%                 exp_delay_growth = true },
%% {continue, State};

%% powrót do job_worm.erl
%% 
%% case InitReturned of
%%     ...
%%     {continue, JobState} ->
%%         lager:info("Started job ~p(~p)", [Module, Arg]),
%%         job:report_progress("accepted", Module),
%%         {ok, pre_check, State#state{ job_state = JobState }, 0}; 

%% ponieważ wynikiem jest {ok, pre_check, State#state{ job_state = JobState }, 0}, timeout = 0, więc następuje przejściedo stanu pre_check
%% 
%% State#state{ job_state = 
%%  #state{ retry_delay = 30000,
%%                  job = pm_exec_delegate_job_ttl,
%%                  job_arg = #{method => 'unix.quota.set',
%%                           method_args => [{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"system_account">>}],
%%                           retry_after_ttl => true,
%%                           ticket_id => 1,
%%                           ttl_ms => 30000},
%%                  exp_delay_growth = true }
%% }
pre_check(timeout, State) ->
    #state{ module = Module } = State,
    case lists:member({pre_check, 1}, Module:module_info(exports)) of
        true ->
            do_pre_check(State);
        false ->
            job:report_progress("preconditions check passed", Module),
            {next_state, do_job, State, 0}
    end.
%% ponieważ moduł pm_exec_retry nie ma funkcji pre_check, case zwraca false i następuje przejście do stanu do_job (timeout = 0)
do_job(timeout, State) ->
    #state{ module = Module, job_state = JobState } = State,
    case Module:do_job(JobState) of
        {continue, NewJobState} ->
            job:report_progress("executed", Module),
            {next_state, verify, State#state{ job_state = NewJobState }, 0}; 
        {continue, NewResult, NewJobState} ->
            job:report_progress("executed", Module),
            job:set_result({ok, NewResult}),
            {next_state, verify, State#state{ job_state = NewJobState }, 0}; 
        {listen, NewJobState} ->
            {next_state, loop, State#state{ job_state = NewJobState }, infinity};
        {error, Reason} ->
            report_and_stop({error, Reason}, State);
        restart ->
            restart(State)
    end.
%% wywołany jest Module:do_job
%% pm_exec_retry:do_job

do_job(S) ->
    run_job(S).

run_job(S) ->
    #state{ job = Job, job_arg = JobArg } = S,
    {ok, Ref, Pid} = job:run_async(Job, JobArg, self()),
    link(Pid),
    NewState = S#state{ job_ref = Ref, job_pid = Pid, awaiting_retry = false },
    {listen, NewState}.


%% S =  #state{ retry_delay = 30000,
%%                  job = pm_exec_delegate_job_ttl,
%%                  job_arg = #{method => 'unix.quota.set',
%%                           method_args => [{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"system_account">>}],
%%                           retry_after_ttl => true,
%%                           ticket_id => 1,
%%                           ttl_ms => 30000},
%%                  exp_delay_growth = true }


%% #state{ job = Job, job_arg = JobArg } = S,
%% Job = pm_exec_delegate_job_ttl
%% JobArt = #{method => 'unix.quota.set',
%%          method_args => [{<<"target_host">>,<<"server0">>},
%%           {<<"unix_username">>,<<"server0">>},
%%           {<<"quota">>,<<"10MB">>},
%%           {<<"type">>,<<"system_account">>}],
%%          retry_after_ttl => true,
%%          ticket_id => 1,
%%          ttl_ms => 30000}

%% {ok, Ref, Pid} = job:run_async(Job, JobArg, self()),


%% Dalsza część w run_delegate_job_ttl.erl

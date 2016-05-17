-module(run_delegate_job_ttl).
-export([example/0]).

%% === pm_exec_retry:do_job === 
%%     Job = pm_exec_delegate_job_ttl
%%     JobArg = #{method => 'unix.quota.set',
%%                method_args => [{<<"target_host">>,<<"server0">>},
%%                 {<<"unix_username">>,<<"server0">>},
%%                 {<<"quota">>,<<"10MB">>},
%%                 {<<"type">>,<<"system_account">>}],
%%                retry_after_ttl => true,
%%                ticket_id => 1,
%%                ttl_ms => 30000}
%% {ok, Ref, Pid} = job:run_async(Job, JobArg, self()),
%% == job:run_async ==
%% run_async(Job0, Arg, ReportTo) ->
%% Job = Job0 =  pm_exec_delegate_job_ttl
%% Arg = #{method => 'unix.quota.set',
%%
%% supervisor:start_child(?JOB_SUP, [ReportTo, Ref, Job, Arg])
%%
%% == job:start_link ==
%% == job:init([ReportTo, ReportRef, Job, Arg]) ==
%% == job_worm:start_link(Job, self(), Arg) ==
%% == job_worm:init([Module, ResultTo, Arg]) ==  
%%   State = #state{ module = Module, result_to = ResultTo, arg = Arg },
%%   Module:init(Arg)
%%   pm_exec_delegate_ttl:init( method = 'unix.quota.set', ticet_id = ???, method_args = [{<<"target_host">> ...}])
%%   == pm_exec_delegate_ttl: init(#{ method := Method, ticket_id := TicketID, method_args := MethodArgs} = Opts) ==  
%%      method => 'unix.quota.set',
%%      method_args => [{<<"target_host">>,<<"server0">>},
%%                 {<<"unix_username">>,<<"server0">>},
%%                 {<<"quota">>,<<"10MB">>},
%%                 {<<"type">>,<<"system_account">>}]
%% == job_worm:do_job(State) ==  
%% Module =  pm_exec_delegate_job_ttl
%% Arg = #{method => 'unix.quota.set',
%%                method_args => [{<<"target_host">>,<<"server0">>},
%%                 {<<"unix_username">>,<<"server0">>},
%%                 {<<"quota">>,<<"10MB">>},
%%                 {<<"type">>,<<"system_account">>}],
%%                retry_after_ttl => true,
%%                ticket_id => 1,
%%                ttl_ms => 30000}
%% Module:do_job(JobState)
%%

%% pm_exec_delegate_job_ttl.erl
-spec init(opts()) -> {continue, #state{}}.
init(#{ method := Method, ticket_id := TicketID, method_args := MethodArgs} = Opts) ->
    {ok, JobID0} = pm_exec_id_provider:get_id(30*24*60*60),
    JobID = utils:to_int(JobID0),
    TargetHost = get_target_host(MethodArgs),
    pm_exec_ehandler_work:sub_job(JobID, self()),
    pm_exec_ehandler_adm_introductions:sub_server_started(TargetHost, self()),
    State = #state{ target_host = TargetHost,
                    ticket_id   = TicketID,
                    job_id      = JobID,
                    method      = Method,
                    method_args = MethodArgs,
                    ttl_ms      = maps:get(ttl_ms, Opts, undefined),
                    retry_after_ttl = maps:get(retry_after_ttl, Opts)
                  },
    {continue, State}.


%% init(#{ method := Method, ticket_id := TicketID, method_args := MethodArgs} = Opts) ->
%% Method = 'unix.quota.set'
%% TicketID = 1
%% MethodArgs = [{<<"target_host">>,<<"server0">>},
%%                 {<<"unix_username">>,<<"server0">>},
%%                 {<<"quota">>,<<"10MB">>},
%%                 {<<"type">>,<<"system_account">>}]
%% TargetHost = <<"server0">>
%% pm_exec_ehandler_work:sub_job(JobID, self()),





-module(delegate_retry).
-export([delegate_retry/2, example/0]).

example() ->
%% JobSpec0 = [{'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"system_account">>}]},
%%         {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"total-mysql">>}]},
%%         {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"total-mail">>}]}],
%%
%% Job = {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"system_account">>}]},

JobSpec0 = {parallel,[{'unix.quota.set',[{<<"target_host">>,
                                <<"server0">>},
                               {<<"unix_username">>,<<"server0">>},
                               {<<"quota">>,<<"10MB">>},
                               {<<"type">>,<<"system_account">>}]},
            {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
                               {<<"unix_username">>,<<"server0">>},
                               {<<"quota">>,<<"10MB">>},
                               {<<"type">>,<<"total-mysql">>}]},
            {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
                               {<<"unix_username">>,<<"server0">>},
                               {<<"quota">>,<<"10MB">>},
                               {<<"type">>,<<"total-mail">>}]}]},
JobSpec1 = delegate_retry(JobSpec0),
JobSpec = fmap(fun retry_exp/1, JobSpec1).

delegate_retry(Job) ->
    delegate_retry(Job, #{}).

delegate_retry(Job, OptsIn) ->
    fmap(fun ({Method, Args}) ->
                 OptsDef = #{ method      => Method,
                              method_args => Args,
                              ticket_id   => 1,
                              ttl_ms      => 30*1000,
                              retry_after_ttl => true 
                            },
                 Opts = maps:merge(OptsDef, OptsIn),
                 {pm_exec_delegate_job_ttl, Opts}
         end, Job).


fmap(Trans, {sequence, ListOfJobs}) ->
    {sequence, lists:map(fun (E) -> fmap(Trans, E) end, ListOfJobs)};
fmap(Trans, {parallel, ListOfJobs}) ->
    {parallel, lists:map(fun (E) -> fmap(Trans, E) end, ListOfJobs)};
fmap(Trans, {sleep, {Time, Job}}) ->
    {sleep, {Time, fmap(Trans, Job)}};
fmap(Trans, Job) when is_function(Trans) ->
    Trans(Job);
fmap(Trans, Job) when is_atom(Trans) ->
    job:Trans(Job).




retry_exp({_, _} = Job) ->
    {pm_exec_retry, {exp, Job}}.

retry_exp(StartDelay, {_, _} = Job) ->
    {pm_exec_retry, {{exp, StartDelay}, Job}}.


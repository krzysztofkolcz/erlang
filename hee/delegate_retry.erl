-module(delegate_retry).
-export([delegate_retry/2, example/0]).

example() ->
%% JobSpec0 = {parallel,[{'unix.quota.set',[{<<"target_host">>,<<"server0">>},
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
%%                            {<<"type">>,<<"total-mail">>}]}]}
%%
%% Job = {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                            {<<"unix_username">>,<<"server0">>},
%%                            {<<"quota">>,<<"10MB">>},
%%                            {<<"type">>,<<"system_account">>}]},

%% JobSpec1 = delegate_retry(JobSpec0),
%% 
%% JobSpec1 = 
%% {parallel,[
%% {pm_exec_delegate_ttl,#{ method => 'unix.quota.set',
%%   method_args => [{<<"target_host">>,<<"server0">>}, {<<"unix_username">>,<<"server0">>},{<<"quota">>,<<"10MB">>},{<<"type">>,<<"system_account">>}],
%%   ticket_id   => 1,
%%   ttl_ms      => 30*1000,
%%   retry_after_ttl => true 
%% }},
%% {pm_exec_delegate_ttl,#{ method => 'unix.quota.set',
%%   method_args => [{<<"target_host">>,<<"server0">>}, {<<"unix_username">>,<<"server0">>},{<<"quota">>,<<"10MB">>},{<<"type">>,<<"system_account">>}],
%%   ticket_id   => 1,
%%   ttl_ms      => 30*1000,
%%   retry_after_ttl => true 
%% }},
%% {pm_exec_delegate_ttl,#{ method => 'unix.quota.set',
%%   method_args => [{<<"target_host">>,<<"server0">>}, {<<"unix_username">>,<<"server0">>},{<<"quota">>,<<"10MB">>},{<<"type">>,<<"system_account">>}],
%%   ticket_id   => 1,
%%   ttl_ms      => 30*1000,
%%   retry_after_ttl => true 
%% }}
%% ]}

%% JobSpec = fmap(fun retry_exp/1, JobSpec1).
%% JobSpec = 
%% {parallel,[
%% {pm_exec_retry,{exp,{pm_exec_delegate_ttl,#{ method => 'unix.quota.set',
%%   method_args => [{<<"target_host">>,<<"server0">>}, {<<"unix_username">>,<<"server0">>},{<<"quota">>,<<"10MB">>},{<<"type">>,<<"system_account">>}],
%%   ticket_id   => 1,
%%   ttl_ms      => 30*1000,
%%   retry_after_ttl => true 
%% }}}},
%% {pm_exec_retry,{exp,{pm_exec_delegate_ttl,#{ method => 'unix.quota.set',
%%   method_args => [{<<"target_host">>,<<"server0">>}, {<<"unix_username">>,<<"server0">>},{<<"quota">>,<<"10MB">>},{<<"type">>,<<"system_account">>}],
%%   ticket_id   => 1,
%%   ttl_ms      => 30*1000,
%%   retry_after_ttl => true 
%% }}}},
%% {pm_exec_retry,{exp,{pm_exec_delegate_ttl,#{ method => 'unix.quota.set',
%%   method_args => [{<<"target_host">>,<<"server0">>}, {<<"unix_username">>,<<"server0">>},{<<"quota">>,<<"10MB">>},{<<"type">>,<<"system_account">>}],
%%   ticket_id   => 1,
%%   ttl_ms      => 30*1000,
%%   retry_after_ttl => true 
%% }}}}
%% ]}

JobSpec0 = {parallel,[{'unix.quota.set',[{<<"target_host">>, <<"server0">>},
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


%% fmap(Trans, {parallel, ListOfJobs}) ->
    %% {parallel, lists:map(fun (E) -> fmap(Trans, E) end, ListOfJobs)};

%% Trans = 
%% fun ({Method, Args}) ->
%%         OptsDef = #{ method      => Method,
%%                      method_args => Args,
%%                      ticket_id   => 1,
%%                      ttl_ms      => 30*1000,
%%                      retry_after_ttl => true 
%%                    },
%%         Opts = maps:merge(OptsDef, OptsIn),
%%         {pm_exec_delegate_job_ttl, Opts}
%% end

%% ListOfJobs = [{'unix.quota.set',[{<<"target_host">>,
%%                     <<"server0">>},
%%                    {<<"unix_username">>,<<"server0">>},
%%                    {<<"quota">>,<<"10MB">>},
%%                    {<<"type">>,<<"system_account">>}]},
%%              {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                    {<<"unix_username">>,<<"server0">>},
%%                    {<<"quota">>,<<"10MB">>},
%%                    {<<"type">>,<<"total-mysql">>}]},
%%              {'unix.quota.set',[{<<"target_host">>,<<"server0">>},
%%                    {<<"unix_username">>,<<"server0">>},
%%                    {<<"quota">>,<<"10MB">>},
%%                    {<<"type">>,<<"total-mail">>}]}]

%% Dla pierwszego elementu ListOfJobs
%% fun (E) -> fmap(Trans, E) end, ListOfJobs
%% Trans = -> patrz linia 76
%% E = {'unix.quota.set',[{<<"target_host">>,
%%                     <<"server0">>},
%%                    {<<"unix_username">>,<<"server0">>},
%%                    {<<"quota">>,<<"10MB">>},
%%                    {<<"type">>,<<"system_account">>}]}

%% fmap(Trans, Job) when is_function(Trans) ->
%%    Trans(Job);

%% Wynik:
%%  OptsDef = #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }

%% OptsIn = {}
%% Opts = maps:merge(OptsDef, OptsIn),
%% {pm_exec_delegate_job_ttl, Opts}
%%

%% Wynik:
%%  {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}


%% JobSpec1 = 

%%  {paralell,[{pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }},
%% {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }},
%% {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}]}


%% JobSpec = fmap(fun retry_exp/1, JobSpec1).

%% fmap(Trans, {parallel, ListOfJobs}) ->
    %% {parallel, lists:map(fun (E) -> fmap(Trans, E) end, ListOfJobs)};

%% Dla pierwszego elementu ListOfJobs
%% fun (E) -> fmap(Trans, E) end, ListOfJobs
%% Trans = -> retry_exp
%% E = {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}


%% Wynik:

%% {pm_exec_retry, {exp,
%% {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}
%% }}

%% JobSpec = 

%% {parallel[
%% {pm_exec_retry, {exp,
%% {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}
%% }},
%% {pm_exec_retry, {exp,
%% {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}
%% }},
%% {pm_exec_retry, {exp,
%% {pm_exec_delegate_job_ttl, #{ method => 'unix.quota.set', 
%%               method_args => [{<<"target_host">>,....}]
%%               ticket_id   => 1,
%%               ttl_ms      => 30*1000,
%%               retry_after_ttl => true }}
%% }}
%% ]}

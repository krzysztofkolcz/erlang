-module(plan).
-export([plan/0]).

plan() ->
    Hosting = <<"server0">>,
    DefaultTargetHost = <<"server0">>,

    Jobs = lists:flatmap(
             fun ({Type, QuotaArgument, TargetHostArgument}) ->
                   [ {Type,
                      {'unix.quota.set', [ {<<"target_host">>,  DefaultTargetHost},
                                           {<<"unix_username">>, Hosting},
                                           {<<"quota">>, <<"10MB">>}, 
                                           {<<"type">>, Type}
                                         ]}
                     } ]
             end,
             [ {<<"system_account">>, <<"system_account_quota">>, <<"target_host">>      },  
               {<<"total-mysql">>,    <<"total-mysql_quota">>,    <<"mysql_target_host">>},
               {<<"total-mail">>,     <<"total-mail_quota">>,     <<"mail_target_host">> }]
            ),
    Jobs.
    %% {Order, JobSpec0} = lists:unzip(Jobs),
    %% JobSpec0.
    %% {Order, parallel(JobSpec0)}.

parallel(ListOfJobs) ->
    {parallel, ListOfJobs}.


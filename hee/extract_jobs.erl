-module(extract_jobs).
-export([extract_jobs/1,example/0]).

example() ->
JobSpec = {parallel,[{'unix.quota.set',[{<<"target_host">>,
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

extract_jobs(JobSpec) .

extract_jobs(JobSpec) ->
    lists:reverse(extract_jobs(JobSpec, [])).
extract_jobs({SequenceOrParallel, JobList}, Acc)
  when (SequenceOrParallel == sequence);
       (SequenceOrParallel == parallel) ->
    lists:foldl(fun(E, S) -> extract_jobs(E, S) end, Acc, JobList);
extract_jobs({sleep, {_, Job}}, Acc) ->
    extract_jobs(Job, Acc);
extract_jobs({Method, _Args}, Acc) ->
    [to_bin(Method) | Acc].



to_bin({ok, V}) ->
    {ok, to_bin(V)};
to_bin(B) when is_binary(B) ->
    B;  
to_bin(I) when is_integer(I) ->
    list_to_binary(integer_to_list(I));
to_bin(L) when is_list(L) ->
    case mnesia_lib:is_string(L) of
        true ->
            list_to_binary(L);
        false ->
            iolist_to_binary(io_lib:format("~p", [L]))
    end;
to_bin(A) when is_atom(A) ->
    list_to_binary(atom_to_list(A));
to_bin(Other) ->
    iolist_to_binary(io_lib:format("~p", [Other])).


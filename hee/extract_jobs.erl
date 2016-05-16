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


%% Pytanie - czym jest 'unix.quota.set' - atomem, binary, stringiem?
%% Odp. 'unix.quota.set' jest traktowane jako atom

%% JobSpec = {parallel,[{'unix.quota.set',[...]},{'unix.quota.set',[...]},{'unix.quota.set',[...]}]}
%% extract_jobs(JobSpec) ->
%%    lists:reverse(extract_jobs(JobSpec, [])).

%% JobSpec = {parallel,[{'unix.quota.set',[...]},{'unix.quota.set',[...]},{'unix.quota.set',[...]}]}
%% extract_jobs(JobSpec, [])

%% extract_jobs({SequenceOrParallel, JobList}, Acc)
%%   when (SequenceOrParallel == sequence);
%%        (SequenceOrParallel == parallel) ->
%%     lists:foldl(fun(E, S) -> extract_jobs(E, S) end, Acc, JobList);
%% SezuenceOrParallel = parallel
%% JobList = [{'unix.quota.set',[...]},{'unix.quota.set',[...]},{'unix.quota.set',[...]}]

%%     lists:foldl(fun(E, S) -> extract_jobs(E, S) end, Acc, JobList);
%%      Acc = []
%%      JobList = [{'unix.quota.set',[...]},{'unix.quota.set',[...]},{'unix.quota.set',[...]}]


%% Pierwszy element JobList
%% Method = 'unix.quota.set'
%% _Args = [...]
%% Acc = []

%% extract_jobs({Method, _Args}, Acc) ->
%%     [to_bin(Method) | Acc].

%% Wynik Acc:
%% Acc = [<<"unix.quota.set">>]

%% Drugi element JobList
%% Method = 'unix.quota.set'
%% _Args = [...]
%% Acc = [<<"unix.quota.set">>]

%% extract_jobs({Method, _Args}, Acc) ->
%%     [to_bin(Method) | Acc].

%% Wynik Acc:
%% Acc = [<<"unix.quota.set">>,<<"unix.quota.set">>]

%% Itd...



to_bin({ok, V}) ->
    io:format("to_bin({ok,V})~n",[]),
    {ok, to_bin(V)};
to_bin(B) when is_binary(B) ->
    io:format("to_bin is_binary~n",[]),
    B;  
to_bin(I) when is_integer(I) ->
    io:format("to_bin is_integer~n",[]),
    list_to_binary(integer_to_list(I));
to_bin(L) when is_list(L) ->
    io:format("to_bin is_list~n",[]),
    case mnesia_lib:is_string(L) of
        true ->
            list_to_binary(L);
        false ->
            iolist_to_binary(io_lib:format("~p", [L]))
    end;
to_bin(A) when is_atom(A) ->
    io:format("to_bin is_atom~n",[]),
    list_to_binary(atom_to_list(A));
to_bin(Other) ->
    io:format("to_bin other~n",[]),
    iolist_to_binary(io_lib:format("~p", [Other])).


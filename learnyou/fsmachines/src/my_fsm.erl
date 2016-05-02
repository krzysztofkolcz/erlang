-module(my_fsm).
-behaviour(gen_fsm).
-export(start_link/1, start/1, init/1, sit/3, stay/3).

%% gen_fsm callbacks
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).
-record(state, {name="",state}).

start(Name) ->
  gen_fsm:start(?MODULE, [Name], []).

start_link(Name) ->
  gen_fsm:start_link(?MODULE, [Name], []).

sit_order(OwnPid) ->
    gen_fsm:sync_send_event(OwnPid, sit, infinity).

stay_order(OwnPid) ->
    gen_fsm:sync_send_event(OwnPid, stay, infinity).

%%% gen_fsm
%% init
init(Name) ->
    {ok, sit, #state{name=Name}}. 

%% Send user a notice. 
notice(#state{name=N}, Str, Args) ->
    io:format("~s: "++Str++"~n", [N|Args]),
    notice(S,"",[]).

sit(sit,S=#state{}) ->
    {next_state, sit, S#state{state="sit"}},
    notice(S,"",[]).

sit(stay,S=#state{}) ->
    {next_state, stay, S#state{state="stay"}},
    notice(S,"",[]).

stay(stay,S=#state{}) ->
    {next_state, stay, S#state{state="stay"}};
    notice(S).

stay(sit,S=#state{}) ->
    {next_state, sit, S#state{state="sit"}};
    notice(S).

code_change(_OldVsn, StateName, Data, _Extra) ->
    {ok, StateName, Data}.
 
%% Transaction completed.
terminate(normal, ready, S=#state{}) ->
    notice(S);
    terminate(_Reason, _StateName, _StateData) ->
    ok.

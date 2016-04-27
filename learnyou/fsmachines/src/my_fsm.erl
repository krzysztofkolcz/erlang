-module(my_fsm).
-behaviour(gen_fsm).
-export(start_link/1, start/1, init/1, sit/3, stay/3).

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
notice(#state{name=N,state=S}) ->
    io:format("~s~s: ~n", [N|S]).

sit(sit,S=#state{}) ->
    {next_state, sit, S#state{state="sit"}};
    notice(S).

sit(stay,S=#state{}) ->
    {next_state, stay, S#state{state="stay"}};
    notice(S).

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
    notice(S, "FSM leaving.", []);
    terminate(_Reason, _StateName, _StateData) ->
    ok.

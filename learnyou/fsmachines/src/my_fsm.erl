-module(my_fsm).
-behaviour(gen_fsm).
-export([start_link/1, start/1,  sit_order/1, stay_order/1]).
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3,terminate/3, code_change/4]).

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
    notice(S,"",[]);
sit(stay,S=#state{}) ->
    {next_state, stay, S#state{state="stay"}},
    notice(S,"",[]).

stay(stay,S=#state{}) ->
    {next_state, stay, S#state{state="stay"}},
    notice(S,"",[]);
stay(sit,S=#state{}) ->
    {next_state, sit, S#state{state="sit"}},
     notice(S,"",[]).

code_change(_OldVsn, StateName, Data, _Extra) ->
    {ok, StateName, Data}.
 
%% Transaction completed.
terminate(normal, ready, S=#state{}) ->
    notice(S,"",[]);
terminate(_Reason, _StateName, _StateData) ->
    ok.

%% The other player has sent this cancel event
%% stop whatever we're doing and shut down!
handle_event(cancel, _StateName, S=#state{}) ->
    notice(S, "received cancel event", []),
    {stop, other_cancelled, S};

handle_event(Event, StateName, Data) ->
    unexpected(Event, StateName),
    {next_state, StateName, Data}.

handle_info({'DOWN', Ref, process, Pid, Reason}, _, S=#state{}) ->
    notice(S, "Other side dead", []),
    {stop, {other_down, Reason}, S};

handle_info(Info, StateName, Data) ->
    unexpected(Info, StateName),
    {next_state, StateName, Data}.

 
%% Unexpected allows to log unexpected messages
unexpected(Msg, State) ->
  io:format("~p received unknown event ~p while in state ~p~n", [self(), Msg, State]).

%% This cancel event comes from the client. We must warn the other
%% player that we have a quitter!
handle_sync_event(cancel, _From, _StateName, S = #state{}) ->
    notice(S, "cancelling", []),
    {stop, cancelled, ok, S};

%% Note: DO NOT reply to unexpected calls. Let the call-maker crash!
handle_sync_event(Event, _From, StateName, Data) ->
    unexpected(Event, StateName),
    {next_state, StateName, Data}.

notify_cancel(OtherPid) ->
    gen_fsm:send_all_state_event(OtherPid, cancel).

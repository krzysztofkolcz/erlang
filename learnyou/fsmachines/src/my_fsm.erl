-module(my_fsm).
-behaviour(gen_fsm).
-export([start_link/1, start/1,  sit_order/0, stay_order/0, print_list/1, sit/2, stay/2]).
%% gen_fsm callbacks
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).
-record(state, {name="",current_state,state_list}).

start(Name) ->
  %% gen_fsm:start(?MODULE, [Name], []).
  gen_fsm:start({local, my_fsm}, my_fsm, Name, []).

start_link(Name) ->
  %% gen_fsm:start_link(?MODULE, [Name], []).
  gen_fsm:start_link({local, my_fsm}, my_fsm, Name, []).

sit_order() ->
    gen_fsm:send_event(my_fsm, sit).%% TODO sync_send_event

stay_order() ->
    gen_fsm:send_event(my_fsm, stay).%% TODO sync_send_event

%%% gen_fsm
%% init
init(Name) ->
    {ok, sit, #state{name=Name,current_state="sit",state_list=["sit"]}}. 

%% Send user a notice. 
notice(#state{name=N}, Str, Args) ->
    io:format("~s: "++Str++"~n", [N|Args]).

print_list([H|T]) ->
  io:format("~p,",[H]),
  print_list(T);
print_list([]) ->
  ok.

%% TODO sync_send_event - sit(event,from,data)
sit(sit,S=#state{}) ->
    notice(S,"",[]),
    print_list(S#state.state_list),
    {next_state, sit, S#state{current_state="sit",state_list=["sit"|S#state.state_list]}};
sit(stay,S=#state{}) ->
    notice(S,"",[]),
    print_list(S#state.state_list),
    {next_state, stay, S#state{current_state="stay",state_list=["stay"|S#state.state_list]}};
sit(Event,Data) ->
    unexpected(Event,sit),
    {next_state,sit,Data}.


%% TODO sync_send_event - stay(event,from,data)
stay(stay,S=#state{}) ->
    notice(S,"",[]),
    print_list(S#state.state_list),
    {next_state, stay, S#state{current_state="stay",state_list=["stay"|S#state.state_list]}};
stay(sit,S=#state{}) ->
    notice(S,"",[]),
    print_list(S#state.state_list),
    {next_state, sit, S#state{current_state="sit",state_list=["sit"|S#state.state_list]}};
stay(Event,Data) ->
    unexpected(Event,stay),
    {next_state,stay,Data}.

code_change(_OldVsn, StateName, Data, _Extra) ->
    {ok, StateName, Data}.
 
%% Transaction completed.
terminate(normal, ready, S=#state{}) ->
    notice(S,"",[]);
terminate(_Reason, _StateName, _StateData) ->
    ok.

unexpected(Msg, State) ->
    io:format("~p received unknown event ~p while in state ~p~n", [self(), Msg, State]).

handle_event(Event, StateName, Data) ->
    unexpected(Event, StateName).

handle_info(Info, StateName, Data) ->
    unexpected(Info, StateName).


handle_sync_event(Event, _From, StateName, Data) ->
    unexpected(Event, StateName).

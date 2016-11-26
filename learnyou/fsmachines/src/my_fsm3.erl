-module(my_fsm3).
-behaviour(gen_fsm).
-export([start_link/1, start/1]).
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3,terminate/3, code_change/4]).
-export([sit/1, stay/1]).

-record(state, {name="", items=[]}).

start_link(Name) ->
    gen_fsm:start_link({local, my_fsm3}, my_fsm3, Name, []).

start(Name) ->
    gen_fsm:start({local, my_fsm3}, my_fsm3, Name, []).

init(Name) ->
    {ok, sit, #state{name=Name, items=[]}}. 

sit(FsmRef) ->
  gen_fsm:send_all_state_event(FsmRef,{sit}).

stay(FsmRef) ->
  gen_fsm:send_all_state_event(FsmRef,{stay}).

%%% Helper functions
print_list([H|T]) ->
    io:format("~p,",[H]),
    print_list(T);
print_list([]) ->
    ok.

sit(Event,StateData = #state{Name = name,Items = items}) ->
    print_list(Items), 
    StaetData#state.items = [sit|Items],
    {next_state,sit,StateData}.

stay(Event,StateData) ->
    print_list(Items), 
    {next_state,stay,StateData#state{items=[sit|StateData#state.items]}}.

handle_info({sit}, sit, Data) ->
    {next_state, sit, Data};
handle_info({stay}, sit, Data) ->
    {next_state, sit, Data};
handle_info({sit}, stay, Data) ->
    {next_state, stay, Data};
handle_info({stay}, stay, Data) ->
    {next_state, stay, Data};
handle_info(Info, StateName, Data) ->
    {next_state, StateName, Data}.

unexpected(Msg, State) ->
    io:format("~p received unknown event ~p while in state ~p~n", [self(), Msg, State]).

handle_event(Event, StateName, Data) ->
    unexpected(Event, StateName),
    {next_state, StateName, Data}.

handle_sync_event(Event, _From, StateName, Data) ->
    unexpected(Event, StateName),
    {next_state, StateName, Data}.

terminate(_Reason, _StateName, _StateData) ->
    ok.

code_change(_OldVsn, StateName, Data, _Extra) ->
    {ok, StateName, Data}.

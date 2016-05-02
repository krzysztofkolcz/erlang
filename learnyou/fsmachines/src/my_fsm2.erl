-module(my_fsm2).
-behaviour(gen_fsm).
-export([start_link/1, start/1,  pet/1]).
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3,terminate/3, code_change/4]).
-export([dont_give_crap/2, dont_give_crap/3,print_list/1]).

-record(state, {name="", items=[]}).

start_link(Name) ->
      gen_fsm:start_link({local, my_fsm2}, my_fsm2, Name, []).

start(Name) ->
      gen_fsm:start({local, my_fsm2}, my_fsm2, Name, []).

init(Name) ->
    {ok, dont_give_crap, #state{name=Name, items=[]}}. 

pet(Whoispetting) ->
  gen_fsm:send_event(my_fsm2,{event, Whoispetting}).


print_list([H|T]) ->
  io:format("~p,",[H]),
  print_list(T);
print_list([]) ->
  ok.

%% StateName(Event, Data) ->
dont_give_crap({event,Whoispetting}, S=#state{}) ->
    notice(S, "", []),
    io:format("\"~s\",", [Whoispetting]),
    %% io:format("~s: ~n", S#state.items),
    print_list(S#state.items),
    io:format("~n",[]),
    %% print_list(S#state.items),
    {next_state,dont_give_crap,S#state{items=[Whoispetting|S#state.items]}};
dont_give_crap(Event, Data)  ->
    unexpected(Event,dont_give_crap),
    {next_state,dont_give_crap,Data}.


%% StateName(Event,From, Data) ->
dont_give_crap({event,Whoispetting}, From, S=#state{}) ->
    notice(S, "", []),
    notice(S, "~w", S#state.items),
    {next_state,dont_give_crap,S#state{items=[Whoispetting|S#state.items]}};
dont_give_crap(Event, From, Data) ->
    unexpected(Event,dont_give_crap),
    {next_state,dont_give_crap,Data}.

notice(#state{name=N}, Str, Args) ->
    io:format("~s: "++Str++"~n", [N|Args]).

%% Unexpected allows to log unexpected messages
unexpected(Msg, State) ->
    io:format("~p received unknown event ~p while in state ~p~n", [self(), Msg, State]).



handle_info(Info, StateName, Data) ->
    unexpected(Info, StateName),
    {next_state, StateName, Data}.

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

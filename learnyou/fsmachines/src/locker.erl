%% https://pdincau.wordpress.com/2010/09/07/an-introduction-to-gen_fsm-behaviour/
%% -module(lock_fsm).
%% -export([start_link/0, init/1]).
%% -behaviour(gen_fsm).
%%
%% start_link() ->
%%   gen_fsm:start_link({local, ?SERVER}, ?MODULE, [], []).
%%
%% init([]) ->
%%     {ok, unlocked, #state{code=1234}}.
%%
%% %% asynchronous
%% %% StateName(Event, StateData) ->
%% %%     .. code for actions here ...
%% %%     {next_state, NewStateName, NewStateData}
%%
%% %% synchronous - returns value to the user
%% %% StateName(Event, From, StateData) ->
%% %%     .. code for actions here ...
%% %%     {next_state, Reply, NewStateName, NewStateData}
%%
%% %% State
%% unlocked({lock, Code}, _From, State) ->
%%   case State#state.code =:= Code of
%%     true ->
%%       {reply, ok, locked, State};
%%     false ->
%%       {reply, {error, wrong_code}, unlocked, State}
%%   end;
%%  
%% %% State
%% unlocked(_Event, _From, State) ->
%%   Reply = {error, invalid_message},
%%   {reply, Reply, unlocked, State}.
%%
%%
%% %% Event
%% lock(Code) ->
%%   gen_fsm:sync_send_event(?SERVER, {lock, Code}).

-module(locker).
-behaviour(gen_fsm).
 
%% API
-export([start_link/0]).
 
%% gen_fsm callbacks
-export([init/1, unlocked/2, unlocked/3,  locked/2, locked/3, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).
-export([lock/1, unlock/1]).
-define(SERVER, ?MODULE).
-record(state, {code}).
 
%%%===================================================================
%%% API
%%%===================================================================
 
%%--------------------------------------------------------------------
%% @doc
%% Creates a gen_fsm process which calls Module:init/1 to
%% initialize. To ensure a synchronized start-up procedure, this
%% function does not return until Module:init/1 has returned.
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_fsm:start_link({local, ?SERVER}, ?MODULE, [], []).
 
unlock(Code) ->
  gen_fsm:sync_send_event(?SERVER, {unlock, Code}).
 
lock(Code) ->
  gen_fsm:sync_send_event(?SERVER, {lock, Code}).
 
%%%===================================================================
%%% gen_fsm callbacks
%%%===================================================================
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm is started using gen_fsm:start/[3,4] or
%% gen_fsm:start_link/[3,4], this function is called by the new
%% process to initialize.
%%
%% @spec init(Args) -> {ok, StateName, State} |
%%                     {ok, StateName, State, Timeout} |
%%                     ignore |
%%                     {stop, StopReason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    {ok, unlocked, #state{code=1234}}.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_event/2, the instance of this function with the same
%% name as the current state name StateName is called to handle
%% the event. It is also called if a timeout occurs.
%%
%% @spec state_name(Event, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState}
%% @end
%%--------------------------------------------------------------------
unlocked(_Event, State) ->
  {next_state, unlocked, State}.
 
locked(_Event, State) ->
  {next_state, locked, State}.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_event/[2,3], the instance of this function with
%% the same name as the current state name StateName is called to
%% handle the event.
%%
%% @spec state_name(Event, From, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {reply, Reply, NextStateName, NextState} |
%%                   {reply, Reply, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState} |
%%                   {stop, Reason, Reply, NewState}
%% @end
%%--------------------------------------------------------------------
unlocked({lock, Code}, _From, State) ->
  case State#state.code =:= Code of
    true ->
      {reply, ok, locked, State};
    false ->
      {reply, {error, wrong_code}, unlocked, State}
  end;
 
unlocked(_Event, _From, State) ->
  Reply = {error, invalid_message},
  {reply, Reply, unlocked, State}.
 
locked({unlock, Code}, _From, State) ->
  case State#state.code =:= Code of
    true ->
      {reply, ok, unlocked, State};
    false ->
      {reply, {error, wrong_code}, locked, State}
  end;
 
locked(_Event, _From, State) ->
  Reply = {error, invalid_message},
  {reply, Reply, locked, State}.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_all_state_event/2, this function is called to handle
%% the event.
%%
%% @spec handle_event(Event, StateName, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState}
%% @end
%%--------------------------------------------------------------------
handle_event(_Event, StateName, State) ->
    {next_state, StateName, State}.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_all_state_event/[2,3], this function is called
%% to handle the event.
%%
%% @spec handle_sync_event(Event, From, StateName, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {reply, Reply, NextStateName, NextState} |
%%                   {reply, Reply, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState} |
%%                   {stop, Reason, Reply, NewState}
%% @end
%%--------------------------------------------------------------------
handle_sync_event(_Event, _From, StateName, State) ->
    Reply = ok,
    {reply, Reply, StateName, State}.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it receives any
%% message other than a synchronous or asynchronous event
%% (or a system message).
%%
%% @spec handle_info(Info,StateName,State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, StateName, State) ->
    {next_state, StateName, State}.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_fsm terminates with
%% Reason. The return value is ignored.
%%
%% @spec terminate(Reason, StateName, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _StateName, _State) ->
    ok.
 
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, StateName, State, Extra) ->
%%                   {ok, StateName, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.
 
%%%===================================================================
%%% Internal functions
%%%===================================================================

-module(my_ppool_serv_1).
%% -behaviour(gen_server).
%% -record(state, {limit=1, working_processes, waiting_processes}).
%% -record(process, {name, desc}).
%%
%% -export([start_link/1, add_process/3, stop_server/1, print_processes/1]).
%% -export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).
%%
%% start_link(Name,Limit,SupPid,MFA) -> 
%%   gen_server:start_link({local,?MODULE},?MODULE, [Name,Limit,SupPid,MFA],  []).
%%
%%   %% API
%% add_process(Pid,Name,Desc)->
%%   gen_server:call(Pid,{add,Name,Desc}).
%%
%% print_processes(Pid)->
%%   gen_server:call(Pid,{print}).
%%
%% stop_server(Pid)->
%%   gen_server:call(Pid,terminate).
%%
%% %% Callback
%% init(Name,Limit,SupPid,MFA)->
%%   {ok,#state{limit=Limit,working_processes=[],waiting_processes=[]}}.
%%
%% handle_call({add,Name,Desc},_From,State)->
%%   %% if State#state.limit <= 
%%
%%   NewProcess=#process{name=Name,desc=Desc},
%%   {reply,NewProcess,State#state{working_processes=[NewProcess|State#state.working_processes]}};
%% handle_call({print},_From,State)->
%%   io:format("limit: ~p.~n",[State#state.limit]),
%%   [io:format("~p.~n",[P#process.name]) || P <- State#state.working_processes],
%%   {reply,<<"ok">>,State};
%% handle_call(terminate, _From, State) ->
%%   {stop, normal, ok, State}.
%%
%% handle_cast(Msg, State) ->
%%   {noreply, State}.
%%
%% handle_info(Msg, State) ->
%%   io:format("Unexpected message: ~p~n",[Msg]),
%%   {noreply, State}.
%%
%% terminate(normal, State) ->
%%   io:format("terminate~n",[]),
%%   ok.
%%
%% code_change(_OldVsn, State, _Extra) ->
%%   %% No change planned. The function is there for the behaviour,
%%   %% %% but will not be used. Only a version on the next
%%   {ok, State}.

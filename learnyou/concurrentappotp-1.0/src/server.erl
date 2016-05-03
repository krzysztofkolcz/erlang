-module(server).
-behaviour(gen_server).
-compile(export_all).
-export([subscribe/1, add_event/3,cancel_event/1,shutdown/1]).
-export([start_link/2, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {events,    %% list of #event{} records
                clients}). %% list of Pids
 
%% -record(event, {name="", description="", pid, timeout={{1970,1,1},{0,0,0}}}).
-record(event, {name="", description="", pid, togo}).


add_event({Pid,Ref},Name,ToGo) ->
  gen_server:call({add_event,Name,ToGo},{Pid,Ref}).

start_link(Name,ToGo) ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok,#state{events=orddict:new(), clients=orddict:new()}}.

handle_call({add_event,Name,ToGo},From,State)->
;
handle_call(Request,From,State)->
    io:format("handle_call~n",[]),
    {noreply,State}. 

handle_cast(Request,State)->
    io:format("handle_cast~n",[]),
    {noreply,State}.

terminate(_Reason, _State) ->
    io:format("terminate~n",[]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    io:format("code_change~n",[]),
    {ok, State}.

handle_info(Request,State)->
    io:format("handle_info~n",[]),
    {stop, normal, State}.

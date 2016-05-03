-module(event).
-behaviour(gen_server).
-compile(export_all).
-record(state, {server, name="", to_go=0}).
-export([cancel/1]).
-export([start_link/2, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link(Name,ToGo) ->
    gen_server:start_link(?MODULE, [self(),Name,ToGo], []).

init([Server,Name,ToGo]) ->
    TimeOut = ToGo*1000,
    io:format("init~n",[]),
    {ok, #state{server=Server, name=Name, to_go = ToGo},TimeOut}.

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

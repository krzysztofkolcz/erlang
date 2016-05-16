-module(workworkgenserv).
-behaviour(gen_server).

-export([start_link/3, stop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {time,n,name}).
-define(DELAY, 3000).

start_link(Time,N,Name) ->
    gen_server:start_link({local, Name}, ?MODULE, [Time, N,Name], []).

stop(Pid) ->
  gen_server:call(Pid, stop).

init([Time,N,Name]) ->
  io:format("workworkgenserv init start~n"),
  %% loop(Time,N),
  {ok, #state{time=Time, n=N,name=Name}, Time}.

handle_call(stop, _From, S=#state{}) ->
    {stop, normal, ok, S}; %% ok - nie wywali błedu? Chyba nie, bo to reply, a handle_call jest synchr...

handle_call(_Message, _From, S) ->
    {noreply, S, ?DELAY}.%% co się dzieje w tym wypadku? leci timeout i handle_info(timeout...)???
 
handle_cast(_Message, S) ->
    {noreply, S, ?DELAY}.%% co się dzieje w tym wypadku? leci timeout i handle_info(timeout...) ???

handle_info(timeout, S = #state{time=Time,n=N,name=Name}) ->
    io:format("loop:~p, name:~p ~n",[S#state.n,Name]),
    if S#state.n > 0 ->
      {noreply, S#state{n=N-1}, Time}; %% noreply - leci timeout do handle_info?
      true -> 
      {stop, normal,  S}
    end;

handle_info(_Message, S) ->
    {noreply, S, ?DELAY}.%% co się dzieje w tym wypadku? leci timeout i handle_info(timeout...)???

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
terminate(normal, S) ->
  io:format("finish N:~p, name:~p~n",[S#state.n,S#state.name]);
terminate(_Reason, S) ->
  io:format("finish N:~p, name:~p~n",[S#state.n,S#state.name]).


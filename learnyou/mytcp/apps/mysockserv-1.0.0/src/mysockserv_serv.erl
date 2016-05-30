-module(mysockserv_serv).
-behaviour(gen_server).
-export([start_link/1, ping/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

-define(SERVER,?MODULE).

-record(state, {accept}).

start_link(Socket) ->
  %% gen_server:start_link({local, ?SERVER}, ?MODULE, [Socket], []). %% dla tego wywołania nie można było utworzyć więcej niż jednego wątku tego gen_servera. Co oznacza {local, ?MODULE} jako pierwszy parametr?
  gen_server:start_link( ?MODULE, [Socket], []).

ping() ->
  gen_server:cast(?SERVER, ping).

init([Socket]) ->
  <<A:32, B:32, C:32>> = crypto:rand_bytes(12),
  random:seed({A,B,C}),
  io:format("Socket started!~n",[]),
  gen_server:cast(self(),{listen,Socket}),
  {ok, #state{}}.

handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.

handle_cast(ping, State) ->
  io:format("Got It!~n"),
  {noreply, State};
handle_cast({listen,Socket}, State = #state{}) ->
  {ok, Accept } = gen_tcp:accept(Socket),
  io:format("Socket listen!~n"),
  {noreply, State#state{accept=Accept}}.


handle_info({tcp, _Socket, "quit"++_}, S) ->
  gen_tcp:close(S#state.accept),
  {stop, normal, S};
handle_info({quit}, S) ->
  gen_tcp:close(S#state.accept),
  {stop, normal, S};
handle_info({tcp,Socket,Msg}, State = #state{accept=Accept}) ->
  gen_tcp:send(Accept,io_lib:format("msg:~p~n", [Msg])),
  inet:setopts(Accept, [{active, once}]),
  {noreply, State};
handle_info(timeout, State) ->
  {noreply, State};
handle_info({tcp_closed, _Socket}, S) ->
  {stop, normal, S};
handle_info({tcp_error, _Socket, _}, S) ->
  {stop, normal, S};
handle_info(E, S) ->
  io:format("unexpected: ~p~n", [E]),
  {noreply, S}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

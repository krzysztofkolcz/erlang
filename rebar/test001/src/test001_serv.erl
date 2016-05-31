-module(test001_serv).
-behaviour(gen_server).
-export([start_link/0, ping/0, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

%% Init
start_link()->
  gen_server:start_link({local,?MODULE},?MODULE,[],[]).

init([])->
  {ok,{}}.

%% API
ping() ->
  gen_server:call(?MODULE,{ping}).

stop() ->
  gen_server:call(?MODULE,{stop}).

%% Internal
handle_call({ping},_From,State) ->
  {reply,watsuup,State};
handle_call({stop},_From,State) ->
  {stop, normal, ok, State}.

handle_cast(Msg,State) ->
  {noreply,State}.

handle_info(Msg,State) ->
  {noreply,State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

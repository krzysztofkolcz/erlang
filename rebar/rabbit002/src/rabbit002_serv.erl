-module(rabbit002_serv).
-behaviour(gen_server).
-export([start_link/0, add/1, stop/0, display/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

-record(state, {list}).
start_link() ->
  gen_server:start_link({local,?MODULE},?MODULE, [], []).

stop() ->
  ok.

init([]) ->
  {ok, #state{ }}.

add(Element) ->
  gen_server:call(?MODULE,{add,Element}).

display() ->
  List = gen_server:call(?MODULE,{display}),
  print_list(List).

print_list([Head|Tail])->
  io:format("~p~n",[Head]),
  print_list(Tail);
print_list([])->
  ok.

handle_call({add,Element},From,State = #state{list=List}) ->
  {reply,ok,#state{list=[Element|List]}};
handle_call({display},From,State = #state{list=List}) ->
  {reply,List,State}.

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

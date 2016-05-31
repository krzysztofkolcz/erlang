-module(test001_tests).
-include_lib("eunit/include/eunit.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TESTS DESCRIPTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

start_stop_test_() ->
    {"The server can be started, stopped and has a registered name",
     {setup,
     fun start/0,
     fun stop/1,
     fun is_registered/1}}.

ping_test_() ->
    {"The server can be pinged, returns ok atom",
     {setup,
     fun start/0,
     fun stop/1,
     fun is_pingeable/0}}.

%%%%%%%%%%%%%%%%%%%%%%%
%%% SETUP FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
start() ->
    {ok, Pid} = test001_serv:start_link(),
    Pid.

stop(_) ->
    test001_serv:stop().

%%%%%%%%%%%%%%%%%%%%
%%% ACTUAL TESTS %%%
%%%%%%%%%%%%%%%%%%%%
is_registered(Pid) ->
    [?_assert(erlang:is_process_alive(Pid)),
     ?_assertEqual(Pid, whereis(test001_serv))].

is_pingeable() ->
    [?_assertEqual(test001_serv:ping(), watsuup)].












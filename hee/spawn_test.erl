-module(spawn_test).
-export([example/0]).

example() ->
  io:format("example beginning"),
  %% to leci asynchronicznie
  proc_lib:spawn_link(
    fun()->
      io:format("proc_lib:spawn_link function sleep start"),
      timer:sleep(10000),
      io:format("proc_lib:spawn_link function sleep end")
      end
  ),
  proc_lib:start_link(
    fun()->
      io:format("proc_lib:start_link function sleep start"),
      timer:sleep(10000),
      io:format("proc_lib:start_link function sleep end")
      end
  ),
  io:format("example end"),
  ok.

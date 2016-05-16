-module(worker).
-export([init/1]).

init([x])->
  timer:sleep(x),
  ok.


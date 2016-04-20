-module(evserv).
-compile(export_all).
-record(state, {events,    %% list of #event{} records
                clients}). %% list of Pids
 
-record(event, {name="",
                description="",
                pid,
                timeout={{1970,1,1},{0,0,0}}}).

loop(S = #state{}) ->
  receive
    ...
  end.


init() ->
  %% Loading events from a static file could be done here.
  %% %% You would need to pass an argument to init telling where the
  %% %% resource to find the events is. Then load it from here.
  %% %% Another option is to just pass the events straight to the server
  %% %% through this function.
  loop(#state{events=orddict:new(),
    clients=orddict:new()}).

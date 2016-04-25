3 odpalenie tut17:
1. Na lokalniej maszynie: erl -sname pong (tworzy noda pong)
2. W uruchomionej konsolce noda odpalam tut17:start_pong().
3. Na zadlnej maszynie: erl -sname ping (tworzy noda ping)
4. W uruchomionej konsolce noad odpala tut17:start_ping(pong@parowy). 

# gen_server:
## start_link/3-4 parametry wywołania
gen_server:start_link(?MODULE, [], []).


# implemencacja gen_server behaviour:
## init:
### return:
{ok, State}
{ok, State, TimeOut}
{ok, State, hibernate}
{stop, Reason} or ignore

### desc:
TimeOut
Jeżeli żadna wiadomość nie zostanie obsłużona przed TimeOut (init), po wystąpieniu TimeOut wywoływana jest funkcja handle_info.

## handle_call:
### params:
Request, From, and State.

### return:
{reply,Reply,NewState}
{reply,Reply,NewState,Timeout}
{reply,Reply,NewState,hibernate}
{noreply,NewState}
{noreply,NewState,Timeout}
{noreply,NewState,hibernate}
{stop,Reason,Reply,NewState}
{stop,Reason,NewState}

## handle_cast:
### return:
{noreply,NewState}
{noreply,NewState,Timeout}
{noreply,NewState,hibernate}
{stop,Reason,NewState}

## handle_info:
### desc:
Wywoływana po przekroczeniu TimeOut - init

# gen_fsm return values:
## init:
{ok, StateName, Data}
{ok, StateName, Data, Timeout}
{ok, StateName, Data, hibernate}
{stop, Reason} 

## state:
{reply, Reply, NextStateName, NewStateData}
{reply, Reply, NextStateName, NewStateData, Timeout}
{reply, Reply, NextStateName, NewStateData, hibernate}

{next_state, NextStateName, NewStateData}
{next_state, NextStateName, NewStateData, Timeout}
{next_state, NextStateName, NewStateData, hibernate}

{stop, Reason, Reply, NewStateData}
{stop, Reason, NewStateData}

# Supervisors
## start_link
### params:
supervisor:start_link({local,?MODULE}, ?MODULE, Type).
## init
### return values:
{ok, {{RestartStrategy, MaxRestart, MaxTime},[ChildSpecs]}}.

np.:
{ok, {{one_for_all, 5, 60}, [...]}}.

## ChildSpecs
{ChildId, StartFunc, Restart, Shutdown, Type, Modules}.

np.:
[{fake_id, {fake_mod, start_link, [SomeArg]}, permanent, 5000, worker, [fake_mod]},
{other_id, {event_manager_mod, start_link, []}, transient, infinity, worker, dynamic}]

## start_child





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

# gen_fsm 
## init return values:
{ok, StateName, Data}
{ok, StateName, Data, Timeout}
{ok, StateName, Data, hibernate}
{stop, Reason} 


## state/2 (async):

## state/3 (sync):

## state/3 return values:
{reply, Reply, NextStateName, NewStateData}
{reply, Reply, NextStateName, NewStateData, Timeout}
{reply, Reply, NextStateName, NewStateData, hibernate}

{next_state, NextStateName, NewStateData}
{next_state, NextStateName, NewStateData, Timeout}
{next_state, NextStateName, NewStateData, hibernate}

{stop, Reason, Reply, NewStateData}
{stop, Reason, NewStateData}

## send_event/2 - wysyłanie asynchronicznych eventów

## send_sync_event/2-3 - wysyłanie synchronicznych eventów

## send_all_state_event/2 

## sync_send_all_state_event/2-3

## handle_event/3
handle async events (no mather state we are in)
## handle_sync_event/4
handle sync events (no mather state we are in)

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



## Odpalenie erlcount + ppool
cd erlangtut/learnyou
cd ppool-1.0
erl -make

cd ../erlcount-1.0
erl -make

cd ..
erl -env ERL_LIBS "."

erl> application:load(ppool).
erl> application:start(ppool), application:start(erlcount).




## rebar3


## rabbit
### rabbitmqadmin
sudo ln -s /usr/lib/rabbitmq/bin/rabbitmq-plugins /usr/local/bin/rabbitmq-plugins
http://localhost:15672/cli/ - save rabbitmqadmin; make executable; mv to /usr/local/bin

/etc/rabbitmq/rabbitmq.config 
/etc/rabbitmq/enabled_plugins

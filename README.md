3 odpalenie tut17:
1. Na lokalniej maszynie: erl -sname pong (tworzy noda pong)
2. W uruchomionej konsolce noda odpalam tut17:start_pong().
3. Na zadlnej maszynie: erl -sname ping (tworzy noda ping)
4. W uruchomionej konsolce noad odpala tut17:start_ping(pong@parowy). 


# 
erl -make
erl -pa <directory> 
looking for modules in directory

# spawn:
## spawn/1
spawn(function_name).
zwraca Pid procesu

1> F = fun() -> 2 + 2 end.
2> spawn(F).

4> G = fun(X) -> timer:sleep(10), io:format("~p~n", [X]) end.
5> [spawn(fun() -> G(X) end) || X <- lists:seq(1,10)].

### funkcja w module
spawn(fun linkmon:myproc/0).

## spawn/3
spawn(module_name, function_name, function_params).

# link
Link - jeżeli linkowany proces zginie, zginie również proces linkujący.
When that relationship is set up and one of the processes dies from an unexpected throw, error or exit, the other linked process also dies.

## spawn_link
aby nie czekać na link 

# process_flag
process_flag(trap_exit, true)
System processes are basically normal processes, except they can convert exit signals to regular messages. 
Czyli zmienia sygnał wyjścia w msg:
1> process_flag(trap_exit, true).
true
2> spawn_link(fun() -> linkmon:chain(3) end).
<0.49.0>
3> receive X -> X end.
{'EXIT',<0.49.0>,"chain dies here"}

# monitors
Inaczej niż link, jeżeli monitorowany proces zginie, proces monitorujący otrzyma wiadomość
erlang:monitor/2
pierwszy parametr to atmo process
1> erlang:monitor(process, spawn(fun() -> timer:sleep(500) end)).
#Ref<0.0.0.77>
2> flush().
Shell got {'DOWN',#Ref<0.0.0.77>,process,<0.63.0>,normal}
ok

Every time a process you monitor goes down, you will receive such a message. The message is {'DOWN', MonitorReference, process, Pid, Reason}.

## spawn_monitor/1-3
spawn a process while monitoring it

# register

Pid = spawn_link(?MODULE, critic, []),
register(critic, Pid),
...

critic ! {self(), {Band, Album}},
Pid = whereis(critic),
...

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
### wywołanie
gen_server:call(Pid,{msg})

### params:
handle_call({msg},From,State)

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
### wywołanie
gen_server:cast(Pid,{msg})

### return:
{noreply,NewState}
{noreply,NewState,Timeout}
{noreply,NewState,hibernate}
{stop,Reason,NewState}

## handle_info:
### wywołanie:
self() ! {msg}
handle_info({msg},State)

timeout?

process_flag?

{noreply, {msg}, Delay} - leci do handle_info(timeout,{msg})

### desc:
Wywoływana po przekroczeniu TimeOut - init

# gen_fsm 
http://erlang.org/documentation/doc-4.8.2/doc/design_principles/fsm.html
## init return values:
{ok, StateName, StateData}
{ok, StateName, StateData, Timeout}
{ok, StateName, StateData, hibernate}
{stop, Reason} 


## state/2 (async):

### return
{next_state, NextStateName, NextState} |
{next_state, NextStateName, NextState, Timeout} |
{stop, Reason, NewState}

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

## sync_send_event/2-3 - wysyłanie synchronicznych eventów
gen_fsm:sync_send_event(?SERVER, {msg}).

teraz rozumiem to tak, że jeżeli gen_fsm jest w jakimś stanie (np. unlocked),
wówczas powinien mieć funkcję:
unlocked({msg},_From ,State)


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
start_child(SupervisorNameOrPid, ChildSpec)


## kompilacja
jeżeli pliki są w jednym katalogu, np. src wchodzę do tego katalogu i odpalam:
erlc *.erl
%% *. - nie wiem czemu ten symbol powoduje podświetlenie w vim
następnie:
erl


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
rebar3 new app <app-name>


## rabbit
echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
sudo apt-get update

lub

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash

sudo apt-get install rabbitmq-server

### rabbitmqadmin
sudo ln -s /usr/lib/rabbitmq/bin/rabbitmq-plugins /usr/local/bin/rabbitmq-plugins
sudo ln -s /usr/lib/rabbitmq/bin/rabbitmq-env /usr/local/bin/rabbitmq-env
rabbitmq-plugins enable rabbitmq_management

http://localhost:15672/cli/ - save rabbitmqadmin; 
rename to rabbitmqadmin (if rabbitmqadmin.txt)
make executable; 
mv to /usr/local/bin

http://localhost:15672/
user:guest
pass:guest

/etc/rabbitmq/rabbitmq.config 
/etc/rabbitmq/enabled_plugins

# erlang & rabbit
https://www.rabbitmq.com/erlang-client-user-guide.html --chyba stare 
https://cartesianfaith.com/2011/01/24/rabbitmq-client-examples-using-rebar/ --chyba stare 
https://github.com/careo/rabbitmq-erlang-client-examples -- chyba stare

https://github.com/rabbitmq/rabbitmq-tutorials/tree/master/erlang - wersja sprzed 5 lat
https://www.rabbitmq.com/erlang-client-user-guide.html - wersja sprzed 5 lat
ERL_LIBS=include erlc -o ebin send.erl - za stare
ERL_LIBS=include erlc -o ebin recv.erl - za stare

https://github.com/jbrisbin/amqp_client - rebar friendly version of rabbit


== rabbit ==
katalog:
/erlang/rabbit

rebar3 compile
erl -env ERL_LIBS _build/default/lib/ -eval 'application:ensure_all_started(rabbit_app)' 
erl> rabbit_app:test().

Korzystałem z poniższych linków:
http://dorkydevops.blogspot.com/2014/06/erlang-rabbitmq-amqp-rebar-example.html - uruchomienie poniższego linka za pomocą rebara, z dependencies?
https://www.rabbitmq.com/erlang-client-user-guide.html
https://howistart.org/posts/erlang/1  - rebar3 Homer Simpson asm - stąd wziąłem start aplikacji i kompilacje:

http://www.rabbitmq.com/tutorials/amqp-concepts.html

Wyjaśniony protokół amqp, queues, channels i exchanges:
http://www.rabbitmq.com/tutorials/amqp-concepts.html 

Tutorial erlanga:
https://www.rabbitmq.com/erlang-client-user-guide.html






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
Struktura ppool-1.0:
  ▾ ppool-1.0/
    ▸ ebin/
    ▸ src/
    ▸ test/
      Emakefile

Konieczny jest Emakefile, zawierający:
{"src/*", [debug_info, {i,"include/"}, {outdir, "ebin/"}]}.
{"test/*", [debug_info, {i,"include/"}, {outdir, "ebin/"}]}.

Mogę odpalić:
erl -make

cd ../erlcount-1.0
erl -make

cd ..
erl -env ERL_LIBS "."

hmm, nie podziałało, podziałało podanie ścieżek do katalogów z aplikacjami:
erl -env ERL_LIBS "/home/krzysztof/IdeaProjects/erlang/learnyou/ppool-1.0/:/home/krzysztof/IdeaProjects/erlang/learnyou/erlcount-1.0"

erl> application:load(ppool).
erl> application:start(ppool), application:start(erlcount).

## release with systool
kopiuję ppool-1.0 oraz erlcount-1.0 do release
dodaje odpowiednie wpisy do plików  (description)
dodaje erlcount-1.0.rel (z odpowiednimi wersjami erts, stdlib i kernel - erts widoczne po odpaleniu erl, stdlib i kernel po odpaleniu application:which_applications(). w konsoli erlanga)
następnie odpalam:
erl -env ERL_LIBS .
systools:make_script("erlcount-1.0", [local]).
systools:make_tar("erlcount-1.0", [{erts, "/usr/lib/erlang/"}]).

copiuję plik erlcount-1.0.tar do ~/apps/erlcount/
cd ~/apps/erlcount
./erts-7.2/bin/erl -boot releases/1.0.0/start

## release with reltool
Do katalogu release dodaje plik
erlcount-1.0.config

{sys, [
  {lib_dirs, ["/home/krzysztof/IdeaProjects/erlang/learnyou/release/"]},
  {rel, "erlcount", "1.0.0", [kernel, stdlib, {ppool, permanent}, {erlcount, transient}]},
  {boot_rel, "erlcount"}
]}.

{ok, Conf} = file:consult("erlcount-1.0.config").
{ok, Spec} = reltool:get_target_spec(Conf).
reltool:eval_target_spec(Spec, code:root_dir(), "rel").



## rebar3
rebar3 new app <app-name>



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


## rabbit

### rabbit instalacja
echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
sudo apt-get update

lub

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash

sudo apt-get install rabbitmq-server


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

## Processquest - code replace chapter
Kopia plików z tutoriala.
Struktura plików:
  ▾ processquest/
    ▾ apps/
      ▾ processquest-1.0.0/
        ▸ ebin/
        ▸ src/
          Emakefile
      ▾ regis-1.0.0/
        ▸ ebin/
        ▸ src/
          Emakefile
      ▾ sockserv-1.0.0/
        ▸ ebin/
        ▸ src/
          Emakefile
    ▸ rel/
      processquest-1.0.0.config

Dla każdej aplikacji (np. w katalogu processquest-1.0.0) odpalam erl -make
Następnie w konsoli erlanga, w katalogu processquest odpalam konsolkę:
erl
następnie polecenie:
{ok, Conf} = file:consult("processquest-1.0.0.config"), {ok, Spec} = reltool:get_target_spec(Conf), reltool:eval_target_spec(Spec, code:root_dir(), "rel").

następnie startuję aplikację (w nowej konsolce):
 ./rel/bin/erl -sockserv port 8888


### Upgrade
Struktura plików po upgrade:
  ▾ processquest/
    ▾ apps/
      ▸ processquest-1.0.0/
      ▸ processquest-1.1.0/
      ▸ regis-1.0.0/
      ▸ sockserv-1.0.0/
      ▸ sockserv-1.0.1/
    ▸ rel/
      processquest-1.0.0.config
      processquest-1.1.0.config

Zmiany w plikach src dla wyższej wersji, funkcja code_change

Dodanie plików appup, zmiana wersji w pliku app, dodanie nowych modułów w pliku app (jeżeli doszły)

      ▾ processquest-1.1.0/
        ▾ ebin/
            ...
            processquest.app
            processquest.appup

Szablon pliku appup:
{"1.1.0",
[{"1.0.0", [Instructions]}],
[{"1.0.0", [Instructions]}]}.

Dodanie pliku:
      processquest-1.1.0.config
Zawierającego nową wersję aplikacji, oraz nowe wersje podaplikacji

Dla każdej nowej aplikacji (np. w katalogu processquest-1.1.0) odpalam erl -make
Następnie w konsoli erlanga, w katalogu processquest odpalam konsolkę:
erl -env ERL_LIBS apps/
A w konsolce:
{ok, Conf} = file:consult("processquest-1.1.0.config"), {ok, Spec} = reltool:get_target_spec(Conf), reltool:eval_target_spec(Spec, code:root_dir(), "rel").

Następnie zmieniam nazwy wygenerowanych plików:

  ▾ processquest/
    ▸ apps/
    ▾ rel/
      ...
      ▾ releases/
        ▾ 1.0.0/
            processquest.boot -> processquest-1.0.0.boot i start.boot
            processquest.rel -> processquest-1.0.0.rel
            processquest.script
        ▾ 1.1.0/
            processquest.boot -> processquest-1.1.0.boot i start.boot
            processquest.rel -> processquest-1.1.0.rel
            processquest.script


Następnie odpalam konsolkę z katalogu processquest:
erl -env ERL_LIBS apps/ -pa apps/processquest-1.0.0/ebin/ -pa apps/sockserv-1.0.0/ebin/

Generuję relup file:
systools:make_relup("./rel/releases/1.1.0/processquest-1.1.0", ["rel/releases/1.0.0/processquest-1.0.0"], ["rel/releases/1.0.0/processquest-1.0.0"]).

Pojawia się:
  ▾ processquest/
      ...
      relup

Wygenerowanie tara dla wersji
systools:make_tar("rel/releases/1.1.0/processquest-1.1.0").

Pojawia się:

  ▾ processquest/
    ...
    ▾ rel/
      ...
      ▾ releases/
        ...
        ▾ 1.1.0/
            ...
            processquest-1.1.0.tar.gz

przenoszę plik do rel:
mv rel/releases/1.1.0/processquest-1.1.0.tar.gz rel/releases/ 

  ▾ processquest/
    ...
    ▾ rel/
      ...
      ▾ releases/
        ...
          processquest-1.1.0.tar.gz

Aby mieć możliwość cofnięcia upgradeu (jeszcze nie wiem, dlaczego):
odpalam konsolkę w katalogu processquest:
erl
opalam komendę:
release_handler:create_RELEASES("rel", "rel/releases", "rel/releases/1.0.0/processquest-1.0.0.rel", [{kernel,"2.14.4", "rel/lib"}, {stdlib,"1.17.4","rel/lib"}, {crypto,"2.0.3","rel/lib"},{regis,"1.0.0", "rel/lib"}, {processquest,"1.0.0","rel/lib"},{sockserv,"1.0.0", "rel/lib"}, {sasl,"2.1.9.4", "rel/lib"}]).

odpalenie:
rel/bin/erl - spowoduje uruchomienie najnowszej wersji aplikacji

odpalenie:
./rel/bin/erl -boot rel/releases/1.0.0/processquest. - spowoduje uruchomienie wersji 1.0.0
(nie wiem czemu muszę zmienić nazwę: processquest-1.0.0.boot na: processquest.boot)

Sam upgrade:
release_handler:unpack_release("processquest-1.1.0").
release_handler:which_releases().

wynikiem jest informacja, że wersja jest gotowa do aktualizacji, lecz jeszcze nie zainstalowana

Instalacja:
release_handler:install_release("1.1.0").

Pozostawienie wersji na stałe:
release_handler:make_permanent("1.1.0").


## UDP
(udp 1):
{ok, Socket} = gen_udp:open(8789, [binary, {active,true}]).
gen_udp:close(Socket).

wysyłam info z socketa z drugiego portu (udp 2):
{ok, Socket} = gen_udp:open(8790).
gen_udp:send(Socket, {127,0,0,1}, 8789, "hey there!").
flush().
Shell got {udp,#Port<0.34114>,{127,0,0,1},8790,<<"hey there!">>}

### Passive mode
(udp 1):
{ok, Socket} = gen_udp:open(8789, [binary, {active,false}]).
gen_udp:recv(Socket, 0).
lub z timeout:
gen_udp:recv(Socket, 0, 2000).

(udp 2):
gen_udp:send(Socket, {127,0,0,1}, 8789, "hey there!").

(udp 1):
{ok,{{127,0,0,1},8790,<<"hey there!">>}}

Czyli różnica pomiędzy active a passive:
Dla active, wystarczy wywołać flush()
Dla passive, należy czekać w gen_udp:recv

## TCP
(tcp 1):
{ok, ListenSocket} = gen_tcp:listen(8091, [{active,true}, binary]).
{ok, AcceptSocket} = gen_tcp:accept(ListenSocket).

shell is locked waiting

(tcp 2):
{ok, Socket} = gen_tcp:connect({127,0,0,1}, 8091, [binary, {active,true}]). 
gen_tcp:send(Socket, "Hey there first shell!").

(tcp 1):
flush().
Shell got {tcp,#Port<0.538>,<<"Hey there first shell!">>}

en_tcp:send(AcceptSocket, "Hey there second shell!").

(tcp 2):
flush().
Shell got {tcp,#Port<0.527>,<<"Hey there second shell!">>}
ok



gen_tcp:close(Socket).


















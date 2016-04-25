kitty_server2 and my_server:


1> c(kitty_server2).
{ok,kitty_server2}
2> rr(kitty_server2).
[cat]
3> Pid = kitty_server2:start_link().
<0.57.0>
4> Cat1 = kitty_server2:order_cat(Pid, carl, brown, "loves to burn bridges").
#cat{name = carl,color = brown,
description = "loves to burn bridges"}
5> kitty_server2:return_cat(Pid, Cat1).
ok
6> kitty_server2:order_cat(Pid, jimmy, orange, "cuddly").
#cat{name = carl,color = brown,
description = "loves to burn bridges"}
7> kitty_server2:order_cat(Pid, jimmy, orange, "cuddly").
#cat{name = jimmy,color = orange,description = "cuddly"}
8> kitty_server2:return_cat(Pid, Cat1).
ok
9> kitty_server2:close_shop(Pid).
carl was set free.
ok
10> kitty_server2:close_shop(Pid).
** exception error: no such process or port
in function  kitty_server2:close_shop/1




##### console
Pid = kitty_server2:start_link().

##### kitty_server2
start_link() ->
  my_server:start_link(?MODULE,[]). 

> ?MODULE - makro, odpowiadające nazwie modułu -> kitty_server2

##### my_server
start_link(Module, InitialState) ->
    spawn_link(fun() -> init(Module, InitialState) end).

> start_link(kitty_server2,[]) ->
>    spawn_link(fun() -> init(kitty_server2,[]) end).


##### my_server
init(Module, InitialState) ->
    loop(Module, Module:init(InitialState)).

init my_servera inicjuje pętlę, oraz jako State ustawia wynik funkcji init modułu

> init(kitty_server2, []) ->
>     loop(kitty_server2, kitty_server2:init([])).

Czyli tu jest odwołanie do funkcji init modułu kitty_server2 oraz do loopa my_server

##### kitty_server2 
init([]) -> []. 

Czyli initial state jest pustą listą.

##### my_server
loop(Module, State) ->
   receive
      {async, Msg} ->
           loop(Module, Module:handle_cast(Msg, State));
      {sync, Pid, Ref, Msg} ->
           loop(Module, Module:handle_call(Msg, {Pid, Ref}, State))
  end.

> Module = kitty_server2
> State = []




##### console
  Cat1 = kitty_server2:order_cat(Pid, carl, brown, "loves to burn bridges").

##### kitty_server2
order_cat(Pid, Name, Color, Description) ->
    my_server:call(Pid, {order, Name, Color, Description}).

##### my_server
call(Pid, Msg) ->
    Ref = erlang:monitor(process, Pid),
    Pid ! {sync, self(), Ref, Msg},
    receive
        {Ref, Reply} ->
            erlang:demonitor(Ref, [flush]),
            Reply;
        {'DOWN', Ref, process, Pid, Reason} ->
            erlang:error(Reason)
    after 5000 ->
        erlang:error(timeout)
    end.

> Pid = Pid kitty_server2
> Msq = {order, carl, browl, "loves to burn bridges"}
leci teraz sygnał do pętli (loopa) 
>    Pid ! {sync, self(), Ref, Msg}, 

      {sync, Pid, Ref, Msg} ->
           loop(Module, Module:handle_call(Msg, {Pid, Ref}, State))

z pętli jest wywołana funkcja

Module:handle_call(Msg, {Pid, Ref}, State)

##### kitty_server2
handle_call({order, Name, Color, Description},From,Cats) ->

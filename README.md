odpalenie tut17:
1. Na lokalniej maszynie: erl -sname pong (tworzy noda pong)
2. W uruchomionej konsolce noda odpalam tut17:start_pong().
3. Na zadlnej maszynie: erl -sname ping (tworzy noda ping)
4. W uruchomionej konsolce noad odpala tut17:start_ping(pong@parowy). 

gen_server returns:
init:
{ok, State}
{ok, State, TimeOut}
{ok, State, hibernate}
{stop, Reason} or ignore

handle_call:
{reply,Reply,NewState}
{reply,Reply,NewState,Timeout}
{reply,Reply,NewState,hibernate}
{noreply,NewState}
{noreply,NewState,Timeout}
{noreply,NewState,hibernate}
{stop,Reason,Reply,NewState}
{stop,Reason,NewState}

handle_cast:
{noreply,NewState}
{noreply,NewState,Timeout}
{noreply,NewState,hibernate}
{stop,Reason,NewState}


gen_fsm return values:
init:
{ok, StateName, Data}
{ok, StateName, Data, Timeout}
{ok, StateName, Data, hibernate}
{stop, Reason} 


state:
{reply, Reply, NextStateName, NewStateData}
{reply, Reply, NextStateName, NewStateData, Timeout}
{reply, Reply, NextStateName, NewStateData, hibernate}

{next_state, NextStateName, NewStateData}
{next_state, NextStateName, NewStateData, Timeout}
{next_state, NextStateName, NewStateData, hibernate}

{stop, Reason, Reply, NewStateData}
{stop, Reason, NewStateData}





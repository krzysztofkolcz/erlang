%% %%%-------------------------------------------------------------------
%% %% @doc rabbit public API
%% %% @end
%% %%%-------------------------------------------------------------------
%%
%% -module(rabbit_app).
%%
%% -behaviour(application).
%%
%% %% Application callbacks
%% -export([start/2, stop/1]).
%%
%% %%====================================================================
%% %% API
%% %%====================================================================
%%
%% start(_StartType, _StartArgs) ->
%%     rabbit_sup:start_link().
%%
%% %%--------------------------------------------------------------------
%% stop(_State) ->
%%     ok.
%%
%% %%====================================================================
%% %% Internal functions
%% %%====================================================================

-module(rabbit_app).

      -include("../amqp_client/include/amqp_client.hrl").

      -compile([export_all]).

      test() ->
          %% Start a network connection
          {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
          %% Open a channel on the connection
          {ok, Channel} = amqp_connection:open_channel(Connection),

          %% Declare a queue - random name
          %% #'queue.declare_ok'{queue = Q} = amqp_channel:call(Channel, #'queue.declare'{}),

          Q = <<"my_queue">>,
          Declare = #'queue.declare'{queue = Q},
          #'queue.declare_ok'{} = amqp_channel:call(Channel, Declare),

          %% Publish a message
          Payload = <<"foobar">>,
          Publish = #'basic.publish'{exchange = <<>>, routing_key = Q},
          amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),

          %% Get the message back from the queue
          Get = #'basic.get'{queue = Q},
          {#'basic.get_ok'{delivery_tag = Tag}, Content}
               = amqp_channel:call(Channel, Get),

          %% Do something with the message payload
          %% (some work here)
          io:format("~p",[Content]),

          %% Ack the message
          amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),

          %% Close the channel
          amqp_channel:close(Channel),
          %% Close the connection
          amqp_connection:close(Connection),

          ok.

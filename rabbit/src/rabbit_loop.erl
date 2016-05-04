-module(rabbit_loop).
-include("../amqp_client/include/amqp_client.hrl").
-compile([export_all]).

  loop(Channel) ->
      receive
          %% This is the first message received
          #'basic.consume_ok'{} ->
              loop(Channel);

          %% This is received when the subscription is cancelled
          #'basic.cancel_ok'{} ->
              ok;

          %% A delivery
          {#'basic.deliver'{delivery_tag = Tag}, Content} ->
              %% Do something with the message payload
              %% (some work here)

              %% Ack the message
              amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),

              %% Loop
              loop(Channel)
      end.

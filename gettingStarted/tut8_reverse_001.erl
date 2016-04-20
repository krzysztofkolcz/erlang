-module(tut8_reverse_001).
-export([reverse/1]).

reverse([Head|Rest])->
  reverse(Rest,[Head]). 

reverse ([Head|Rest],List)->
  reverse(Rest,[Head|List]);

reverse ([],List)->
  List.

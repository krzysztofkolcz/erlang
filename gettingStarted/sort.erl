-module(sort).
-export([sort/1,find_max/1,remove_from_list/2]).

% uwaga, elementy powtarzające się wystąpią w wyniku tylko raz, nie poprawiam tego.
sort(List) ->
    sort(List,[]).


sort([],Sorted_list) ->
    Sorted_list;
sort(List,Sorted_list) ->
    Max = find_max(List),
    Removed_list = remove_from_list(List,Max),
    sort(Removed_list,[Max|Sorted_list]).

find_max([Head|Rest]) ->
    find_max(Rest,Head);
find_max([]) ->
    ok.

find_max([Head|Rest],Current_max) when Head > Current_max ->
    find_max(Rest,Head);
find_max([Head|Rest],Current_max) ->
    find_max(Rest,Current_max);
find_max([],Current_max)->
    Current_max.
    

remove_from_list(List,Element) ->
    remove_from_list(List,[],Element).
remove_from_list([Head|Rest],Result,Element) when Head == Element ->
    remove_from_list(Rest,Result,Element);
remove_from_list([Head|Rest],Result,Element) ->
    remove_from_list(Rest,[Head|Result],Element);
remove_from_list([],Result,Element) ->
    Result.

    

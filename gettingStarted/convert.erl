%% tut7:format temps([{moscow, {c, -10}}, {cape town, {f, 70}}, {stockholm, {c, -4}}, {paris, {f, 28}}, {london, {f, 36}}]).

-module(convert).
-export([format_temps/1]).

format_temps(List_of_cities)->
    convert_list_to_c(List_of_cities).

convert_list_to_c([{City_name,{f,Temp}}|Rest])->
    Converted_city = {City_name,{c,(Temp-32)*5/9}},
    [Converted_city|convert_list_to_c(Rest)];
convert_list_to_c([City|Rest])->
    [City|convert_list_to_c(Rest)];
convert_list_to_c([])->
    [].

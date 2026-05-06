-module(test).

-export([prop_merge/0, prop_sum/0, prop_filter/0, prop_hof_lengh/0]).
-include_lib("eqc/include/eqc.hrl").

prop_merge() ->
  ?FORALL(
   {L1 ,L2}, {eqc_gen:list(eqc_gen:int()),eqc_gen:list(eqc_gen:int())},
    length(seq:merge(L1, L2)) == length(L1) + length(L2)
  ).

prop_sum() ->
  ?FORALL(
     {List}, {eqc_gen:list(eqc_gen:int())},
     seq:sum(List) == high_order:foldr(fun (X, Y) -> X + Y end, 0, List)
    ).

prop_filter() ->
  ?FORALL({List, E}, {eqc_gen:list(eqc_gen:int()), eqc_gen:int()},
         length(List) >= length(high_order:filter(fun (X) -> X /= E end, List))
    ),
  ?FORALL({List, E}, {eqc_gen:list(eqc_gen:bool()), eqc_gen:bool()},
         length(List) >= length(high_order:filter(fun (X) -> X /= E end, List))
    ).

prop_hof_lengh() ->
  ?FORALL({List}, {eqc_gen:list(eqc_gen:int())},
         length(List) == length(high_order:map(fun (X) -> X * X end, List))
    ),
  ?FORALL({List}, {eqc_gen:list(eqc_gen:bool())},
         length(List) == length(high_order:map(fun (X) -> not X end, List))
    ).

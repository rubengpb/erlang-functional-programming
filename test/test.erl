-module(test).

-export([prop_merge/0, prop_sum/0, prop_filter/0, prop_hof_lengh/0, main/0]).
-include_lib("eqc/include/eqc.hrl").

prop_merge() -> % check the lenght
  ?FORALL(
   {L1 ,L2}, {eqc_gen:list(eqc_gen:int()),eqc_gen:list(eqc_gen:int())},
    length(seq:merge(L1, L2)) == length(L1) + length(L2)
  ).

prop_merge2() -> % check contains the same elements
  ?FORALL(
   {L1 ,L2}, {eqc_gen:list(eqc_gen:int()),eqc_gen:list(eqc_gen:int())},
   lists:all(
     fun (X) ->
       Result = seq:merge(L1,L2),
       lists:member(X, Result)
     end,
     L1
   ) andalso
   lists:all(
     fun (X) ->
       Result = seq:merge(L1,L2),
       lists:member(X, Result)
     end,
     L2
   )
  ).

prop_sum() -> % list of zeros
  ?FORALL(
     {List}, {eqc_gen:list(eqc_gen:int())},
     seq:sum(List) == high_order:foldr(fun (X, Y) -> X + Y end, 0, List)
    ).

prop_sum2() -> % compare sum with foldr
  ?FORALL(
     {List}, {eqc_gen:list(0)},
     seq:sum(List) == 0
    ).

prop_filter() -> % check lenght
  ?FORALL({List, E}, {eqc_gen:list(eqc_gen:int()), eqc_gen:int()},
         length(List) >= length(high_order:filter(fun (X) -> X /= E end, List))
    ),
  ?FORALL({List, E}, {eqc_gen:list(eqc_gen:bool()), eqc_gen:bool()},
         length(List) >= length(high_order:filter(fun (X) -> X /= E end, List))
    ).

prop_filter2() -> % check same list
  ?FORALL({List}, {eqc_gen:list(eqc_gen:int())},
         List == high_order:filter(fun (_) -> true end, List)
    ).

prop_hof_lengh() -> % check the lenght
  ?FORALL({List}, {eqc_gen:list(eqc_gen:int())},
         length(List) == length(high_order:map(fun (X) -> X * X end, List))
    ),
  ?FORALL({List}, {eqc_gen:list(eqc_gen:bool())},
         length(List) == length(high_order:map(fun (X) -> not X end, List))
    ).

prop_hof_id() -> % map with id function
  ?FORALL({List}, {eqc_gen:list(eqc_gen:int())},
         List == high_order:map(fun (X) -> X end, List)
    ).

main() ->
  eqc:quickcheck(prop_merge()),
  eqc:quickcheck(prop_merge2()),
  eqc:quickcheck(prop_sum()),
  eqc:quickcheck(prop_sum2()),
  eqc:quickcheck(prop_filter()),
  eqc:quickcheck(prop_filter2()),
  eqc:quickcheck(prop_hof_lengh()),
  eqc:quickcheck(prop_hof_id()).

-module(high_order).
-export([all/2, foldr/3, foldl/3, filter/2, map/2, increment1/1, increment2/1, increment3/1, doble_list/1, abs_list/1, tree/2, fold/3, sum/1, find/2]).

% all(F,L)
all(_,[]) -> true;
all(F,[X|Xs]) ->
  case F(X) of
    true -> all(F, Xs);
    false -> false
  end.
% all(F,L) -> lists:foldl(fun (X,Y) -> X and Y end, true, lists:map(F, L)).

% foldr(F,Acc,L)
foldr(_,Acc,[]) -> Acc;
foldr(F,Acc,[X|Xs]) -> F(X, foldr(F, Acc, Xs)).

% foldl(F,Acc,L)
foldl(_,Acc,[]) -> Acc;
foldl(F,Acc,[X|Xs]) -> foldl(F, F(Acc,X), Xs).

% filter(F,L)
filter(_,[]) -> [];
filter(F,[X|Xs]) ->
  case F(X) of
    true -> [X|filter(F,Xs)];
    false -> filter(F,Xs)
  end.

% map(F,L)
map(_,[]) -> [];
map(F,[X|Xs]) -> [F(X)|map(F,Xs)].

% some examples
increment1(L) -> map(fun (X) -> X + 1 end, L).
increment2(L) -> foldr(fun (X, Acc) -> [X+1|Acc] end, [], L).
increment3(L) -> foldl(fun (Acc, X) -> Acc ++ [X+1] end, [], L).
doble_list(L) -> map(fun (X) -> 2 * X end, L).
abs_list(L) -> map(fun abs/1, L).

% tree(F, T)
tree(_, void) -> void;
tree(F,{node,N,L,R}) -> {node, F(N), tree(F, L), tree(F, R)}.

% fold(F, Acc, T)
% The idea is convert the void in acc and F compute the node with right and left
fold(_, Acc, void) -> Acc;
fold(F, Acc, {node, N, L, R}) -> F(N, fold(F, Acc, L), fold(F, Acc, R)).

sum(T) -> fold(fun (X,Y,Z) -> X + Y + Z end, 0, T).

% find(Pred,L)
find(_, void) -> false;
find(P, {node, N, L, R}) ->
  case P(N) of
    true -> {ok, N};
    _ ->
      case {find(P, L), find(P, R)} of
        {{ok,V},_} -> {ok, V};
        {_,{ok,V}} -> {ok, V};
        _ -> false
      end
  end.

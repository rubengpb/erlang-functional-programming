-module(seq).
-export([fib/1, sum/1, member/2, insert/2, sort/1, fib_with_index/1, keyfind/2, merge/2]).

% Exercise 0
% tfib(1) -> 1;
% tfib(2) -> 1;
% tfib(N) -> tfib(N-1) + tfib(N-2).

fib_aux(1) -> {1,0};
fib_aux(2) -> {1,1};
fib_aux(N) -> {A,B} = fib_aux(N-1), {A+B,A}.

fib(N) -> element(1, fib_aux(N)).

% Exercise 1
sum([]) -> 0;
sum([X|Xs]) ->
  if
    is_integer(X) -> X + sum(Xs);
    true -> sum(Xs)
  end.

% Exercise 2
member(_,[]) -> false;
member(E,[E|_]) -> true;
member(E,[_|Xs]) -> member(E,Xs).

% Exercise 2.5
insert(I,[]) -> [I];
insert(I, [X|Xs]) when X >= I -> [I,X|Xs];
insert(I, [X|Xs]) -> [X|insert(I,Xs)].

% Exercise 3
sort(L) -> insert_sort(L, []).
% sort([]) -> [];
% sort([X|Xs]) -> insert(X, sort(Xs)).

insert_sort([], L) -> L;
insert_sort([X|Xs], L) -> insert_sort(Xs, insert(X,L)).

% Exercise 4
fib_with_index(N) -> {N, fib(N)}.

% Exercise 5
keyfind(_,[]) -> false;
keyfind(Key,[{Key,Value}|_]) -> {Key,Value};
keyfind(Key,[{_,_}|Xs]) -> keyfind(Key,Xs).

% Exercise 6
merge([],[]) -> [];
merge(L,[]) -> L;
merge([],L) -> L;
merge([X|Xs],[Y|Ys]) when X > Y -> [Y| merge([X|Xs],Ys)];
merge([X|Xs],[Y|Ys]) -> [X| merge(Xs,[Y|Ys])].

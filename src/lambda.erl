-module(lambda).
-export([print_eval/1]).

print_eval(T) -> term_to_string(eval_no(T)).

term_to_string({var, X}) -> X;
term_to_string({abs, X, B}) -> "\\" ++ X ++ "." ++ term_to_string(B);
term_to_string({app, {var, X}, {var, Y}}) -> X ++ " " ++ Y;
term_to_string({app, {var, X}, M}) -> X ++ " (" ++ term_to_string(M) ++ ")";
term_to_string({app, {app, M, N}, {var, X}}) -> term_to_string({app, M, N}) ++ X;
term_to_string({app, {app, M, N}, T}) ->
  term_to_string({app, M, N}) ++ " (" ++ term_to_string(T) ++ ")";
term_to_string({app, T, {var, X}}) ->
  "(" ++ term_to_string(T) ++ ") " ++ X;
term_to_string({app, M, N}) -> "(" ++ term_to_string(M) ++ ") (" ++ term_to_string(N) ++ ")".

eval_bn({app, M, N}) ->
  M_ = eval_bn(M),
  case M_ of
    {abs, X, B} -> eval_bn(subst(N, X, B));
    _ -> {app, M_, N}
  end;
eval_bn(T) -> T.

eval_no({var, X}) -> {var, X};
eval_no({abs, X, B}) -> {abs, X, eval_no(B)};
eval_no({app, M, N}) ->
  M_ = eval_bn(M),
  case M_ of
    {abs, X, B} -> eval_no(subst(N, X, B));
    _ -> {app, eval_no(M_), eval_no(N)}
  end.

% subst(N, X, B)
subst(N, X, {var, X}) -> N;
subst(_, _, {var, X}) -> {var, X};
subst(N, X, {app, T1, T2}) -> {app, subst(N, X, T1), subst(N, X, T2)};
subst(_, X, {abs, X, B}) -> {abs, X, B};
subst(N, Y, {abs, X, B}) -> Free_body = free_vars(B), Free_n = free_vars(N),
  case {sets:is_element(X, Free_n), sets:is_element(Y, Free_body)} of
    {_, false} -> {abs, X, B};
    {false, _} -> {abs, X, subst(N, Y, B)};
    _ -> Z = fresh_var(X, sets:union(Free_body, Free_n)),
         B_ = subst({var, Z}, X, B),
         {abs, Z, (subst(N, Y, B_))}
  end.

free_vars({var, X}) -> sets:from_list([X], [{version, 2}]);
free_vars({abs, X, B}) -> Free_b = free_vars(B),
  sets:del_element(X, Free_b);
free_vars({app, E1, E2}) ->
  sets:union(free_vars(E1), free_vars(E2)).

fresh_var(X,S) -> Y = X ++ "s",
  case sets:is_element(Y, S) of
    true -> fresh_var(Y, S);
    false -> Y
  end.

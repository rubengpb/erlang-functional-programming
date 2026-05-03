-module(bank).
-export([create_bank/0, new_account/2, withdraw_money/3, deposit_money/3, transfer/4, balance/2]).

bank(State) ->
  receive
    {new_account, AccountNumber, Pid} ->
      case maps:is_key(AccountNumber, State) of
        true ->
          Pid ! false,
          bank(State);
        false ->
          NewState = maps:put(AccountNumber, 0, State),
          Pid ! true,
          bank(NewState)
      end;

    {withdraw_money, AccountNumber, Quantity, Pid} ->
      case maps:is_key(AccountNumber, State) of
        false ->
          Pid ! 0,
          bank(State);
        true ->
          Balance = maps:get(AccountNumber, State),
          if
            Balance >= Quantity ->
              NewBalance = Balance - Quantity,
              NewState = maps:put(AccountNumber, NewBalance, State),
              Pid ! NewBalance,
              bank(NewState);
            true ->
              Pid ! 0,
              bank(State)
          end
      end;

    {deposit_money, AccountNumber, Quantity, Pid} ->
      case maps:is_key(AccountNumber, State) of
        false ->
          Pid ! 0,
          bank(State);
        true ->
          Balance = maps:get(AccountNumber, State),
          NewBalance = Balance + Quantity,
          NewState = maps:put(AccountNumber, NewBalance, State),
          Pid ! NewBalance,
          bank(NewState)
      end;

    {transfer, FromAccount, ToAccount, Quantity, Pid} ->
      case (maps:is_key(FromAccount, State) andalso maps:is_key(ToAccount, State)) of
        false ->
          Pid ! 0,
          bank(State);
        true ->
          FromBalance = maps:get(FromAccount, State),
          ToBalance = maps:get(ToAccount, State),
          if
            FromBalance >= Quantity ->
              NewFromBalance = FromBalance - Quantity,
              NewToBalance = ToBalance + Quantity,
              NewState = maps:put(FromAccount, NewFromBalance, State),
              NewNewState = maps:put(ToAccount, NewToBalance, NewState),
              Pid ! Quantity,
              bank(NewNewState);
            true ->
              Pid ! 0,
              bank(State)
          end
      end;

    {balance, AccountNumber, Pid} ->
      case maps:is_key(AccountNumber, State) of
        false ->
          Pid ! 0,
          bank(State);
        true ->
          Balance = maps:get(AccountNumber, State),
          Pid ! Balance,
          bank(State)
      end
  end.

create_bank() ->
  spawn(fun () -> bank(#{}) end).

new_account(Bank, AccountNumber) ->
  Bank ! {new_account, AccountNumber, self()},
  receive Msg -> Msg end.

withdraw_money(Bank, AccountNumber, Quantity) ->
  Bank ! {withdraw_money, AccountNumber, Quantity, self()},
  receive Msg -> Msg end.

deposit_money(Bank, AccountNumber, Quantity) ->
  Bank ! {deposit_money, AccountNumber, Quantity, self()},
  receive Msg -> Msg end.

transfer(Bank, FromAccount, ToAccount, Quantity) ->
  Bank ! {transfer, FromAccount, ToAccount, Quantity, self()},
  receive Msg -> Msg end.

balance(Bank, AccountNumber) ->
  Bank ! {balance, AccountNumber, self()},
  receive Msg -> Msg end.

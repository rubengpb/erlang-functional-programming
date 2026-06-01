-module(test_bank).

-export([ prop_bank/0, initial_state/0, create_bank/0, create_bank_pre/1, create_bank_args/1, create_bank_next/3, new_account/2, new_account_pre/1, new_account_args/1, new_account_next/3, new_account_post/3, deposit_money/3, deposit_money_pre/1, deposit_money_args/1, deposit_money_next/3, deposit_money_post/3, withdraw_money/3, withdraw_money_pre/1, withdraw_money_args/1, withdraw_money_next/3, withdraw_money_post/3, balance/2, balance_pre/1, balance_args/1, balance_post/3 ]).

-include_lib("eqc/include/eqc.hrl").
-include_lib("eqc/include/eqc_statem.hrl").

initial_state() ->
    #{
        bank => none,
        accounts => #{}
    }.

create_bank() ->
    bank:create_bank().

create_bank_pre(State) ->
    maps:get(bank, State) == none.

create_bank_args(_State) ->
    [].

create_bank_next(State, Var, []) ->
    maps:put(bank, Var, State).

new_account(Bank, Account) ->
    bank:new_account(Bank, Account).

new_account_pre(State) ->
    maps:get(bank, State) =/= none.

new_account_args(State) ->
    [maps:get(bank, State), nat()].

new_account_next(State, _Res, [_, Account]) ->
    Accounts = maps:get(accounts, State),
    case maps:is_key(Account, Accounts) of
        true ->
            State;
        false ->
            State#{
                accounts := maps:put(Account, 0, Accounts)
            }
    end.

new_account_post(State, [_, Account], Result) ->
    Accounts = maps:get(accounts, State),
    Expected =
        case maps:is_key(Account, Accounts) of
            true -> false;
            false -> true
        end,
    Result == Expected.

deposit_money(Bank, Account, Qty) ->
    bank:deposit_money(Bank, Account, Qty).

deposit_money_pre(State) ->
    maps:get(bank, State) =/= none.

deposit_money_args(State) ->
    [maps:get(bank, State), nat(), choose(1,1000)].

deposit_money_next(State, Result, [_, Account, _Qty]) ->
    Accounts = maps:get(accounts, State),

    case maps:is_key(Account, Accounts) of
        false ->
            State;
        true ->
            State#{
                accounts := maps:put(Account, Result, Accounts)
            }
    end.

deposit_money_post(State, [_, Account, Qty], Result) ->
    Accounts = maps:get(accounts, State),

    case maps:is_key(Account, Accounts) of
        false ->
            Result == 0;
        true ->
            Result == maps:get(Account, Accounts) + Qty
    end.

withdraw_money(Bank, Account, Qty) ->
    bank:withdraw_money(Bank, Account, Qty).

withdraw_money_pre(State) ->
    maps:get(bank, State) =/= none.

withdraw_money_args(State) ->
    [maps:get(bank, State), nat(), choose(1,1000)].

withdraw_money_next(State, Result, [_, Account, _Qty]) ->
    Accounts = maps:get(accounts, State),

    case maps:is_key(Account, Accounts) of
        false ->
            State;
        true ->
            case Result of
                0 ->
                    State;
                _ ->
                    State#{
                        accounts := maps:put(Account, Result, Accounts)
                    }
            end
    end.

withdraw_money_post(State, [_, Account, Qty], Result) ->
    Accounts = maps:get(accounts, State),

    case maps:is_key(Account, Accounts) of
        false ->
            Result == 0;
        true ->
            Balance = maps:get(Account, Accounts),
            if
                Balance >= Qty ->
                    Result == Balance - Qty;
                true ->
                    Result == 0
            end
    end.

balance(Bank, Account) ->
    bank:balance(Bank, Account).

balance_pre(State) ->
    maps:get(bank, State) =/= none.

balance_args(State) ->
    [maps:get(bank, State), nat()].

balance_post(State, [_, Account], Result) ->
    Accounts = maps:get(accounts, State),

    case maps:is_key(Account, Accounts) of
        false ->
            Result == 0;
        true ->
            Result == maps:get(Account, Accounts)
    end.

prop_bank() ->
    ?FORALL(
        Cmds,
        commands(?MODULE),
        begin
            {_History, _State, Result} =
                run_commands(?MODULE, Cmds),
            Result == ok
        end).

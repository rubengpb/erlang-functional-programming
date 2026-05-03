-module(basic_concurrent).
-export([ping/0, fibserver/1, largest/0, n_connected_cells/2]).

% Exercise 1
ping() ->
  receive
    {req,Msg,Pid} when is_pid(Pid) ->
      Pid ! {ack,Msg};
    Other -> io:format("Error: Not expected msg: ~p~n", [Other])
  end,
  ping().

% Exercise 2
fib(0) -> 0;
fib(1) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

fibserver(PidsTable) ->
  receive
    {fib, N, ClientPid} ->
      ServerPid = self(),
      WorkerPid = spawn(fun () -> fibworker(N, ServerPid) end),
      NewTable = maps:put(WorkerPid, ClientPid, PidsTable),
      fibserver(NewTable);

    {worker_finished, N, Result, WorkerPid} ->
      ClientPid = maps:get(WorkerPid, PidsTable),
      ClientPid ! {fib, N, is, Result},
      fibserver(PidsTable)

  end.

fibworker(N, Pid) ->
  Result = fib(N), Pid ! {worker_finished, N, Result, self()}.

% Exercise 3
largest() ->
  largest(nan, 0, 0).

largest(LN, P, Q) ->
  receive
    {put, N} when is_integer(N) ->
      if
        LN == nan -> largest(N, P + 1, Q);
        N > LN -> largest(N, P + 1, Q);
        true -> largest(LN, P + 1, Q)
      end;

    {query, Pid} ->
      Pid ! {largest, LN},
      largest(LN, P, Q + 1);

    {statistics, Pid} ->
      Pid ! {P, Q},
      largest(LN, P, Q)
  end.

% Exercise 4
n_connected_cells(N, Pid) when is_integer(N), N > 0, is_pid(Pid) ->
  spawn(fun () -> build_cells(N, Pid) end).

build_cells(1, Pid) ->
  cell(Pid);
build_cells(N, Pid) ->
  NextCell = spawn(fun () -> build_cells(N - 1, Pid) end),
  cell(NextCell).

cell(Pid) ->
  receive
    Msg -> Pid ! Msg
  end,
  cell(Pid).

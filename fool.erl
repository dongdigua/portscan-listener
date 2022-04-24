#!/usr/bin/env escript
-module(fool).
-mode(compile).

main(Args) ->
	{Int, _} = string:to_integer(Args),
	io:fwrite("starting...~n"),
	start(Int).

start(Port) ->
	{ok, Socket} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
	loop_acceptor(Socket).

loop_acceptor(Socket) ->
	{ok, Client} = gen_tcp:accept(Socket),
	io:fwrite("~w", [Client]),
	Recv = gen_tcp:recv(Client, 0),
	io:fwrite("~w~w~n", [Recv, calendar:local_time()]),
	case Recv of
		{ok, <<"HELP\r\n">>} ->
			gen_tcp:send(Client, "FLAG:{YouMuffinHead}+10points"),
			gen_tcp:close(Client);
		_ -> gen_tcp:close(Client)
	end,
	loop_acceptor(Socket).


-module(anarcho_login_server).

-record(state, {socket}).

-export([start_link/1, loop/1, process_input/1]).

-define(RECV_TIMEOUT, 3000).

start_link(Port) ->
    Pid = spawn_link(fun() -> initialize(Port) end),
    {ok, Pid}.

initialize(Port) ->
    {ok, Socket} = gen_tcp:listen(Port, [binary, {active, false}]),
    loop(#state{socket=Socket}).

loop(State) ->
    {ok, Socket} = gen_tcp:accept(State#state.socket),
    spawn(fun() -> anarcho_login_server:process_input(Socket) end),
    anarcho_login_server:loop(State).

process_input(Socket) ->
    io:format("got a conection~n"),
    {ok, Packet} = gen_tcp:recv(Socket, 0, ?RECV_TIMEOUT),
    io:format("read packet ~w~n", [Packet]),
    [User, Pass] = binary:split(Packet, [<<0>>]),
    case anarcho_login_user:login_user(User, Pass) of
        {ok, Token} ->
            io:format("logging in ~p~n", [User]),
            io:format("sending token ~p~n", [Token]),
            gen_tcp:send(Socket, <<0, Token/binary>>);
        {error, no_user} ->
            io:format("no such user ~p~n", [User]),
            gen_tcp:send(Socket, <<1>>);
        {error, invalid_password} ->
            io:format("failed to log in ~p~n", [User]),
            gen_tcp:send(Socket, <<2>>)
    end,
    gen_tcp:close(Socket),
    ok.

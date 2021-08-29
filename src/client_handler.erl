-module(client_handler).

-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2]).

-behaviour(cowboy_websocket).

init(Req, Args) ->
	{cowboy_websocket, Req, Args, #{
		idle_timeout => infinity}}.

websocket_init(State) ->
	device_event_server:subscribe(self()),
	{ok, State}.

websocket_handle(Frame, State) ->
	{binary, Bin} = Frame,
	CommandString = binary_to_list(Bin),
	[Idx, Cmd, Param] = string:split(CommandString, "|", all),
	domoticz_command_server:send_command(Idx, Cmd, Param),
	{ok, State}.

websocket_info({device_event, Name, Value}, State) ->
	{[{text, [Name, "|", Value]}], State}.

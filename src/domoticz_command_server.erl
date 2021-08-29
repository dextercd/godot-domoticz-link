-module(domoticz_command_server).

-behaviour(gen_server).

-export([start_link/0, send_command/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
	gen_server:start_link({local, domoticz_command_server}, domoticz_command_server, [], []).

send_command(Idx, SwitchCmd, Param) ->
	gen_server:call(domoticz_command_server, {sendcmd, Idx, SwitchCmd, Param}).

init(_Args) ->
	{ok, ConnPid} = gun:open("localhost", 8080),
	{ok, Protocol} = gun:await_up(ConnPid),
	{ok, ConnPid}.

handle_call({sendcmd, Idx, SwitchCmd, Param}, From, ConnPid) ->
	Path = "/json.htm",
	QueryString = uri_string:compose_query([
		{"type", "command"},
		{"param", Param},
		{"idx", Idx},
		{"switchcmd", SwitchCmd}]),
	gun:get(ConnPid, Path ++ [$? | QueryString]),
	{reply, ok, ConnPid}.
handle_cast(Request, State) ->
	{noreply, State}.

handle_info({gun_up, _, _}, State) ->
	{noreply, State};
handle_info({gun_down, _, _, _, _}, State) ->
	{noreply, State};
handle_info({gun_response, _, _, _, _, _}, State) ->
	{noreply, State};
handle_info({gun_data, _, _, _, _}, State) ->
	{noreply, State}.

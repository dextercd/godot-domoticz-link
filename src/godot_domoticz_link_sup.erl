-module(godot_domoticz_link_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
	SupFlags = #{strategy => one_for_all,
				 intensity => 0,
				 period => 1},
	ChildSpecs = [
		#{id => device_event_server,
		  start => {device_event_server, start_link, []}},
		#{id => domcom_server,
		  start => {domoticz_command_server, start_link, []}}],
	{ok, {SupFlags, ChildSpecs}}.

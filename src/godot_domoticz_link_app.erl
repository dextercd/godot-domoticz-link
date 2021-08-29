-module(godot_domoticz_link_app).

-behaviour(application).

-export([start/2, stop/1]).

get_cfg_value(Key) ->
	{ok, Value} = application:get_env(godot_domoticz_link, Key),
	Value.

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/device/:name", device_handler, []},
			{"/client", client_handler, []}]}
	]),
	{ok, _} = cowboy:start_clear(my_http_listener,
		[{port, get_cfg_value(port)}],
		#{env => #{dispatch => Dispatch}}),
	godot_domoticz_link_sup:start_link().

stop(_State) ->
	ok.

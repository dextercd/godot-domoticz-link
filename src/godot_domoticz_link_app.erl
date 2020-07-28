%%%-------------------------------------------------------------------
%% @doc godot_domoticz_link public API
%% @end
%%%-------------------------------------------------------------------

-module(godot_domoticz_link_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    godot_domoticz_link_sup:start_link().

stop(_State) ->
    ok.

%% internal functions

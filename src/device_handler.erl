-module(device_handler).

-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, malformed_request/2, content_types_accepted/2]).
-export([accept_any/2, to_html/2]).

-record(state, {
	deviceName = undefined,
	newValue = undefined
}).

init(Req, _Args) ->
	{cowboy_rest, Req, #state{}}.

allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
	{[{'*', accept_any}], Req, State}.

get_name(Req) ->
	case cowboy_req:binding(name, Req) of
		undefined -> missing;
		Value -> Value
	end.

get_value(Req) ->
	#{value := Value} = cowboy_req:match_qs([{value, [], missing}], Req),
	Value.

malformed_request(Req, State) ->
	case {get_name(Req), get_value(Req)} of
		{_, missing} -> {true, Req, State};
		{missing, _} -> {true, Req, State};
		{Name, Value} ->
			NextState = State#state{deviceName=Name, newValue=Value},
			{false, Req, NextState}
	end.

accept_any(Req, #state{deviceName=Name, newValue=Value} = State) ->
	device_event_server:broadcast(Name, Value),
	{true, Req, State}.

to_html(Req, State) ->
	{ok, Req, State}.

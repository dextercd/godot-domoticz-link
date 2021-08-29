-module(device_event_server).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([start_link/0, subscribe/1, unsubscribe/1, broadcast/2]).

subscribe(Pid) ->
	gen_server:call(device_event_server, {subscribe, Pid}).

unsubscribe(Pid) ->
	gen_server:call(device_event_server, {unsubscribe, Pid}).

broadcast(Device, Value) ->
	gen_server:call(device_event_server, {broadcast, Device, Value}).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
	{ok, ordsets:new()}.

handle_call({subscribe, Pid}, _From, State) ->
	monitor(process, Pid),
	{reply, ok, ordsets:add_element(Pid, State)};
handle_call({unsubscribe, Pid}, _From, State) ->
	{reply, ok, ordsets:del_element(Pid, State)};
handle_call({broadcast, Device, Value}, _From, State) ->
	[Pid ! {device_event, Device, Value} || Pid <- State],
	{reply, ok, State}.

handle_cast(_, State) ->
	{noreply, State}.

handle_info({'DOWN', _MRef, process, Pid, _Reason}, State) ->
	{noreply, ordsets:del_element(Pid, State)}.

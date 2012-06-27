-module(wsdemo_server_logger).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/3, start_link/2, stop/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
start_link(Host, Port, Servername) when is_integer(Port) ->
    HostAndPort = lists:flatten([Host, ":", integer_to_list(Port)]),
    start_link(HostAndPort, Servername).

-spec start_link(iolist(), string()) -> {ok, pid()}.
start_link(HostAndPort, Servername) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [HostAndPort, Servername], []).

stop() ->
    gen_server:call(?SERVER, stop).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([HostAndPort, Servername]) ->
    erlang:send_after(timer:seconds(1), self(), log_stats),
    {ok, {HostAndPort, Servername}}.

handle_call(stop, _From, State) ->
    {stop, normal, ok, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(log_stats, {HostAndPort, Servername}) ->
    {ok, RSS} = wsdemo_server_manager:memusage(Servername),
    {ok, Connections} = wsdemo_server_manager:connections(HostAndPort),

    wsdemo_logger:event({server, {rss, RSS}}),
    wsdemo_logger:event({server, {connections, Connections}}),

    erlang:send_after(timer:seconds(1), self(), log_stats),
    {noreply, {HostAndPort, Servername}}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------


%% -------------------------------------------------------------------
%%
%% basho_bench: Benchmarking Suite
%%
%% Copyright (c) 2009-2010 Basho Techonologies
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%	    sqlite3:sql_exec(?SQLITE3_DB, "INSERT INTO rack ( name) VALUES (?)", [{1, "john"}]),
%% -------------------------------------------------------------------
-module(basho_bench_driver_sqlite3).
-export([new/1,
         run/4]).

-include("basho_bench.hrl").

%% ====================================================================
%% API
%% ====================================================================
-define(SQLITE3_DB,db).
-define(TABLE,user).
new(_Id) ->
    case sqlite3:open(?SQLITE3_DB,[in_memory]) of
	{ok,_}->
	    TableInfo = [{id, integer, [{primary_key, [asc, autoincrement]}]}, 
			 {name, text, [not_null]}, 
			 {age, integer}, 
			 {wage, integer}],
	    sqlite3:create_table(?SQLITE3_DB, ?TABLE, TableInfo),
	    ok;
	Reason-> ?FAIL_MSG("~p ~p open db error.\n",
			   [code:priv_dir(sqlite3),code:get_path()])
		 
    end,
    {ok, undefined}.

run(insert, KeyGen, _ValueGen, State) ->
    _Key = KeyGen(),
    case sqlite3:sql_exec(?SQLITE3_DB, "INSERT INTO user ( name) VALUES (?)", [{1, "john"}]) of
	{rowid,_}->
	    {ok, State};
	Result->{error,Result}
    end;
run(put, KeyGen, ValueGen, State) ->
    _Key = KeyGen(),
    ValueGen(),
    {ok, State};
run(delete, KeyGen, _ValueGen, State) ->
    _Key = KeyGen(),
    {ok, State};
run(an_error, KeyGen, _ValueGen, State) ->
    _Key = KeyGen(),
    {error, went_wrong, State};
run(another_error, KeyGen, _ValueGen, State) ->
    _Key = KeyGen(),
    {error, {bad, things, happened}, State}.


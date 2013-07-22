-module(name_db).
-export([create/0, insert/2, delete/2, get/2]).

%-record(name, {id, name}).

%-record(table, {name_lst, maxid, readnum, writenum}).
-include("name.hrl").

%����һ�����б����ڴ������
create() ->
    #table{name_lst = [], maxid = 0, readnum = 0, writenum = 0}.

insert(Name, Table) ->
    NameLst = Table#table.name_lst,
    insert(NameLst, Name, Table).

insert([], Name, Table) ->
    NameRec = #name{id = 1, name = Name},
    NewTable = Table#table{name_lst = [NameRec], maxid = 1, writenum = 1},
    {ok, NewTable};
insert(NameLst, Name, Table = #table{maxid = MaxId}) ->
    case lists:any(fun(X) -> X#name.name == Name end, NameLst) of
        true ->
            {ok, Table};
        false ->
            %�����µ�name��¼
            #table{
                maxid = MaxId
            } = Table,
            Maxid = Table#table.maxid,
            NameRec = #name{id = Maxid + 1, name = Name},
            %���µ�Table��¼
            Writenum = Table#table.writenum,
            NewTable = Table#table{name_lst = [NameRec | NameLst], maxid = Maxid + 1, writenum = Writenum + 1},
            {ok, NewTable}
    end.

delete(Name, Table) ->
    NameLst = Table#table.name_lst,
    NewLst = lists:filter(fun(X) -> X#name.name /= Name end, NameLst),
    %���µ�Table��¼
    Writenum = Table#table.writenum,
    NewTable = Table#table{name_lst = NewLst, writenum = Writenum + 1},
    {ok, NewTable}.

get(NameId, Table) ->
    NameLst = Table#table.name_lst,
    %Table�����Ӷ�ȡ����
    Readnum = Table#table.readnum,
    NewTable = Table#table{readnum = Readnum + 1},
    
    NameRecLst = lists:filter(fun(X) -> X#name.id == NameId end, NameLst),
    case NameRecLst == [] of
        true ->
            {notexists, NewTable};
        false ->
            [NameRec | _ ] = NameRecLst,
            {NameRec#name.name, NewTable}
    end.
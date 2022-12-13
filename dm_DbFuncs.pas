unit dm_DbFuncs;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, FireDAC.Comp.Script;

type
  TDBFuncsDM = class(TDataModule)
    fdqr_city: TFDQuery;
    fds_Data: TFDScript;
    fdqr_subItems: TFDQuery;
  private
    { Private declarations }
    FconnRef:TFDConnection;
  public
    { Public declarations }
    nameFilterValue:string;
    currLevel,currID,currParentID,currOwnerID:integer;
    currName:string;
    LastErrorMess:string;
    /// <summary>
    ///   получение 1 значения первого поля первой найденной записи по запросу
    /// </summary>
    function oneValueForSQL(const aSQL:string):Variant;

    /// <summary>
    ///   получение из запроса ID в виде строки
    /// </summary>
    function commaIDSForSQL(const aSQL:string):string;
    ///
    ///
    function FillHomeData: Boolean;
    procedure setConnRef(aConn:TFDConnection);
    function getTableNameForLevel(aLvl:integer):string;
    function getItemsForID(aLevel,aID:Integer; aParentFlag:boolean):integer;
    function getItemData(aLevel,aID:Integer; var arV:Variant):Boolean;
    function addItemData(aLevel,aparentID:Integer; const arV:Variant):integer;
    function setItemData(aLevel,aID:Integer; const arV:Variant):integer;
    function getPLOwnerData(arefTypeID,arefID:integer; var arV:Variant):integer;
    function setPLOwnerData(arefTypeID,arefID:integer; const arV:Variant):integer;
    function deleteItem(aLevel,aID:Integer):Boolean;
  end;

var
  DBFuncsDM: TDBFuncsDM;

function AppDB_DM: TDBFuncsDM;

implementation

{$R *.dfm}

uses
  UniGUIVars, uniGUIMainModule, MainModule, u_wCodeTrace, System.Variants, u_fdScriptFuncs;

 function AppDB_DM: TDBFuncsDM;
begin
  Result := TDBFuncsDM(UniMainModule.GetModuleInstance(TDBFuncsDM));
end;


function TDBFuncsDM.addItemData(aLevel, aparentID: Integer;
  const arV: Variant): integer;
var LQ:TFDQuery;
    L_tableName:string;
begin
  Result:=0;
  LQ:=TFDQuery.Create(nil);
  with LQ do
   try
    Connection:=FconnRef;
    SQL.Text:=Format('select * from %s where ID=0',[getTableNameForLevel(aLevel)]);
    LQ.Active:=True;
    First;
    Append;
    if FindField('parentID')<>nil then
       FieldByName('parentID').AsInteger:=aparentID;
    FieldByName('name').AsWideString:=arV[0];
    FieldByName('sign').AsInteger:=0;
    Post;
    Result:=FieldByName('ID').AsInteger;
    ///
    currLevel:=aLevel;
    currID:=Result;
    currName:=FieldByName('name').AsWideString;
    currParentID:=FieldByName('parentID').AsInteger;
   finally
    LQ.Free;
  end;
end;

function TDBFuncsDM.setPLOwnerData(arefTypeID, arefID: integer;
  const arV: Variant): integer;
var LQ:TFDQuery;
    L_ID:integer;
begin
  Result:=0;
  LQ:=TFDQuery.Create(nil);
  with LQ do
   try
    Connection:=FconnRef;
    SQL.Text:=Format('select * from plOwner where refTypeID=%d and refID=%d',[arefTypeID, arefID]);
    LQ.Active:=True;
    First;
    L_ID:=FieldByName('ownID').AsInteger;
    if L_ID=0 then
       Append
    else Edit;
    FieldByName('refTypeID').AsInteger:=arefTypeID;
    FieldByName('refID').AsInteger:=arefID;
    FieldByName('ownInfo').AsWideString:=arV[1];
    FieldByName('cDate').AsFloat:=arV[2];
    Post;
    Result:=FieldByName('ownID').AsInteger;
    currOwnerID:=Result;
   finally
    LQ.Free;
  end;
end;

function TDBFuncsDM.commaIDSForSQL(const aSQL:string): string;
var LQ:TFDQuery;
begin
 Result:='';
 LQ:=TFDQuery.Create(nil);
 with LQ do
 try
  LQ.Connection:=FconnRef;
  SQL.Text:=aSQL;
  LQ.Active:=True;
  LQ.First;
  if LQ.FieldCount>0 then
   while not(LQ.Eof) do
     begin
       if LQ.Fields[0].IsNull=false then
          Result:=Result+','+IntToStr(LQ.Fields[0].AsInteger);
       LQ.Next;
     end;
  if Length(Result)>0 then
     Result:=Copy(Result,2,MaxInt);
  ///
  with TStringList.Create do
   try
     StrictDelimiter:=False;
     Sorted:=True;
     Duplicates:=dupIgnore;
     CommaText:=Result;
     Result:=CommaText;
   finally
     Free;
   end;
  ///
 finally
   LQ.Free;
 end;
end;

function TDBFuncsDM.deleteItem(aLevel, aID: Integer): Boolean;
var LLocS,LStreetS,LhouseS:string;
begin
 Result:=false;
 LLocS:='';
 LStreetS:='';
 LhouseS:='';
 case aLevel of
   1: LLocS:=commaIDSForSQL('select ID from locality where parentID='+IntToStr(aID));
   2: LLocS:=IntToStr(aID);
   3: LStreetS:=IntToStr(aID);
   4: LhouseS:=IntToStr(aID);
 end;
 if Length(LLocS)>0 then
    LStreetS:=commaIDSForSQL('select ID from street where parentID in ('+LLocS+')');
 if Length(LStreetS)>0 then
    LhouseS:=commaIDSForSQL('select ID from house where parentID in ('+LStreetS+')');
 ///
 with FconnRef do
  try
   ///
   if Length(LhouseS)>0 then
    begin
      ExecSQL(Format('delete from house where ID in (%s);',[LhouseS]));
      ExecSQL(Format('delete from plOwner where refTypeID=4 and refID in (%s)',[LhouseS]));
    end;
   if Length(LStreetS)>0 then
    begin
      ExecSQL(Format('delete from street where ID in (%s);',[LstreetS]));
      ExecSQL(Format('delete from plOwner where refTypeID=3 and refID in (%s)',[LstreetS]));
    end;
   if Length(LLocS)>0 then
     begin
      ExecSQL(Format('delete from locality where ID in (%s);',[LLocS]));
      ExecSQL(Format('delete from plOwner where refTypeID=2 and refID in (%s)',[LLocS]));
     end;
   if aLevel=1 then
    begin
      ExecSQL(Format('delete from city where ID=%d;',[aID]));
      ExecSQL(Format('delete from plOwner where refTypeID=1 and refID=%d',[aID]));
    end;
   Result:=True;
   except on E:Exception do
    begin
      wLogE('TDBFuncsDM.deleteItem',E);
      LastErrorMess:=E.ClassName+' : '+E.Message;
    end;
  end;
end;

function TDBFuncsDM.FillHomeData: Boolean;
var LQ:TFDQuery;
    LList:TStrings;
    i,j,LID:integer;
    LS:string;
begin
 Result:=False;
 LID:=1;
 LQ:=TFDQuery.Create(nil);
 LList:=TStringList.Create;
 try
   LList.StrictDelimiter:=False;
   LQ.Connection:=FconnRef;
  // LQ.Options.DefaultValues:=True;
   LQ.SQL.Text:='select * from city';
   try
     LQ.Active:=True;
     if LQ.RecordCount<=1 then
        with LQ do
         begin
           AppendRecord([1,'Москва',0]);
           AppendRecord([2,'Санкт-Петербург',0]);
           AppendRecord([3,'Новосибирск',0]);
           AppendRecord([4,'Екатеринбург',0]);
           AppendRecord([5,'Казань',0]);
           AppendRecord([6,'Нижний Новгород',0]);
           AppendRecord([7,'Челябинск',0]);
           AppendRecord([8,'Самара',0]);
           AppendRecord([9,'Уфа',0]);
           AppendRecord([10,'Ростов-на-Дону',0]);
           AppendRecord([11,'Омск',0]);
           AppendRecord([12,'Красноярск',0]);
           AppendRecord([13,'Воронеж',0]);
           AppendRecord([14,'Пермь',0]);
           AppendRecord([15,'Волгоград',0]);
           Result:=True;
        end;
    LQ.Active:=False;
 {   FconnRef.ExecSQL('delete from locality');
    FconnRef.ExecSQL('vacuum;');
    }
    LQ.SQL.Text:='select * from locality';
    LQ.Active:=True;
     if LQ.RecordCount<=1 then
        with LQ do
         begin
          LList.DelimitedText:=GetSQLScriptTextByName(fds_Data,'Moskva_Locality');
          for i:=0 to LList.Count-1 do
           begin
            LS:=Trim(StringReplace(LList.Strings[i],'_',' ',[rfReplaceAll]));
            if Length(LS)>0 then
             begin
               AppendRecord([LID,1,LS,0]);
               Inc(LID);
             end;
           end;
          LList.DelimitedText:=GetSQLScriptTextByName(fds_Data,'SPB_Locality');
          for j:=0 to LList.Count-1 do
           begin
            LS:=Trim(StringReplace(LList.Strings[j],'_',' ',[rfReplaceAll]));
            if Length(LS)>0 then
             begin
               AppendRecord([LID,2,LS,0]);
               Inc(LID);
             end;
           end;
           Result:=(i>0) or (j>0);
         end;
    except on E:Exception do
      wLogE('TDBFuncs_DM.FillHomeData Err',E);
   end;
 finally
   LQ.Free;
   LList.Free;
 end;
end;

function TDBFuncsDM.getItemData(aLevel, aID: Integer;
  var arV: Variant): Boolean;
var LQ:TFDQuery;
    L_tableName:string;
begin
  Result:=False;
  LQ:=TFDQuery.Create(nil);
  with LQ do
   try
    Connection:=FconnRef;
    SQL.Text:=Format('select * from %s it left join plOwner pl on pl.refID=it.ID and pl.refTypeID=%d '+
                     'where it.ID=%d',[getTableNameForLevel(aLevel),aLevel,aID]);
    LQ.Active:=True;
    First;
    if FindField('name')<>nil then
      begin
        arV:=VarArrayof([FieldByName('name').AsWideString,
        FieldByName('ownID').Value,FieldByName('ownInfo').Value,
        FieldByName('cDate').Value]);
        Result:=True;
      end;
   finally
    LQ.Free;
  end;
end;

function TDBFuncsDM.getItemsForID(aLevel, aID: Integer; aParentFlag:boolean): integer;
var LQref:TFDQuery;
    LS,LcityStr,LocStr,Lstr,LHouseStr:string;
    L_fieldName:string;
      function L_inStr(const aStr:string):string;
        begin
          Result:=L_fieldName+'='+IntToStr(aID)+' and ID in ('+aStr+') ';
        end;
begin
  Result:=0;
  if aParentFlag then L_fieldName:='parentID'
  else L_fieldName:='ID';
  LQref:=fdqr_subItems;
  LQref.Active:=false;
  if (Length(nameFilterValue)>0) then
   begin
      LHouseStr:=commaIDSForSQL('select ID from house where name LIKE('''+nameFilterValue+'%'')');
      if Length(LHouseStr)=0 then LHouseStr:='0';
      LStr:=commaIDSForSQL('select s.ID from street s left join house h on h.parentID=s.ID '+
             ' where s.name LIKE('''+nameFilterValue+'%'') or h.ID in ('+LHouseStr+') group by s.ID');
      if Length(LStr)=0 then LStr:='0';
      LocStr:=commaIDSForSQL(' select l.ID from locality l left join street s on s.parentID=l.ID '+
      ' where l.name LIKE('''+nameFilterValue+'%'') or s.ID in ('+LStr+') group by l.ID');
      if Length(LocStr)=0 then LocStr:='0';
      LcityStr:=commaIDSForSQL(' select c.ID from city c left join locality l on l.parentID=c.ID '+
      ' where c.name LIKE('''+nameFilterValue+'%'') or l.ID in ('+LocStr+') group by c.ID');
      if Length(LcityStr)=0 then LcityStr:='0';
      LHouseStr:=L_inStr(LHouseStr);
      Lstr:=L_inStr(Lstr);
      LocStr:=L_inStr(LocStr);
      LcityStr:=' and ID in ('+LcityStr+') ';
   end
  else begin
        LcityStr:='';
        LocStr:=L_fieldName+'='+IntToStr(aID);
        Lstr:=L_fieldName+'='+IntToStr(aID);
        LHouseStr:=L_fieldName+'='+IntToStr(aID);
  end;
  ///
   with LQRef do
    try
     // LQref.Connection:=FconnRef;
      case aLevel of
        1: SQL.Text:=Format('select * from city where ID>0 %s order by name',[LcityStr]);
        2: SQL.Text:=Format('select * from locality where %s order by name',[LocStr]);
        3: SQL.Text:=Format('select * from street where %s order by name',[LStr]);
        4: SQL.Text:=Format('select * from house where %s',[LHouseStr]);
        else begin
              wLog('!','TDBFuncsDM.getItemsForParentID Error Level='+IntToStr(aLevel));
              Exit;
        end;
      end;
     LQref.Active:=True;
     LQref.First;
     Result:=LQref.RecordCount;
    except on E:Exception do
     wLogE('TDBFuncsDM.getItemsForID',E);
  end;
end;

function TDBFuncsDM.getPLOwnerData(arefTypeID, arefID: integer;
  var arV: Variant): integer;
var LQ:TFDQuery;
    L_ID:integer;
begin
  Result:=0;
  arV:=VarArrayOf([0,'',0]);
  if (arefTypeID=0) or (arefID=0) then Exit;
  LQ:=TFDQuery.Create(nil);
  with LQ do
   try
    Connection:=FconnRef;
    SQL.Text:=Format('select * from plOwner where refTypeID=%d and refID=%d',[arefTypeID, arefID]);
    LQ.Active:=True;
    First;
    arV[0]:=FieldByName('ownID').AsInteger;
    arV[1]:=FieldByName('ownInfo').AsWideString;
    arV[2]:=FieldByName('cDate').AsFloat;
    Result:=arV[0];
   finally
    LQ.Free;
  end;
end;

function TDBFuncsDM.getTableNameForLevel(aLvl: integer): string;
begin
  Result:='';
  case aLvl of
    1: Result:='city';
    2: Result:='locality';
    3: Result:='street';
    4: Result:='house';
    else wLog('e','TDBFuncsDM.getTableNameForLevel ERROR Level='+IntToStr(aLvl));
  end;
end;

function TDBFuncsDM.oneValueForSQL(const aSQL: string): Variant;
var LQ:TFDQuery;
begin
  Result:=Null;
  LQ:=TFDQuery.Create(nil);
  with LQ do
   try
    Connection:=FconnRef;
    SQL.Text:=aSQL;
    try
     Active:=true;
     First;
     if Fields.Count>0 then
        Result:=Fields[0].Value;
    except on E:Exception do
      wLogE('TDBFuncsDM.oneValueForSQL',E);
    end;
   finally
     LQ.Free;
   end;
end;

procedure TDBFuncsDM.setConnRef(aConn: TFDConnection);
begin
  FconnRef:=aConn;
end;

function TDBFuncsDM.setItemData(aLevel, aID: Integer;
  const arV: Variant): integer;
var LQ:TFDQuery;
    L_tableName:string;
begin
  Result:=0;
  LQ:=TFDQuery.Create(nil);
  with LQ do
   try
    Connection:=FconnRef;
    SQL.Text:=Format('select * from %s where ID=%d',[getTableNameForLevel(aLevel),aID]);
    LQ.Active:=True;
    First;
    Result:=FieldByName('ID').AsInteger;
    if Result>0 then
     begin
       Edit;
       /// if FindField('parentID')<>nil then
       ///     FieldByName('parentID').AsInteger:=aparentID;
       FieldByName('name').AsWideString:=arV[0];
       // FieldByName('sign').AsInteger:=0;
       Post;
     end;
    ///
    currLevel:=aLevel;
    currID:=Result;
    currName:=FieldByName('name').AsWideString;
    currParentID:=FieldByName('parentID').AsInteger;
   finally
    LQ.Free;
  end;
end;

initialization
  RegisterModuleClass(TDBFuncsDM);
end.

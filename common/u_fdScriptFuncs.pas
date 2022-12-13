unit u_fdScriptFuncs;

interface

 uses System.Classes,//FireDAC.Comp.Client,
 FireDAC.Comp.Script;

 function GetSQLScriptByName(aFDScrComp: TFDScript; const ASName: string):TStrings;
 function GetSQLScriptTextByName(aFDScrComp: TFDScript; const ASName: string): string;

implementation

function GetSQLScriptByName(aFDScrComp: TFDScript; const ASName: string):TStrings;
 var LSr:TFDSQLScript;
begin
  LSr:=aFDScrComp.SQLScripts.FindScript(ASName);
  if Assigned(LSr) then
     Result:=LSr.SQL
  else Result:=nil;
end;

function GetSQLScriptTextByName(aFDScrComp: TFDScript; const ASName: string): string;
 var LSr:TFDSQLScript;
begin
  LSr:=aFDScrComp.SQLScripts.FindScript(ASName);
  if Assigned(LSr) then
     Result:=LSr.SQL.Text
  else Result:='';
end;

end.

program nnTestPrj;

uses
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {nnTreeTestForm: TUniForm},
  u_wCodeTrace in 'common\u_wCodeTrace.pas',
  u_udTreeFuncs in 'u_udTreeFuncs.pas',
  dm_DbFuncs in 'dm_DbFuncs.pas' {DBFuncsDM: TDataModule},
  u_fdScriptFuncs in 'common\u_fdScriptFuncs.pas',
  ufm_PlaceProps in 'ufm_PlaceProps.pas' {PlacePropsForm: TUniForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.

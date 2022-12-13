unit ServerModule;

interface

uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication, uIdCustomHTTPServer,
  uniGUITypes, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client;

type
  TUniServerModule = class(TUniGUIServerModule)
    Conn: TFDConnection;
    procedure UniGUIServerModuleBeforeInit(Sender: TObject);
    procedure UniGUIServerModuleException(Sender: TUniGUIMainModule;
      AException: Exception; var Handled: Boolean);
    procedure UniGUIServerModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    F_CoInitFlag:Boolean;
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars, Winapi.ActiveX, u_wCodeTrace;

function UniServerModule: TUniServerModule;
begin
  Result:=TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;

procedure TUniServerModule.UniGUIServerModuleBeforeInit(Sender: TObject);
begin
  CharSet := 'utf-8';
  wCode.Enabled:=True;
  try
   // CoInitializeEx(NIL, COINIT_APARTMENTTHREADED);
  //  F_CoInitFlag:=True;
   Conn.Params.Database:=ExtractFilePath(ParamStr(0))+'nnKladr.sqlite';
   Conn.Connected:=True;
   wLog('+','Connected=true');
       ///
   except on E:Exception do
            wLogE('Connect base',E);
   end;
end;

procedure TUniServerModule.UniGUIServerModuleDestroy(Sender: TObject);
begin
  if F_CoInitFlag then CoUninitialize;
end;

procedure TUniServerModule.UniGUIServerModuleException(
  Sender: TUniGUIMainModule; AException: Exception; var Handled: Boolean);
begin
 wLogE('UniGUIServerModuleException',AException);
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.

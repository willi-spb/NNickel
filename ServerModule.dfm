object UniServerModule: TUniServerModule
  OldCreateOrder = False
  OnDestroy = UniGUIServerModuleDestroy
  AutoCoInitialize = True
  TempFolder = 'temp\'
  Title = 'New Application'
  SuppressErrors = []
  Bindings = <>
  SSL.SSLOptions.RootCertFile = 'root.pem'
  SSL.SSLOptions.CertFile = 'cert.pem'
  SSL.SSLOptions.KeyFile = 'key.pem'
  SSL.SSLOptions.Method = sslvTLSv1_1
  SSL.SSLOptions.SSLVersions = [sslvTLSv1_1]
  SSL.SSLOptions.Mode = sslmUnassigned
  SSL.SSLOptions.VerifyMode = []
  SSL.SSLOptions.VerifyDepth = 0
  ConnectionFailureRecovery.ErrorMessage = 'Connection Error'
  ConnectionFailureRecovery.RetryMessage = 'Retrying...'
  OnBeforeInit = UniGUIServerModuleBeforeInit
  OnException = UniGUIServerModuleException
  Height = 275
  Width = 410
  object Conn: TFDConnection
    Params.Strings = (
      'Database=D:\NorNickel_UNItest\Win32\Debug\nnKladr.sqlite'
      'DateTimeFormat=DateTime'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 64
    Top = 64
  end
end

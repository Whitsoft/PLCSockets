program TestPLCS;

uses
  Forms,
  TestPLC in 'TestPLC.pas' {Form1},
  ConnectThread in 'ConnectThread.pas',
  FileStrToData in 'FileStrToData.pas',
  UnitUtil in 'UnitUtil.pas',
  UnitFunctions in 'UnitFunctions.pas',
  PLCTypedFile in 'PLCTypedFile.pas',
  PLCLogical in 'PLCLogical.pas',
  PLCCIF in 'PLCCIF',
  UnitH in 'UnitH.pas',
  PLCConnectClass in 'PLCConnectClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

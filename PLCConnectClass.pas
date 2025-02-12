unit PLCConnectClass;

interface

uses   
  SysUtils, Classes, ScktComp,WinSock2,types, UnitUtil, UnitFunctions,ExtCtrls,
                     FileStrToData, UnitH;

type
  TPLCConnectClass = class(TComponent)
  private
    { Private declarations }
    fActive:     boolean;
    fTimerDisCon: TTimer;
    fHostPort:   word;
    fHostName:   String;
    fHostIP:     String;
    fPLCIP:      String;
    fPLCPort:    word;
    fSession:    Integer;
    fConnected:  Boolean;
    fRegistered: Boolean;
    fPLCType:    String;
    fPLCSeries:  String;
    fPLCRev:     String;
    fPEtherInfo: PPLC_EtherIP_info;
    fElement:    String;
    fFileData:   PFileData;
    fError:      String;
    ferrorNo:    byte;
    fCIPError:   String;
    fCIPErrorNo: Integer;
    fSockError:  String;
    ferrorLocal: String;
    ferrorRemote:String;
    property Active: boolean read fActive write fActive;
    //function  getIPs(var IPS: String): String;
  protected
    { Protected declarations }
     function  getIPs(var IPS: String): String;
     procedure setPLCIP(IP: String);
     procedure setPLCPort(Port: word);
     function  getPLCIP: String;
     function  getPLCPort: word;
     function  getEtherInfo: PPLC_EtherIP_info;
     procedure setError(Err: byte);
     procedure setCIPError(Err: Integer);
     procedure setElement(value: String);
     procedure setTimeout(Value: Cardinal);
     function  getTimeout:Cardinal;
     function  getTimerEnabled:boolean;
     procedure setTimerEnabled(OnOff: Boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    connect:String;
    procedure   disConnect;
    procedure   DisConTimer(Sender: TObject);
    function    registerSession(PIP_info: PPLC_EtherIP_info):Integer;
    function    unRegisterSession(PIP_info: PPLC_EtherIP_info):Integer;
    function    getPLCStatus(PIPInfo:PPLC_EtherIP_info):PCCCReply;
    function    getHostInfo: String;
    property    EtherInfo: PPLC_EtherIP_info read getEtherInfo;
    property    PLCType:    String read fPLCType;
    property    PLCSeries:  String read fPLCSeries;
    property    PLCRev:     String read fPLCRev;
    property    PLCSession: Integer read fSession write fSession;
    property    Connected:  Boolean read fConnected write fConnected;
    property    Registered: Boolean read fRegistered write fRegistered;
    property    Error:      byte read fErrorNo write setError;
    property    ConLocalErr:   String read fErrorLocal;
    property    ConRemoteErr:  String read fErrorRemote;
    property    SocketError:   String read fSockError;
    property    CIPErrorNo:    Integer read fCIPErrorNo write setCIPError;
    property    ConCIPError:   String read fCIPError;
    procedure   Init;
    property    PLCElement:    String read fElement write setElement;
    property    TimeoutEnabled: boolean read getTimerEnabled write setTimerEnabled;
    property    HostPort:      word read fHostPort write fHostPort;
  published
    { Published declarations }
     property    HostIP:   String read fHostIP write fHostIP;
     property    HostName:   String read fHostName;
     property    PLCIP: String read getPLCIP write setPLCIP;
     property    PLCPort: word read getPLCPort write setPLCPort;
     property    Timeout: Cardinal read getTimeout write setTimeout;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('PLCSockets', [TPLCConnectClass]);
end;

function TPLCConnectClass.getHostInfo: String;
var
  Host, IP, Err: string;
begin
  if GetIPFromHost(Host, IP, Err)then
    begin
      fSockError:= Err;
      fHostName := Host;
      HostIP := IP;
    end;
    result:=Err;
end;

procedure TPLCConnectClass.Init;
begin
  fPEtherInfo^.tag:=0;
  fPEtherInfo^.PCIP.CipTimeOut := 1000;
  fPEtherInfo^.session_handle:=0;
  fPEtherInfo^.Sock_handle:=0;
  fPEtherInfo^.error:=0;
  fPEtherInfo^.PLCHostport:=$AF12;   //44818
  RandContext(fPEtherInfo);
  setPLCPort(44818);
  RandContext(fPEtherInfo);
end;

constructor TPLCConnectClass.Create(AOwner: TComponent);
var
  Len: Integer;
begin
  inherited Create(AOwner);
  getHostInfo;
  new(fFileData);
  New(fPEtherInfo);
  Len:=SizeOf(fPEtherInfo^);
  bzero(fPEtherInfo,Len);
  fTimerDisCon:=TTimer.Create(Self);
  fTimerDisCon.Enabled:=false;
  fTimerDisCon.OnTimer:=DisConTimer;
  fTimerDisCon.Interval:=5000;
  Init;
end;

destructor TPLCConnectClass.Destroy;
begin
  Dispose(fPEtherInfo);
  if fFileData<> nil then
     dispose(fFileData);
  fTimerDisCon.destroy;
  inherited Destroy;
end;

function  TPLCConnectClass.getEtherInfo: PPLC_EtherIP_info;
begin
  result:= fPEtherInfo;
end;

procedure TPLCConnectClass.setPLCIP(IP: String);
begin
   fPLCIP := IP;
   if fPEtherInfo <> nil then
     fPEtherInfo^.PLCHostIP:=IP;
end;

procedure TPLCConnectClass.setPLCPort(Port: word);
begin
   fPLCPort := Port;
   if fPEtherInfo <> nil then
      fPEtherInfo^.PLCHostPort:=Port;
end;

function  TPLCConnectClass.getPLCIP: String;
  begin
    if fPEtherInfo = nil then
       result:=''
    else
       result:=fPEtherInfo^.PLCHostIP;
  end;

function  TPLCConnectClass.getPLCPort: word;
  begin
     if fPEtherInfo =nil then
        result:=0
     else
        result:=fPEtherInfo^.PLCHostPort;
  end;

function TPLCConnectClass.getIPs(var IPS: String): String;
type
  TaPInAddr = ARRAY[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0..63] of AnsiChar;
  I: Integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  //Result := TstringList.Create;
  //Result.CLEAR;
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(buffer);
  if phe = nil then EXIT;
  Result:=phe.h_name;
  pPtr := PaPInAddr(phe^.h_addr_list);
  I    := 0;
  while pPtr^[I] <> nil do
  begin
    IPS:=(inet_ntoa(pptr^[I]^));
    break;
    Inc(I);
  end;
  WSACleanup;
end;




function TPLCConnectClass.Connect:String;
begin
  ferror := '';
  if Connected then exit;
  Init;
  ferror:=CommConnect(EtherInfo);
  sleep(100);
  if  EtherInfo^.Connected=OK then
 // if ferror = 'OK'
     begin
       Connected:=true;
       Registered:=true;
     end
  else
     begin
       Connected:=false;
       Registered := false;
     end;
end;

procedure TPLCConnectClass.disConnect;
begin
  CommDisCon(EtherInfo);
  Connected:=false;
  Registered := false;
end;

function TPLCConnectClass.registerSession(PIP_info: PPLC_EtherIP_info):Integer;
  begin
    result:=register_session(PIP_info);
  end;

function TPLCConnectClass.unRegisterSession(PIP_info: PPLC_EtherIP_info):Integer;
  begin
    result:=unregister_session(PIP_info);
  end;

function TPLCConnectClass.getPLCStatus(PIPInfo:PPLC_EtherIP_info):PCCCReply;
var
  Reply: PCCCReply;
  Ser,Rev,PName: String;
  Err: Boolean;
begin
  if not connected then exit;
  Reply:=getStatus(PIPInfo);
  Err:=parseStatus(Reply,Ser,Rev,PName);
  if Err then
    begin
      fError:='Status Error';
      fPLCType:= '';
      fPLCSeries:='';
      fPLCRev:='';
    end
  else
    begin
      fError := '';
      fPLCType:= PName;
      fPLCSeries:= Ser;
      fPLCRev:=Rev;
    end;
end;

procedure TPLCConnectClass.setError(Err:Byte);
var
  localErr, remoteErr: Byte;
begin
  localErr:=Err and $0F;
  remoteErr:=(Err SHR 4);
  fErrorNo:=Err;
  FErrorLocal:=PCErrors[localErr];
  FErrorRemote:=PLCErrors[remoteErr];
end;

procedure TPLCConnectClass.setCIPError(Err: Integer);
var
  SErr: Integer;
begin
  fCIPErrorNo:=Err;
  If (Err <=0) and (Err > -10) then
    begin
      SErr:=-Err;
      fCIPError:=CIPErrors[SErr];
    end
  else
    fCIPError:='None';
end;

procedure TPLCConnectClass.setElement(value: String);
begin
   fElement:=value;
   fFileData^:=StrToFileData(Value);
end;

function TPLCConnectClass.getTimeout:Cardinal;
begin
  if fTimerDisCon <> nil then
     result:=fTimerDisCon.Interval
  else
     result:=0;
end;

procedure TPLCConnectClass.setTimeout(Value: Cardinal);
begin
  if fTimerDisCon <> nil then
    begin
      fTimerDisCon.Interval := Value;
    end;
end;

procedure TPLCConnectClass.DisConTimer(Sender: TObject);
begin
  fTimerDisCon.enabled := false;
  if connected then DisConnect;
end;

function TPLCConnectClass.getTimerEnabled:boolean;
begin
  result:=fTimerDisCon.enabled;
end;

procedure TPLCConnectClass.setTimerEnabled(OnOff: Boolean);
begin
  fTimerDisCon.enabled:=onOff;
end;

end.



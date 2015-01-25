unit PLCConnection;

interface

uses
  SysUtils, Classes, ScktComp,WinSock,types, UnitUtil, UnitFunctions, UnitH;

type
  TPLCConnection = class(TComponent)
  private
    { Private declarations }
    fActive:     boolean;
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
    ferrorNo:    byte;
    fCIPError:   String;
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
     procedure setCIPError(Err: String);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    connect:String;
    procedure   disConnect;
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
    property    ConCIPError:   String read fCIPError write setCIPError;
    procedure   Init;
   // property    PLCIP:      String read getPLCIP write setPLCIP;
  published
    { Published declarations }
     property HostName:   String read fHostName;
     property HostIP: String read fHostIP write fHostIP;
     property HostPort: word read fHostPort write fHostPort;
     property PLCIP: String read getPLCIP write setPLCIP;
     property PLCPort: word read getPLCPort write setPLCPort;
  end;

procedure Register;

implementation
   {$R tplcconnection.dcr}


procedure Register;
begin
  RegisterComponents('Samples', [TPLCConnection]);
end;

function TPLCConnection.getHostInfo: String;
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

procedure TPLCConnection.Init;
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

constructor TPLCConnection.Create(AOwner: TComponent);
var
  Len: Integer;
begin
  inherited Create(AOwner);
  getHostInfo;
  New(fPEtherInfo);
  Len:=SizeOf(fPEtherInfo^);
  bzero(fPEtherInfo,Len);
  Init;
end;

destructor TPLCConnection.Destroy;
begin
  Dispose(fPEtherInfo);
  inherited Destroy;
end;

function  TPLCConnection.getEtherInfo: PPLC_EtherIP_info;
begin
  result:= fPEtherInfo;
end;  

procedure TPLCConnection.setPLCIP(IP: String);
begin
   fPLCIP := IP;
   if fPEtherInfo <> nil then
     fPEtherInfo^.PLCHostIP:=IP;
end;

procedure TPLCConnection.setPLCPort(Port: word);
begin
   fPLCPort := Port;
   if fPEtherInfo <> nil then
      fPEtherInfo^.PLCHostPort:=Port;
end;

function  TPLCConnection.getPLCIP: String;
  begin
    if fPEtherInfo = nil then
       result:=''
    else
       result:=fPEtherInfo^.PLCHostIP;
  end;

function  TPLCConnection.getPLCPort: word;
  begin
     if fPEtherInfo =nil then
        result:=0
     else
        result:=fPEtherInfo^.PLCHostPort;
  end;

function TPLCConnection.getIPs(var IPS: String): String;
type
  TaPInAddr = ARRAY[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0..63] of CHAR;
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

function TPLCConnection.Connect:String;
begin
  Init;
  fSockError:=CommConnect(EtherInfo);
  if fSockError = 'OK'
   then
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

procedure TPLCConnection.disConnect;
begin
  CommDisCon(EtherInfo);
  Connected:=false;
  Registered := false;
end;

function TPLCConnection.registerSession(PIP_info: PPLC_EtherIP_info):Integer;
  begin
    result:=register_session(PIP_info);
  end;

function TPLCConnection.unRegisterSession(PIP_info: PPLC_EtherIP_info):Integer;
  begin
    result:=unregister_session(PIP_info);
  end;

function TPLCConnection.getPLCStatus(PIPInfo:PPLC_EtherIP_info):PCCCReply;
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
      fErrorRemote:='Status Error';
      fPLCType:= '';
      fPLCSeries:='';
      fPLCRev:='';
    end
  else
    begin
      fErrorRemote := '';
      fPLCType:= PName;
      fPLCSeries:= Ser;
      fPLCRev:=Rev;
    end;
end;

procedure TPLCConnection.setError(Err:Byte);
var
  localErr, remoteErr: Byte;
begin
  localErr:=Err and $0F;
  remoteErr:=(Err SHR 4);
  fErrorNo:=Err;
  FErrorLocal:=PCErrors[localErr];
  FErrorRemote:=PLCErrors[remoteErr];
end;

procedure TPLCConnection.setCIPError(Err: String);
begin
  fCIPError:=Err;
end;

end.



unit PLCMsg;

interface

uses
   SysUtils, Classes, ScktComp,types, ExtCtrls, PLCConnectClass,
   UnitUtil,UnitH, UnitFunctions, FileStrToData, Winsock, dialogs;

const
  MAXWORDS=24;

type
  FloatRecord = record
    HiWord: word;
    LoWord: word;
  end;

type
  TBytes = array[0..3] of byte;

type
  PConID=^ConID;
  ConID= record
    context: Int64;
    ID: array[0..3] of byte;
end;

type
  PPLCMessage = ^PLCMessage;
   PLCMessage = packed record
     SHandle: array[0..3] of byte;
     CMD: byte;
     ConID:array[0..3] of byte;
     funct: byte;
     Size: byte;
     FileNo: byte;
     FileType: byte;
     Element: byte;
     SubElement: Byte;
     Data: array[0..63] of byte;
     FileDesc: String;
end;

type
  TPLCMsg = class(TServerSocket)
  private
    { Private declarations }
    fSockHandle: Integer;
    fSessionHandle: cardinal;
    FClientAfterRead: TSocketNotifyEvent;
    fHostPort:   word;
    fHostName:   String;
    fHostIP:     String;
    fPLCList:    TStringList;
    fConList:    TStringList;
    fPLCPort:    word;
    fError:      String;
  protected
    { Protected declarations }
    property  SessionHandle: cardinal read fSessionHandle write fSessionHandle;
    function  getHostIP: String;
  public
    { Public declarations }
    procedure   ClientRead(Sender: TObject;Socket: TCustomWinSocket);
    property    PLCList: TStringList read fPLCList write fPLCList;
    property    ConList: TStringList read fConList write fConList;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  published
    { Published declarations }
    property LocalIP: String read getHostIP write fHostIP;
  end;

procedure Register;

implementation
       {$R TPLCMSG.dcr}
procedure Register;
begin
  RegisterComponents('PLCSockets', [TPLCMSG]);
end;

constructor TPLCMsg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  PLCList := TStringList.Create;
  ConList := TStringList.Create;
  fSessionHandle:=0;
  Port:=44818;
  FClientAfterRead := onClientRead;
  onClientRead:=ClientRead;
end;

destructor TPLCMsg.Destroy;
var
  IDX: Integer;
begin
  for IDX := 0 to PLCList.Count -1 do
    if assigned(PLCList.Objects[IDX]) then
        dispose(PConID(PLCList.Objects[IDX]));

  for IDX := 0 to ConList.Count -1 do
    if assigned(ConList.Objects[IDX]) then
      dispose(PConID(ConList.Objects[IDX]));

  PLCList.Free;
  ConList.Free;
  inherited Destroy;
end;

// ***********************************************************
// Read a buffer of data from PLC into buffer
// Buffer starts at Industrial Protocol (Ethernet/IP)
// First item is encapsulation header
// Respond to PLC by sending OBuf
// ***********************************************************
procedure TPLCMsg.ClientRead(Sender: TObject;Socket: TCustomWinSocket);
var
  buffer: array[0..255] of byte;
  OBuf: array[0..69] of byte;
  bytes, cnt, IDX, DEX,CDEX: Integer;
  S: String;
  Session: array[0..3] of byte;
  Arr: array[0..3] of byte;
begin
  S:='';
  for cnt := 0 to 255  do
    buffer[cnt]:=0;
  cnt:=255;
  bytes:=Socket.ReceiveBuf(buffer,cnt);
  for cnt:=0 to bytes-1 do
    S:=S+ByteToHex(buffer[cnt]);
  if buffer[0] = PLC_Register_Session then   //Register Session     $65
    begin
      SessionHandle:=sessionHandle+1;
      Cardinal2ByteArray(SessionHandle,session);
      Buffer[4]:=Session[0];
      Buffer[5]:=Session[1];
      Buffer[6]:=Session[2];
      Buffer[7]:=Session[3];
      Socket.SendBuf(Buffer,28);
    end
  else if buffer[0] = EIP_SendRRData then   //open forward   $6F
    begin
      for IDX := 0 to 3 do
        Arr[IDX]:=buffer[IDX+12];
      S:=IntToStr(Integer(Arr));

      DEX:=ConList.IndexOf(S);
      if DEX < 0 then
         begin
           ConList.AddObject(S,TObject(new(PConID)));
           DEX:=ConList.IndexOf(S);
         end;

      with PConID(pointer(ConList.Objects[DEX]))^ do
        begin
          ID[0]:=buffer[52];
          ID[1]:=buffer[53];
          ID[2]:=buffer[54];
          ID[3]:=buffer[55];
        end;
       for IDX := 0 to 69 do
        OBuf[IDX]:=0;
      for IDX := 0 to 41 do
        OBuf[IDX] := Buffer[IDX]; // Header info
      OBuf[2]  := 46;
      OBuf[38] := 30;
      OBuf[39] := 0;           //30 bytes follow
      OBuf[40] := FwdOpen_Resp;
      OBuf[41] := 0;
      OBuf[44]:=Session[0];
      OBuf[45]:=Session[1];
      OBuf[46]:=Session[2];
      OBuf[47]:=Session[3];
      for IDX := 48 to 59 do
        OBuf[IDX] := Buffer[IDX+4];
      for IDX :=60 to 63 do
        begin
          OBuf[IDX]:= Buffer[IDX+8];
          OBuf[IDX+4]:=Buffer[IDX+8];
        end;
      for IDX := 74 to 77 do
        OBuf[IDX] := Buffer[IDX+10];
      Socket.SendBuf(OBuf,70);
    end
  else if buffer[0] = SendUnitData then   //CIP message  $70
    begin
       Cnt:=buffer[42];
      //String = PLC IP Address+space+FileType+FileNo+':'+Element+'/'+SubElement
      //Identifies a unique element in a unique PLC
      // Buffer[12] starts 8 byte Sender Context - for Allen Bradley
      //   this is 4 byte IP Address +
      S:=IntToStr(Buffer[12])+'.'+ IntToStr(Buffer[13])+'.' +
         IntToStr(Buffer[14])+'.'+IntToStr(Buffer[15]);     //PLC IP Address
      //buffer[66] is encoded prefix 'N','B','F','C',etc
      S:=S+' '+PREFIX[buffer[66]-128]+ IntToStr(buffer[65])+':' +  //File number + ':'
                        intToStr(buffer[67])+'/'+intToStr(buffer[68]); // Element no + '/' + sub Element no.
      DEX:=PLCList.IndexOf(S);
      if DEX < 0 then
         begin  //Keep a list of PLC objects
           PLCList.AddObject(S,TObject(new(PPLCMessage)));
           DEX:=PLCList.IndexOf(S);
         end;
      with PPLCMessage(pointer(PLCList.Objects[DEX]))^ do
        begin
          SHandle[0]:=buffer[4]; //Record 4 byte session handle
          SHandle[1]:=buffer[5];
          SHandle[2]:=buffer[6];
          SHandle[3]:=buffer[7];
          FileDesc:=S;
          Cmd:=buffer[60];
          funct:=buffer[63];       // Perhaps 0xAA Protected logical write 3 address fields
          Size:=buffer[64];        // Perhaps 8 bytes
          FileNo:=buffer[65];      // 8 for F8 for instance
          FileType:=buffer[66];    // Perhaps F for FileType F
          Element:=buffer[67];     // File Element number
          SubElement:=buffer[68];  // File sub Element    Ex: of all of this F8:7/0
          for IDX:=69 to (44+Cnt) do   //This is the value sent by the PLC - must interpret it
            Data[IDX-69] := buffer[IDX];
        end;    
      for IDX := 0 to 50 do
        OBuf[IDX]:=0;
      for IDX:=0 to 49 do
        OBuf[IDX]:=buffer[IDX];
      OBuf[2]:=26;
      OBuf[42]:=6;
      OBuf[46]:=$CB;
      OBuf[47]:=0;
      OBuf[48]:=0;
      OBuf[49]:=0;
      OBuf[4]:=buffer[4];  //4 byte session handle
      OBuf[5]:=buffer[5];
      OBuf[6]:=buffer[6];
      OBuf[7]:=buffer[7];

      for IDX := 0 to 3 do
        Arr[IDX]:=buffer[IDX+12];
      S:=IntToStr(Integer(Arr));
      CDEX:=ConList.IndexOf(S);
      If CDex >= 0 then
        with PConID(pointer(ConList.Objects[CDEX]))^ do
          begin
            OBuf[36]:= ID[0];
            OBuf[37]:= ID[1];
            OBuf[38]:= ID[2];
            OBuf[39]:= ID[3];
          end;
      Socket.SendBuf(OBuf,50);
    end;
  if Assigned(FClientAfterRead) then
     FClientAfterRead(Sender,Socket);
end;

function TPLCMsg.getHostIP:String;
type
  pu_long = ^u_long;
var
  varTWSAData : TWSAData;
  varPHostEnt : PHostEnt;
  varTInAddr : TInAddr;
  namebuf : Array[0..255] of char;
begin
  If WSAStartup($101,varTWSAData) <> 0 Then
  Result := 'No connection'
  else
    begin
      gethostname(namebuf,sizeof(namebuf));
      varPHostEnt := gethostbyname(namebuf);
      varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
      Result := inet_ntoa(varTInAddr);
    end;
  WSACleanup;
end;

end.

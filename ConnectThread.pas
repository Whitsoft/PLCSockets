unit ConnectThread;

interface

uses
  Classes, Windows,WinSock, unitH, unitUtil, sysUtils, dialogs;

type
  TConnectThread = class(TThread)
  private
    fPLCPtr: PPLC_EtherIP_info;
    procedure Terminated(Sender: TObject);
    procedure TestPrint(TmpStr: String);
  public
    constructor create(CreateSuspended: Boolean; aPLCPtr: PPLC_EtherIP_info);
    procedure  Execute();override;
    property PLCPtr:PPLC_EtherIP_info read fPLCPtr write fPLCPtr;
  end;

  implementation

  uses
    unitFunctions;

procedure TConnectThread.Terminated(Sender: TObject);
begin
  //Form1.btnStartThrd.Enabled := true;
end;

constructor TConnectThread.create(CreateSuspended: Boolean; aPLCPtr: PPLC_EtherIP_info);
begin
  inherited create(CreateSuspended);
  PLCPtr:=aPLCPtr;
end;

procedure TConnectThread.Execute();
var
  hostInfo: pHostEnt;
  address: TSockAddrIn;
  header, rcvd: ethernet_header;
  custom: custom_connect;
  WSAData: TWSAData;
  len, response_len, IntIP: Integer;
  WSAERR: String;
  BPtr: PChar;
  IDX: Integer;
  HostNme: String;
  error: Integer;
begin
  try
     PLCPtr^.tag:=99;
     PLCPtr^.Connected:=1;
     error:=0;
     Len:=SizeOf(Address);
     bzero(@Address,Len);
     //Len:=SizeOf(PLCPtr^);
     //bzero(PLCPtr,Len);
       //struct hostent   -- from windows SDK
       //    char FAR *       h_name;  //name of host PC
       //    char FAR * FAR * h_aliases; //Null terminated string of alternate names
       //    short            h_addrtype; //Address type returned
       //    short            h_length;    //Lenght in bytes of each address
       //    char FAR * FAR * h_addr_list;  //null terminated list of IP addresses

                                                 //At least Version 1 Rev 1
      if WSAStartup($0101, WSAData) <> 0 then    //initialize Winsock library
         begin
           WSAErr := 'Winsock is not responding."';
           Exit;
         end;

    error:=0;
    HostNme:=PLCPtr.PLCHostIP;   //PLC IP address
    HostInfo:=getHostByName(PChar(PLCPtr^.PLCHostIP));
  If not assigned(HostInfo) then
     error:=NOHOST
  else
    begin
      //create a socket - windows api function
      PLCPtr^.sock_handle := socket(AF_INET, SOCK_STREAM, 0);
      if (PLCPtr^.sock_handle = -1) then
       	PLCPtr^.error:=NOCONNECT
      else
        begin
          address.sin_family := AF_INET;       //family
          BPtr:=HostInfo.h_addr^;
          address.sin_addr.S_un_b.s_b1 := char(BPtr^);
          inc(BPtr);
          address.sin_addr.S_un_b.s_b2 := char(BPtr^);
          inc(BPtr);
          address.sin_addr.S_un_b.s_b3 := char(BPtr^);
          inc(BPtr);
          address.sin_addr.S_un_b.s_b4 := char(BPtr^);

          if (address.sin_addr.s_addr = 0) then
             PLCPtr^.error:=BADADDR
          else
            begin
              address.sin_port := htons(PLCPtr^.PLCHostPort);
              len := sizeof(address);
              // connect to an IP address - windows API
              //syn, syn/ack, ack  - computer - plc - computer
             IDX:= connect(PLCPtr^.sock_handle, address, len);

             if  IDX <0 then
                 PLCPtr^.error:=WSAGetLastError
             else
               begin
                 PLCPtr^.error:=0;
                 bzero(Addr(custom), sizeof(custom_connect));
                 bzero(Addr(rcvd), sizeof(ethernet_header));
                 bzero(Addr(header), sizeof(ethernet_header));

                 header.mode := 1;
                 header.submode := CONNECT_CMD;
                 header.conn := 0;
                 header.pccc_length := 0;

                 custom.version := htons(PCCC_VERSION);
                 custom.backlog := htons(PCCC_BACKLOG);
                // testPrint(INtTOStr(custom.version+' '+IntToStr(custom.backlog);
                 StructToByteArray(header.custom,Addr(custom),_CUSTOM_LEN,0);
                 //psh/ack - psh/ack computer - plc
                 send(PLCPtr^.sock_handle, header, _ENET_HEADER_LEN,0);
                 response_len := recv(PLCPtr^.sock_handle, rcvd, 255, 0);

                 if (response_len <20) then
                   PLCPtr^.error:=NOCONNECT
                 else
                   begin
                     PLCPtr^.Connected:=OK;
                     register_Session(PLCPtr);
                   end;  
               end;
            end;
         end;
    end;
  except
    PLCPtr^.error:=NOCONNECT;
  end;
end;

procedure TConnectThread.TestPrint(TmpStr: String);
{Used primarily for debugging}
var
  F1:  TextFile;
  FName: String;
begin
    FName:='C:\Test.LOG';
    AssignFile(F1,FName);
    {$I-}
    Append(F1);
    {$I+}
    if IOResult <>0  then  {File did not exist}
       Rewrite(F1);
    WriteLn(F1,TmpStr+' '+DateTimeToStr(Now));
    CloseFile(F1);
  end;
end.

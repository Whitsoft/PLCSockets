unit UnitFunctions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinSock, StdCtrls,ScktComp, UnitUtil, UnitH, FileStrToData,BinDecConv;


 function _Connect(PLCPtr:PPLC_EtherIP_info):String;

 function  getPosInteger(S: String): Integer;

 function  parseStatus(PCCC: PCCCReply;
           var Series,Revision,PLCName: String):Boolean;

 procedure insertByte(PLCPtr:PPLC_EtherIP_info;
                      PLCCmd: Byte;offset: integer;var total: integer);

 function  addBuffer(var aBuffer:array of byte;addBuf: PSimpleBuf;Len: Integer): integer;
 procedure RegisterReply(Socket:TCustomWinSocket;PBuf: PSimpleBuf; len: integer);
 procedure RRReply(Socket:TCustomWinSocket	;PBuf: PSimpleBuf; len: integer);
 function  Fill_CS_Data(PLCPtr:PPLC_EtherIP_info;
                      Cmd_Type:Integer;PLCCmd:byte; var EthIPLen: Integer):Integer;

// function  PLCListen(PLCPtr: PPLC_EtherIP_info; SocketInfo:PMsgSocketInfo): String;
 function  PLCConnect(PLCPtr: PPLC_EtherIP_info): String;
 function  senddata(buff: Pdata_buffer; ASocket: Integer):Integer;
 function  establish_connection(PLCPtr: PPLC_EtherIP_info; var error: string):Integer;
 function  sendRRdata(timeout: word; PLCPtr: PPLC_EtherIP_info;
		       head: PEtherIP_Hdr; buff: Pdata_buffer):Integer;
 function  getTNS: word;
 procedure BZeero(PLCPtr: PPLC_EtherIP_info; aBuffer, rBuffer:array of byte);
 function  GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
 function  Fill_CS_Address(PLCPtr: PPLC_EtherIP_info; CSAddress_Type: word;
                        Address:String; var EthIPLen: Integer):Integer;
                        
 function  fillBuffer(PLCPtr: PPLC_EtherIP_info; var aBuffer:array of byte;DtLen: Integer): Integer; //len
 function  getCommand(rBuffer: array of byte): word;
 function  emptyBuffer(PLCPtr: PPLC_EtherIP_info; var rBuffer:array of byte): PCCCReply;
 function  register_session(PLCPtr:PPLC_EtherIP_info):Integer;
 function  unregister_session(PLCPtr:PPLC_EtherIP_info): Integer;
 procedure RandContext(Plc:PPLC_EtherIP_info);
 function  RandID:conID;
 function  ProtFileOpen(PLCPtr:PPLC_EtherIP_info;FileNo: word;FileType: byte):PCCCReply;
 function  ProtFileClose(PLCPtr:PPLC_EtherIP_info):PCCCReply;
 function  ProtFileRead(PLCPtr:PPLC_EtherIP_info; size: byte;fOffset: word):PCCCReply;
 function  ProtFileWrite(PLCPtr:PPLC_EtherIP_info; size: byte;fOffset: word;
                        PDataBuf:PSimpleBuf):PCCCReply;

 function  ProtectedRead(PLCPtr:PPLC_EtherIP_info; size: byte;
                       PLCFile: String):PCCCReply;

 function  ProtectedWrite(PLCPtr:PPLC_EtherIP_info; size:byte;PLCFile: String;
                        PSimpleData:PSimpleBuf):PCCCReply;

 function CIFRead(PLCPtr:PPLC_EtherIP_info; size: byte;
                           PLC_Address: word):PCCCReply;

 function CIFWrite(PLCPtr:PPLC_EtherIP_info; size: byte;
                           PLC_Address: word;
                           PSimpleData:PSimpleBuf):PCCCReply;

 function  CommConnect(PLCPtr:PPLC_EtherIP_info): String;
 procedure CommDisCon(PLCPtr:PPLC_EtherIP_info);
 function getStatus(PLCPtr:PPLC_EtherIP_info):PCCCReply;
 //function  getIPs(IPS: Tstrings): String;
implementation
 {$R-} {$RANGECHECKS OFF}
 const ByteSize: array[0..10] of byte = (0,0,0,$14,$48,$06,0,$3C,$04,0,0);

var
  TnsValue: Word;
  WSAStarted: Boolean;
  NetworkConID:Array[0..3] of byte;

function IntIPfromAddr(IPAddrList: String; Len: Integer): Integer;
begin
    if Len<=0 then
      result:=0
    else
      result:=16777216*ord(IPAddrList[1])+65536*ord(IPAddrList[2])+256*ord(IPAddrList[3])+ord(IPAddrList[4]);
end;

function StrIPfromAddr(IPAddrList: String; Len: Integer): String;
var
  IDX: Integer;
begin
   IDX:=1;
   result:='';
   while IDX<Len do
     begin
       result:=result+IntToStr(ord(IPAddrList[IDX]))+'.';
       inc(IDX);
     end;
   result:=result+IntToStr(ord(IPAddrList[IDX]));
end;

procedure RandContext(Plc :PPLC_EtherIP_info);
begin
  Plc^.EIP_context[0] := trunc(Random(127));
  Plc^.EIP_context[1] := trunc(Random(127));
  Plc^.EIP_context[2] := trunc(Random(127));
  Plc^.EIP_context[3] := trunc(Random(127));
  Plc^.EIP_context[4] := trunc(Random(127));
  Plc^.EIP_context[5] := trunc(Random(127));
  Plc^.EIP_context[6] := trunc(Random(127));
  Plc^.EIP_context[7] := trunc(Random(127));
end;

function RandID:conID;
var
  I1: Integer;
begin
  I1:=trunc(Random(65536));
  result[0]:=I1 and $000F;
  result[1]:=I1 and $00F0;
  result[2]:=I1 and $0F00;
  result[3]:=I1 and $F000;
end;


function examineError(Err: Integer): String;
begin
   case Err of
     WSANOTINITIALISED:
        result := 'No WSAStartup';
     WSAENETDOWN:
        result := 'Network Sub System Failure';
     WSAEADDRINUSE:
        result := 'Address already in use';
     WSAEINTR:
        result := 'Blocking call was canceled';
     WSAEINPROGRESS:
        result := 'Already in progress';
     WSAEALREADY:
        result := 'A Blocking connect call is in progress';
     WSAEADDRNOTAVAIL:
        result := 'The address is not available';
     WSAEAFNOSUPPORT:
        result := 'Addresses in the specified family can not be used with this socket';
     WSAECONNREFUSED:
        result := 'The connection attempt was forcefully rejected';
     WSAEFAULT:
        result := 'Name or Name Len argument is wrong';
     WSAEINVAL:
        result := 'Socket may be a listening socket';
     WSAEISCONN:
        result := 'The socket is already connected';
     WSAENETUNREACH:
        result := 'The network is unreachable';
     WSAENOBUFS:
        result := ' No Buffer space is available';
     WSAENOTSOCK:
        result := 'The socket descriptor is not a socket';
     WSAETIMEDOUT:
        result := ' Time out waiting for connection';
     WSAEWOULDBLOCK:
        result := ' Connection can not be completed on non blocking socket';
     WSAEACCES:
         result := ' Broadcast attempted but option not selected';
     else
        result := ' Unknown connection error';
     end;
end;

function _Connect(PLCPtr:PPLC_EtherIP_info):String;   //Send a header - receive a header
type
  Name = array[0..100] of Char;
  PName = ^Name;
var
  hostInfo: pHostEnt;
  InAddr: in_addr;
  address: TSockAddrIn;
  header, rcvd: ethernet_header;
  custom: custom_connect;
  WSAData: TWSAData;
  len, place, response_len: Integer;
  WSAERR: String;
  BPtr: PAnsiChar;
  IDX: Integer;

  HostNme: String;
  ERROR: Integer;
begin
 result:='ERROR';
 PLCPtr^.connected:=NOCON;
                                             //At least Version 1 Rev 1
 if WSAStartup($0101, WSAData) <> 0 then    //initialize Winsock library
    begin
      WSAErr := 'Winsock is not responding."';
      Exit;
    end;

    error:=0;
    HostNme:=PLCPtr.PLCHostIP;   //PLC IP address
    {  in_addr = record
    case Integer of
      0: (S_un_b: SunB);
      1: (S_un_c: SunC);
      2: (S_un_w: SunW);
      3: (S_addr: u_long);}

 { type
   sockaddr_in = record
    sin_family: Smallint;
    sin_port: u_short;
    sin_addr: in_addr;
    sin_zero: array [0..7] of a_char;
  end;  }

  // create a socket - windows api function
  // success returns a socket hande
  PLCPtr^.sock_handle := socket(AF_INET, SOCK_STREAM, 0);
  if (PLCPtr^.sock_handle = -1) then       //Socket function failure
    begin
      //ShowMessage('attach_socket error');
    	error:=NOCONNECT;
      exit;
    end;
  InAddr.S_addr := inet_addr(PAnsiChar(AnsiString(PLCPtr.PLCHostIP)));
  address.sin_family := AF_INET;       //family
  address.sin_addr  := InAddr;

  if (address.sin_addr.s_addr = 0) then
    begin
      error:=BADADDR;
      exit;
    end;
  address.sin_port := htons(PLCPtr^.PLCHostPort);
//   address.sin_port := htons(2222);
  len := sizeof(address);
 // connect to an IP address - windows API
 //syn, syn/ack, ack  - computer - plc - computer
  IDX:= connect(PLCPtr^.sock_handle, address, len);
  if  IDX <0 then
    begin
      ERROR:=WSAGetLastError;
      examineError(ERROR);
      //CommDisCon(PLCPtr);  DDW
    	error:=NOCONNECT;
      exit;
    end;
   error:=OK;
   place:=0;
   bzero(Addr(custom), sizeof(custom_connect));
   bzero(Addr(rcvd), sizeof(ethernet_header));
   bzero(Addr(header), sizeof(ethernet_header));
   header.mode := 1;
   header.submode := CONNECT_CMD;
   header.conn := 0;
   header.pccc_length := 0;
   custom.version := htons(PCCC_VERSION);
   custom.backlog := htons(PCCC_BACKLOG);
   StructToByteArray(header.custom,Addr(custom),_CUSTOM_LEN,0);
   //psh/ack - psh/ack computer - plc
   send(PLCPtr^.sock_handle, header, _ENET_HEADER_LEN,0);
   response_len := recv(PLCPtr^.sock_handle, rcvd, 255, 0);

    if (response_len <20) then
	    begin
	      error:=NOCONNECT;
        exit;
	    end;
  // PLCPtr^.PLCHostPort:=address.sin_port;
   PLCPtr^.Error:=error;
   PLCPtr^.connected:=CON;
   result:='OK';
 end;


procedure insertByte(PLCPtr:PPLC_EtherIP_info;
                      PLCCmd: Byte;offset: integer;var total: integer);

begin
  With PLCPtr^.PCIP.PData do
    begin
      ItemData[DataLen-offset]:=PLCCmd; //insert a one byte command
      DataLen:=DataLen+1;  //increment the data buffer length
    end;
  PLCPtr^.CIP_Len:=PLCPtr^.CIP_Len+1;   //increment the CIP length
  total:=total+1;
end;

function getTNS: word;
begin
  inc(TNSValue);
  result:=TNSValue;
end;

function ProtFileOpen(PLCPtr:PPLC_EtherIP_info;FileNo: word;FileType: byte):PCCCReply;
const
  IPADDUNPROT='';
var
   IDX,offset: Integer;
   AddDataLen,DataDataLen,RbuffLen: Integer;
   FileLo,FileHi: Byte;
   TagLo,TagHi: Byte;
   ETH_IPLen: Integer;
   aBuffer, rBuffer: array[0..255] of byte;
begin

   Word2Net(FileNo,FileLo,FileHi);

   ETH_IPLen:=32;
   BZero(@aBuffer,sizeOf(aBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData,CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData,CIPDATALEN);
   AddDataLen:=Fill_CS_Address(PLCPtr,RRADDTYPE,IPADDUNPROT,ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr,UNPROTECTED,OPEN_CMD,ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;

   with PLCPtr^ do
     begin
       EIP_Command := EIP_SendRRData;
       PCIP.ItemCnt:=2;
       CIP_Len:=AddDataLen+DataDataLen+16;
//       PCIP.PData.cmd:= UWRITE_CMD;
     end;


  insertByte(PLCPtr, OPEN_FNC, offset,ETH_IPLen);
  insertByte(PLCPtr, READ_WRITE, offset,ETH_IPLen);
  insertByte(PLCPtr, FileLo, offset, ETH_IPLen);
  insertByte(PLCPtr, FileHi, offset, ETH_IPLen);
  insertByte(PLCPtr, FileType, offset, ETH_IPLen);
  IDX:=StructToByteArray(aBuffer, PLCPtr, 24, 0);
  IDX:=StructToByteArray(aBuffer, @PLCPtr.PCIP, 8, IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer, @PLCPtr.PCIP.PAddress, PLCPtr^.PCIP.PAddress.DataLen+4, IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer, @PLCPtr.PCIP.PData, PLCPtr^.PCIP.PData.DataLen+4, IDX);
  send(PLCPtr^.Sock_handle, aBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  Result:=emptyBuffer(PLCPtr, rBuffer);
  if result.answer[1] = OK then
    begin
      TagLo:=result.answer[4];
      TagHi:=result.answer[5];
      PLCPtr^.tag:= Net2Word(TagLo, TagHi);
    end
  else
    PLCPtr^.tag:=0;
 end;



function getStatus(PLCPtr:PPLC_EtherIP_info):PCCCReply;
var
   Ln: Integer;
   aBuffer, rBuffer: array[0..255] of byte;
   AddDataLen,DataDataLen, RbuffLen: Integer;
  // PtrInfo:PPLC_EtherIP_info;
   Offset: Integer;
   //PtrPComm: PComm;
   IPAdd: String;
   ETH_IPLen: Integer;
begin
  ETH_IPLen:=0;
 // PtrInfo:=PlcList[PlcNo];
  BZero(@aBuffer,sizeOf(aBuffer));
  BZero(@PLCPtr^.PCIP.PAddress.ItemData, CIPADDLEN);
  BZero(@PLCPtr^.PCIP.PData.ItemData, CIPDATALEN);
  IPAdd:=PLCPtr^.PLChostIP;
  AddDataLen:=Fill_CS_Address(PLCPtr, STATTYPE,IPAdd, ETH_IPLen);
  DataDataLen:=Fill_CS_Data(PLCPtr, FLSTATUS, FLSTATUS, ETH_IPLen);   //Length of data to eventually include in buff
  offset:=DataDataLen;
  with PLCPtr^ do
    begin
      EIP_Command := EIP_SendRRData;
      PCIP.ItemCnt:=2;
      CIP_Len:=AddDataLen+DataDataLen+16;
     // PCIP.PData.cmd:= FLSTATUS;
    end;
  insertByte(PLCPtr,DIAGNOSTIC,offset,ETH_IPLen);
  Ln:=fillBuffer(PLCPtr, aBuffer,0);
  send(PLCPtr^.Sock_handle, aBuffer, Ln,0);

  RbuffLen := recv(PLCPtr^.sock_handle, Rbuffer, SizeOf(Rbuffer), 0);
  Result:=emptyBuffer(PLCPtr, RBuffer);
end;

function ProtFileRead(PLCPtr:PPLC_EtherIP_info; size: byte;fOffset: word):PCCCReply;
const
  IPADDUNPROT='';
var
   IDX,offset: Integer;
   AddDataLen,DataDataLen, RbuffLen: Integer;
   offsetLo,offsetHi: Byte;
   tagLo,tagHi, fileType: Byte;
   Tag: word;
   ETH_IPLen: Integer;
   rBuffer: array[0..255] of byte;
begin
   ETH_IPLen:=32;
   Tag:=PLCPtr^.tag;
   fileType:=PLCPtr^.fType;

   Word2Net(Tag,TagLo,TagHi);
   Word2Net(fOffset,offsetLo,offsetHi);

   BZero(@rBuffer, sizeOf(rBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData, CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData, CIPDATALEN);
   AddDataLen:=Fill_CS_Address(PLCPtr, RRADDTYPE, IPADDUNPROT, ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr, UNPROTECTED, OPEN_CMD, ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;

   with PLCPtr^ do
     begin
       EIP_Command := EIP_SendRRData;
       PCIP.ItemCnt:=2;
       CIP_Len:=AddDataLen+DataDataLen+16;
//       PCIP.PData.cmd:= UWRITE_CMD;
     end;
  insertByte(PLCPtr, PREAD_FILE_FNC, offset, ETH_IPLen);
  insertByte(PLCPtr, size, offset, ETH_IPLen);
  insertByte(PLCPtr, tagLo, offset, ETH_IPLen);
  insertByte(PLCPtr, tagHi, offset, ETH_IPLen);
  insertByte(PLCPtr, offsetLo, offset, ETH_IPLen);
  insertByte(PLCPtr, offsetHi, offset, ETH_IPLen);
  insertByte(PLCPtr, fileType, offset, ETH_IPLen);
  PLCPtr^.PCIP.PData.DataLen:= PLCPtr^.PCIP.PData.DataLen; // add data count
  IDX:=StructToByteArray(rBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(rBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(rBuffer, @PLCPtr.PCIP.PAddress, PLCPtr^.PCIP.PAddress.DataLen+4, IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(rBuffer, @PLCPtr.PCIP.PData, PLCPtr^.PCIP.PData.DataLen+4, IDX);
  send(PLCPtr^.Sock_handle, rBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  Result:=emptyBuffer(PLCPtr, rBuffer);
end;

function ProtFileWrite(PLCPtr:PPLC_EtherIP_info; size: byte;fOffset: word;
                        PDataBuf:PSimpleBuf):PCCCReply;
const
  IPADDUNPROT='';
var
   IDX,offset: Integer;
   AddDataLen,DataDataLen,DataByteCnt,RbuffLen: Integer;
   offsetLo,offsetHi: Byte;
   Tag: word;
   tagLo,tagHi, fileType: Byte;
   ETH_IPLen: Integer;
   rBuffer: array[0..255] of byte;
begin
   ETH_IPLen:=32;
   dataByteCnt:=PDataBuf^.Cnt;
   Tag:=PLCPtr^.tag;
   fileType:=PLCPtr^.fType;

   Word2Net(Tag, TagLo, TagHi);
   Word2Net(fOffset, offsetLo, offsetHi);

   BZero(@rBuffer, sizeOf(rBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData, CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData, CIPDATALEN);
   AddDataLen:=Fill_CS_Address(PLCPtr, RRADDTYPE, IPADDUNPROT, ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr, UNPROTECTED, OPEN_CMD, ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;

   with PLCPtr^ do
     begin
       EIP_Command := EIP_SendRRData;
       PCIP.ItemCnt:=2;
       CIP_Len:=AddDataLen+DataDataLen+DataByteCnt+16;
//       PCIP.PData.cmd:= UWRITE_CMD;
     end;
  insertByte(PLCPtr,PWRITE_FILE_FNC,offset,ETH_IPLen);
  insertByte(PLCPtr,size,offset,ETH_IPLen);
  insertByte(PLCPtr,tagLo,offset,ETH_IPLen);
  insertByte(PLCPtr,tagHi,offset,ETH_IPLen);
  insertByte(PLCPtr,offsetLo,offset,ETH_IPLen);
  insertByte(PLCPtr,offsetHi,offset,ETH_IPLen);
  insertByte(PLCPtr,fileType,offset,ETH_IPLen);

  ETH_IPLen:=ETH_IPLen+dataByteCnt;
  PLCPtr^.PCIP.PData.DataLen:= PLCPtr^.PCIP.PData.DataLen+dataByteCnt; // add data count
  IDX:=StructToByteArray(rBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(rBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(rBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(rBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen-DataByteCnt+4,IDX);
   If DataByteCnt > 0 then
     IDX:=StructToByteArray(rBuffer,@PDataBuf.Data,DataByteCnt,IDX);
  send(PLCPtr^.Sock_handle, rbuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  Result:=emptyBuffer(PLCPtr,rBuffer);
end;

function ProtFileClose(PLCPtr:PPLC_EtherIP_info):PCCCReply;
const
  IPADDUNPROT='';
var
   IDX, offset: Integer;
   Tag: word;
   AddDataLen,DataDataLen,RbuffLen: Integer;
   TagLo,TagHi: Byte;
   ETH_IPLen: Integer;
   aBuffer, rBuffer: array[0..255] of byte;
begin
   ETH_IPLen:=32;
   Tag:=PLCPtr^.tag;
   Word2Net(Tag,TagLo,TagHi);
   BZero(@aBuffer,sizeOf(aBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData,CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData,CIPDATALEN);
   AddDataLen:=Fill_CS_Address(PLCPtr,RRADDTYPE,IPADDUNPROT,ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr,UNPROTECTED,CLOSE_CMD,ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;

   with PLCPtr^ do
     begin
       EIP_Command := EIP_SendRRData;
       PCIP.ItemCnt:=2;
       CIP_Len:=AddDataLen+DataDataLen+16;
//       PCIP.PData.cmd:= UWRITE_CMD;
     end;


  insertByte(PLCPtr,CLOSE_FNC,offset,ETH_IPLen);
  insertByte(PLCPtr,TagLo,offset,ETH_IPLen);
  insertByte(PLCPtr,TagHi,offset,ETH_IPLen);
  IDX:=StructToByteArray(aBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen+4,IDX);
  send(PLCPtr^.Sock_handle, aBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  PLCPtr^.tag:=0;
  Result:=emptyBuffer(PLCPtr,rBuffer);
end;

function ProtectedRead(PLCPtr:PPLC_EtherIP_info; size: byte;
                       PLCFile: String):PCCCReply;
const
  IPREAD='' ;
var
   IDX, offset: Integer;
   AddDataLen,DataDataLen, RbuffLen: Integer;
   PLCFileData: FileData;
   ETH_IPLen: Integer;
   aBuffer, rBuffer: array[0..255] of byte;
begin
   ETH_IPLen:=32;
   BZero(@aBuffer,sizeOf(aBuffer));
   BZero(@rBuffer,sizeOf(rBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData,CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData,CIPDATALEN);

   AddDataLen:=Fill_CS_Address(PLCPtr,RRADDTYPE,IPREAD,ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr,PROT_TYPED,PREAD_CMD,ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;


  PLCFileData := StrToFileData(PLCFile);
  if (PLCFileData.element > 254) then
    begin
      //we are not considering >254 which adds a n xtra byte
      ShowMessage('We are not handling elements > than 254');
      exit;
    end;
  insertByte(PLCPtr,PRead_FNC,offset,ETH_IPLen);
  insertByte(PLCPtr,size,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData._file,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData._type,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData.element,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData.subElement,offset,ETH_IPLen);
  ETH_IPLen:=ETH_IPLen;
  with PLCPtr^ do
    begin
      EIP_Command := EIP_SendRRData;
      PCIP.ItemCnt:=2;
      CIP_Len:=ETH_IPLen-24;  //account for length of data buffer
    end;
  IDX:=StructToByteArray(aBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen+4,IDX);
  send(PLCPtr^.Sock_handle, aBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  Result:=emptyBuffer(PLCPtr,rBuffer);
end;

function ProtectedWrite(PLCPtr:PPLC_EtherIP_info; size:byte;PLCFile: String;
                        PSimpleData:PSimpleBuf):PCCCReply;
const
  IPWRITE='';
var
   offset, IDX: Integer;
   AddDataLen,DataDataLen, RbuffLen: Integer;
   //PtrInfo: PPLC_EtherIP_info;
   PLCFileData: FileData;
   dataByteCnt: byte;
   ETH_IPLen: Integer;
   aBuffer, rBuffer: array[0..255] of byte;
begin
   ETH_IPLen:=32;
   dataByteCnt:=PSimpleData^.Cnt;

   dataByteCnt:=PSimpleData^.Cnt;
   //PtrInfo:=PLCList[PlcNo];
   BZero(@aBuffer,sizeOf(aBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData,CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData,CIPDATALEN);

   AddDataLen:=Fill_CS_Address(PLCPtr,RRADDTYPE,IPWRITE,ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr,PROT_TYPED,PWRITE_CMD,ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;


  PLCFileData := StrToFileData(PLCFile);
  if (PLCFileData.element > 254) then
    begin
      //we are not considering >254 which adds a n xtra byte
      ShowMessage('We are not handling elements > than 254');
      exit;
    end;
  insertByte(PLCPtr,PWrite_FNC,offset,ETH_IPLen);
  insertByte(PLCPtr,size,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData._file,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData._type,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData.element,offset,ETH_IPLen);
  insertByte(PLCPtr,PLCFileData.subElement,offset,ETH_IPLen);
  ETH_IPLen:=ETH_IPLen+dataByteCnt;
  PLCPtr^.PCIP.PData.DataLen:= PLCPtr^.PCIP.PData.DataLen+dataByteCnt; // add data count
  with PLCPtr^ do
    begin
      EIP_Command := EIP_SendRRData;
      PCIP.ItemCnt:=2;
      CIP_Len:=ETH_IPLen-24;  //account for length of data buffer
    end;
  IDX:=StructToByteArray(aBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen-DataByteCnt+4,IDX);
  If DataByteCnt > 0 then
     IDX:=StructToByteArray(aBuffer,@PSimpleData.Data,DataByteCnt,IDX);
  send(PLCPtr^.Sock_handle, aBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  Result:=emptyBuffer(PLCPtr,rBuffer);
end;

function CIFWrite(PLCPtr:PPLC_EtherIP_info; size: byte; PLC_Address: word;
                          PSimpleData:PSimpleBuf):PCCCReply;
const
  IPADDUNPROT='';
var
   IDX,offset: Integer;
   AddDataLen,DataDataLen, RbuffLen: Integer;
  // PLCPtr: PPLC_EtherIP_info;
   bytes, LowByte, HighByte: byte;
   ETH_IPLen, dataByteCnt: Integer;
   aBuffer, rBuffer: array[0..255] of byte;
begin
   ETH_IPLen:=32;
   dataByteCnt:=PSimpleData^.Cnt;

   BZero(@aBuffer,sizeOf(aBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData,CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData,CIPDATALEN);
   Word2Net(PLC_Address,LowByte, HighByte);
   bytes:=PSimpleData.Cnt;

   AddDataLen:=Fill_CS_Address(PLCPtr,RRADDTYPE,IPADDUNPROT,ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr,UNPROTECTED,UWRITE_CMD,ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;

   insertByte(PLCPtr,LowByte,offset,ETH_IPLen);
   insertByte(PLCPtr,HighByte,offset,ETH_IPLen);

   ETH_IPLen:=ETH_IPLen+dataByteCnt;
   PLCPtr^.PCIP.PData.DataLen:= PLCPtr^.PCIP.PData.DataLen+dataByteCnt; // add data count

   with PLCPtr^ do
     begin
       EIP_Command := EIP_SendRRData;
       PCIP.ItemCnt:=2;
       CIP_Len:=ETH_IPLen-24;  //account for length of data buffer
       EIP_Command := EIP_SendRRData;
     end;

  IDX:=StructToByteArray(aBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen-DataByteCnt+4,IDX);
  If DataByteCnt > 0 then
     IDX:=StructToByteArray(aBuffer,@PSimpleData.Data,DataByteCnt,IDX);

  send(PLCPtr^.Sock_handle, aBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  Result:=emptyBuffer(PLCPtr,rBuffer);
end;

function CIFRead(PLCPtr:PPLC_EtherIP_info; size: byte;
                           PLC_Address: word):PCCCReply;
const
  IPADDUNPROT='';
var
   offset, IDX: Integer;
   AddDataLen,DataDataLen, RbuffLen: Integer;
  // PLCPtr: PPLC_EtherIP_info;
   ETH_IPLen: Integer;
   LowByte, HighByte: byte;
   aBuffer, rBuffer: array[0..255] of byte;
   Error: Integer;
   ErrorMsg: String;
begin
  // SockHndl :=Integer(@PLCPtr^.sock_handle);
   ETH_IPLen:=32;
   BZero(@aBuffer,sizeOf(aBuffer));
   BZero(@PLCPtr^.PCIP.PAddress.ItemData,CIPADDLEN);
   BZero(@PLCPtr^.PCIP.PData.ItemData,CIPDATALEN);
   Word2Net(PLC_Address,LowByte, HighByte);

   AddDataLen:=Fill_CS_Address(PLCPtr,RRADDTYPE,IPADDUNPROT,ETH_IPLen);
   DataDataLen:=Fill_CS_Data(PLCPtr,UNPROTECTED,UREAD_CMD,ETH_IPLen);   //Length of data to eventually include in buff
   offset:=DataDataLen;
   with PLCPtr^ do
    begin
      EIP_Command := EIP_SendRRData;
      PCIP.ItemCnt:=2;
      CIP_Len:=ETH_IPLen-24;  //account for length of data buffer
    end;

  insertByte(PLCPtr,LowByte,offset,ETH_IPLen);
  insertByte(PLCPtr,HighByte,offset,ETH_IPLen);
  insertByte(PLCPtr,Size,offset,ETH_IPLen);
  //insertByte(PLCPtr,size,offset,ETH_IPLen);
  IDX:=StructToByteArray(aBuffer,PLCPtr,24,0);
  IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP,8,IDX);
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen+4,IDX);
  send(PLCPtr^.Sock_handle, aBuffer, IDX,0);
  RbuffLen := recv(PLCPtr^.sock_handle, rBuffer, SizeOf(rBuffer), 0);
  if RBuffLen = SOCKET_ERROR then
    begin
     Error := WSAGetLastError();
     ErrorMsg :=  examineError(Error);
     ShowMessage(ErrorMsg);
    end;
  if RBuffLen > 0 then
     result := emptyBuffer(PLCPtr,rBuffer)
end;

{function UnProtectedRead(PLCPtr:PPLC_EtherIP_info; addr: word;Count: Integer):Integer;
var
  IDX: Integer;
  LoVal, HiVal: byte;
begin   }
 { PCCC.PType:=UNPROTECTED;
  PCCC.cmd :=UREAD_CMD;
  PCCC.sts:=$00;
  PCCC.tns:=getTNS;
  PCCC.ADDR:=addr;
  PCCC.size:=Count;
  PCCC.DataSize:=7;
  result:=PCCC.DataSize; }
//end;

function senddata(buff: Pdata_buffer; ASocket: Integer):Integer;
begin
   result:=send(ASocket, buff.data, buff.overall_len,0);
  //  result:=send (comm.sock_handle, buff.data, 28,0);
end;


function readdata(pBuffer: Pdata_buffer; ASocket: Integer): Cardinal;
var
err: Integer;
  byte0,byte1,byte2,byte3: byte;
  Session: Cardinal; //Integer;
begin
  bzero(pBuffer, DATA_Buffer_Length);
  pBuffer.overall_len := recv(ASocket, pBuffer.data, DATA_Buffer_Length, 0);
 Err :=  WSAGetLastError();
  Byte0:=pBuffer.data[4];
  Byte1:=pBuffer.data[5];
  Byte2:=pBuffer.data[6];
  Byte3:=pBuffer.data[7];
  Session:=Net2Cardinal(Byte0,Byte1,Byte2,Byte3);
  if (pBuffer.overall_len < 1)  then
    begin
      result:=0;
      exit;
    end
  else
    result:=Session;
end;

//*************************************************
// Get a session handle from the PLC
//*************************************************
function register_session(PLCPtr:PPLC_EtherIP_info):integer;
var
  buff: Pdata_buffer;     //success = 0
  receive_buffer: Pdata_buffer;
  ret: Integer;
 begin
  RandContext(PLCPtr);
  PLCPtr^.CIP_Len :=4;
  new(buff);
  new(receive_buffer);


  bzero(buff, sizeof(_data_buffer));
  bzero(receive_buffer, sizeof(_data_buffer));

  //fill_header(comm, head, debug);
  PLCPtr^.EIP_Command := PLC_Register_Session;
  memcpy(@buff.data, PLCPtr, ETHIP_Header_Length);

  buff.data[ETHIP_Header_Length] := 1;	//* Protocol Version Number */
  buff.overall_len := ETHIP_Header_Length + 4;
  //session(req) - session(res) computer - plc returns a session
  ret := senddata(buff, PLCPtr^.sock_handle);
  result:=ret;
  if ret <> 0 then
    begin
      //get the session handle
      ret := readdata(receive_buffer, PLCPtr^.sock_handle);
      PLCPtr^.session_handle:=ret;
    end;
  if ret = CFALSE then
    begin
      dispose(buff);
      dispose(receive_buffer);
      exit;
    end;
 // bzero(PLCPtr, ETHIP_Header_Length);
//  memcpy(PLCPtr, @receive_buffer.data, ETHIP_Header_Length);
  dispose(buff);
  dispose(receive_buffer);
end;

function unregister_session(PLCPtr:PPLC_EtherIP_info):Integer;
 var
  buff: Pdata_buffer;     //success = 0
  receive_buffer: Pdata_buffer;
  ret: Integer;
  ASocket: Integer;
begin
  result:=0;
  new(buff);
  new(receive_buffer);

  bzero(buff, sizeof(_data_buffer));
  bzero(receive_buffer, sizeof(_data_buffer));
  PLCPtr^.EIP_Command := PLC_unRegister_Session;  //command 102 or $66
  PLCPtr^.CIP_Len:=0;
  memcpy(@buff.data, PLCPtr, ETHIP_Header_Length);


  buff.overall_len := ETHIP_Header_Length + PLCPtr^.CIP_Len;
  ASocket:= PLCPtr^.sock_handle;
  ret := senddata(buff, ASocket);
  if ret <> 0 then
    ret := readdata(receive_buffer, ASocket);

  if ret = CFALSE then
    begin
      dispose(buff);
      dispose(receive_buffer);
      result:=ret;
      exit;
    end;
  //memcpy(PLCPtr, @receive_buffer.data, ETHIP_Header_Length);
  dispose(buff);
  dispose(receive_buffer);
 end;



//*******************************************************
// Command specific data - data portion
//*******************************************************
function Fill_CS_Data(PLCPtr:PPLC_EtherIP_info;
                      Cmd_Type:Integer;PLCCmd:byte; var EthIPLen: Integer):Integer;
const
  MINLEN = 4; //size of CSItemType_ID + size of dataLen (Data_Item)
begin
  With PLCPtr^.PCIP.PData do   //len = size of sts+ size of cmd + size of TNS
    begin
      sts:=0;      //byte
      cmd:=PLCCmd;    //byte
      tns:=getTNS; //word
      DataLen:=4;   //word  don't count total 1 word + 2 bytes = 4 bytes
      case Cmd_Type of
        TYPED_LOGICAL:
          begin
            CSItemType_ID:=RRDATATYPE; //word  - don't count this
          end;
        PROT_TYPED:
          begin
            CSItemType_ID:=RRDATATYPE;
          end;
        UNPROTECTED:
          begin
            CSItemType_ID:=RRDATATYPE;
          end;
        FOPEN:
          begin
            CSItemType_ID:=RRDATATYPE;
          end;
        FCLOSE:
          begin
            CSItemType_ID:=RRDATATYPE;
          end;
        FLSTATUS:
          begin
            CSItemType_ID:=RRDATATYPE;
            cmd:=FLSTATUS;
           // fnc:=STATUS_FNC;
          end;
        end; //case
      EthIPLen:=EthIPLen+DataLen+MinLen;
      result:=DataLen;
    end;
end;

//*******************************************************
// Command specific data - address portion
//*******************************************************
function Fill_CS_Address(PLCPtr: PPLC_EtherIP_info; CSAddress_Type: word;
                        Address:String; var EthIPLen: Integer):Integer;
const
  MINLEN = 4;  //size of CSItemType_ID + size of dataLen (Address_Item)
var
  IDX,len: Integer;
begin
  With PLCPtr^.PCIP.PAddress do
    begin
      Len:=Length(Address);
      DataLen:=Len;
      CSItemType_ID:=CSAddress_Type;
      for IDX:=0 to Len-1 do
        ItemData[IDX]:=ord(Address[IDX+1]);
      if len mod 2 <> 0 then
        begin
          inc(len);
          ItemData[len]:=0;
        end
      else if len <= 0 then
        ItemData[0]:=1; //ddw
      DataLen :=Len+1;//:=1;// Len+1;    //DDW
   //   DataItem.ItemData:=PCCC;
    //  DataItem.DataLen:=PCCC.DataSize; //DDW
      EthIPLen:=EthIPLen+DataLen+MinLen;
      result:= DataLen;
    end;
end;


function PLCConnect(PLCPtr: PPLC_EtherIP_info): String;
var
  hostInfo: pHostEnt;
  address: TSockAddrIn;
  WSAData: TWSAData;
  results, len, IDX: Integer;
  BPtr: PAnsiChar;
begin
  PLCPtr.error:=OK;
  result:='No Errors';
  If not WSAStarted then
    if WSAStartup($0101, WSAData) <> 0 then
      begin
        PLCPtr.error := WINSOCKERROR;
        WSAStarted:=false;
        result:='WSA error';
        Exit;
      end;
  WSAStarted:=true;
  HostInfo:=getHostByName(PAnsiChar(PLCPtr^.PLCHostIP));
  if not assigned(hostinfo) then
    begin
      PLCPtr^.Error := NOHOST;
      result:='No Host';
      Exit;
    end;
  PLCPtr^.sock_handle := socket(AF_INET, SOCK_STREAM, 0);
  if (PLCPtr^.sock_handle = NOCONNECT) then
    begin
      PLCPtr^.error:=NOCONNECT;
      result:='Connect error';
      exit;
    end;
  PLCPtr^.PCIP.CipTimeout := CELL_DFLT_TIMEOUT;
  address.sin_family := AF_INET;       //family
  BPtr:=HostInfo.h_addr^;
  address.sin_addr.S_un_b.s_b1 := AnsiChar(BPtr^);
  inc(BPtr);
  address.sin_addr.S_un_b.s_b2 := AnsiChar(BPtr^);
  inc(BPtr);
  address.sin_addr.S_un_b.s_b3 := AnsiChar(BPtr^);
  inc(BPtr);
  address.sin_addr.S_un_b.s_b4 := AnsiChar(BPtr^);
  //address.sin_addr = *(struct in_addr *) *hostinfo->h_addr_list;
  if (address.sin_addr.s_addr = 0) then
    begin
      PLCPtr^.error:=BADADDR;
      result:='Bad address';
      exit;
    end;
  address.sin_port := htons(PLCPtr^.PLCHostPort); //$AF12
  results:=0;
  len := sizeof(address);
  IDX:= connect(PLCPtr^.sock_handle, address, len);
  if (results < 0) then
    begin
      PLCPtr^.error:=NOCONNECT;
      result:='Bad results';
      exit;
    end;
end;

function CommConnect(PLCPtr:PPLC_EtherIP_info):String;
var
  ERR: String;
begin
   ERR :=_Connect(PLCPtr);
   result:=ERR;
   if ERR = 'OK' then
     PLCPtr^.connected:=0
   else
     begin
       PLCPtr^.connected:=1;
       exit;
     end;
   register_Session(PLCPtr);
end;

procedure CommDisCon(PLCPtr:PPLC_EtherIP_info);
var
  PLCDst: Integer;
begin
  PLCDst:=Unregister_Session(PLCPtr);
  CloseSocket(PLCPtr^.sock_handle);
end;
function establish_connection(PLCPtr: PPLC_EtherIP_info; var error: string):Integer;
var
  res1: Integer;
begin
  PLCConnect(PLCPtr);
  res1:=PLCPtr.error;
  if (PLCPtr.error <> OK) then
    error:='Attached Failed'
  else
    begin
      error:='Attached';
      register_session(PLCPtr);
    end;
    result:=res1;

end;

function sendRRdata(timeout: word; PLCPtr: PPLC_EtherIP_info;
		head: PEtherIP_Hdr; buff: Pdata_buffer):Integer;
begin
  result:=0;
  if (not assigned(head)) or (not assigned(buff)) then
    begin
      result:=-1;
      exit;
    end;
end;

function GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
type
  Name = array[0..100] of AnsiChar;
  PName = ^Name;
var
  HEnt: pHostEnt;   //A windows structure host and address info
  HName: PName;
  WSAData: TWSAData;
  i: Integer;
begin
  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then begin
    WSAErr := 'Winsock is not responding."';
    Exit;
  end;
  IPaddr := '';  //This computer host IP address
  New(HName);    //HName is the host name for this computer
  if GetHostName(HName^, SizeOf(Name)) = 0 then
  begin
    HostName := String(HName^);
    HEnt := GetHostByName(HName^);
    for i := 0 to HEnt^.h_length - 1 do
     IPaddr := Concat(IPaddr,      IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
    SetLength(IPaddr, Length(IPaddr) - 1);
   // ShowMEssage(IPaddr);
    Result := True;
  end
  else begin
   case WSAGetLastError of
    WSANOTINITIALISED:WSAErr:='WSANotInitialised';
    WSAENETDOWN      :WSAErr:='WSAENetDown';
    WSAEINPROGRESS   :WSAErr:='WSAEInProgress';
   end;
  end;
  Dispose(HName);
  WSACleanup;
end;
procedure BZeero(PLCPtr: PPLC_EtherIP_info; aBuffer, rBuffer:array of byte);
var
  Len: Integer;
begin
  Len:=SizeOf(PLCPtr^);
  bzero(PLCPtr,Len);
  bzero(@aBuffer, 256);
  bzero(@rBuffer, 256);
  {bzero(PEtherIP_Header, EIP_Header_Length);
  bzero(@buff, 256);
  bzero(@rBuffer, 256);
  bzero(_PCSData,SizeOf(Address_Item)+SizeOf(Data_Item)+2);
  bzero(PCCC, SizeOf(PCCC.data)+17);  }
end;
function  addBuffer(var aBuffer:array of byte;addBuf: PSimpleBuf;Len: Integer): integer;
var
  IDX: Integer;
begin
  With addBuf^ do
    begin
      for IDX := 0 to Cnt-1 do
        aBuffer[Len+IDX]:= Data[IDX];
    end;
  result:=Len+addBuf^.Cnt;
end;
function  fillBuffer(PLCPtr: PPLC_EtherIP_info; var aBuffer:array of byte;DtLen: Integer): Integer; //len
var
  IDX: Integer;
begin
 // APCCC:=PData.CSDataPtr.DataItem.ItemData;
  // Insert ethernet/IP data up to CIP
  IDX:=StructToByteArray(aBuffer,PLCPtr,24,0);
  // Insert CIP (00 00 00 00)  & TimeOut
  IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP,8,IDX);
  //Insert Address item
  if PLCPtr^.PCIP.ItemCnt > 0 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PAddress,PLCPtr^.PCIP.PAddress.DataLen+4,IDX);
 //Insert Data item
  if PLCPtr^.PCIP.ItemCnt > 1 then
    IDX:=StructToByteArray(aBuffer,@PLCPtr.PCIP.PData,PLCPtr^.PCIP.PData.DataLen+4,IDX);
  result:=IDX;
end;

procedure RegisterReply(Socket:TCustomWinSocket	;PBuf: PSimpleBuf; len: integer);
 var
   SessionHandle: word;
 begin
   SessionHandle:=trunc(Random(65255));
   PBuf.data[4]:=SessionHandle and $F000;
   PBuf.data[5]:=SessionHandle and $0F00;
   PBuf.data[6]:=SessionHandle and $00F0;
   PBuf.data[7]:=SessionHandle and $000F;
   Socket.SendBuf(PBuf.data,len);
end;
procedure RRReply(Socket:TCustomWinSocket	;PBuf: PSimpleBuf; len: integer);
 var
   IDX, Cnt: Integer;
   PRBuf: PSimpleBuf;
begin
   try
     new(PRBuf);
     Cnt:=SizeOf(SimpleBuf);
     bzero(PRBuf,Cnt);
     PRBuf.data[0]:=$6F;
     PRBuf.data[1]:=$00;
     PRBuf.data[2]:=$2E;
     PRBuf.data[3]:=$00;
     for IDX:=4 to 27 do     //Through encaps header and IF handle
       PRBuf.data[IDX]:=PBuf.Data[IDX];
     PRBuf.Data[28]:=$1E;
     PRBuf.Data[29]:=$00;
     //Cnt:=30;
     for IDX:=30 to 37 do
        PRBuf.Data[IDX]:=PBuf.Data[IDX]; //Item cnt, typeID null, len, TypeID unconnected
     //Cnt:=38;
     PRBuf.Data[38]:=$1E;   //len
     PRBuf.Data[39]:=$00;
     //Cnt:=40;
     PRBuf.Data[40]:=$D4;   //Service
     PRBuf.Data[41]:=$00;   //Other junk
     PRBuf.Data[42]:=$00;
     PRBuf.Data[43]:=$00;
     //Cnt:=44;
     PRBuf.Data[44]:=$01;   //Service
     PRBuf.Data[45]:=$00;   //Other junk
     PRBuf.Data[46]:=$00;
     PRBuf.Data[47]:=$80;
     for IDX:=48 to 59 do
        PRBuf.Data[IDX]:=PBuf.Data[IDX+4];
     PRBuf.Data[60]:=$00;
     PRBuf.Data[61]:=$00;
     PRBuf.Data[62]:=$4C;
     PRBuf.Data[63]:=$00;
     PRBuf.Data[64]:=$00;
     PRBuf.Data[65]:=$00;
     PRBuf.Data[66]:=$4C;
     PRBuf.Data[67]:=$00;
     PRBuf.Data[68]:=$00;
     PRBuf.Data[69]:=$00;
     NetworkConID[0]:=PBuf.data[52];
     NetworkConID[1]:=PBuf.data[53];
     NetworkConID[2]:=PBuf.data[54];
     NetworkConID[3]:=PBuf.data[55];
     Socket.SendBuf(PRBuf.Data,70);
   finally
     dispose(PRBuf);
   end;    
end;
{
procedure UnitDataReply(Socket:TCustomWinSocket	;PBuf: PSimpleBuf; len: integer);
 var
   IDX, Cnt: Integer;
   PRBuf: PSimpleBuf;
   HiByte,LoByte: Byte;
begin
    If (PBuf.data[8]<>$00) or (PBuf.data[9]<>$00) then
       exit;
   try
     new(PRBuf);
     PRBuf.data[0]:=$70;
     PRBuf.data[1]:=$00;
     PRBuf.data[2]:=$26; //
     PRBuf.data[3]:=$00;
     for IDX:=4 to 27 do     //Through encaps header and IF handle
       PRBuf.data[IDX]:=PBuf.Data[IDX];
     PRBuf.Data[28]:=$00;   //Timeout
     PRBuf.Data[29]:=$00;
     Cnt:=30;
     for IDX:=30 to 35 do
        PRBuf.Data[IDX]:=PBuf.Data[IDX]; //Item cnt, Address typeID , len,
     PRBuf.data[36]:=NetworkConID[0];
     PRBuf.data[37]:=NetworkConID[1];
     PRBuf.data[38]:=NetworkConID[2];
     PRBuf.data[39]:=NetworkConID[3];
     PRBuf.Data[40]:=$B1;   //Connected address item
     PRBuf.Data[41]:=$00;
     Cnt:=40;
     PRBuf.Data[42]:=$12;   //Length
     PRBuf.Data[43]:=$00;
     PRBuf.Data[44]:=PBuf.Data[44];   //Sequence count
     PRBuf.Data[45]:=PBuf.Data[45];
     PRBuf.Data[46]:=$CC;   //Service request
     PRBuf.Data[47]:=$00;
     PRBuf.Data[48]:=$00;
     PRBuf.Data[49]:=$00;
   
     for IDX:=50 to 53 do
        PRBuf.Data[IDX]:=PBuf.Data[IDX+6];
     for IDX:=54 to 57 do
        PRBuf.Data[IDX]:=PBuf.Data[IDX-2];
     PRBuf.Data[58]:=$48;   //Who knows
     PRBuf.Data[59]:=$10;
     PRBuf.Data[60]:=PBuf.Data[62];   //Some kind of TNS
     PRBuf.Data[61]:=PBuf.Data[63];
    // for IDX:=12 to 18 do    //context
      // PRBuf.Data[IDX]:=$00;
     HiByte:=PBuf.Data[66];
     LoByte:=PBuf.Data[67];
     With Form1 do
       begin
         Edit1.Text:= IntToStr(Net2Word(HiByte, LoByte));
         HiByte:=PBuf.Data[68];
         LoByte:=PBuf.Data[69];
         Ed12.Text := IntToStr(Net2Word(HiByte, LoByte));
         HiByte:=PBuf.Data[70];
         LoByte:=PBuf.Data[71];
         Ed13.Text := IntToStr(Net2Word(HiByte, LoByte));
         HiByte:=PBuf.Data[72];
         LoByte:=PBuf.Data[73];
         Ed14.Text := IntToStr(Net2Word(HiByte, LoByte));
         HiByte:=PBuf.Data[74];
         LoByte:=PBuf.Data[75];
         Ed15.Text := IntToStr(Net2Word(HiByte, LoByte));
         HiByte:=PBuf.Data[76];
         LoByte:=PBuf.Data[77];
         Ed16.Text := IntToStr(Net2Word(HiByte, LoByte));
      end;
     Socket.SendBuf(PRBuf.Data,62);
   finally
     dispose(PRBuf);
   end;    
end;

 }
function getCommand(rBuffer: array of byte): word;
var
  IDX: Integer;
  PHead: EtherIP_Hdr;
begin
  IDX:=ByteArrayToStruct(@PHead,rBuffer,24,0);
  result:=rBuffer[1]*256+rBuffer[0];
end;
//************************************************************
// Record errors here
//************************************************************
function  emptyBuffer(PLCPtr: PPLC_EtherIP_info; var rBuffer: array of byte): PCCCReply; //len
var
  IDX,I: Integer;
  AItem: Address_Item;
  DItem: Data_Item;
  AnswerLen: Integer;
  PHead: EtherIP_Hdr; PData: EtherIP_data;
begin
  for IDX:=0 to 31 do
    result.answer[IDX]:=0;
  result.Error:=0;
  bzero(@AItem.ItemData,16);
  // Extract encapsulation header
  IDX:=ByteArrayToStruct(@PHead,rBuffer,24,0); //Cmd through options

  // Extract Encapsulation data.Handle & data.TimeOut
  IDX:=ByteArrayToStruct(@PData,rBuffer,6,IDX);
  // Extract CSData packet.ItemCount
  IDX:=ByteArrayToStruct(@PData.CSDataPtr,rBuffer,2,IDX);
  // Extract CSData packet.AddressItem.type and length = 4 bytes
  IDX:=ByteArrayToStruct(@AItem,rBuffer,4,IDX);
  // Extract CSData packet.AddressItem.Data
  IDX:=ByteArrayToStruct(@AItem.ItemData,rBuffer, AItem.DataLen,IDX);
   // Extract CSData packet.DataItem.type and length = 4 bytes
  IDX:=ByteArrayToStruct(@DItem,rBuffer,4,IDX);
  AnswerLen:=DItem.DataLen;
  result.len:=AnswerLen;
  // Extract data from PLC
  for I:=0 to AnswerLen-1 do
    result.answer[I]:=rBuffer[IDX+I];
  if (PHead.EIP_status <> 0) then
     result.Error:=STATUSERROR
  else if (PHead.session_handle <> PLCPtr^.session_handle) then
      result.error:= NOSESSIONMATCH
  else if contextCompare(PHead.Context, PLCPtr^.EIP_context, 8) <> 0  then
     result.Error:=NOCONTEXTMATCH
  else if addressCompare(AItem.ItemData, PLCPtr^.PCIP.PAddress.ItemData, 16) <> 0 then
    result.Error:=NOADDRESSMATCH;
  result.CIPError := Result.error;
  result.Status:= result.answer[1];
 end;

function  getPosInteger(S: String): Integer;
var
  IDX: Integer;
begin
  result:=-1;
  for IDX := 1 to Length(S) do
    if (S[IDX] < '0') or (S[IDX] > '9') then
      exit;
  result:=StrToInt(S);
end;
function toByte(S: ByteStr): Byte;
var
  IDX: Integer;
begin
  result:=0;
  for IDX := 3 downto 0 do
    if S[IDX+1] = '1' then
      result:=result+PwrTwo(3-IDX);
end;
function parseStatus(PCCC: PCCCReply;
           var Series,Revision,PLCName: String):Boolean;
var
  IDX: Integer;
  SerRev: byte;
begin
  result:=false;
  PLCName:='';
  With PCCC do
    if (error <> 0) or (answer[1]<> 0) then
      begin
        result := true;
        exit;
      end
    else
      begin
        SerRev:=answer[8];
        Series:=IntToStr(1+(SerRev and 240) SHR 4);
        Revision:=chr((SerRev and 15)+64);
        for IDX := 9 to 16 do
          PLCName:=PLCName+chr(Answer[IDX]);
      end;
end;
end.




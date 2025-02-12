unit UnitH;

interface
uses

Windows, Classes, WinSock2;

const
   PREFIX: array[0..15] of String = (' ', ' ', ' ', ' ', 'S',
          'B', 'T', 'C', 'R','N', 'F' ,'O', 'I', 'ST', 'A', 'D');
   MAXWORDS=24;
   MAXFILEARRAY = 120;
   MAXOFFSET=64;
   TYPED_LOGICAL=1;
   PROT_TYPED=2;
   UNPROTECTED=3;
   DIAGNOSTIC = 3;
   FOPEN=4;
   FCLOSE=5;
   FLSTATUS=6;
   CONNECT_CMD = 1;
   READ_ONLY = 1;
   READ_WRITE = 3;

   CELL_DFLT_TIMEOUT = 5000;
   STATTYPE=$85;
   RRADDTYPE=$81;
   RRDATATYPE=$91; //Who knows - undocumented
   PLCCOUNT=1;

   ADDRTYPESCOUNT = 26;
   DATA_Buffer_Length = 2024;
   CPH_Null = 0;

   SLC = 3;
   MICRO = 4;
   CTRUE = 0;
   CFALSE = 1;
  _ENET_HEADER_LEN = 28;
  _CUSTOM_LEN = 16;
  PCCC_VERSION = 4;
  PCCC_BACKLOG = 5;
 // Use one of the these values for the fnc, prot logical. Do not use any other
 // values; doing so may result in unpredictable results.
 //**********************************************
 // FILE TYPES
 //**********************************************
  FNC_STATUS  = $84;
  FNC_BIT     = $85;
  FNC_TIMER   = $86;
  FNC_COUNTER = $87;
  FNC_CONTROL = $88;
  FNC_INTEGER = $89;
  FNC_FLOAT   = $8A;
  FNC_OUTPUT  = $8B;
  FNC_INPUT   = $8C;
  FNC_STRING  = $8D;
  FNC_ASCII   = $8E;
  FNC_BCD     = $8F;


  ETHERNET = 1;
  CIPADDLEN = 15;
  CIPDATALEN=94;
  OK = 0;
  CON =1;
  NOCON =0;
  NOSESSIONMATCH = -1;
  NOCONTEXTMATCH = -2;
  NOADDRESSMATCH = -3;
  STATUSERROR = -9;
  NOHOST = -1;
  BADADDR = -2;
  NOCONNECT = -3;
  BADCMDRET = -1;
  WINSOCKERROR = -4;


  NOP = 0;

  List_Targets = 1;
  List_Services = 4;
  ListIdentity = $63;
  List_Interfaces = $64;
  PLC_Register_Session = $65;
  PLC_UnRegister_Session = $66;
  EIP_SendRRData = $6F;
  SendUnitData = $70;
  ETHIP_Header_Length = 24;
  DATA_MINLEN = 16;
  FwdOpen_Resp = $D4;


  //*****************************************
  // PCCC commands
  //*****************************************
  CLOSE_CMD  = $0F;
  CLOSE_FNC  = $82;
  OPEN_CMD   = $0F;
  OPEN_FNC   = $81;
  STATUS_FNC = $03;
  PWRITE_CMD = $0F;
  PREAD_CMD  = $0F;
  PWRITE_ANS = $4F;
  PREAD_ANS  = $4F;
  UWRITE_CMD = $08;
  UREAD_CMD  = $01;
  UWRITE_ANS = $48;
  UREAD_ANS  = $41;
  PWRITE_FNC = $AA;
  PREAD_FNC  = $A2;
  PREAD_FILE_FNC = $A7;
  PWRITE_FILE_FNC = $AF;

const CIPErrors: array[0..9] of String = ('None',
      'No Session Match',
      'No Context Match',
      'No Address Match',
      '?','?','?','?','?',
      'CIP status error');

const PCErrors: array[0..15] of String = ('Success',
      'PLC node out of buffer space',
      'PLC node does not ACK',
      'Duplicate token holder',
      'PLC port disconnected',
      'Time out waiting for response from PLC',
      'Duplicate PLC node detected',
      'PLC is offline',
      'Hardware fault',
      '?','?','?','?','?','?','?');

const PLCErrors: array[0..15] of String = ('Success',
      'Illegal command format',
      'Host will not communicate',
      'Remote node disconnected',
      'PLC hardware fault',
      'Addressing or rungs protected fault',
      'Command is protected',
      'PLC in program mode',
      'Compatibility or communication fault',
      'PLC cannot buffer command',
      'PLC waiting for ACK',
      'PLC in download mode',
      'Waiting for ACK',
      '?','?','?');

type
  TBytes = array[0..3] of byte;

type
  PSimpleBuf = ^SimpleBuf;
  SimpleBuf = record
    Cnt: Integer;
    data:array[0..MAXFILEARRAY*2] of byte;
end;

type
  FloatRecord = record
    HiWord: word;
    LoWord: word;
  end;

type
  PLCFileArray = array [0..MAXWORDS-1] of word;

type
  PLCFloatArray = array [0..MAXWORDS-1] of FloatRecord;
type
  PLCTimerArray = array[0..2] of word;

type
  PLCCounterArray = array[0..2] of word;

type
  FileArray = array[0..MAXFILEARRAY] of word;

type
  PServices = ^ _services;
  _services = packed record
    _type: word;
    _length: word;
    version: word;
    flags: word;
    name:array[0..15] of byte;
end;

type
  Float_Buffer = array[0..32] of byte;

type
  Pdata_buffer = ^_data_buffer;
  _data_buffer = packed record
     data:array[0..DATA_Buffer_Length-1] of byte;
     len: word;
     overall_len: word;
end;
{struct sockaddr_in
        short   sin_family;
        u_short sin_port;
        struct  in_addr sin_addr;
        char    sin_zero[8];
;}
//***********************************************************
// Ethernet/IP Encapsulation header - same for all commands *
//***********************************************************
 PEtherIP_Hdr = ^EtherIP_Hdr;
  EtherIP_Hdr = packed record
    EIP_Command: word;
    CIP_Len: word;
    session_handle: cardinal;
    EIP_status: cardinal;
    context: array[0..7] of byte;
    case Opt: boolean of
      true:  (Options: cardinal);
      false: (ProtoVersion:word;OptionFlags:word);
end;
//***********************************************************
// Forward Open parameters                                  *
//***********************************************************
 PFwdOpenParr = ^FwdOpenPar;
  FwdOpenPar = packed record
    OT_ConID: array[0..3] of byte;
    TO_ConID: array[0..3] of byte;
    OT_RPI:   array[0..3] of byte;
    TO_RPI:   array[0..3] of byte;
    ConnectSN:word;
end;

type
  PData500 = ^Data500;
  Data500 = record
  CmdSpecificHdr: array[0..8] of byte;
  SeqNo: word;
  Cmd: byte;
  NumBytes: Byte;
  FileNo: byte;
  FileType: byte;
  case FileData: integer of
    1: (floats: array[0..63] of dword);
    2: (words: array[0..127] of word);
    3: (bytes: array[0..255] of byte);
end;

type
  PCPF = ^CPF;   //for Slc500 message
  CPF = record
    Header:EtherIP_Hdr;
    IFaceHandle: dword;
    TimeOut: word;
    ItemCnt: word;
    AddrType: word;
    AddrLn: word;
    ConnectID: dword;
    DataType: word;
    DataLn: word;
    SeqCnt: word;
    CIPService: byte;
    ReqPathSize: byte;
    ReqPath: dword;
    DataSlc500: Data500;
end;

type
  PFwdOpenHdr = ^FwdOpenHdr;   //for Slc500 message
  FwdOpenHdr = packed record
    //Header:EtherIP_Hdr;
    IFaceHandle: dword;
    TimeOut: word;
    ItemCnt: word;
    AddrType: word;
    AddrLn: word;
    DataType: word;
    DataLn: word;
    CIPService: byte;
    ReqPathSize: byte;
    ReqPath: dword;
end;

type
  conID = array[0..3] of byte;

type
  PFwdOpenReq = ^FwdOpenReq;   //for Slc500 message
  FwdOpenReq = packed record
    Priority: byte;
    TOTicks: byte;
    OTConID: conID;
    TOConID: conID;
    ConSN: word;
    VendID: word;
    OriginSN: dword;
    Reserve0: byte;
    Reserve1: byte;
    Reserv2: byte;
    OT_RPI: conID;
    OT_ConParams: word;
    TO_RPI: conID;
    TO_ConParams: word;
    TransTrigger: byte;
    ConPathSize: byte;
    MsgRoutPath: dword;
end;

type
  PFwdOpenResp = ^FwdOpenResp;   //for Slc500 message
  FwdOpenResp = packed record
    unknown: word;
    OTConID: conID;
    TOConID: conID;
    ConSN: word;
    VendID: word;
    OriginSN: dword;
    OT_API: conID;
    TO_API: conID;
    TO_ConParams: word;
    reply: byte;
    reserved: byte;
end;

type
  PFwdOpenRequest = ^FwdOpenRequest;
  FwdOpenRequest = record
    IPHeader: EtherIP_Hdr;
    OpenHdr:FwdOpenHdr;
    OpenReq: FwdOpenReq;
end;

type
  PFwdOpenResponse = ^FwdOpenResponse;
  FwdOpenResponse = record
    IPHeader: EtherIP_Hdr;
    OpenHdr:FwdOpenHdr;
    OpenRes: FwdOpenResp;
end;

type
  PAddress_Item=^Address_Item;
  Address_Item = packed record
    CSItemType_ID: word;  //Init to CPH_Null = $0000
    DataLen: word;   //Init to 0
    ItemData: array[0..CIPADDLEN] of byte;
end;

type
  PCSD=^CSD; //command specific data
  CSD = packed record
    CMD: byte;
    Status: byte;
    TNS: word;
    func: byte;
    Size: byte;
    FileNo: byte;
    FileType: Byte;
    Element: byte;
    SubElement: byte;
    CSDData:array[0..CIPDATALEN] of byte;
end;

type
  PData_Item=^Data_Item;
  Data_Item = packed record
  CSItemType_ID: word; //usually $91
  DataLen: word;
  cmd: byte;
  sts: byte;
  tns: smallInt;
  ItemData: array[0..CIPDATALEN] of byte;
  //  fnc: byte;
   // FileNo: byte;
   // FileType: byte;
   // Cmdsize: byte; //sans data array size
  //  offset: word;
  //  Elem: byte;
  //  SubElem: Byte;
   // Addr: word;      //unique to unprotected file read N9 or N7 SLC & Micro?
   // tag: word;       //unique to protected typed file read/write
   // data: array[0..63] of byte;
end;

type PtrCIP = ^CIP;
  CIP = packed record
    CIPCmd: cardinal; //zero
    CipTimeOut: word;
    ItemCnt: word;
    PAddress: Address_Item;
    PData: Data_Item;
end;
{struct sockaddr_in {
        short   sin_family;
        u_short sin_port;
        struct  in_addr sin_addr;
        char    sin_zero[8];
}

type
  PMsgSocketInfo = ^MsgSocketInfo;
  MsgSocketInfo = packed record
    SockHandle: Integer;
    PCPort:     word;
    PLCPort:    word;
    SockAddr:   TSockAddrIn;
    SockError:  Integer;
    PCIP:       String;
    PLCIP:      String;
    tag:        Byte;
end;

type  //Keep this data for individual PLC connections   -  see CIP encapsulation packet header -
  PPLC_EtherIP_info = ^PLC_EtherIP_info;
  PLC_EtherIP_info = packed record
    EIP_Command: word;
    CIP_Len: word;
    session_handle: cardinal;
    EIP_status: cardinal;
    EIP_context: array[0..7] of byte;
    Options: cardinal;                   // tail of an encapsulation header
    PCIP: CIP;
    sock_handle: Integer;
    PLCHostIP: AnsiString;
    PLCHostPort: word;
    error: Integer;
    tag: byte;
    FType: byte;
    connected: byte;  //1 = connected;
 end;

 type
  PCSData=^ACSData;
  ACSData = packed record
    ItemCount: word;  //Init to $02
    AddItem: Address_Item;
    DataItem: Data_Item;
end;

type
  PEtherIP_data = ^EtherIP_data;
  EtherIP_data = packed record
    CIPHandle: cardinal; //initialize to 0
    TimeOut: word;       // init to 0 - applies to router
    CSDataPtr: PCSData;        //Pointer to a CSData record;
end;

type
  PPCCCReplyUn = ^PCCCReplyUn;
  PCCCReplyUn = record
    answer: array[0..127] of byte; //was 31 DDW
end;

type
  PPCCCReply = ^PCCCReply;
  PCCCReply = record
    len: word;
    error: Integer;
    CIPError: Integer;
    Status: Byte;
    answer: array[0..127] of byte; //was 31 DDW
end;

type
  ethernet_header = packed record
    mode: byte;
    submode: byte;
    pccc_length: word;
    conn: dword;
    status: dword;
    custom: array[0..15] of byte;
    df1_data1: array[0..245] of byte;
end;

type
  custom_connect = record
    version: SmallInt;
    backlog: SmallInt;
    junk: array[0..11] of byte;
end;

type
   PFileData = ^FileData;
   FileData = packed record
     section: Integer;
     _file: byte;
     element: byte;
     subelement: byte;
     _type: byte;
     typelen: Integer;
     bit: byte;
     len: Byte;
     floatdata: Byte;
     data: array[0..23] of Byte;
end;

implementation

procedure StructToByteArray(var ByteArray:array of byte; struct: Pointer; Len: Integer);
var
  IDX: Integer;
  BPtr: ^Byte;
begin
  BPtr:=struct;
  for IDX:= 0 to Len-1 do
    begin
      ByteArray[IDX]:=BPtr^;
      inc(BPtr);
    end;
end;

procedure ByteArrayToStruct(struct: Pointer; ByteArray:array of byte; Len: Integer);
var
  IDX: Integer;
  BPtr: ^Byte;
begin
  BPtr:=struct;
  for IDX:= 0 to Len-1 do
    begin
      BPtr^:=ByteArray[IDX];
      inc(BPtr);
    end;
end;



end.

ext
char *errors[] = {
	"No Error",
	"Illegal Command or Format",
	"Host has a problem and will not communicate",
	"Remote Node Host is missing, disconnected, or shutdown",
	"Host could not complete function due to hardware fault",
	"Addressing problem or memory protected rungs",
	"Function not allowed due to command protection selection",
	"Processor is in Program Mode",
	"Compatability mode file missing or communication zone problem",
	"Remote node cannot buffer command",
	"Wait ACK (1775-KA buffer full)",
	"Remote Node problem due to download",
	"Wait ACK (1775-KA buffer full)",
	"Not Used 1",
	"Not Used 2",
	"Extended error data received"};
char *plc_id[] = {
	"1785 - L40B (PLC5/40 ) ",
	"1785 - LT4  (PLC5/10 ) ",
	"1785 - L60B (PLC5/60 ) ",
	"1785 - L40L (PLC5/40L) ",
	"1785 - L60L (PLC5/60L) ",
	"1785 - L11B (PLC5/11 ) ",
	"1785 - L20B (PLC5/20 ) ",
	"1785 - L30B (PLC5/30 ) ",
	"1785 - L20E (PLC5/20E) ",
	"1785 - L40E (PLC5/40E) ",
	"1785 - L80B (PLC5/25 ) ",
	"1785 - L80E (PLC5/80E) ",
	"1785 - xxxx (SoftLogix PLC)"};
int id_count=17;
int plc_index[] = 	{0x15, 0x22, 0x23, 0x28, 0x29, 0x31, 0x32, 0x33,
			 0x4a, 0x4b, 0x55, 0x59, 0x7b};
char *ext_errors[] = {
	"No Error",
	"A field has an illegal value",
	"Less Levels specified in address than minimum for any address",
	"More Levels specified in address than system supports",
	"Symbol Not Found",
	"Symbol is of improper format",
	"Address doesn't point to something usable",
	"File is wrong size",
	"Can not complete request, situation has changed.",
	"Data or file is too large",
	"Transaction size plus word address is too large",
	"Access denied, improper privilege",
	"Condition can not be generated",
	"Condition already exists",
	"Command cannot be executed",
	"Histogram Overflow",
	"No access",
	"Illegal Data Type",
	"Invalid parameter or data type",
	"Address reference exists to deleted area",
	"Command execution failure for unknown reason",
	"Data Conversion error",
	"Scanner not able to communicate with 1771 rack adaptor",
	"Type Mismatch",
	"1771 module response was not valid",
	"Duplicated label",
	"Remote Rack fault",
	"Timeout",
	"Unknown error",
	"File is open, another node owns it",
	"Another node is program owner",
	"Reserved",
	"Reserved",
	"Data table element protection violation",
	"Temporary internal problem"};

char *datatypes[] = 	{"bit",
			"bit string",
			"byte string",
			"integer",
			"timer",
			"counter",
			"control",
			"IEEE floating point",
			"array (byte)",
			"not defined - 10",
			"not defined - 11",
			"not defined - 12",
			"Rung data",
			"not defined - 14",
			"address data",
			"BCD"};
char *addrtypes[] = 	{"O",	//Output
			"I",	//Input
			"S",	//Status
			"B",	//Binary
			"T",	//Timer
			"C",	//Counter
			"R",	//Control
			"N",	//Integer
			"F",	//Float
			"A",	//ASCII
			"D",	//BCD
			"BT",	//Block Transfer
			"L",	//Long Integer
			"MG",	//Message
			"PD",	//PID
			"SC",	// ??
			"ST",	//String
			"PN",	//PLC Name
			"RG",	//Rung
			"FO",	//Output Force Table
			"FI",	//Input Force Table
			"XA",	//Section 3 File
			"XB",	//Section 4 File
			"XC",	//Section 5 File
			"XD",	//Section 6 File
			"FF"};	// Force File Section



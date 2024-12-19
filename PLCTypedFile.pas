unit PLCTypedFile;

interface

uses
  SysUtils, Classes, ScktComp,types, ExtCtrls, PLCConnectClass,
  UnitUtil, UnitH, UnitFunctions, FileStrToData,BinDecConv;

const
  MAXWORDS=24;

const FileTypeArray:array[1..10] of Integer
      = (FNC_STATUS,FNC_BIT,FNC_TIMER,FNC_COUNTER,FNC_CONTROL,FNC_INTEGER,
         FNC_FLOAT,FNC_STRING,FNC_ASCII,FNC_BCD);

type
  TProtFileType = (tpStatus,tpBit,tpTimer,tpCounter,tpControl,
                   tpInteger,tpFloat,tpString,tpASCII,tpBCD);
type
  TPLCTypedFile = class(TPLCConnectClass)
    private
      { Private declarations }
     // fTimerDisCon: TTimer;
      fBytes:       Integer;
      fProtFileType:TProtFileType;
      fFileData:    PFileData;
      fOffset:      Integer;
      fOpen:        Boolean;
      fFileNo:      byte;
      fFileType:    byte;
      fFromFile:    PLCFileArray;
      fToFile:      PLCFileArray;
      fFromBit:     PLCFileArray;
      fToBit:       PLCFileArray;
      fFromFloat:   PLCFloatArray;
      fToFloat:     PLCFloatArray;
      fToCounter:   PLCCounterArray;
      fFromCounter: PLCCounterArray;
      fToTimer:     PLCTimerArray;
      fFromTimer:   PLCTimerArray;
      //fElement:     String;
      ferror:       String;
   { Private declarations }
  protected
    { Protected declarations }
   // procedure setElement(value: String);
    function  getFileTypeByte(Ch: Char):Byte;
    procedure SetFileType(Value: TProtFileType);
    procedure ClearArrays;
    procedure setOffset(Val: Integer);
  public
    { Public declarations }
  //  procedure   DisConTimer(Sender: TObject);
    property    FileTypeProp: byte read fFileType;
    property    Offset: Integer read foffset write setOffset;
    property    FileNo: Byte read fFileNo write fFileNo;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    //procedure   setInterval(Value: Cardinal);
    //function    getInterval:Cardinal;
    function    TypedFileWrite(nWords, Offset: word; FType: Char):boolean;
    function    TypedFileRead(nWords, Offset: word; FileType: Char): boolean;
    function    TypedFileWriteFloat(nWords, Offset: word):boolean;
    function    TypedFileReadFloat(nWords, Offset: word): boolean;
    procedure   PutFile(IDX: Integer; Value: word);
    function    getFile(IDX: Integer): word;
    procedure   PutBit(IDX: Integer; Value: word);
    function    GetBit(IDX: Integer): word;
    procedure   PutCounter(IDX: Integer; Value: word);
    function    GetCounter(IDX: Integer): word;
    procedure   PutTimer(IDX: Integer; Value: word);
    function    GetTimer(IDX: Integer): word;
    procedure   PutFloat(IDX: Integer; Value: single);
    function    GetFloat(IDX: Integer): single;
    function    FileOpen(Elem: String):Boolean;
    function    FileClose:Boolean;
    property    PRFileOpen: boolean read fOpen;    
  published
    { Published declarations }
  //  property Timeout: Cardinal read getInterval write setInterval;
    //property PLCElement: String read fElement write setElement;
    property FileType: TProtFileType read fProtFileType write SetFileType default tpInteger;
  end;

procedure Register;

implementation
       {$R TPLCTypedFile.dcr}
procedure Register;
begin
  RegisterComponents('PLCSockets', [TPLCTypedFile]);
end;

constructor TPLCTypedFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ClearArrays;
  fBytes:= 0;
  FileType:=tpInteger;
 // fTimerDisCon:=TTimer.Create(Self);
//  fTimerDisCon.Enabled:=false;
 // fTimerDisCon.OnTimer:=DisConTimer;
//  fTimerDisCon.Interval:=5000;
  new(fFileData);
  fBytes:= 0;
end;

destructor TPLCTypedFile.Destroy;
begin
 //   fTimerDisCon.destroy;
    dispose(fFileData);
    inherited;
end;

procedure TPLCTypedFile.setoffset(val: Integer);
begin
  if val <= MAXOFFSET then
    foffset:=val;
end;

procedure TPLCTypedFile.SetFileType(Value: TProtFileType);
var
  NumVal: Byte;
begin
  NumVal:=ord(Value)+1;
  if fProtFileType <> Value then
  begin
    fProtFileType := Value;
    fFileType:=FileTypeArray[NumVal];
    if NumVal <=7 then
      fFileNo:=NumVal+1
    else
      fFileNo:=NumVal+4;
  end;
end;       

procedure TPLCTypedFile.ClearArrays;
var
  IDX: Integer;
begin
   for IDX:=0 to MAXWORDS - 1 do        // MAXFILEARRAY = 120   MAXWORDS = 24
     begin                              // PLCFileArray = array [0..MAXWORDS-1] of word;
       ffromFile[IDX]:=0;                  // ffromFile is type PCLFileArray
       ftoFile[IDX]:=0;
     end;
end;

procedure TPLCTypedFile.PutFile(IDX: Integer; Value: word);
begin
  fToFile[IDX]:=value;
end;

function TPLCTypedFile.getFile(IDX: Integer): word;
begin
  result:=fFromFile[IDX];
end;

procedure TPLCTypedFile.PutFloat(IDX: Integer; Value: single);
begin
  fToFloat[IDX]:=FloatToBinary(value);
end;

function TPLCTypedFile.GetFloat(IDX: Integer): single;
begin
  result:=BinaryToFloat(fFromFloat[IDX]);
end;

procedure TPLCTypedFile.PutBit(IDX: Integer; Value: word);
begin
  fToBit[IDX]:=value;
end;

function TPLCTypedFile.GetBit(IDX: Integer): word;
begin
  result:=fFromBit[IDX]
end;

procedure TPLCTypedFile.PutCounter(IDX: Integer; Value: word);
begin
  fToCounter[IDX]:=value;
end;

function TPLCTypedFile.GetCounter(IDX: Integer): word;
begin
  result:=fFromCounter[IDX]
end;

procedure TPLCTypedFile.PutTimer(IDX: Integer; Value: word);
begin
  fToTimer[IDX]:=value;
end;

function TPLCTypedFile.GetTimer(IDX: Integer): word;
begin
  result:=fFromTimer[IDX]
end;

function TPLCTypedFile.getFileTypeByte(Ch: Char):Byte;
begin
      If Ch = 'S' then
        result:= FNC_STATUS
      else if Ch = 'B' then
        result := FNC_BIT
      else if Ch = 'T' then
        result :=  FNC_TIMER
      else if Ch = 'C' then
        result := FNC_COUNTER
      else if Ch = 'R' then
        result := FNC_CONTROL
      else if Ch = 'N' then
        result := FNC_INTEGER
      else if Ch = 'F' then
        result := FNC_FLOAT
      else if Ch = 'O' then
        result := FNC_OUTPUT
      else if Ch = 'I' then
        result := FNC_INPUT
      else if Ch = 'D' then
        result := FNC_BCD
      else if Ch = 'A' then
        result := FNC_ASCII
      else
        result:=0;
end;

function TPLCTypedFile.TypedFileRead(nWords, Offset: word; FileType: Char): boolean;
var
  size, HiByte, LoByte: byte;
  I,IDX,Ln: Integer;
  reply: PCCCReply;
begin
  result:=false;


  if not PRFileOpen then exit;
  TimeoutEnabled:=false;

  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  size:=nWords*2;
  EtherInfo.FType:=getFileTypeByte(FileType);
  reply:=ProtFileRead(EtherInfo,size,offset);
  if reply.Status <> 0 then
    begin
      result:=false;
      exit;
    end;
  I:=0;
  Ln:=(Reply.Len - 4) div 2;
  With Reply do
    for IDX := 0 to Ln -1 do
      begin
        HiByte:=answer[4+IDX*2];
        LoByte:=answer[5+IDX*2];
        If FileType = 'N' then
          fFromFile[I]:=net2Word(HiByte,LoByte)
        else if FileType = 'B' then
          fFromBit[I]:=net2Word(HiByte,LoByte)
        else if FileType = 'T' then
           fFromTimer[I]:=net2Word(HiByte,LoByte)
        else if FileType = 'C' then
           fFromCounter[I]:= net2Word(HiByte,LoByte);
        inc(I);
      end;
  result:=intToBool(Reply.Status);
 // FileClose;
  //TimeoutEnabled:=true;
end;

function TPLCTypedFile.TypedFileWrite(nWords, Offset: word; FType: Char):boolean;
var
  Reply: PCCCReply;
  Size,Cnt,IDX: Integer;
  HiByte, LoByte: Byte;
  PSimpleData: PSimpleBuf;
begin
  result:=false;
  if not PRFileOpen then exit;
  TimeoutEnabled:=false;
  new(PSimpleData);
  BZero(PSimpleData,MAXFILEARRAY*2);
   if (FType ='T') or (FType='C') then
    Cnt:=2
  else
    Cnt:=nWords;
  if Cnt > MAXWORDS then Cnt :=MAXWORDS;
  for IDX := 0 to Cnt  do
    try
      if FType = 'N' then
         Word2Net(fToFile[IDX], LoByte, HiByte)
      else if FType ='B' then
         Word2Net(fToBit[IDX], LoByte, HiByte)
      else if FType ='T' then
         Word2Net(fToTimer[IDX], LoByte, HiByte)
      else if FType ='C' then
         Word2Net(fToCounter[IDX], LoByte, HiByte);
      PSimpleData.data[2*IDX]   := LoByte;
      PSimpleData.data[2*IDX+1] := HiByte;
    except
      dispose(PSimpleData);
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  PSimpleData.Cnt:=Cnt*2;
  size:=PSimpleData.Cnt;

  reply:=ProtFileWrite(EtherInfo, size, Offset, PSimpleData);
 // ProtFileClose(EtherInfo);
  dispose(PSimpleData);
  result:=intToBool(Reply.Status);
 // FileClose;
 // TimeoutEnabled:=true;
end;

function TPLCTypedFile.TypedFileReadFloat(nWords, Offset: word): boolean;
var
  size, HiByte, LoByte: byte;
  LoWord, HiWord: Word;
  IDX,Len,Ln: Integer;
  reply: PCCCReply;
begin
  result:=false;
  if not PRFileOpen then exit;
  TimeoutEnabled:=false;

  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  size:=nWords*2;
  reply:=ProtFileRead(EtherInfo,size,offset);
  Len:=Reply.Len-4;  //CMD byte + Status byte + TNS word = 4 bytes
  Ln:=Len div 4;
  With Reply do
    for IDX := 0 to Ln do
      begin
        HiByte:=answer[4+IDX*4];
        LoByte:=answer[5+IDX*4];
        LoWord:=net2Word(HiByte, LoByte);
        HiByte:=answer[6+IDX*4];
        LoByte:=answer[7+IDX*4];
        HiWord:=net2Word(HiByte, LoByte);
        fFromFloat[IDX].LoWord:= LoWord;
        fFromFloat[IDX].HiWord:= HiWord;
      end;
  result:=intToBool(Reply.Status);

end;

function TPLCTypedFile.TypedFileWriteFloat(nWords, Offset: word):boolean;
var
  Reply: PCCCReply;
  Size,Cnt,IDX: Integer;
  HiByte, LoByte: Byte;
  PSimpleData: PSimpleBuf;
begin
  result:=false;
  if not PRFileOpen then exit;
  TimeoutEnabled:=false; 
  new(PSimpleData);
  BZero(PSimpleData, MAXFILEARRAY*2);
  Cnt:=nWords;
  if Cnt > MAXWORDS then Cnt := MAXWORDS;
  for IDX := 0 to Cnt -1 do
    try
      Word2Net(fToFloat[IDX].HiWord, LoByte, HiByte);
      PSimpleData.data[4*IDX]:=LoByte;
      PSimpleData.data[4*IDX+1]:=HiByte;
      Word2Net(fToFloat[IDX].LoWord, LoByte, HiByte);
      PSimpleData.data[4*IDX+2]:=LoByte;
      PSimpleData.data[4*IDX+3]:=HiByte;
    except
      dispose(PSimpleData);
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
    PSimpleData.Cnt:=Cnt*4;
    size := PSimpleData.Cnt;
    if not Connected then
    Connect;

    if not connected then
      begin
        result:=false;
        TimeoutEnabled:=true;
        exit;
      end;
  reply:=ProtFileWrite(EtherInfo, size, Offset, PSimpleData);
  dispose(PSimpleData);
  result:=intToBool(Reply.Status);
end;

{procedure TPLCTypedFile.setElement(value: String);
begin
   fElement:=value;
   fFileData^:=StrToFileData(Value);
end;  }

{function TPLCTypedFile.getInterval:Cardinal;
begin
  if TimeoutEnabled <> nil then
      result:=TimeoutEnabled.Interval
  else
      result:=0;

end;

procedure TPLCTypedFile.setInterval(Value: Cardinal);
begin
  if TimeoutEnabled <> nil then
    begin
      TimeoutEnabled.Interval := Value;
    end;
end; }

{procedure TPLCTypedFile.DisConTimer(Sender: TObject);
begin
  TimeoutEnabled := false;
  if connected then DisConnect;
end;  }

function TPLCTypedFile.FileOpen(Elem: String):Boolean;
var
  Reply: PCCCReply;
  FileType, FileNo: Byte;
  name: FileData;
begin
  TimeoutEnabled:=false;
  PLCElement:=Elem;
  name := fileStrToFileData(PLCElement);
  FileNo:=name._file;
  FileType:=name._type;
  EtherInfo.fType:=FileType;
  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  Reply:= ProtFileOpen(EtherInfo,FileNo, FileType);
  result:=intToBool(Reply.Status);
  fOpen:=result;
end;

function TPLCTypedFile.FileClose:Boolean;
var
  Reply: PCCCReply;
begin
  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  Reply:= ProtFileClose(EtherInfo);
  result:=intToBool(Reply.Status);
  fOpen:=result;
  TimeoutEnabled:=true;
end;

end.

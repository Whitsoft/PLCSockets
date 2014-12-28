unit PLCLogical;

interface

uses
   SysUtils, Classes, ScktComp,types, ExtCtrls, PLCConnectClass,
   UnitUtil, UnitH, UnitFunctions, FileStrToData, BinDecConv;

const
  MAXWORDS=24;
type
  FloatRecord = record
    HiWord: word;
    LoWord: word;
  end;

type
  TPLCLogical = class(TPLCConnectClass)
    private
      { Private declarations }
      fTimerDisCon: TTimer;
      fBytes:       Integer;
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
    //procedure setElement(value: String);
   // function  getEtherInfo: PPLC_EtherIP_info;
   // procedure setActive(const Value: Boolean);
    function  getWords: Integer;
    procedure setWords(NumWords: Integer);
    procedure ClearArrays;

  public
    { Public declarations }
    procedure   DisConTimer(Sender: TObject);
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
   // procedure   setInterval(Value: Cardinal);
   // function    getInterval:Cardinal;
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
    property    Words: integer read getWords write setWords;
    function    LogicalRead(nWords: word; FType: char):boolean;
    function    LogicalWrite(nWords: word; FType: char):boolean;
    function    LogicalReadFloat(nRecords: word):boolean;
    function    LogicalWriteFloat(nRecords: word):boolean;
    //function    LogicalWrite(
  published
    { Published declarations }
   // property Active: Boolean read GetActive write SetActive Default False;
   // property PLCElement: String read fElement write setElement;
  //  property Timeout: Cardinal read getInterval write setInterval;
  end;

procedure Register;

implementation
     {$R TPLCLogical.dcr}
procedure Register;
begin
  RegisterComponents('PLCSockets', [TPLCLogical]);
end;

constructor TPLCLogical.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
 // fTimerDisCon:=TTimer.Create(Self);
 // fTimerDisCon.Enabled:=false;
 // fTimerDisCon.OnTimer:=DisConTimer;
  fBytes:= 0;
 // fTimerDisCon.Interval:=5000;
end;

destructor TPLCLogical.Destroy;
begin
 // fTimerDisCon.destroy;
  inherited;
end;


procedure TPLCLogical.ClearArrays;
var
  IDX: Integer;
begin
   for IDX:=0 to MAXWORDS-1 do
     begin
       fFromFile[IDX]:=0;
       fToFile[IDX]:=0;
     end;
end;

{procedure TPLCLogical.setElement(value: String);
begin
   fElement:=value;
   fFileData^:=StrToFileData(Value);
end; }

{function TPLCLogical.getInterval:Cardinal;
begin
  if fTimerDisCon <> nil then
     result:=fTimerDisCon.Interval
  else
     result:=0;
end;

procedure TPLCLogical.setInterval(Value: Cardinal);
begin
  if fTimerDisCon <> nil then
    begin
      fTimerDisCon.Interval := Value;
    end;
end;  }

procedure TPLCLogical.PutFile(IDX: Integer; Value: word);
begin
  fToFile[IDX]:=value;
end;

function TPLCLogical.getFile(IDX: Integer): word;
begin
  result:=fFromFile[IDX];
end;

procedure TPLCLogical.PutFloat(IDX: Integer; Value: single);
begin
  fToFloat[IDX]:=FloatToBinary(value);
end;

function TPLCLogical.GetFloat(IDX: Integer): single;
begin
  result:=BinaryToFloat(fFromFloat[IDX]);
end;

procedure TPLCLogical.PutBit(IDX: Integer; Value: word);
begin
  fToBit[IDX]:=value;
end;

function TPLCLogical.GetBit(IDX: Integer): word;
begin
  result:=fFromBit[IDX]
end;

procedure TPLCLogical.PutCounter(IDX: Integer; Value: word);
begin
  fToCounter[IDX]:=value;
end;

function TPLCLogical.GetCounter(IDX: Integer): word;
begin
  result:=fFromCounter[IDX]
end;

procedure TPLCLogical.PutTimer(IDX: Integer; Value: word);
begin
  fToTimer[IDX]:=value;
end;

function TPLCLogical.GetTimer(IDX: Integer): word;
begin
  result:=fFromTimer[IDX]
end;


procedure TPLCLogical.setWords(NumWords: Integer);
begin
  If NumWords > MAXWORDS then
    fBytes := MAXWORDS *2
  else
    fBytes := NumWords *2;
end;

function TPLCLogical.getWords: Integer;
begin
  result:=fBytes div 2;
end;

function TPLCLogical.LogicalRead(nWords: word; FType: char):boolean;
var
  Reply: PCCCReply;
  I, IDX, Ln: Integer;
  Size: byte;
  LoByte, HiByte: Byte;
begin
  TimeoutEnabled:=false;
  if (pos('.',PLCElement) > 0) or (pos('/',PLCElement) > 0) then
    size := 2
  else if (FType='T') or (FType = 'C') then
    size := 2
  else
    size := 2*nwords;
  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  Reply:=ProtectedRead(EtherInfo,size,PLCElement);
  I:=0;
  Ln:=Reply.Len div 2 -3;
  With Reply do
    for IDX := 0 to Ln do
      begin
        HiByte:=answer[4+IDX*2];
        LoByte:=answer[5+IDX*2];
        If FType = 'N' then
          fFromFile[I]:=net2Word(HiByte,LoByte)
        else if FType = 'B' then
          fFromBit[I]:=net2Word(HiByte,LoByte)
        else if FType = 'T' then
           fFromTimer[I]:=net2Word(HiByte,LoByte)
        else if FType = 'C' then
           fFromCounter[I]:= net2Word(HiByte,LoByte);
        inc(I);
      end;
  TimeoutEnabled:=true;
  result:=intToBool(Reply.Status);
  TimeoutEnabled:=true;
end;

function TPLCLogical.LogicalReadFloat(nRecords: word):boolean;
var
  Reply: PCCCReply;
  IDX, Ln: Integer;
  Size: byte;
  LoByte, HiByte: Byte;
  LoWord, HiWord: word;
begin
  TimeoutEnabled:=false;
  size := 2*nRecords;
   if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  Reply:=ProtectedRead(EtherInfo,size,PLCElement);
  Ln:=Reply.Len div 2 -3;
  With Reply do
    for IDX := 0 to Ln do
      begin
        HiByte:=answer[4+4*IDX];
        LoByte:=answer[4+4*IDX+1];
        LoWord:=net2Word(HiByte,LoByte);
        HiByte:=answer[4+4*IDX+2];
        LoByte:=answer[4+4*IDX+3];
        HiWord:=net2Word(HiByte,LoByte);
        fFromFloat[IDX].LoWord:=LoWord;
        fFromFloat[IDX].HiWord:=HiWord;
      end;
  TimeoutEnabled:=true;
  result:=intToBool(Reply.Status);
  TimeoutEnabled:=true;
end;

function TPLCLogical.LogicalWriteFloat(nRecords: word):boolean;
var
  Reply: PCCCReply;
  IDX, Cnt: Integer;
  Size: byte;
  LoByte, HiByte: Byte;
  PSimpleData: PSimpleBuf;
begin
  TimeoutEnabled:=false;
  new(PSimpleData);
  BZero(PSimpleData,MAXFILEARRAY*2);
  //Put data to be sent into a record of type SimpleBuff
  Cnt:=nRecords;
  if Cnt > MAXWORDS then Cnt :=MAXWORDS;
  for IDX := 0 to Cnt-1 do
    try
      Word2Net(fToFloat[IDX].HiWord,LoByte,HiByte);
      PSimpleData.data[4*IDX]:=LoByte;
      PSimpleData.data[4*IDX+1]:=HiByte;
      Word2Net(fToFloat[IDX].LoWord,LoByte,HiByte);
      PSimpleData.data[4*IDX+2]:=LoByte;
      PSimpleData.data[4*IDX+3]:=HiByte;
    except
      dispose(PSimpleData);
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  PSimpleData.Cnt:=Cnt*4;
  //Done with SimpleBuff

  size := PSimpleData.Cnt;
 // PSimpleData.Cnt:=PSimpleData.Cnt*2;
  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;

  Reply:=ProtectedWrite(EtherInfo,size,PLCElement,PSimpleData);
  dispose(PSimpleData);
  TimeoutEnabled:=true;
  result:=intToBool(Reply.Status);
  TimeoutEnabled:=true;
end;

function TPLCLogical.LogicalWrite(nWords: word; FType: char):boolean;
var
  Reply: PCCCReply;
  IDX, Cnt: Integer;
  Size: byte;
  LoByte, HiByte: Byte;
  PSimpleData: PSimpleBuf;
begin
  TimeoutEnabled:=false;
  new(PSimpleData);
  BZero(PSimpleData,MAXFILEARRAY*2);

  //Put data to be sent into a record of type SimpleBuff
  if (FType ='T') or (FType='C') then
    Cnt:=2
  else
    Cnt:=nWords;
  if Cnt > MAXWORDS then Cnt :=MAXWORDS;
  for IDX := 0 to Cnt -1 do
    try
      if FType = 'N' then
         Word2Net(fToFile[IDX],LoByte,HiByte)
      else if FType ='B' then
         Word2Net(fToBit[IDX],LoByte,HiByte)
      else if FType ='T' then
         Word2Net(fToTimer[IDX],LoByte,HiByte)
      else if FType ='C' then
         Word2Net(fToCounter[IDX],LoByte,HiByte);
      PSimpleData.data[2*IDX]:=LoByte;
      PSimpleData.data[2*IDX+1]:=HiByte;
    except
      dispose(PSimpleData);
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  PSimpleData.Cnt:=Cnt*2;
  //Done with SimpleBuff

  if (pos('.',PLCElement) > 0) or (pos('/',PLCElement) > 0) then
    size := 2
  else
    size := PSimpleData.Cnt;

  if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;

  Reply:=ProtectedWrite(EtherInfo,size,PLCElement,PSimpleData);
  dispose(PSimpleData);
  TimeoutEnabled:=true;
  result:=intToBool(Reply.Status);
  TimeoutEnabled:=true;
end;

procedure TPLCLogical.DisConTimer(Sender: TObject);
begin
  TimeoutEnabled := false;
  if connected then DisConnect;
end;

end.

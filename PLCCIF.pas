unit PLCCIF;

interface

uses
   SysUtils, Classes, ScktComp,types, ExtCtrls, PLCConnectClass,
   UnitH, UnitFunctions, FileStrToData;

const
  MAXWORDS=24;
type
  FloatRecord = record
    HiWord: word;
    LoWord: word;
  end;

type
  TPLCCIF = class(TPLCConnectClass)
    private
      { Private declarations }
      fBytes:       Integer;
      fToWords:     FileArray;
      fFromWords:   FileArray;
      ferror:       String;
   { Private declarations }
  protected
    { Protected declarations }
    procedure ClearArrays;

  public
    { Public declarations }
    //procedure   DisConTimer(Sender: TObject);
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    writeCIFFile(nWords, Offset: word):boolean;
    function    readCIFFile(nWords, Offset: word): boolean;
    procedure   putWord(IDX: Integer; Value: word);
    function    getWord(IDX: Integer): word;
   // procedure   setInterval(Value: Cardinal);
  published
    { Published declarations }
  end;

procedure Register;

implementation
  {$R TPLCCIF.dcr}
  uses
  UnitUtil; 
procedure Register;
begin
  RegisterComponents('PLCSockets', [TPLCCIF]);
end;

constructor TPLCCIF.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
 // fTimerDisCon:=TTimer.Create(Self);
 // fTimerDisCon.Enabled:=false;
 // fTimerDisCon.OnTimer:=DisConTimer;
  fBytes:= 0;
 // fTimerDisCon.Interval:=5000;
end;

destructor TPLCCIF.Destroy;
begin
//  fTimerDisCon.destroy;
  inherited;
end;


procedure TPLCCIF.ClearArrays;
var
  IDX: Integer;
begin
   for IDX:=0 to MAXWORDS-1 do
     begin
       fFromWords[IDX]:=0;
       fToWords[IDX]:=0;
     end;
end;


{procedure TPLCCIF.setInterval(Value: Cardinal);
begin
  if fTimerDisCon <> nil then
    begin
      fTimerDisCon.Interval := Value;
    end;
end;}

{procedure TPLCCIF.DisConTimer(Sender: TObject);
begin
  fTimerDisCon.enabled := false;
  if connected then DisConnect;
end; }

procedure TPLCCIF.putWord(IDX: Integer; Value: word);
begin
  if IDX <=MAXFILEARRAY then
     fToWords[IDX]:=value;
end;

function TPLCCIF.getWord(IDX: Integer): word;
begin
  if IDX <=MAXFILEARRAY then
     result:=fFromWords[IDX]
  else
     result:=0;   
end;

function TPLCCIF.readCIFFile(nWords, Offset: word): boolean;
var
  Reply: PCCCReply;
  PLCPtr:PPLC_EtherIP_info;
  size, IDX,Ln: Integer;
  HiByte, LoByte: Byte;
  words: word;
begin
   TimeoutEnabled:=false;
   result:=false;

   PLCPtr:=EtherInfo;

   words:=nWords;
   if (words*2) > MAXFILEARRAY*2 then words:=MAXFILEARRAY*2 ;

   if not Connected then
    Connect;

  if not connected then
    begin
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
   Size:=Words*2;
   Reply:=CIFRead(PLCPtr,size,Offset);
   Ln:=Reply.Len div 2 -3;
   With Reply do
     for IDX := 0 to Ln do
       begin
         HiByte:=answer[4+IDX*2];
         LoByte:=answer[5+IDX*2];
         fFromWords[IDX]:=net2Word(HiByte,LoByte);
       end;
   CommDiscon(PLCPtr);
   result:=intToBool(Reply.Status);
   TimeoutEnabled:=true;
end;


function TPLCCIF.writeCIFFile(nWords, Offset: word):boolean;
var
  Reply: PCCCReply;
  PLCPtr:PPLC_EtherIP_info;
  Size,IDX: Integer;
  HiByte, LoByte: Byte;
  PSimpleData: PSimpleBuf;
  words: word;
begin
  TimeoutEnabled:=false;
  result:=false;
      
  PLCPtr:=EtherInfo;
  new(PSimpleData);
  BZero(PSimpleData,MAXFILEARRAY*2);
  words:=nWords;
  if (words*2) > MAXFILEARRAY*2 then words:=MAXFILEARRAY*2 ;
  for IDX := 0 to words -1 do
    try
      Word2Net(fToWords[IDX],LoByte,HiByte);
      PSimpleData.data[2*IDX]:=LoByte;
      PSimpleData.data[2*IDX+1]:=HiByte;
    except
      dispose(PSimpleData);
      result:=false;
      TimeoutEnabled:=true;
      exit;
    end;
  PSimpleData.Cnt:=words*2;
  size:=PSimpleData.Cnt;
  if not Connected then
    Connect;

  if not connected then
    begin
      TimeoutEnabled:=true;
      exit;
    end;


  Reply:=CIFWrite(PLCPtr,Size,Offset,PSimpleData);
  TimeoutEnabled:=true;
  dispose(PSimpleData);
  result:=intToBool(Reply.Status);
  TimeoutEnabled:=true;
end;

end.

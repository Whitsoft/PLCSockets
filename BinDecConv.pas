unit BinDecConv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Dialogs, StdCtrls, math, StrUtils, UnitH;


type
  PFileArray=^FileArray;     
  FileArray = array [0..31] of word;

type
  HexBuf=array[1..8] of char;

type
  BinStr=String[32];

type
  ByteStr=string[8];

type
  binBuf=array[0..31] of char;

function charToHexValue(S: char): Integer;
function RightOfDec(S: String): String;
function LeftOfDec(S: String): String;
function HexStrToInt(H: String): Integer;
function IntToBin(value: Integer): string;
function BinToInt(Value: String): LongInt;
function getIntegerPart(S: String): String;
function PwrTwo(Exp:Integer): Integer;
function calcSingle(Sign,Exp,Man: Integer):Single;
function MakeExponent(val: String;lnFrac: Integer):String;
function getSign(S: String): char;
function getExponent(HexStr: HexBuf):Integer;
function getMantissa(HexStr: HexBuf): Integer;
function FractToBinary(S: String):String;
//function FloatToBinary(FStr: String):String;
function StrToWords(BS: BinStr): FloatRecord;
function toByte(S: ByteStr): Byte;

function FloatToBinary(Val: Single):FloatRecord;
function binaryToFloat(FRec: FloatRecord): Single;

implementation


function charToHexValue(S: char): Integer;
const HexDigits: array[0..15] of Char = '0123456789ABCDEF';

var
  H: String;
  IDX: Integer;
begin
  result:=-1;
  H := upperCase(S);
  for IDX := 0 to 15 do
      if H = HexDigits[IDX] then
         begin
           result:=IDX;
           exit;
         end;
end;

function RightOfDec(S: String): String;
begin
  result:=MidStr(S,pos('.',S),32);
end;

function LeftOfDec(S: String): String;
begin
  result:=LeftStr(S,pos('.',S)-1);
end;

function HexStrToInt(H: String): Integer;
var
  ln: Integer;
  IDX,Dig: Integer;
begin
  result:=0;
  Ln:=Length(H);
  for IDX:=1 to LN do
    begin
      Dig:=charToHexValue(H[IDX]);
      if Dig<0 then
         begin
           result:=-1;
           exit;
         end
      else
        result:=result+trunc(Power(16,LN-IDX)*Dig);
    end;
end;

function IntToBin(value: Integer): string;
var
  Tmp: String;
  Zeroes, Digits, IDX: Integer;
begin
    Digits:=24;
    Zeroes:=1;
    result:='';
    Tmp := StringOfChar ( '0', digits ) ;
    while value > 0 do
      begin
        if ( value and 1 ) = 1 then
           Tmp [ digits ] := '1';
           dec ( digits ) ;
           value := value shr 1;
      end;
     while Tmp[Zeroes]='0' do
       inc(Zeroes);

     for IDX:=Zeroes to Length(Tmp) do
       Result:=Result+Tmp[IDX];
end;

function getIntegerPart(S: String): String;
var
  P: Integer;
  IStr,IntStr: String;
begin
  P:=pos('.',S);
  If P > 0 then
    IStr:=LeftStr(S,P-1)
  else
    IStr:=S;
  if LeftStr(IStr,1)='-' then
     IStr:=MidStr(IStr,2,32);
  if (IStr = '') or (LeftStr(IStr,1) = '0') then
     Istr:='0';
  if IStr = '0' then
    result := '0'
  else
    begin
      IntStr:=IntToBin(StrToInt(IStr));
      result:=RightStr(IntStr,Length(IntStr));
    end;  
end;


function BinToInt(Value: String): LongInt;
var i: Integer;
begin
  Result:=0;
//remove leading zeroes
  while Copy(Value,1,1)='0' do
     Value:=Copy(Value,2,Length(Value)-1) ;
//do the conversion
  for i:=Length(Value) downto 1 do
     if Copy(Value,i,1)='1' then
        Result:=Result+(1 shl (Length(Value)-i)) ;
end;

function PwrTwo(Exp:Integer): Integer;
var
  IDX: Integer;
begin
  result:=1;
  for IDX := 1 to Exp do
     Result:=Result*2;
end;

{function Pwr(Num,Exp:Integer): Integer;
var
  IDX, Res: Integer;
begin
  Result:=Num;
  for IDX := 1 to Exp-1 do
     Result:=Result*Num;
end; }

function calcSingle(Sign,Exp,Man: Integer):Single;
var
   IDX, Mult, Mant: Integer;
   Sum: Single;
begin
   Sum:=0.0;
   Mant:=Man;
   Mult:=PwrTwo(Exp);
    for IDX := 0 to 23 do
     begin
       if Mant and 8388608 > 0 then
         Sum:=Sum + 1.0/PwrTwo(IDX)*Mult;
       Mant:=(Mant SHL 1) and 16777215;
     end;
     result:=Sign*Sum;
end;

function MakeExponent(val: String;lnFrac: Integer):String;
var
  Tmp: Integer;
  TmpRes, Dec: Integer;
  TmpS: String;
begin
  Dec:=pos(val,'1');
  TmpS:=IntToBin(Length(Val)-lnFrac-pos('1',val)+127);
  While Length(Tmps) < 8 do
    TmpS:='0'+Tmps;
  result:=Tmps;
end;

function getSign(S: String): char;
begin
  If LeftStr(S,1) = '-'
    then result:='1'
  else
    result:='0';
end;

function getExponent(HexStr: HexBuf):Integer;
var
  Exp, B1, B2, B3: Integer;
begin
  B1:=StrToInt('$'+HexStr[1]) and 7;
  B2:=StrToInt('$'+HexStr[2]) and 15;
  B3:=StrToInt('$'+HexStr[3]) and 8;
  Exp:=((B1*256+B2*16+B3) SHR 3)-127;
  result:=Exp;
end;

function getMantissa(HexStr: HexBuf): Integer;
var
  B1,B2,B3,B4,B5,B6: Integer;
begin
   B6:=StrToInt('$'+HexStr[8]);
   B5:=StrToInt('$'+HexStr[7]);
   B4:=StrToInt('$'+HexStr[6]);
   B3:=StrToInt('$'+HexStr[5]);
   B2:=StrToInt('$'+HexStr[4]);
   B1:=StrToInt('$'+HexStr[3]) or 8;
   result:=B6+B5*16+B4*256+B3*4096+B2*65536+B1*1048576;
 end;


function FractToBinary(S: String):String;
var
  Sng, Tmp: Single;
  TmpMant: String;
  Cnt: Integer;
begin
  TmpMant:='';
  Cnt:=0;
  Tmp:=0.0;
  Sng:=StrToFloat(RightOfDec(S));
  While Sng > 0 do
    begin
      Tmp:= 2.0*Sng;
      if trunc(Tmp) > 0 then
         TmpMant:=TmpMant+'1'
      else
         TmpMant:=TmpMant+'0';
      If Tmp >= 1 then
         Sng:=Tmp-trunc(Tmp)
      else
         Sng:=Tmp;
      Inc(Cnt);
      if Cnt>24 then break;
    end;
  result:=TmpMant;
end;

function normalize(S: String): String;
var
  one: Integer;
  ResStr, TmpS: String;
  IDX, Cnt: Integer;
begin
  ResStr:=StringOfChar('0', 23);
  one:=pos('1',S)+1;
  TmpS:=midStr(S,one,32);
  Cnt:=1;
  for IDX:=1 to length(TmpS) do
  begin
      ResStr[Cnt]:= TmpS[IDX];
      inc(Cnt);
      If Cnt>23 then break;
  end;
  result:=ResStr;
end;

function FloatToBinary(Val: Single):FloatRecord;
var
  IntPart, FracPart, Exp, ResStr, Mantissa, SVal: String;
  Sn: Char;
  IDX, Ln: Integer;
begin
  SVal:=FormatFloat('0.00000000',val);
  ResStr:=StringOfChar('0', 32);
  IntPart:=getIntegerPart(SVal);
  FracPart:=FractToBinary(SVal);
  Exp:=MakeExponent(IntPart+FracPart,length(FracPart));
  Mantissa:=normalize(IntPart+FracPart);
//  IntPart:=MidStr(IntPart,2,32);
  Sn:=GetSign(SVal);

  ResStr[1]:=Sn;
  for IDX:=1 to 8 do
    ResStr[IDX+1]:=Exp[IDX];


  Ln:=Length(Mantissa);

  for IDX := 1 to Ln do
  begin
    if IDX > 23 then break;
    ResStr[IDX+9]:=Mantissa[IDX];
  end;

 // ResStr:=FloatToBinary(ResStr);
  result:=StrToWords(ResStr);
end;

function toByte(S: ByteStr): Byte;
var
  IDX: Integer;
begin
  result:=0;
  for IDX := 7 downto 0 do
    if S[IDX+1] = '1' then
      result:=result+PwrTwo(7-IDX);
end;

function StrToWords(BS: BinStr): FloatRecord;
var
  IDX,I: Integer;
  B: String;
  B1,B2:Byte;
  W: Word;
  FBuf: FileArray;
begin
  for IDX := 0 to 31 do
    FBuf[IDX]:=0;
 // fBuf := StringOfChar ('0', 32) ;
  //for IDX := 0 to 1 do
    begin
      I:=1;
      B:=MidStr(BS,I,8);
      B2:=toByte(B);
      I:=I+8;
      B:=MidStr(BS,I,8);
      B1:=toByte(B);
      result.LoWord:=B1+B2*256;

      //FBuf[1]:=W;
      I:=16+1;
      B:=MidStr(BS,I,8);
      B2:=toByte(B);
      I:=I+8;
      B:=MidStr(BS,I,8);
      B1:=toByte(B);
      result.HiWord:=B1+B2*256;
//      FBuf[0]:=W;
    end;
end;

{function FloatStrToBuffer(val: single):FileArray;
var
  SStr: String;
  SBinary: String;
begin
  SStr:=FormatFloat('0.00000000',val);
  SBinary:=FloatToBinary(SStr);
  Result:=StrToWords(SBinary);
end; }
function binaryToFloat(FRec: FloatRecord): Single;
//function binaryToFloat(S1,S2: String): String;
var
  HexStr,HexStr1, HexStr2: String;
  HexBuffer: HexBuf;
  IDX, Sign: Integer;
  SignBit: Byte;
  BinNum, Exponent, Mantissa: Integer;
begin
  HexStr1:=IntToHex(FRec.LoWord,4);
  HexStr2:=IntToHex(FRec.HiWord,4);
  HexStr :=HexStr2+HexStr1;
  for IDX :=1 to 8 do
    begin
      HexBuffer[IDX]:=HexStr[IDX];
    end;
  Exponent:=getExponent(HexBuffer);
  Mantissa:=getMantissa(HexBuffer);
  SignBit:= StrToInt('$'+HexStr) and StrToInt('$80000000');
    if SignBit >0 then Sign:=-1 else Sign:=1;
  result:=calcSingle(Sign,Exponent,Mantissa);
end;

end.

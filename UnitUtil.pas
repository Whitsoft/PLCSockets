unit UnitUtil;

interface

uses
  UnitH, dialogs, sysutils;

function  intToBool(N: Integer): boolean;
procedure bZero(struct: Pointer; Len: Integer);
function  StructToByteArray(var ByteArray:array of byte;
          struct: pointer;Len,offset: Integer): Integer;

function  ByteArrayToStruct(struct: Pointer;
                            ByteArray:array of byte;
                            Len, Offset: Integer):Integer;

procedure memcpy(dataPtr,buffPtr: Pointer; len: integer);
procedure Word2Net(Data: Word; var LoByte: byte; var HiByte: Byte);
function  Net2Word(HiByte, LoByte: Byte):word;

function  Net2Cardinal(Byte0,Byte1,Byte2,Byte3: byte):cardinal;
procedure Cardinal2Net(data: cardinal;var Byte0: Byte;
                       var Byte1: Byte;var Byte2: Byte;var Byte3: Byte);

function  addressCompare(Add1,Add2: array of byte; len: Integer): Integer;
function  contextCompare(Add1,Add2: array of byte; len: Integer): Integer;

implementation

procedure Word2Net(Data: word; var LoByte: byte; var HiByte: Byte);
begin
 	LoByte := Data and 255;
  HiByte:=  Data div 256;
end;
procedure Cardinal2Net(data: cardinal;var Byte0: Byte;
                       var Byte1: Byte;var Byte2: Byte;var Byte3: Byte);
var
  HiWord, LoWord: word;
begin
  LoWord:=Data and  $FFFF;
  HiWord:=Data div   $10000;
  Word2Net(HiWord,Byte3,Byte2);
  Word2Net(LoWord,Byte1,Byte0);
end;

function  Net2Cardinal(Byte0,Byte1,Byte2,Byte3: byte):cardinal;
begin
  result:=Byte3*16777216+Byte2*65536+Byte1*256+Byte0;
end;

function Net2Word(HiByte, LoByte: Byte):word;
begin
  result:=LoByte*256+HiByte;
end;

procedure memcpy(dataPtr,buffPtr: Pointer; len: integer);
var
  BPtrData,BPtrBuff: ^Byte;
  IDX: Integer;
begin
  BPtrData:=dataPtr;
  BPtrBuff:=buffPtr;
  for IDX:=0 to len -1 do
    begin
      BPtrData^:=BPtrBuff^;
      inc(BPtrData);
      inc(BPtrBuff);
    end;
end;

function StructToByteArray(var ByteArray:array of byte;
          struct: pointer; Len, offset: Integer):Integer;
var
  IDX: Integer;
  BPtr: ^Byte;
begin
  BPtr:=struct;
  for IDX:= 0 to Len-1 do
    begin
      ByteArray[IDX+Offset]:=BPtr^;
      inc(BPtr);
    end;
  result:=Offset+Len;
end;

function ByteArrayToStruct(struct: Pointer;
                            ByteArray:array of byte; Len, Offset: Integer): Integer;
type
  BytePointer = ^Byte;

var
  IDX: Integer;
  BPtr: ^Byte;
begin
  BPtr:=struct;
  for IDX:= 0 to Len-1 do
    begin
      BPtr^:=ByteArray[IDX+Offset];
      inc(BPtr);
    end;
   result:=Offset+Len;
end;

procedure bZero(struct: Pointer; Len: Integer);
var
  BPtr: ^Byte;
  IDX: Integer;
begin
  BPtr:=struct;
  for IDX:=0 to Len-1 do
    begin
      BPtr^:=0;
      inc(BPtr);
    end;
end;

{
function in_cksum(var Paddr: ethernet_header; len:Integer): Word;
var
  nLeft: Integer;
  w: ^Word;
  sum : Cardinal;
begin
  nLeft:=Len;
  w:=addr(Paddr);
  sum:=0;
	//*
	//*  Our algorithm is simple, using a 32 bit accumulator (sum),
	//*  we add sequential 16 bit words to it, and at the end, fold
	//*  back all the carry bits from the top 16 bits into the lower
	//*  16 bits.
	//*/

	while( nleft > 1 )  do
    begin
      sum:=sum+w^;
      inc(w);
      nLeft:=nLeft-2;
    end;

	//* mop up an odd byte, if necessary */
	if( nleft = 1 ) then
     sum:=sum+ byte(w^);

	// * add back carry outs from top 16 bits to low 16 bits
	sum := (sum shr 16) + (sum and $ffff);	//* add hi 16 to low 16 */
	sum :=sum+(sum shr 16);       //* add carry */
	result:= not (Sum and $FFFF); //* truncate to 16 bits and do a one's complement*/
end;
}

function  intToBool(N: Integer): boolean;
begin
  if N = 0 then
    result:=true
  else
    result:=false;  
end;

function addressCompare(Add1,Add2: array of byte; len: Integer): Integer;
var
  IDX: Integer;
begin
  result:=0;
  for IDX:=0 to len-1 do
    if Add1[IDX]<>Add2[IDX] then
      begin
        result:=NOADDRESSMATCH;
        break;
      end;
end;

function contextCompare(Add1,Add2: array of byte; len: Integer): Integer;
var
  IDX: Integer;
begin
  result:=0;
  for IDX:=0 to len-1 do
    if Add1[IDX]<>Add2[IDX] then
      begin
        result:=NOCONTEXTMATCH;
        break;
      end;
end;

end.

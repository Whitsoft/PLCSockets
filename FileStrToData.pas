unit FileStrToData;

interface
uses
  SysUtils, UnitH, StrUtils;
  function StrToFileData(FileAddr:String): FileData;
  function fileStrToFileData(FileAddr:String): FileData;
const
  _FALSE=1;
  _TRUE=0;

var
  x, l: integer;
  junk: String;
  _try: boolean;
  var
   addrtypes: array [0..ADDRTYPESCOUNT-1] of string=('O', //Output
     	'I',	//Input
			'S',	//Status
			'B',	//Binary
			'T',	//Timer
			'C',	//Counter
			'R',	//Control
			'N',	//Integer
			'F',	//Float
			'A',	//ASCII
			'D',	//BCD
			'BT',	//Block Transfer
			'L',	//Long Integer
			'MG',	//Message
			'PD',	//PID
			'SC',	// ??
			'ST',	//String
			'PN',	//PLC Name
			'RG',	//Rung
			'FO',	//Output Force Table
			'FI',	//Input Force Table
			'XA',	//Section 3 File
			'XB',	//Section 4 File
			'XC',	//Section 5 File
			'XD',	//Section 6 File
			'FF');	// Force File Section

   datatypes: array [0..15] of string=('bit',
			'bit string',
			'byte string',
			'integer',
			'timer',
			'counter',
			'control',
			'IEEE floating point',
			'array (byte)',
			'not defined - 10',
			'not defined - 11',
			'not defined - 12',
			'Rung data',
			'not defined - 14',
			'address data',
			'BCD');


implementation

function isalpha(C: char): boolean;
begin
  If (c>='A') and (c<='z') then
    result:=true
  else
    result:=false;
end;

function isdigit(C: char): boolean;
begin
  If (c>='0') and (c<='9') then
    result:=true
  else
    result:=false;
end;

function strncasecmp(S1,S2: String; NumChars: Integer): Integer;
    //S1 >, = or <   1,0,-1
var
  US1,US2: String;
  IDX: Integer;
begin
  US1:=UpperCase(S1);
  US2:=UpperCase(S2);
  If (NumChars>Length(S1)) or (NumChars>Length(S2)) then
    begin
      result:=-2;
      exit;
    end;
  try
    result:=0;
    for IDX:=1 to NumChars do
      begin
        If US1[IDX]<US2[IDX] then
          begin
            result:=-1;
            break;
          end
        else if US1[IDX]>US2[IDX] then
          begin
            result:=1;
            break;
          end;
      end;
   except
     result:=-2;
   end;
end;

function firstDigit(S: String):Integer;
var
  IDX: Integer;
begin
  for IDX:=1 to Length(S) do
    if isDigit(S[IDX]) then
      begin
        result:=IDX;
        exit;
      end;
  result:=0;
end;

function delimit(S: String):integer;
var
  I: Integer;
begin
  I:=pos(':',S);
  If I <=0 then
    I := Pos(' ',S);
  If I <= 0 then
    result:=0
  else
    result:=I;
end;

function StrToFileData(FileAddr:String): FileData;
var          
  FileDesc: FileData;
  I,Slash, Dot: Integer;
  _FType,_File,_elem,_Sub, _Bit, TmpF: String;
  FileNum: Byte;
  Tmp: Char;
begin
  FileDesc.section:=-1;
  FileDesc._file:=0;
  FileDesc.element:=0;
  FileDesc.subelement:=0;
  FileDesc.floatdata:=_FALSE;

//------------------------- SLC 5/05 Encoding ----------------------
  begin  //SLC
		FileDesc._file:=0;
		FileDesc.element:=0;
		FileDesc.subelement:=0;
		FileDesc.section:=0;
    FileDesc.bit:=0;

  TmpF:=upperCase(FileAddr);
  I:=FirstDigit(TmpF);
  _FType:=LeftStr(TmpF,I-1);
  if I = 0 then
    begin
      result:=FileDesc;
      exit;
    end;
  TmpF:=MidStr(TmpF,I,32);
  I := Delimit(TmpF); //I:=pos(':',TmpF);
  if I = 0 then
    begin
      result:=FileDesc;
      exit;
    end;
  _File:=LeftStr(TmpF,I-1);
  FileNum:=StrToInt(_File);
  TmpF:=MidStr(TmpF,I+1,32);
  I :=FirstDigit(TmpF);
  If I <= 0 then TmpF:='';
  slash:=pos('/',TmpF);
  dot:=pos('.',TmpF);
  if (dot > 0) and (slash > dot) then
    begin
       Tmp:=TmpF[Dot];
       TmpF[Dot]:=TmpF[Slash];
       TmpF[Slash]:=Tmp;
       Slash:=Dot;
    end;
  If Slash > 0 then
     _elem:=LeftStr(TmpF,Slash-1)
  else
    _elem:=TmpF;
  slash:=pos('/',TmpF);
  dot:=pos('.',TmpF);
  if dot > 0 then
    begin
      _Bit:=MidStr(TmpF,Dot+1,32);
      _Sub:=MidStr(TmpF,Slash+1,Dot-Slash-1);
    end
  else if slash > 0 then
    _Sub:=MidStr(TmpF,Slash+1,32);

  if _Elem <> '' then
    FileDesc.element:=StrToInt(_Elem);
  if (_Sub='ACC') then
    FileDesc.Subelement := 2
  else if (_sub = 'PRE') then
    FileDesc.Subelement := 1
  else if (_sub = 'LEN') then
    FileDesc.Subelement := 1
  else if (_sub = 'POS') then
    FileDesc.Subelement := 2
  else
    FileDesc.Subelement := 0;

  FileDesc.typelen :=2;  //default
  FileDesc._file:=FileNum;
   If _FType = 'O' then
     begin
       FileDesc._type := FNC_OUTPUT;
			 FileDesc._file := 0;   //zero
     end
   else if _FType = 'I' then
     begin
       FileDesc._type := FNC_INPUT;
			 FileDesc._file := 1;     //one
     end
   else if _FType = 'S' then
     begin
       FileDesc._file := 0;
       FileDesc._type := FNC_STATUS;
     end
   else if _FType = 'ST' then
     begin
        FileDesc._file := 0;
       	FileDesc._type:=FNC_STRING;
  		  FileDesc.typelen := $54;
     end
   else if _FType = 'B' then
     begin
       FileDesc._type := FNC_BIT;
     end
   else if _FType = 'T' then
     begin
       FileDesc._type := FNC_TIMER;
     end
   else if _FType = 'C' then
     begin
       FileDesc._type := FNC_COUNTER;
     end
   else if _FType = 'R' then
     begin
       FileDesc._type := FNC_CONTROL;
     end
   else if _FType = 'N' then
     begin
       FileDesc._type := FNC_INTEGER;
     end
   else if _FType = 'F' then
     begin
       FileDesc._type := FNC_FLOAT;
       FileDesc.floatdata:=_TRUE;
			 FileDesc.typelen := 4;
     end
   else if _FType = 'A' then
     begin
       FileDesc._type := FNC_ASCII;
       FileDesc.Bit:=FileDesc.SubElement;
       FileDesc.SubElement:=0;
       FileDesc.typelen := Length(_File);
     end
   else if _FType = 'D' then
     begin
       FileDesc._type := FNC_BCD;
     end
   else if _FType = 'P' then
     begin
       FileDesc.section  := 1;
       FileDesc._file := 7;
		  	FileDesc.element := 0;
     end;

		FileDesc.len := 1;
		if (FileDesc._file <> 0) then
      begin
        FileDesc.data[0] := FileDesc.data[0] or 2;
			  FileDesc.data[FileDesc.len] := FileDesc._file;
        inc(FileDesc.len);
		   end;
		if (FileDesc.section <> 0) then
      begin
        FileDesc.data[FileDesc.len] := FileDesc.section;
        inc(FileDesc.len);
			  FileDesc.data[0] := FileDesc.data[0] or 1;
      end;

		if (FileDesc.element <> 0) then
      begin
			  FileDesc.data[0] := FileDesc.data[0] or 4;
        FileDesc.data[FileDesc.len] := FileDesc.element;
        inc(FileDesc.len);
      end;

		if (FileDesc.subelement <> 0) then
      begin
        FileDesc.data[0] := FileDesc.data[0] or 8;
			  FileDesc.data[FileDesc.len] := FileDesc.subelement;
        inc(FileDesc.len);
      end;
  end;
  result:=FileDesc;
end;


//***********************************************
// Convert a string into a FileData structure
//***********************************************
function fileStrToFileData(FileAddr:String): FileData;
var
  FileLoc: FileData;
  x: Integer;
  prefix: String;
  suffix: string;
  tempFileLoc: String[3];
begin
  FileLoc.section:=-1;
  FileLoc._file:=0;
  FileLoc.element:=0;
  FileLoc.subelement:=0;
  FileLoc.floatdata:=_FALSE;
  tempFileLoc:='';


//------------------------- SLC 5/05 Encoding ----------------------
  begin  //SLC
		FileLoc._file:=0;
		FileLoc.element:=0;
		FileLoc.subelement:=0;
		FileLoc.section:=0;
   suffix :='';
   prefix:=FileAddr[1];
   for x :=2 to length(FileAddr) do
     begin
       if isDigit(FileAddr[x]) then
         suffix :=suffix + FileAddr[x]
       else
         break;
     end;
     FileLoc._file:=strToInt(suffix);

     if prefix = 'O' then
        begin
          FileLoc._type := FNC_OUTPUT;
          FileLoc.typelen := 2;
        end
      else if prefix ='I' then
        begin
          FileLoc._type := FNC_INPUT;
					FileLoc.typelen := 2;
				end
      else if prefix ='S' then
        begin
					FileLoc._type := FNC_STATUS;
					FileLoc.typelen := 2;
				end
			else if prefix ='B' then
        begin
          //inc(x);
					FileLoc._type := FNC_BIT;
					FileLoc.typelen := 2;
				end
      else if prefix ='T' then
        begin
					FileLoc._type := FNC_TIMER;
					FileLoc.typelen := 2;
        end
			else if prefix = 'C' then
        begin
				  FileLoc._type := FNC_COUNTER;
					FileLoc.typelen := 2;
        end
      else if prefix = 'R' then
        begin
					FileLoc._type := FNC_CONTROL;
					FileLoc.typelen := 2;
				end
			else if prefix ='N' then
        begin
					FileLoc._type := FNC_INTEGER;
					FileLoc.typelen:=2;
        end
      else if prefix = 'F' then
        begin
          FileLoc._type := FNC_FLOAT;
					FileLoc.floatdata:=_TRUE;
					FileLoc.typelen := 4;
        end
      else if prefix = 'A' then
        begin
        //  inc(x);
					FileLoc._type := FNC_ASCII;
					FileLoc.typelen := 1;
        end
      else if prefix = 'D' then
        begin
					FileLoc._type := FNC_BCD;
					FileLoc.typelen := 2;
        end
      else if prefix = 'P' then   //special case to read program FileLoc from PLC.
        begin
					FileLoc.section  := 1;
          FileLoc._file := 7;
					FileLoc.element := 0;
        end;
    result:=FileLoc;
  end;
end;

end.

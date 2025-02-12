unit TestPLC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, PLCLogical, PLCConnectClass, Winsock2, System.Net.Socket,
  PLCCIF, PLCTypedFile, ExtCtrls, ScktComp, PLCMsg, BinDecConv, UnitH;

type
  TForm1 = class(TForm)
    MemoIn: TMemo;
    MemoOut: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    Label4: TLabel;
    EdInput: TEdit;
    Label16: TLabel;
    EdProtLen: TEdit;
    Label38: TLabel;
    Label6: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    EdCIFLen: TEdit;
    UDUnProt: TUpDown;
    BtnOpen: TButton;
    BtnClose: TButton;
    Label5: TLabel;
    EdFileOff: TEdit;
    UpDown2: TUpDown;
    Label32: TLabel;
    Label33: TLabel;
    EdFileLen: TEdit;
    UDFileLen: TUpDown;
    CBFileType: TComboBox;
    Label26: TLabel;
    EdTag: TEdit;
    Label7: TLabel;
    UpDown3: TUpDown;
    BtnLogRead: TButton;
    BtnLogWrite: TButton;
    BtnUnProtRead: TButton;
    BtnUnProtWrite: TButton;
    BtnReadProt: TButton;
    BtnWriteProt: TButton;
    Label8: TLabel;
    EdUnProt: TEdit;
    UpDown1: TUpDown;
    Timer1: TTimer;
    PLCTypedFile1: TPLCTypedFile;
    PLCCIF1: TPLCCIF;
    PLCLogical1: TPLCLogical;
    Edit1: TEdit;
    Edit2: TEdit;
    Label3: TLabel;
    Label9: TLabel;
    PLCMsg1: TPLCMsg;
    EdRec: TEdit;
    EdVal: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    procedure UDUnProtMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UDFileLenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDown3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDown2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnLogWriteClick(Sender: TObject);
    procedure BtnLogReadClick(Sender: TObject);

    procedure BtnUnProtReadClick(Sender: TObject);
    procedure BtnUnProtWriteClick(Sender: TObject);
    procedure BtnReadProtClick(Sender: TObject);
    procedure BtnWriteProtClick(Sender: TObject);
    procedure EdInputExit(Sender: TObject);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure PLCMsg1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.UDUnProtMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 EdCIFLen.Text:=IntToStr(UDUnProt.position);
end;

procedure TForm1.UDFileLenMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   EdFileLen.Text:=IntToStr(UDFileLen.position);
end;

procedure TForm1.UpDown3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   EdProtLen.Text:=IntToStr(UpDown3.position);
end;

procedure TForm1.UpDown2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 EdFileOff.Text:=IntToStr(UpDown2.position);
end;

procedure TForm1.UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   EdUnProt.Text:=IntToStr(UpDown1.position);
end;



procedure TForm1.BtnLogWriteClick(Sender: TObject);
var
  written: Boolean;
  FType: char;
  Ln, IDX: Integer;
begin
  MemoOut.Clear;
  Ln:=MemoIn.Lines.Count-1;//StrToInt(EdProtLen.Text)-1;
  With PLCLogical1 do  //format lines from MemoIn
    begin
      TimeOut:=5000;
      PLCElement:=upperCase(EdInput.Text);
      FType:=PLCElement[1];
      if FType ='N' then
         for IDX :=0 to ln do
            putFile(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='B' then
         for IDX :=0 to ln do
            putBit(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='T' then
         for IDX :=0 to ln do
            putTimer(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='C' then
         for IDX :=0 to ln do
            putCounter(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='F' then
         for IDX :=0 to ln do
            putFloat(IDX,StrToFloat(MemoIn.Lines[IDX]));
      //Output the formatted lines to PLC
      inc(Ln);
    //  Ln:= MemoIn.Lines.Count;
  //    Ln:=StrToInt(EdProtLen.Text);
  //      FType:=PLCElement[1];
      If FType = 'F' then
         written:=LogicalWriteFloat(Ln)
      else
         written:=LogicalWrite(Ln,FType);
     end;
end;

procedure TForm1.BtnLogReadClick(Sender: TObject);
var
  Sing: Single;
  FType: char;
  IDX, Ln: Integer;
begin
  MemoOut.Clear;
  With PLCLogical1 do
    begin  //Get data from PLC
 //     Sing:=getFloat(IDX);
      Ln:=StrToInt(EdProtLen.Text);
      TimeOut:=5000;
      PLCElement:=upperCase(EdInput.Text);
      FType:=PLCElement[1];
      If FType = 'F' then
         LogicalReadFloat(Ln*2)
      else
         logicalRead(Ln*2,FType);
      //Interpret data and write lines to MemoOut
      dec(Ln);
      If FType = 'F' then
        for IDX :=0 to ln do
          begin
            Sing:=getFloat(IDX);
            MemoOut.Lines.Add(formatFloat('0.0000',Sing));
          end
      else
        begin
          if FType ='N' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getFile(IDX)))
          else if FType ='B' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getBit(IDX)))
          else if FType ='T' then
             MemoOut.Lines.Add(IntToStr(getTimer(0)))
          else if FType ='C' then
             MemoOut.Lines.Add(IntToStr(getCounter(0)));
        end;
     end; // With PLCLogical1
end;

procedure TForm1.BtnUnProtReadClick(Sender: TObject);
var
  FileNo, nWords: Word;
  IDX, Ln: Integer;
begin
  MemoOut.Clear;
  Ln:=StrToInt(EdCIFLen.Text)-1;
  With PLCCIF1 do
    begin
      FileNo:=StrToInt(EdUnProt.Text);
      nWords:=StrToInt(EdCIFLen.Text);
      Timeout:=5000;
      readCIFFile(nWords, FileNo);
      for IDX:=0 to Ln  do
        MemoOut.Lines.Add(IntToStr(PLCCIF1.getWord(IDX)));
    end;
end;

procedure TForm1.BtnUnProtWriteClick(Sender: TObject);
var
  FAddress, nWords: Word;
  IDX, Ln: Integer;
begin
  Ln:=MemoIn.Lines.Count-1;//Ln:=StrToInt(EdCIFLen.Text)-1;
  If Ln < 0 then exit;
  MemoOut.Clear;
  for IDX:=0 to Ln do
    PLCCIF1.PutWord(IDX,StrToInt(MemoIn.Lines[IDX]));
  With PLCCIF1 do
    begin
      FAddress:=StrToInt(EdUnProt.Text);
      nWords:=StrToInt(EdCIFLen.Text);
      TimeOut:=5000;
      WriteCIFFile(nWords, FAddress);
  end;
end;

procedure TForm1.BtnReadProtClick(Sender: TObject);
var
  Sing: Single;
  written: Boolean;
  FType: char;
  IDX, Ln, Offst: word;
begin
  Ln:=StrToInt(EdFileLen.text);

  MemoIn.Clear;
  Offst:= StrToInt(edFileOff.Text);
  MemoOut.Clear;
  Ln:=StrToInt(EdFileLen.Text);
  With PLCTypedFile1 do  //Read data from PLC protected file 
    begin
      TimeOut:=5000;
      PLCElement:= CBFileType.Text;
      FType:=PLCElement[1];
      If FType = 'F' then
         Written:=TypedFileReadFloat(Ln*2, Offst)
      else
         Written:=TypedFileRead(Ln, Offst, FType);
      //Put interpreted data into MemoOut
      if not Written then
        begin
          ShowMEssage('File may have not been opened');
          exit;
        end;
      Dec(Ln);

      If FType = 'F' then
         for IDX :=0 to ln do
           begin
             Sing:=getFloat(IDX);
             MemoOut.Lines.Add(formatFloat('0.0000',Sing));
           end
      else
        begin
          if FType ='N' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getFile(IDX)))
          else if FType ='B' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getBit(IDX)))
          else if FType ='T' then
            for IDX :=0 to ln do
             MemoOut.Lines.Add(IntToStr(getTimer(IDX)))
          else if FType ='C' then
            for IDX :=0 to ln do
             MemoOut.Lines.Add(IntToStr(getCounter(IDX)));
        end;
   end;
end;

procedure TForm1.BtnWriteProtClick(Sender: TObject);
var
  written: Boolean;
  FType: char;
  IDX, Ln, offset: word;
begin
  //format data from MemoIn
  if MemoIn.Lines.Count <= 0 then
    exit;
  Ln:=MemoIn.Lines.Count -1;
  With PLCTypedFile1 do
    begin
      TimeOut:=5000;
      PLCElement:=upperCase(CBFileType.Text);
      FType:=PLCElement[1];
      if FType ='N' then
         for IDX :=0 to ln do
            putFile(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='B' then
         for IDX :=0 to ln do
            putBit(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='T' then
         for IDX :=0 to ln do
            putTimer(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='C' then
         for IDX :=0 to ln do
            putCounter(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='F' then
         for IDX :=0 to ln do
            putFloat(IDX,StrToFloat(MemoIn.Lines[IDX]));
      //Write formatted data to PLC
      Inc(Ln);
      MemoOut.Clear;
      offset:=StrToInt(EdFileOff.text);
      If FType = 'F' then
         written:=TypedFileWriteFloat(Ln, Offset)
      else
         written:=TypedFileWrite(Ln, Offset, FType);
      if not written then
        ShowMessage('File may not have been opened.');
   end;
end;

procedure TForm1.EdInputExit(Sender: TObject);
begin
   PLCLogical1.PLCElement:=EdInput.Text;
end;

procedure TForm1.BtnOpenClick(Sender: TObject);
begin
  PLCTypedFile1.FileOpen(CBFileType.Text);
  EdTag.Text:=IntToStr(PLCTypedFile1.EtherInfo.Tag);
end;

procedure TForm1.BtnCloseClick(Sender: TObject);
begin
  PLCTypedFile1.FileClose;
  EdTag.Text:='';
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  PLCLogical1.HostIP:=Edit1.Text;
  PLCCIF1.HostIP:=Edit1.Text;
  PLCTypedFile1.HostIP:=Edit1.Text;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  PLCLogical1.PLCIP:=Edit2.Text;
  PLCCIF1.PLCIP:=Edit2.Text;
  PLCTypedFile1.PLCIP:=Edit2.Text;
end;

procedure TForm1.PLCMsg1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  DataSize, DataCmd,DataFileNo,DataFileType,DataElement,DataSubElem, DataFunct: Byte;
  DataFileDesc: String;
  FR: FloatRecord;
  Val: Single;
begin
  PLCMsg1.ClientRead(Sender,Socket);
  if PLCMsg1.PLCList.Count <= 0 then exit;
  With  PPLCMessage(pointer(PLCMsg1.PLCList.Objects[0]))^ do
    begin
      DataSize:= Size;
      DataFileDesc:=FileDesc;
      DataCmd:=Cmd;
      DataFunct:=funct;
      DataFileNo:=FileNo;
      DataFileType:=FileType;
      DataElement:=Element;
      DataSubElem:=SubElement;
      FR:=bufToFloatRecord(Data[0],Data[1],Data[2],Data[3]);
      Val:=binaryToFloat(FR);
      EdVal.Text:=formatFloat('0.000',Val);
    end;
  EdRec.Text:=DataFileDesc;
end;

end.

{procedure TForm1.BtnGetDataClick(Sender: TObject);
var
  Sing: Single;
  FType: char;
  IDX, Ln: Integer;
begin
  Ln:=StrToInt(EdProtLen.Text)-1;
  With PLCLogical1 do
    begin
      FType:=PLCElement[1];
      If FType = 'F' then
        for IDX :=0 to ln do
          begin
            Sing:=getFloat(IDX);
            MemoOut.Lines.Add(formatFloat('0.0000',Sing));
          end
      else
        begin
          if FType ='N' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getFile(IDX)))
          else if FType ='B' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getBit(IDX)))
          else if FType ='T' then
             MemoOut.Lines.Add(IntToStr(getTimer(0)))
          else if FType ='C' then
             MemoOut.Lines.Add(IntToStr(getCounter(0)));
        end;
   end;
end;

procedure TForm1.BtnPutDataClick(Sender: TObject);
var
  FType: char;
  IDX, Ln: Integer;
begin
  Ln:=StrToInt(EdProtLen.Text)-1;
  With PLCLogical1 do
    begin
      FType:=PLCElement[1];
      if FType ='N' then
         for IDX :=0 to ln do
            putFile(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='B' then
         for IDX :=0 to ln do
            putBit(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='T' then
         for IDX :=0 to ln do
            putTimer(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='C' then
         for IDX :=0 to ln do
            putCounter(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='F' then
         for IDX :=0 to ln do
            putFloat(IDX,StrToFloat(MemoIn.Lines[IDX]));
   end;
end;

procedure TForm1.BtnPutFileClick(Sender: TObject);
var
  FType: char;
  IDX, Ln: Integer;
begin
  Ln:=StrToInt(EdFileLen.Text)-1;
  With PLCTypedFile1 do
    begin
      PLCElement:=CBFileType.Text;
      FType:=PLCElement[1];
      if FType ='N' then
         for IDX :=0 to ln do
            putFile(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='B' then
         for IDX :=0 to ln do
            putBit(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='T' then
         for IDX :=0 to ln do
            putTimer(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='C' then
         for IDX :=0 to ln do
            putCounter(IDX,StrToInt(MemoIn.Lines[IDX]))
      else if FType ='F' then
         for IDX :=0 to ln do
            putFloat(IDX,StrToFloat(MemoIn.Lines[IDX]));
   end;

end;

procedure TForm1.BtnGetFileClick(Sender: TObject);
var
  Sing: Single;
  FType: char;
  IDX, Ln: Integer;
begin
  Ln:=StrToInt(EdFileLen.Text)-1;
  With PLCTypedFile1 do
    begin
      PLCElement:=CBFileType.Text;
      FType:=PLCElement[1];
      If FType = 'F' then
         for IDX :=0 to ln do
           begin
             Sing:=getFloat(IDX);
             MemoOut.Lines.Add(formatFloat('0.0000',Sing));
           end
      else
        begin
          if FType ='N' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getFile(IDX)))
          else if FType ='B' then
            for IDX :=0 to ln do
                MemoOut.Lines.Add(IntToStr(getBit(IDX)))
          else if FType ='T' then
            for IDX :=0 to ln do
             MemoOut.Lines.Add(IntToStr(getTimer(IDX)))
          else if FType ='C' then
            for IDX :=0 to ln do
             MemoOut.Lines.Add(IntToStr(getCounter(IDX)));
        end;
   end;
end;}

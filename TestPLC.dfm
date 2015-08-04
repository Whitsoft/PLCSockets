object Form1: TForm1
  Left = 205
  Top = 133
  Width = 1215
  Height = 853
  Caption = 'TestPLC'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 20
    Top = 421
    Width = 47
    Height = 24
    Caption = 'Input'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 443
    Top = 421
    Width = 63
    Height = 24
    Caption = 'Output'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 719
    Top = 491
    Width = 196
    Height = 24
    Caption = 'Computer IP address'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 719
    Top = 590
    Width = 143
    Height = 24
    Caption = 'PLC IP address'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object MemoIn: TMemo
    Left = 20
    Top = 453
    Width = 227
    Height = 297
    TabOrder = 0
  end
  object MemoOut: TMemo
    Left = 443
    Top = 453
    Width = 228
    Height = 297
    Lines.Strings = (
      '')
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 506
    Top = 21
    Width = 293
    Height = 384
    Caption = 'Protected File'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label5: TLabel
      Left = 20
      Top = 137
      Width = 51
      Height = 20
      Caption = 'Offset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label32: TLabel
      Left = 20
      Top = 292
      Width = 91
      Height = 16
      Caption = 'Len in words '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label33: TLabel
      Left = 20
      Top = 311
      Width = 110
      Height = 16
      Caption = 'To read or write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label26: TLabel
      Left = 20
      Top = 213
      Width = 35
      Height = 20
      Caption = 'File '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 186
      Top = 304
      Width = 65
      Height = 20
      Caption = 'File Tag'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnOpen: TButton
      Left = 20
      Top = 39
      Width = 92
      Height = 31
      Caption = 'File Open'
      TabOrder = 0
      OnClick = BtnOpenClick
    end
    object BtnClose: TButton
      Left = 20
      Top = 89
      Width = 92
      Height = 30
      Caption = 'File Close'
      TabOrder = 1
      OnClick = BtnCloseClick
    end
    object EdFileOff: TEdit
      Left = 20
      Top = 160
      Width = 70
      Height = 28
      TabOrder = 2
      Text = '0'
    end
    object UpDown2: TUpDown
      Left = 98
      Top = 158
      Width = 21
      Height = 30
      Max = 16
      Position = 1
      TabOrder = 3
      OnMouseUp = UpDown2MouseUp
    end
    object EdFileLen: TEdit
      Left = 20
      Top = 335
      Width = 109
      Height = 28
      ReadOnly = True
      TabOrder = 4
      Text = '1'
    end
    object UDFileLen: TUpDown
      Left = 137
      Top = 335
      Width = 21
      Height = 31
      Min = 1
      Max = 16
      Position = 1
      TabOrder = 5
      OnMouseUp = UDFileLenMouseUp
    end
    object CBFileType: TComboBox
      Left = 20
      Top = 239
      Width = 129
      Height = 28
      ItemHeight = 20
      MaxLength = 10
      TabOrder = 6
      Text = 'N7 - INTEGER'
      Items.Strings = (
        'A10  - ASCII'
        'B3   - BIT'
        'T4 - TIMER'
        'C5  - COUNTER'
        'D11  - BCD'
        'F8  - FLOAT'
        'I0 -  INPUT'
        'N7 - INTEGER'
        'N9 - INTEGER'
        'O1  - OUTPUT'
        'P12  - PROGRAM'
        'R6  - CONTROL'
        'S2  - STATUS')
    end
    object BtnPutFile: TButton
      Left = 177
      Top = 167
      Width = 93
      Height = 31
      Caption = 'Put File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      OnClick = BtnPutFileClick
    end
    object BtnGetFile: TButton
      Left = 177
      Top = 212
      Width = 93
      Height = 30
      Caption = 'Get File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = BtnGetFileClick
    end
    object EdTag: TEdit
      Left = 188
      Top = 336
      Width = 72
      Height = 28
      Color = 12372936
      ReadOnly = True
      TabOrder = 9
    end
  end
  object GroupBox2: TGroupBox
    Left = 223
    Top = 21
    Width = 271
    Height = 385
    Caption = 'CIF - F9'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object Label38: TLabel
      Left = 20
      Top = 38
      Width = 30
      Height = 20
      Caption = 'CIF'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 20
      Top = 60
      Width = 89
      Height = 20
      Caption = 'File No N9 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label30: TLabel
      Left = 20
      Top = 162
      Width = 91
      Height = 16
      Caption = 'Len in words '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label31: TLabel
      Left = 20
      Top = 180
      Width = 110
      Height = 16
      Caption = 'To read or write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label8: TLabel
      Left = 20
      Top = 97
      Width = 51
      Height = 20
      Caption = 'Offset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EdCIFLen: TEdit
      Left = 20
      Top = 201
      Width = 71
      Height = 28
      ReadOnly = True
      TabOrder = 0
      Text = '1'
    end
    object UDUnProt: TUpDown
      Left = 101
      Top = 198
      Width = 21
      Height = 31
      Min = 1
      Max = 16
      Position = 1
      TabOrder = 1
      OnMouseUp = UDUnProtMouseUp
    end
    object BtnGetUnProt: TButton
      Left = 20
      Top = 300
      Width = 92
      Height = 31
      Caption = 'Get Data '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = BtnGetUnProtClick
    end
    object BtnUnProtRead: TButton
      Left = 151
      Top = 118
      Width = 93
      Height = 31
      Caption = 'Read'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = BtnUnProtReadClick
    end
    object BtnUnProtWrite: TButton
      Left = 151
      Top = 167
      Width = 93
      Height = 31
      Caption = 'Write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = BtnUnProtWriteClick
    end
    object BtnPutUnProt: TButton
      Left = 20
      Top = 256
      Width = 92
      Height = 31
      Caption = 'Put Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = BtnPutUnProtClick
    end
    object EdUnProt: TEdit
      Left = 20
      Top = 121
      Width = 70
      Height = 28
      TabOrder = 6
      Text = '0'
    end
    object UpDown1: TUpDown
      Left = 98
      Top = 118
      Width = 21
      Height = 31
      Max = 16
      Position = 1
      TabOrder = 7
      OnMouseUp = UpDown1MouseUp
    end
  end
  object GroupBox4: TGroupBox
    Left = 20
    Top = 21
    Width = 197
    Height = 385
    Caption = 'Logical'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object Label4: TLabel
      Left = 14
      Top = 34
      Width = 112
      Height = 20
      Caption = 'File:Elem.Sub'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label16: TLabel
      Left = 14
      Top = 106
      Width = 87
      Height = 16
      Caption = 'Len in words'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label28: TLabel
      Left = 14
      Top = 126
      Width = 110
      Height = 16
      Caption = 'To read or write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EdInput: TEdit
      Left = 14
      Top = 62
      Width = 139
      Height = 28
      TabOrder = 0
      Text = 'T4:1/ACC'
      OnExit = EdInputExit
    end
    object EdProtLen: TEdit
      Left = 14
      Top = 153
      Width = 109
      Height = 28
      ReadOnly = True
      TabOrder = 1
      Text = '1'
    end
    object BtnPutData: TButton
      Left = 14
      Top = 271
      Width = 92
      Height = 31
      Caption = 'Put Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = BtnPutDataClick
    end
    object BtnGetData: TButton
      Left = 14
      Top = 308
      Width = 92
      Height = 30
      Caption = 'Get Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = BtnGetDataClick
    end
    object UpDown3: TUpDown
      Left = 132
      Top = 148
      Width = 21
      Height = 30
      Min = 1
      Max = 16
      Position = 1
      TabOrder = 4
      OnMouseUp = UpDown3MouseUp
    end
    object BtnLogRead: TButton
      Left = 14
      Top = 197
      Width = 92
      Height = 31
      Caption = 'Read'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = BtnLogReadClick
    end
    object BtnLogWrite: TButton
      Left = 14
      Top = 234
      Width = 92
      Height = 31
      Caption = 'Write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = BtnLogWriteClick
    end
  end
  object BtnReadProt: TButton
    Left = 683
    Top = 69
    Width = 92
    Height = 31
    Caption = 'Read'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = BtnReadProtClick
  end
  object BtnWriteProt: TButton
    Left = 683
    Top = 116
    Width = 92
    Height = 30
    Caption = 'Write'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = BtnWriteProtClick
  end
  object Edit1: TEdit
    Left = 720
    Top = 522
    Width = 204
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 720
    Top = 620
    Width = 204
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    OnChange = Edit2Change
  end
  object EdRec: TEdit
    Left = 888
    Top = 112
    Width = 225
    Height = 24
    TabOrder = 9
  end
  object EdVal: TEdit
    Left = 888
    Top = 144
    Width = 225
    Height = 24
    TabOrder = 10
  end
  object Timer1: TTimer
    Left = 680
    Top = 160
  end
  object PLCTypedFile1: TPLCTypedFile
    HostIP = '192.168.1.10'
    PLCIP = '192.168.1.50'
    PLCPort = 44818
    Timeout = 5000
    Left = 523
    Top = 49
  end
  object PLCCIF1: TPLCCIF
    HostIP = '192.168.1.10'
    PLCIP = '192.168.1.50'
    PLCPort = 44818
    Timeout = 5000
    Left = 357
    Top = 33
  end
  object PLCLogical1: TPLCLogical
    HostIP = '192.168.1.10'
    PLCIP = '192.168.1.50'
    PLCPort = 44818
    Timeout = 5000
    Left = 136
    Top = 289
  end
  object PLCMsg1: TPLCMsg
    Active = True
    Port = 44818
    ServerType = stNonBlocking
    OnClientRead = PLCMsg1ClientRead
    LocalIP = '192.168.1.10'
    Left = 920
    Top = 72
  end
end

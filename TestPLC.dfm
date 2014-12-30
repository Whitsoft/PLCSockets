object Form1: TForm1
  Left = 205
  Top = 133
  Width = 788
  Height = 656
  Caption = 'TestPLC'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 342
    Width = 43
    Height = 20
    Caption = 'Input'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 360
    Top = 342
    Width = 56
    Height = 20
    Caption = 'Output'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 584
    Top = 399
    Width = 170
    Height = 20
    Caption = 'Computer IP address'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 584
    Top = 479
    Width = 125
    Height = 20
    Caption = 'PLC IP address'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object MemoIn: TMemo
    Left = 16
    Top = 368
    Width = 185
    Height = 241
    TabOrder = 0
  end
  object MemoOut: TMemo
    Left = 360
    Top = 368
    Width = 185
    Height = 241
    Lines.Strings = (
      '')
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 411
    Top = 17
    Width = 238
    Height = 312
    Caption = 'Protected File'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label5: TLabel
      Left = 16
      Top = 111
      Width = 41
      Height = 16
      Caption = 'Offset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label32: TLabel
      Left = 16
      Top = 237
      Width = 77
      Height = 13
      Caption = 'Len in words '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label33: TLabel
      Left = 16
      Top = 253
      Width = 91
      Height = 13
      Caption = 'To read or write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label26: TLabel
      Left = 16
      Top = 173
      Width = 31
      Height = 16
      Caption = 'File '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 151
      Top = 247
      Width = 59
      Height = 16
      Caption = 'File Tag'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnOpen: TButton
      Left = 16
      Top = 32
      Width = 75
      Height = 25
      Caption = 'File Open'
      TabOrder = 0
      OnClick = BtnOpenClick
    end
    object BtnClose: TButton
      Left = 16
      Top = 72
      Width = 75
      Height = 25
      Caption = 'File Close'
      TabOrder = 1
      OnClick = BtnCloseClick
    end
    object EdFileOff: TEdit
      Left = 16
      Top = 130
      Width = 57
      Height = 24
      TabOrder = 2
      Text = '0'
    end
    object UpDown2: TUpDown
      Left = 80
      Top = 128
      Width = 17
      Height = 25
      Max = 16
      Position = 1
      TabOrder = 3
      OnMouseUp = UpDown2MouseUp
    end
    object EdFileLen: TEdit
      Left = 16
      Top = 272
      Width = 89
      Height = 24
      ReadOnly = True
      TabOrder = 4
      Text = '1'
    end
    object UDFileLen: TUpDown
      Left = 111
      Top = 272
      Width = 17
      Height = 25
      Min = 1
      Max = 16
      Position = 1
      TabOrder = 5
      OnMouseUp = UDFileLenMouseUp
    end
    object CBFileType: TComboBox
      Left = 16
      Top = 194
      Width = 105
      Height = 24
      ItemHeight = 16
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
      Left = 144
      Top = 136
      Width = 75
      Height = 25
      Caption = 'Put File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      OnClick = BtnPutFileClick
    end
    object BtnGetFile: TButton
      Left = 144
      Top = 172
      Width = 75
      Height = 25
      Caption = 'Get File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = BtnGetFileClick
    end
    object EdTag: TEdit
      Left = 153
      Top = 273
      Width = 58
      Height = 24
      Color = 12372936
      ReadOnly = True
      TabOrder = 9
    end
  end
  object GroupBox2: TGroupBox
    Left = 181
    Top = 17
    Width = 220
    Height = 313
    Caption = 'CIF - F9'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object Label38: TLabel
      Left = 16
      Top = 31
      Width = 24
      Height = 16
      Caption = 'CIF'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 16
      Top = 49
      Width = 78
      Height = 16
      Caption = 'File No N9 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label30: TLabel
      Left = 16
      Top = 132
      Width = 77
      Height = 13
      Caption = 'Len in words '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label31: TLabel
      Left = 16
      Top = 146
      Width = 91
      Height = 13
      Caption = 'To read or write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label8: TLabel
      Left = 16
      Top = 79
      Width = 41
      Height = 16
      Caption = 'Offset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EdCIFLen: TEdit
      Left = 16
      Top = 163
      Width = 58
      Height = 24
      ReadOnly = True
      TabOrder = 0
      Text = '1'
    end
    object UDUnProt: TUpDown
      Left = 82
      Top = 161
      Width = 17
      Height = 25
      Min = 1
      Max = 16
      Position = 1
      TabOrder = 1
      OnMouseUp = UDUnProtMouseUp
    end
    object BtnGetUnProt: TButton
      Left = 16
      Top = 244
      Width = 75
      Height = 25
      Caption = 'Get Data '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = BtnGetUnProtClick
    end
    object BtnUnProtRead: TButton
      Left = 123
      Top = 96
      Width = 75
      Height = 25
      Caption = 'Read'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = BtnUnProtReadClick
    end
    object BtnUnProtWrite: TButton
      Left = 123
      Top = 136
      Width = 75
      Height = 25
      Caption = 'Write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = BtnUnProtWriteClick
    end
    object BtnPutUnProt: TButton
      Left = 16
      Top = 208
      Width = 75
      Height = 25
      Caption = 'Put Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = BtnPutUnProtClick
    end
    object EdUnProt: TEdit
      Left = 16
      Top = 98
      Width = 57
      Height = 24
      TabOrder = 6
      Text = '0'
    end
    object UpDown1: TUpDown
      Left = 80
      Top = 96
      Width = 17
      Height = 25
      Max = 16
      Position = 1
      TabOrder = 7
      OnMouseUp = UpDown1MouseUp
    end
  end
  object GroupBox4: TGroupBox
    Left = 16
    Top = 17
    Width = 160
    Height = 313
    Caption = 'Logical'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object Label4: TLabel
      Left = 11
      Top = 28
      Width = 97
      Height = 16
      Caption = 'File:Elem.Sub'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label16: TLabel
      Left = 11
      Top = 86
      Width = 73
      Height = 13
      Caption = 'Len in words'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label28: TLabel
      Left = 11
      Top = 102
      Width = 91
      Height = 13
      Caption = 'To read or write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EdInput: TEdit
      Left = 11
      Top = 50
      Width = 113
      Height = 24
      TabOrder = 0
      Text = 'T4:1/ACC'
      OnExit = EdInputExit
    end
    object EdProtLen: TEdit
      Left = 11
      Top = 124
      Width = 89
      Height = 24
      ReadOnly = True
      TabOrder = 1
      Text = '1'
    end
    object BtnPutData: TButton
      Left = 11
      Top = 220
      Width = 75
      Height = 25
      Caption = 'Put Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = BtnPutDataClick
    end
    object BtnGetData: TButton
      Left = 11
      Top = 250
      Width = 75
      Height = 25
      Caption = 'Get Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = BtnGetDataClick
    end
    object UpDown3: TUpDown
      Left = 107
      Top = 120
      Width = 17
      Height = 25
      Min = 1
      Max = 16
      Position = 1
      TabOrder = 4
      OnMouseUp = UpDown3MouseUp
    end
    object BtnLogRead: TButton
      Left = 11
      Top = 160
      Width = 75
      Height = 25
      Caption = 'Read'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = BtnLogReadClick
    end
    object BtnLogWrite: TButton
      Left = 11
      Top = 190
      Width = 75
      Height = 25
      Caption = 'Write'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = BtnLogWriteClick
    end
  end
  object BtnReadProt: TButton
    Left = 555
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Read'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = BtnReadProtClick
  end
  object BtnWriteProt: TButton
    Left = 555
    Top = 94
    Width = 75
    Height = 25
    Caption = 'Write'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = BtnWriteProtClick
  end
  object Edit1: TEdit
    Left = 585
    Top = 424
    Width = 166
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 585
    Top = 504
    Width = 166
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    OnChange = Edit2Change
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
end

object frmOptMPEGa: TfrmOptMPEGa
  Left = 268
  Top = 385
  BorderStyle = bsToolWindow
  Caption = 'MPEG Audio Options'
  ClientHeight = 295
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblVersion: TLabel
    Left = 8
    Top = 280
    Width = 361
    Height = 11
    AutoSize = False
    Caption = 'Default HyperRipper Plugin v1.0.0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -9
    Font.Name = 'Small Fonts'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Bevel2: TBevel
    Left = 0
    Top = 272
    Width = 369
    Height = 10
    Shape = bsTopLine
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 441
    Height = 89
    Caption = 'Formats MPEG Audio a rechercher'
    TabOrder = 0
    object Label5: TLabel
      Left = 8
      Top = 16
      Width = 113
      Height = 13
      AutoSize = False
      Caption = '(ISO/IEC 11172-3)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 136
      Top = 16
      Width = 113
      Height = 13
      AutoSize = False
      Caption = '(ISO/IEC 13818-3)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblUnof: TLabel
      Left = 264
      Top = 16
      Width = 113
      Height = 13
      AutoSize = False
      Caption = '(Unofficial)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkMP10_1: TCheckBox
      Left = 8
      Top = 32
      Width = 113
      Height = 17
      Caption = 'MPEG 1.0 Layer I'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkMP10_2: TCheckBox
      Left = 8
      Top = 48
      Width = 113
      Height = 17
      Caption = 'MPEG 1.0 Layer II'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chkMP10_3: TCheckBox
      Left = 8
      Top = 64
      Width = 113
      Height = 17
      Caption = 'MPEG 1.0 Layer III'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object chkMP20_1: TCheckBox
      Left = 136
      Top = 32
      Width = 113
      Height = 17
      Caption = 'MPEG 2.0 Layer I'
      TabOrder = 3
    end
    object chkMP20_2: TCheckBox
      Left = 136
      Top = 48
      Width = 113
      Height = 17
      Caption = 'MPEG 2.0 Layer II'
      TabOrder = 4
    end
    object chkMP20_3: TCheckBox
      Left = 136
      Top = 64
      Width = 113
      Height = 17
      Caption = 'MPEG 2.0 Layer III'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object chkMP25_1: TCheckBox
      Left = 264
      Top = 32
      Width = 113
      Height = 17
      Caption = 'MPEG 2.5 Layer I'
      TabOrder = 6
    end
    object chkMP25_2: TCheckBox
      Left = 264
      Top = 48
      Width = 113
      Height = 17
      Caption = 'MPEG 2.5 Layer II'
      TabOrder = 7
    end
    object chkMP25_3: TCheckBox
      Left = 264
      Top = 64
      Width = 113
      Height = 17
      Caption = 'MPEG 2.5 Layer III'
      Checked = True
      State = cbChecked
      TabOrder = 8
    end
    object cmdMP1: TButton
      Left = 392
      Top = 32
      Width = 43
      Height = 17
      Caption = 'MP1'
      TabOrder = 10
      OnClick = cmdMP1Click
    end
    object cmdMP2: TButton
      Left = 392
      Top = 48
      Width = 43
      Height = 17
      Caption = 'MP2'
      TabOrder = 11
      OnClick = cmdMP2Click
    end
    object cmdMP3: TButton
      Left = 392
      Top = 64
      Width = 43
      Height = 17
      Caption = 'MP3'
      TabOrder = 9
      OnClick = cmdMP3Click
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 104
    Width = 441
    Height = 105
    Caption = 'Limitations'
    TabOrder = 1
    object Bevel1: TBevel
      Left = 0
      Top = 56
      Width = 441
      Height = 9
      Shape = bsTopLine
    end
    object lblFrameMin: TLabel
      Left = 360
      Top = 15
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'frame(s)'
    end
    object lblFrameMax: TLabel
      Left = 360
      Top = 36
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'frame(s)'
    end
    object lblSizeMax: TLabel
      Left = 360
      Top = 84
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'octet(s)'
    end
    object lblSizeMin: TLabel
      Left = 360
      Top = 63
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'octet(s)'
    end
    object chkFramesMin: TCheckBox
      Left = 8
      Top = 16
      Width = 177
      Height = 17
      Caption = 'Nombre de frames minimum:'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = chkFramesMinClick
    end
    object numFramesMin: TRxSpinEdit
      Left = 232
      Top = 10
      Width = 121
      Height = 21
      Alignment = taRightJustify
      MaxValue = 30000.000000000000000000
      MinValue = 2.000000000000000000
      Value = 20.000000000000000000
      TabOrder = 1
      OnChange = numFramesMinChange
    end
    object numFramesMax: TRxSpinEdit
      Left = 232
      Top = 32
      Width = 121
      Height = 21
      Alignment = taRightJustify
      MaxValue = 2147483647.000000000000000000
      MinValue = 20.000000000000000000
      Value = 30000.000000000000000000
      Enabled = False
      TabOrder = 2
      OnChange = numFramesMaxChange
    end
    object chkFramesMax: TCheckBox
      Left = 8
      Top = 32
      Width = 177
      Height = 17
      Caption = 'Nombre de frames maximum:'
      TabOrder = 3
      OnClick = chkFramesMaxClick
    end
    object chkSizeMin: TCheckBox
      Left = 8
      Top = 64
      Width = 217
      Height = 17
      Caption = 'Taille minimum:'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = chkSizeMinClick
    end
    object chkSizeMax: TCheckBox
      Left = 8
      Top = 80
      Width = 217
      Height = 17
      Caption = 'Taille maximum:'
      TabOrder = 5
      OnClick = chkSizeMaxClick
    end
    object numSizeMin: TRxSpinEdit
      Left = 232
      Top = 58
      Width = 121
      Height = 21
      Alignment = taRightJustify
      MaxValue = 30000.000000000000000000
      MinValue = 512.000000000000000000
      Value = 2048.000000000000000000
      TabOrder = 6
      OnChange = numSizeMinChange
    end
    object numSizeMax: TRxSpinEdit
      Left = 232
      Top = 80
      Width = 121
      Height = 21
      Alignment = taRightJustify
      MaxValue = 2147483647.000000000000000000
      MinValue = 2048.000000000000000000
      Value = 30000.000000000000000000
      Enabled = False
      TabOrder = 7
      OnChange = numSizeMaxChange
    end
  end
  object grp3: TGroupBox
    Left = 8
    Top = 216
    Width = 441
    Height = 41
    Caption = 'Sp'#233'cial'
    TabOrder = 2
    object chkXingVBR: TCheckBox
      Left = 8
      Top = 16
      Width = 201
      Height = 17
      Caption = 'Rechercher ent'#234'te Xing VBR'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkID3Tag: TCheckBox
      Left = 232
      Top = 16
      Width = 201
      Height = 17
      Caption = 'Recherche ID3Tag v1.0/1.1'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object cmdOk: TButton
    Left = 376
    Top = 264
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = cmdOkClick
  end
end

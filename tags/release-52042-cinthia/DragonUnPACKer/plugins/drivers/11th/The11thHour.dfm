object frm11thHour: Tfrm11thHour
  Left = 659
  Top = 62
  BorderStyle = bsToolWindow
  Caption = '11th Hour plugin configuration'
  ClientHeight = 134
  ClientWidth = 233
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblVersion: TLabel
    Left = 8
    Top = 116
    Width = 137
    Height = 10
    AutoSize = False
    Caption = 'v1.0.1 Beta 1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Small Fonts'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 106
    Width = 137
    Height = 10
    AutoSize = False
    Caption = 'Elbereth'#39's 11th Hour driver plugin'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Small Fonts'
    Font.Style = []
    ParentFont = False
  end
  object grp11th: TGroupBox
    Left = 8
    Top = 8
    Width = 217
    Height = 89
    Caption = 'The 11th Hour support'
    TabOrder = 0
    object strStatus: TLabel
      Left = 8
      Top = 24
      Width = 105
      Height = 13
      AutoSize = False
      Caption = 'Current status:'
    end
    object lblStatus: TStaticText
      Left = 120
      Top = 24
      Width = 89
      Height = 17
      Alignment = taCenter
      AutoSize = False
      BevelInner = bvLowered
      BevelKind = bkFlat
      Caption = '-'
      TabOrder = 0
    end
    object cmdEnable: TButton
      Left = 8
      Top = 56
      Width = 97
      Height = 25
      Caption = 'Enable'
      TabOrder = 1
      OnClick = cmdEnableClick
    end
    object cmdDisable: TButton
      Left = 112
      Top = 56
      Width = 99
      Height = 25
      Caption = 'Disable'
      TabOrder = 2
      OnClick = cmdDisableClick
    end
  end
  object cmdOk: TButton
    Left = 152
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = cmdOkClick
  end
end

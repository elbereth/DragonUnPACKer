object frmGameHint: TfrmGameHint
  Left = 404
  Top = 335
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'A.Cordero'#39's UT Package Driver'
  ClientHeight = 275
  ClientWidth = 424
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
  object panOpen: TPanel
    Left = 0
    Top = 0
    Width = 321
    Height = 89
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 305
      Height = 13
      AutoSize = False
      Caption = 'From which game is the package you are opening ?'
    end
    object lstGameHints: TComboBox
      Left = 8
      Top = 28
      Width = 305
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object chkDontAsk: TCheckBox
      Left = 8
      Top = 56
      Width = 225
      Height = 25
      Caption = 'Don'#39't ask again for this directory'
      Checked = True
      State = cbChecked
      TabOrder = 1
      WordWrap = True
    end
    object butOK: TButton
      Left = 238
      Top = 56
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 2
      OnClick = butOKClick
    end
  end
  object grpEdit: TGroupBox
    Left = 8
    Top = 168
    Width = 321
    Height = 97
    Caption = 'Edit game'
    TabOrder = 1
  end
end

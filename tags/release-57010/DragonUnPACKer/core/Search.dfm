object frmSearch: TfrmSearch
  Left = 390
  Top = 410
  BorderStyle = bsToolWindow
  Caption = 'Rechercher'
  ClientHeight = 147
  ClientWidth = 352
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
  object GroupBox: TGroupBox
    Left = 8
    Top = 40
    Width = 337
    Height = 81
    Caption = 'Options'
    TabOrder = 0
    object CheckCase: TCheckBox
      Left = 8
      Top = 16
      Width = 265
      Height = 17
      Caption = 'Faire la difference entre Majuscules et Minuscules'
      TabOrder = 0
      OnClick = CheckCaseClick
    end
    object RadioTout: TRadioButton
      Left = 8
      Top = 40
      Width = 265
      Height = 17
      Caption = 'Tous les fichiers'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = RadioToutClick
    end
    object RadioDirOnly: TRadioButton
      Left = 8
      Top = 56
      Width = 265
      Height = 17
      Caption = 'R'#233'pertoire actuel uniquement'
      TabOrder = 2
      OnClick = RadioDirOnlyClick
    end
  end
  object txtSearch: TEdit
    Left = 8
    Top = 8
    Width = 225
    Height = 21
    TabOrder = 1
  end
  object cmdSearch: TButton
    Left = 240
    Top = 8
    Width = 51
    Height = 21
    Caption = 'Go!'
    Default = True
    TabOrder = 2
    OnClick = cmdSearchClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 128
    Width = 352
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 50
      end>
  end
  object cmdOk: TButton
    Left = 296
    Top = 8
    Width = 51
    Height = 21
    Caption = 'Exit'
    Default = True
    TabOrder = 4
    OnClick = cmdOkClick
  end
end

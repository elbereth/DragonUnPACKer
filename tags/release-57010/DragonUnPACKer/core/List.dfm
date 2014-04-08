object frmList: TfrmList
  Left = 199
  Top = 238
  BorderStyle = bsToolWindow
  Caption = 'Cr'#233'er une liste'
  ClientHeight = 303
  ClientWidth = 446
  Color = clBtnFace
  TransparentColorValue = clLime
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 433
    Height = 113
    Caption = 'Template'
    TabOrder = 0
    object strVersion: TLabel
      Left = 8
      Top = 40
      Width = 81
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Version:'
    end
    object strAuthor: TLabel
      Left = 8
      Top = 56
      Width = 81
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Auteur:'
    end
    object strEmail: TLabel
      Left = 8
      Top = 72
      Width = 81
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Email:'
    end
    object strURL: TLabel
      Left = 8
      Top = 88
      Width = 81
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'URL:'
    end
    object lblVersion: TLabel
      Left = 96
      Top = 40
      Width = 329
      Height = 13
      AutoSize = False
      Caption = '-'
    end
    object lblAuthor: TLabel
      Left = 96
      Top = 56
      Width = 329
      Height = 13
      AutoSize = False
      Caption = '-'
    end
    object lblEmail: TLabel
      Left = 96
      Top = 72
      Width = 329
      Height = 13
      AutoSize = False
      Caption = '-'
    end
    object lblURL: TLabel
      Left = 96
      Top = 88
      Width = 329
      Height = 13
      AutoSize = False
      Caption = '-'
    end
    object lstTemplates: TComboBox
      Left = 8
      Top = 16
      Width = 417
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = lstTemplatesChange
    end
  end
  object Panel1: TPanel
    Left = 8
    Top = 128
    Width = 204
    Height = 104
    BevelOuter = bvNone
    BorderWidth = 1
    BorderStyle = bsSingle
    TabOrder = 1
    object imgPreview: TImage
      Left = 0
      Top = 0
      Width = 200
      Height = 100
    end
  end
  object grp2: TGroupBox
    Left = 224
    Top = 128
    Width = 217
    Height = 89
    Caption = 'Liste'
    TabOrder = 2
    object optSelected: TRadioButton
      Left = 8
      Top = 16
      Width = 201
      Height = 17
      Caption = 'Entr'#233'es s'#233'lectionn'#233'es'
      TabOrder = 0
      OnClick = optSelectedClick
    end
    object optAll: TRadioButton
      Left = 8
      Top = 32
      Width = 201
      Height = 17
      Caption = 'Toutes les entr'#233'es'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = optAllClick
    end
    object optCurrentDir: TRadioButton
      Left = 8
      Top = 48
      Width = 201
      Height = 17
      Caption = 'R'#233'pertoire actuel'
      TabOrder = 2
      OnClick = optCurrentDirClick
    end
    object chkSubDirs: TCheckBox
      Left = 24
      Top = 64
      Width = 185
      Height = 17
      Caption = 'Inclure les sous-r'#233'pertoires'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = chkSubDirsClick
    end
  end
  object grp3: TGroupBox
    Left = 8
    Top = 240
    Width = 353
    Height = 41
    Caption = 'Ordre de Tri'
    TabOrder = 3
    object optSortAlpha: TRadioButton
      Left = 8
      Top = 16
      Width = 97
      Height = 17
      Caption = 'Alphab'#233'tique'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = optSortAlphaClick
    end
    object optSortSize: TRadioButton
      Left = 104
      Top = 16
      Width = 81
      Height = 17
      Caption = 'Taille'
      TabOrder = 1
      OnClick = optSortSizeClick
    end
    object optSortOffset: TRadioButton
      Left = 184
      Top = 16
      Width = 73
      Height = 17
      Caption = 'Position'
      TabOrder = 2
      OnClick = optSortOffsetClick
    end
    object optSortInvert: TCheckBox
      Left = 256
      Top = 16
      Width = 89
      Height = 17
      Caption = 'D'#233'croissant'
      TabOrder = 3
      OnClick = optSortInvertClick
    end
  end
  object status: TStatusBar
    Left = 0
    Top = 284
    Width = 446
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object cmdGo: TButton
    Left = 368
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Continuer'
    TabOrder = 5
    OnClick = cmdGoClick
  end
  object cmdCancel: TButton
    Left = 368
    Top = 224
    Width = 75
    Height = 25
    Caption = 'Annuler'
    TabOrder = 6
    OnClick = cmdCancelClick
  end
  object chkSort: TCheckBox
    Left = 232
    Top = 224
    Width = 129
    Height = 17
    Caption = 'Trier:'
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = chkSortClick
  end
  object panSortDisabled: TPanel
    Left = 8
    Top = 242
    Width = 353
    Height = 39
    BevelOuter = bvNone
    Caption = 'ATTENTION: Activer le tri ralentira enormement le traitement...'
    TabOrder = 8
    Visible = False
  end
  object SaveDialog: TSaveDialog
    Left = 408
    Top = 144
  end
end

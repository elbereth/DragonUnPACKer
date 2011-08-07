object frmConvert: TfrmConvert
  Left = 456
  Top = 259
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Convert'
  ClientHeight = 62
  ClientWidth = 361
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object grpPal: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 49
    Caption = 'Palette'
    TabOrder = 0
    object cmdAdd: TButton
      Left = 200
      Top = 16
      Width = 57
      Height = 21
      Caption = 'Add'
      TabOrder = 1
      OnClick = cmdAddClick
    end
    object lstPal: TComboBox
      Left = 8
      Top = 16
      Width = 185
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object cmdRemove: TButton
      Left = 200
      Top = 16
      Width = 57
      Height = 21
      Caption = 'Remove'
      TabOrder = 2
      Visible = False
      OnClick = cmdRemoveClick
    end
  end
  object cmdGo: TButton
    Left = 280
    Top = 16
    Width = 75
    Height = 33
    Caption = 'Convertir'
    Default = True
    TabOrder = 1
    OnClick = cmdGoClick
  end
  object grpAdd: TGroupBox
    Left = 8
    Top = 64
    Width = 345
    Height = 121
    Caption = 'Ajout d'#39'une nouvelle palette'
    TabOrder = 2
    object lblSource: TLabel
      Left = 8
      Top = 19
      Width = 49
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Source:'
    end
    object lblName: TLabel
      Left = 8
      Top = 43
      Width = 49
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Name:'
    end
    object lblAuthor: TLabel
      Left = 8
      Top = 67
      Width = 49
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Author:'
    end
    object lblFormat: TLabel
      Left = 8
      Top = 91
      Width = 49
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Format:'
    end
    object txtSource: TEdit
      Left = 64
      Top = 16
      Width = 241
      Height = 21
      TabOrder = 0
      OnChange = txtSourceChange
    end
    object cmdBrowse: TButton
      Left = 312
      Top = 16
      Width = 21
      Height = 21
      Caption = '+'
      TabOrder = 1
      OnClick = cmdBrowseClick
    end
    object txtName: TEdit
      Left = 64
      Top = 40
      Width = 273
      Height = 21
      TabOrder = 2
      Text = 'Unknown'
      OnChange = txtNameChange
    end
    object txtAuthor: TEdit
      Left = 64
      Top = 64
      Width = 273
      Height = 21
      TabOrder = 3
      Text = 'Unknown'
    end
    object lstFormats: TComboBox
      Left = 64
      Top = 88
      Width = 185
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = 'PCX - ZSoft Paintbrush v5'
      Items.Strings = (
        'PCX - ZSoft Paintbrush v5'
        'BMP - Windows BitMaP (8bit ARGB)'
        'PAL - Microsoft Palette (RIFF)'
        'PSPPALETTE - Jasc PSP Palette'
        'RAW - Binary (RGB)'
        'RAW - Binary (BGR)')
    end
    object cmdAddPal: TButton
      Left = 256
      Top = 88
      Width = 81
      Height = 21
      Caption = 'Add Palette'
      Enabled = False
      TabOrder = 5
      OnClick = cmdAddPalClick
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 
      'Palettes|*.pcx;*.bmp;*.pal;*.psppalette;*.bin;*.raw|Windows BitM' +
      'aP (*.BMP)|*.bmp|Microsoft Palette (*.PAL)|*.pal|Jasc PSP Palett' +
      'e (*.PSPPALETTE)|*.psppalette|Raw 768bytes Binary Palette (*.*)|' +
      '*.*|ZSoft Paintbrush v5 (*.PCX)|*.pcx'
    Left = 328
    Top = 8
  end
end

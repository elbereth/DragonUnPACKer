object frmDrvInfo: TfrmDrvInfo
  Left = 195
  Top = 407
  BorderStyle = bsToolWindow
  Caption = 'Informations'
  ClientHeight = 282
  ClientWidth = 236
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClick = FormClick
  PixelsPerInch = 96
  TextHeight = 13
  object Driver: TGroupBox
    Left = 8
    Top = 120
    Width = 217
    Height = 153
    Caption = 'Driver'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = FormClick
    object strName: TLabel
      Left = 8
      Top = 16
      Width = 41
      Height = 13
      AutoSize = False
      Caption = 'Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object strAuthor: TLabel
      Left = 8
      Top = 32
      Width = 41
      Height = 13
      AutoSize = False
      Caption = 'Author:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object strComment: TLabel
      Left = 8
      Top = 64
      Width = 161
      Height = 13
      AutoSize = False
      Caption = 'Comment:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblName: TLabel
      Left = 58
      Top = 16
      Width = 151
      Height = 13
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblAuthor: TLabel
      Left = 58
      Top = 32
      Width = 151
      Height = 17
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblVersion: TLabel
      Left = 58
      Top = 48
      Width = 151
      Height = 13
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object strVersion: TLabel
      Left = 8
      Top = 48
      Width = 49
      Height = 13
      AutoSize = False
      Caption = 'Version:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object bevComment: TBevel
      Left = 8
      Top = 80
      Width = 201
      Height = 65
    end
    object lblComment: TLabel
      Left = 9
      Top = 81
      Width = 199
      Height = 63
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = False
      WordWrap = True
      OnClick = FormClick
    end
  end
  object Fichier: TGroupBox
    Left = 8
    Top = 8
    Width = 217
    Height = 105
    Caption = 'Fichier'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = FormClick
    object strFileFormat: TLabel
      Left = 8
      Top = 16
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'Format:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object strFileEntries: TLabel
      Left = 8
      Top = 32
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'Entries:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object strFileSize: TLabel
      Left = 8
      Top = 48
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'Size:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object strFileLoadTime: TLabel
      Left = 8
      Top = 64
      Width = 65
      Height = 13
      AutoSize = False
      Caption = 'Load time:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblFileFormat: TLabel
      Left = 80
      Top = 16
      Width = 129
      Height = 13
      AutoSize = False
      Caption = 'WAD3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblFileEntries: TLabel
      Left = 80
      Top = 32
      Width = 129
      Height = 13
      AutoSize = False
      Caption = '3456'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblFileSize: TLabel
      Left = 80
      Top = 48
      Width = 129
      Height = 13
      AutoSize = False
      Caption = '652321053 bytes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblFileLoadTime: TLabel
      Left = 80
      Top = 64
      Width = 129
      Height = 13
      AutoSize = False
      Caption = '5230ms'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
    object lblFileTotalTime: TLabel
      Left = 80
      Top = 80
      Width = 129
      Height = 13
      AutoSize = False
      Caption = '0ms'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormClick
    end
  end
end

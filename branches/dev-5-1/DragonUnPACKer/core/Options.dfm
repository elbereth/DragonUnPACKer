object frmConfig: TfrmConfig
  Left = 199
  Top = 241
  BorderStyle = bsToolWindow
  Caption = 'Configuration'
  ClientHeight = 295
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tabLook: TPanel
    Left = 144
    Top = 8
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 2
    object strLookList: TLabel
      Left = 0
      Top = 0
      Width = 425
      Height = 13
      AutoSize = False
      Caption = 'Fichiers de Look:'
    end
    object lstLook: TListBox
      Left = 0
      Top = 16
      Width = 441
      Height = 121
      ItemHeight = 13
      TabOrder = 0
      OnClick = lstLookClick
      OnKeyDown = FormKeyDown
    end
    object grpLookInfo: TGroupBox
      Left = 0
      Top = 144
      Width = 441
      Height = 137
      Caption = 'Information'
      TabOrder = 1
      object strLookName: TLabel
        Left = 8
        Top = 16
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Nom:'
      end
      object strLookAuthor: TLabel
        Left = 8
        Top = 32
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Auteur:'
      end
      object strLookEmail: TLabel
        Left = 8
        Top = 48
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'E-mail:'
      end
      object lblLookName: TLabel
        Left = 64
        Top = 16
        Width = 369
        Height = 13
        AutoSize = False
      end
      object lblLookAuthor: TLabel
        Left = 64
        Top = 32
        Width = 369
        Height = 13
        AutoSize = False
      end
      object lblLookEmail: TLabel
        Left = 64
        Top = 48
        Width = 369
        Height = 13
        AutoSize = False
      end
      object strLookComment: TLabel
        Left = 8
        Top = 64
        Width = 57
        Height = 13
        AutoSize = False
        Caption = 'Comment:'
      end
      object Panel2: TPanel
        Left = 64
        Top = 64
        Width = 369
        Height = 65
        BevelOuter = bvLowered
        TabOrder = 0
        object lblLookComment: TLabel
          Left = 1
          Top = 1
          Width = 3
          Height = 13
        end
      end
    end
  end
  object tabPlugins: TPanel
    Left = 144
    Top = 8
    Width = 441
    Height = 281
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    object strDriversList: TLabel
      Left = 0
      Top = 0
      Width = 241
      Height = 13
      AutoSize = False
      Caption = 'Drivers:'
    end
    object cmdDrvSetup: TButton
      Left = 366
      Top = 0
      Width = 75
      Height = 17
      Caption = 'Setup'
      Enabled = False
      TabOrder = 0
      OnClick = cmdDrvSetupClick
      OnKeyDown = FormKeyDown
    end
    object grpDrvInfo: TGroupBox
      Left = 0
      Top = 144
      Width = 305
      Height = 137
      Caption = 'Driver Info'
      TabOrder = 1
      object strDrvInfoAuthor: TLabel
        Left = 8
        Top = 32
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Author:'
      end
      object lblDrvInfoAuthor: TLabel
        Left = 80
        Top = 32
        Width = 217
        Height = 13
        AutoSize = False
      end
      object strDrvInfoVersion: TLabel
        Left = 8
        Top = 16
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Version:'
      end
      object lblDrvInfoVersion: TLabel
        Left = 80
        Top = 16
        Width = 217
        Height = 13
        AutoSize = False
      end
      object strDrvInfoComments: TLabel
        Left = 8
        Top = 48
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Comments:'
      end
      object Panel1: TPanel
        Left = 80
        Top = 48
        Width = 217
        Height = 81
        BevelInner = bvLowered
        BevelOuter = bvNone
        TabOrder = 0
        object lblDrvInfoComments: TLabel
          Left = 1
          Top = 1
          Width = 215
          Height = 79
          AutoSize = False
          WordWrap = True
        end
      end
    end
    object cmdDrvAbout: TButton
      Left = 288
      Top = 0
      Width = 75
      Height = 17
      Caption = 'About'
      Enabled = False
      TabOrder = 2
      OnClick = cmdDrvAboutClick
      OnKeyDown = FormKeyDown
    end
    object lstDrivers2: TListView
      Left = 0
      Top = 24
      Width = 441
      Height = 113
      Columns = <
        item
          Caption = 'P'
          Width = 30
        end
        item
          Caption = 'Plugin name'
          Width = 220
        end
        item
          Caption = 'Version'
          Width = 105
        end
        item
          Caption = 'Filename'
          Width = 65
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 3
      ViewStyle = vsReport
      OnChange = lstDrivers2Change
      OnKeyDown = FormKeyDown
    end
    object grpAdvInfo: TGroupBox
      Left = 312
      Top = 144
      Width = 129
      Height = 137
      Caption = 'Advanced Info'
      TabOrder = 4
      object lblDUDI: TLabel
        Left = 8
        Top = 18
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'DUDI :'
      end
      object lblIntVer: TLabel
        Left = 8
        Top = 37
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Int.Ver. :'
      end
      object lblPriority: TLabel
        Left = 8
        Top = 61
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Priority :'
      end
      object txtDUDI: TStaticText
        Left = 64
        Top = 16
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 0
      end
      object txtIntVer: TStaticText
        Left = 64
        Top = 35
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 1
      end
      object trkPriority: TTrackBar
        Left = 8
        Top = 75
        Width = 113
        Height = 33
        Max = 200
        PageSize = 10
        Frequency = 10
        TabOrder = 2
        TickMarks = tmTopLeft
        OnChange = trkPriorityChange
      end
      object txtPriority: TStaticText
        Left = 64
        Top = 59
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 3
      end
      object butRefresh: TButton
        Left = 16
        Top = 112
        Width = 97
        Height = 17
        Caption = 'Refresh List'
        TabOrder = 4
        OnClick = butRefreshClick
        OnKeyDown = FormKeyDown
      end
    end
  end
  object tabHyperRipper: TPanel
    Left = 144
    Top = 8
    Width = 441
    Height = 281
    BevelOuter = bvNone
    TabOrder = 7
    Visible = False
    object lblHR: TLabel
      Left = 0
      Top = 0
      Width = 265
      Height = 13
      AutoSize = False
      Caption = 'HyperRipper plugins:'
    end
    object cmdHRSetup: TButton
      Left = 366
      Top = 0
      Width = 75
      Height = 17
      Caption = 'Setup'
      Enabled = False
      TabOrder = 0
      OnClick = cmdHRSetupClick
      OnKeyDown = FormKeyDown
    end
    object grpHRInfo: TGroupBox
      Left = 0
      Top = 144
      Width = 305
      Height = 137
      Caption = 'Driver Info'
      TabOrder = 1
      object strHRInfoAuthor: TLabel
        Left = 8
        Top = 32
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Author:'
      end
      object lblHRInfoAuthor: TLabel
        Left = 80
        Top = 32
        Width = 217
        Height = 13
        AutoSize = False
      end
      object strHRInfoVersion: TLabel
        Left = 8
        Top = 16
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Version:'
      end
      object lblHRInfoVersion: TLabel
        Left = 80
        Top = 16
        Width = 217
        Height = 13
        AutoSize = False
      end
      object strHRInfoComments: TLabel
        Left = 8
        Top = 48
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Comments:'
      end
      object Panel5: TPanel
        Left = 80
        Top = 48
        Width = 217
        Height = 81
        BevelInner = bvLowered
        BevelOuter = bvNone
        TabOrder = 0
        object lblHRInfoComments: TLabel
          Left = 1
          Top = 1
          Width = 215
          Height = 79
          AutoSize = False
          WordWrap = True
        end
      end
    end
    object cmdHRAbout: TButton
      Left = 288
      Top = 0
      Width = 75
      Height = 17
      Caption = 'About'
      Enabled = False
      TabOrder = 2
      OnClick = cmdHRAboutClick
      OnKeyDown = FormKeyDown
    end
    object lstHR2: TListView
      Left = 0
      Top = 24
      Width = 441
      Height = 113
      Columns = <
        item
          Caption = 'Plugin name'
          Width = 250
        end
        item
          Caption = 'Version'
          Width = 105
        end
        item
          Caption = 'Filename'
          Width = 65
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 3
      ViewStyle = vsReport
      OnChange = lstHR2Change
      OnKeyDown = FormKeyDown
    end
    object grpHRAdvInfo: TGroupBox
      Left = 312
      Top = 144
      Width = 129
      Height = 137
      Caption = 'Advanced Info'
      TabOrder = 4
      object lblDUHI: TLabel
        Left = 8
        Top = 18
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'DUHI :'
      end
      object lblHIntVer: TLabel
        Left = 8
        Top = 37
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Int.Ver. :'
      end
      object txtDUHI: TStaticText
        Left = 64
        Top = 16
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 0
      end
      object txtHIntVer: TStaticText
        Left = 64
        Top = 35
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 1
      end
    end
  end
  object tabConvert: TPanel
    Left = 144
    Top = 8
    Width = 441
    Height = 281
    BevelOuter = bvNone
    TabOrder = 5
    Visible = False
    object strConvertList: TLabel
      Left = 0
      Top = 0
      Width = 257
      Height = 13
      AutoSize = False
      Caption = 'Convert plugins:'
    end
    object cmdCnvSetup: TButton
      Left = 366
      Top = 0
      Width = 75
      Height = 17
      Caption = 'Setup'
      Enabled = False
      TabOrder = 0
      OnClick = cmdCnvSetupClick
      OnKeyDown = FormKeyDown
    end
    object cmdCnvAbout: TButton
      Left = 288
      Top = 0
      Width = 75
      Height = 17
      Caption = 'About'
      Enabled = False
      TabOrder = 1
      OnClick = cmdCnvAboutClick
      OnKeyDown = FormKeyDown
    end
    object grpCnvInfo: TGroupBox
      Left = 0
      Top = 144
      Width = 305
      Height = 137
      Caption = 'Convert plugin info'
      TabOrder = 2
      object strCnvInfoAuthor: TLabel
        Left = 8
        Top = 32
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Author:'
      end
      object lblCnvInfoAuthor: TLabel
        Left = 80
        Top = 32
        Width = 217
        Height = 13
        AutoSize = False
      end
      object strCnvInfoVersion: TLabel
        Left = 8
        Top = 16
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Version:'
      end
      object lblCnvInfoVersion: TLabel
        Left = 80
        Top = 16
        Width = 217
        Height = 13
        AutoSize = False
      end
      object strCnvInfoComments: TLabel
        Left = 8
        Top = 48
        Width = 65
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Comments:'
      end
      object Panel3: TPanel
        Left = 80
        Top = 48
        Width = 217
        Height = 81
        BevelInner = bvLowered
        BevelOuter = bvNone
        TabOrder = 0
        object lblCnvInfoComments: TLabel
          Left = 1
          Top = 1
          Width = 215
          Height = 79
          AutoSize = False
          WordWrap = True
        end
      end
    end
    object lstConvert2: TListView
      Left = 0
      Top = 24
      Width = 441
      Height = 113
      Columns = <
        item
          Caption = 'Plugin name'
          Width = 250
        end
        item
          Caption = 'Version'
          Width = 105
        end
        item
          Caption = 'Filename'
          Width = 65
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 3
      ViewStyle = vsReport
      OnChange = lstConvert2Change
      OnKeyDown = FormKeyDown
    end
    object grpCnvAdvInfo: TGroupBox
      Left = 312
      Top = 144
      Width = 129
      Height = 137
      Caption = 'Advanced Info'
      TabOrder = 4
      object lblDUCI: TLabel
        Left = 8
        Top = 18
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'DUCI :'
      end
      object lblCIntVer: TLabel
        Left = 8
        Top = 37
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Int.Ver. :'
      end
      object txtDUCI: TStaticText
        Left = 64
        Top = 16
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 0
      end
      object txtCIntVer: TStaticText
        Left = 64
        Top = 35
        Width = 58
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = '-'
        TabOrder = 1
      end
    end
  end
  object tabAssoc: TGroupBox
    Left = 144
    Top = 8
    Width = 441
    Height = 281
    Caption = 'Types de fichiers'
    TabOrder = 4
    Visible = False
    object grpAssoc1: TGroupBox
      Left = 10
      Top = 15
      Width = 423
      Height = 258
      Caption = 'Extensions associ'#233'es'
      TabOrder = 0
      object cmdTypesAll: TButton
        Left = 72
        Top = 16
        Width = 57
        Height = 25
        Caption = 'Toutes'
        TabOrder = 0
        OnClick = cmdTypesAllClick
        OnKeyDown = FormKeyDown
      end
      object cmdTypesNone: TButton
        Left = 8
        Top = 16
        Width = 59
        Height = 25
        Caption = 'Aucunes'
        TabOrder = 1
        OnClick = cmdTypesNoneClick
        OnKeyDown = FormKeyDown
      end
      object lstTypes: TCheckListBox
        Left = 8
        Top = 48
        Width = 409
        Height = 201
        OnClickCheck = lstTypesClickCheck
        Columns = 7
        ItemHeight = 13
        Sorted = True
        TabOrder = 2
        OnKeyDown = FormKeyDown
      end
    end
    object GroupBox2: TGroupBox
      Left = 288
      Top = 16
      Width = 145
      Height = 89
      Caption = 'Options'
      TabOrder = 1
      Visible = False
    end
    object grpAssoc2: TGroupBox
      Left = 288
      Top = 136
      Width = 145
      Height = 137
      Caption = 'Ic'#244'ne et description'
      Enabled = False
      TabOrder = 2
      Visible = False
      object imgAssocIcon: TImage
        Left = 56
        Top = 24
        Width = 32
        Height = 32
        Enabled = False
        Visible = False
      end
      object Edit1: TEdit
        Left = 8
        Top = 104
        Width = 129
        Height = 21
        AutoSelect = False
        AutoSize = False
        Enabled = False
        ReadOnly = True
        TabOrder = 0
        Text = 'Dragon UnPACKer Archive'
        Visible = False
        OnKeyDown = FormKeyDown
      end
      object trkAssocIcon: TTrackBar
        Left = 8
        Top = 64
        Width = 129
        Height = 33
        Enabled = False
        Max = 1
        TabOrder = 1
        TickMarks = tmTopLeft
        Visible = False
        OnKeyDown = FormKeyDown
      end
    end
  end
  object tabBasic: TPanel
    Left = 144
    Top = 8
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 1
    object grpLanguage: TGroupBox
      Left = 0
      Top = 184
      Width = 441
      Height = 97
      Caption = 'Langue'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      object strAuthor: TLabel
        Left = 8
        Top = 44
        Width = 34
        Height = 13
        Caption = 'Auteur:'
      end
      object lblAuthor: TLabel
        Left = 48
        Top = 44
        Width = 385
        Height = 13
        AutoSize = False
      end
      object strEmail: TLabel
        Left = 8
        Top = 59
        Width = 31
        Height = 13
        Caption = 'E-mail:'
      end
      object strURL: TLabel
        Left = 8
        Top = 76
        Width = 25
        Height = 13
        Caption = 'URL:'
      end
      object lblEmail: TLabel
        Left = 48
        Top = 59
        Width = 385
        Height = 13
        AutoSize = False
      end
      object lblURL: TLabel
        Left = 40
        Top = 76
        Width = 393
        Height = 13
        AutoSize = False
      end
      object lstLangues: TComboBoxEx
        Left = 8
        Top = 16
        Width = 425
        Height = 22
        ItemsEx = <
          item
            Caption = 'Fran'#231'ais (French)'
            ImageIndex = 0
            SelectedImageIndex = 0
          end>
        Style = csExDropDownList
        ItemHeight = 16
        TabOrder = 0
        OnKeyDown = FormKeyDown
        OnSelect = lstLanguesSelect
        Images = imgLstLangue
        DropDownCount = 8
      end
    end
    object grpOptions: TGroupBox
      Left = 0
      Top = 0
      Width = 441
      Height = 177
      Caption = 'Options'
      TabOrder = 1
      object ChkNoSplash: TCheckBox
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Ne pas afficher d'#39#233'cran de d'#233'marrage'
        TabOrder = 0
        OnClick = ChkNoSplashClick
        OnKeyDown = FormKeyDown
      end
      object ChkOneInstance: TCheckBox
        Left = 8
        Top = 32
        Width = 425
        Height = 17
        Caption = 'Permettre seulement une instance du programme a la fois'
        TabOrder = 1
        OnClick = ChkOneInstanceClick
        OnKeyDown = FormKeyDown
      end
      object ChkSmartOpen: TCheckBox
        Left = 8
        Top = 48
        Width = 425
        Height = 17
        Caption = 'D'#233'tection intelligente des formats de fichiers'
        TabOrder = 2
        OnClick = ChkSmartOpenClick
        OnKeyDown = FormKeyDown
      end
      object chkRegistryIcons: TCheckBox
        Left = 8
        Top = 64
        Width = 425
        Height = 17
        Caption = 'Rechercher les icones en base de registre'
        TabOrder = 3
        OnClick = chkRegistryIconsClick
      end
      object chkUseHyperRipper: TCheckBox
        Left = 8
        Top = 80
        Width = 425
        Height = 17
        Caption = 
          'Utiliser l'#39'HyperRipper si aucun plugin n'#39'arrive '#224' ouvrir le fich' +
          'ier'
        TabOrder = 4
        WordWrap = True
        OnClick = chkUseHyperRipperClick
      end
      object chkLog: TCheckBox
        Left = 8
        Top = 96
        Width = 425
        Height = 17
        Caption = 'Afficher le journal d'#39'ex'#233'cution'
        TabOrder = 5
        OnClick = chkLogClick
      end
    end
  end
  object cmdOk: TButton
    Left = 8
    Top = 264
    Width = 129
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOkClick
    OnKeyDown = FormKeyDown
  end
  object treeConfig: TTreeView
    Left = 8
    Top = 8
    Width = 129
    Height = 249
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    HideSelection = False
    Indent = 19
    ParentFont = False
    ReadOnly = True
    TabOrder = 6
    OnChange = treeConfigChange
    OnKeyDown = FormKeyDown
    Items.Data = {
      040000002A0000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      114F7074696F6E732067E96EE972616C6573200000000000000000000000FFFF
      FFFFFFFFFFFF000000000300000007506C7567696E7320000000000000000000
      0000FFFFFFFFFFFFFFFF000000000000000007436F6E76657274200000000000
      000000000000FFFFFFFFFFFFFFFF000000000000000007447269766572732400
      00000000000000000000FFFFFFFFFFFFFFFF00000000000000000B4879706572
      5269707065721D0000000000000000000000FFFFFFFFFFFFFFFF000000000100
      0000044C6F6F6B240000000000000000000000FFFFFFFFFFFFFFFF0000000000
      0000000B4C6F67206F7074696F6E732E0000000000000000000000FFFFFFFFFF
      FFFFFF0000000000000000154173736F63696174696F6E732066696368696572
      73}
  end
  object imgLstLangue: TImageList
    BlendColor = clBlack
    DrawingStyle = dsTransparent
    Masked = False
    Left = 8
    Top = 8
    Bitmap = {
      494C010101000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000FFFF000000000000
      FFFF00000000000083C100000000000083C100000000000083C1000000000000
      83C100000000000083C100000000000083C100000000000083C1000000000000
      83C100000000000083C1000000000000FFFF000000000000FFFF000000000000
      FFFF000000000000FFFF00000000000000000000000000000000000000000000
      000000000000}
  end
end

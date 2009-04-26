object frmConfig: TfrmConfig
  Left = 252
  Top = 468
  BorderStyle = bsToolWindow
  Caption = 'Configuration'
  ClientHeight = 295
  ClientWidth = 632
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tabPluginsInfos: TPanel
    Left = 184
    Top = 8
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 10
    Visible = False
    object grpPluginsInfo: TGroupBox
      Left = 0
      Top = 0
      Width = 441
      Height = 281
      Caption = 'Plugins'
      TabOrder = 0
      object lblPluginsConvert: TLabel
        Left = 8
        Top = 16
        Width = 425
        Height = 13
        AutoSize = False
        Caption = 'Convert plugins:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object lblPluginsDrivers: TLabel
        Left = 8
        Top = 112
        Width = 425
        Height = 13
        AutoSize = False
        Caption = 'Drivers plugins:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object lblPluginsHyperRipper: TLabel
        Left = 8
        Top = 208
        Width = 425
        Height = 13
        AutoSize = False
        Caption = 'HyperRipper plugins:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object panPluginsConvert: TPanel
        Left = 8
        Top = 32
        Width = 425
        Height = 65
        BevelOuter = bvLowered
        TabOrder = 0
        object lblPluginsConvertInfo: TLabel
          Left = 1
          Top = 1
          Width = 423
          Height = 63
          Align = alClient
          AutoSize = False
          Caption = 
            'Those plugins will handle the convertion of file formats when ex' +
            'tracting or previewing files. Example: Convert textures from .AR' +
            'T file format to .BMP'
          WordWrap = True
        end
      end
      object panPluginsDrivers: TPanel
        Left = 8
        Top = 128
        Width = 425
        Height = 65
        BevelOuter = bvLowered
        TabOrder = 1
        object lblPluginsDriversInfo: TLabel
          Left = 1
          Top = 1
          Width = 423
          Height = 63
          Align = alClient
          AutoSize = False
          Caption = 
            'Those plugins handle opening file formats so Dragon UnPACKer can' +
            ' browse into them. If a file is not supported that means no driv' +
            'er plugin could load it. HyperRipper handle files with another t' +
            'ype of plugins (see below).'
          WordWrap = True
        end
      end
      object panPluginsHyperRipper: TPanel
        Left = 8
        Top = 224
        Width = 425
        Height = 49
        BevelOuter = bvLowered
        TabOrder = 2
        object lblPluginsHyperRipperInfo: TLabel
          Left = 1
          Top = 1
          Width = 423
          Height = 47
          Align = alClient
          AutoSize = False
          Caption = 
            'Those plugins handle the file format to scan in HyperRipper (ex:' +
            ' MPEG Audio, BMP, etc..)'
          WordWrap = True
        end
      end
    end
  end
  object tabBasic: TPanel
    Left = 184
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
      object lblFindNewLanguages: TLabel
        Left = 296
        Top = 16
        Width = 141
        Height = 25
        Cursor = crHandPoint
        Alignment = taCenter
        AutoSize = False
        Caption = 'Trouver d'#39'autres traductions...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Transparent = True
        WordWrap = True
        OnClick = lblFindNewLanguagesClick
        OnMouseEnter = lblFindNewLanguagesMouseEnter
        OnMouseLeave = lblFindNewLanguagesMouseLeave
      end
      object lstLangues: TComboBoxEx
        Left = 8
        Top = 16
        Width = 281
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
      Height = 161
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
    end
  end
  object tabLog: TPanel
    Left = 184
    Top = 8
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 8
    object grpLogVerbose: TGroupBox
      Left = 0
      Top = 200
      Width = 441
      Height = 81
      Caption = 'Verbose Options'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      object strVerbose: TLabel
        Left = 8
        Top = 16
        Width = 425
        Height = 13
        AutoSize = False
        Caption = 'Select level of verbose for log:'
      end
      object lblVerbose: TLabel
        Left = 168
        Top = 32
        Width = 265
        Height = 41
        AutoSize = False
        Layout = tlCenter
        WordWrap = True
      end
      object trackbarVerbose: TTrackBar
        Left = 8
        Top = 40
        Width = 150
        Height = 33
        Max = 2
        PageSize = 1
        TabOrder = 0
        OnChange = trackbarVerboseChange
      end
    end
    object grpLogOptions: TGroupBox
      Left = 0
      Top = 0
      Width = 441
      Height = 193
      Caption = 'Log Options'
      TabOrder = 1
      object chkLog: TCheckBox
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Afficher le journal d'#39'ex'#233'cution'
        TabOrder = 0
        OnClick = chkLogClick
      end
    end
  end
  object tabAdvanced: TPanel
    Left = 183
    Top = 8
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 9
    Visible = False
    object grpAdvOpenFile: TGroupBox
      Left = 0
      Top = 120
      Width = 441
      Height = 41
      Caption = 'Options for '#39'Open file'#39
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      object chkMakeExtractDefault: TCheckBox
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Make '#39'Extract file... Without conversion'#39' the default option'
        TabOrder = 0
        OnClick = chkMakeExtractDefaultClick
      end
    end
    object grpAdvTemp: TGroupBox
      Left = 0
      Top = 0
      Width = 441
      Height = 113
      Caption = 'Temporary Directory'
      TabOrder = 1
      object txtTmpDir: TEdit
        Left = 24
        Top = 85
        Width = 385
        Height = 21
        Enabled = False
        TabOrder = 0
        OnChange = txtTmpDirChange
      end
      object butTmpDirSelect: TButton
        Left = 408
        Top = 85
        Width = 21
        Height = 21
        Caption = '+'
        Enabled = False
        TabOrder = 1
        OnClick = butTmpDirSelectClick
      end
      object radTmpDirDefault: TRadioButton
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Use auto-detected temporary directory'
        Checked = True
        TabOrder = 2
        TabStop = True
        OnClick = radTmpDirOtherClick
      end
      object radTmpDirOther: TRadioButton
        Left = 8
        Top = 64
        Width = 425
        Height = 17
        Caption = 'Use defined temporary directory:'
        TabOrder = 3
        OnClick = radTmpDirOtherClick
      end
      object txtTmpDirDefault: TEdit
        Left = 24
        Top = 36
        Width = 409
        Height = 21
        ReadOnly = True
        TabOrder = 4
      end
    end
    object grpAdvBufferSize: TGroupBox
      Left = 0
      Top = 168
      Width = 441
      Height = 73
      Caption = 'Buffer memory'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 2
      object lblBufferSize: TLabel
        Left = 8
        Top = 16
        Width = 425
        Height = 13
        AutoSize = False
        Caption = 'Select the size of the extraction buffer:'
      end
      object lstBufferSize: TComboBox
        Left = 8
        Top = 40
        Width = 425
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = lstBufferSizeChange
        Items.Strings = (
          '1 byte -- No buffer'
          '512 bytes'
          '1 kbytes'
          '2 kbytes'
          '4 kbytes'
          '8 kbytes'
          '16 kbytes -- Default'
          '32 kbytes'
          '64 kbytes'
          '128 kbytes'
          '256 kbytes'
          '512 kbytes'
          '1 Mbytes')
      end
    end
  end
  object tabPreview: TPanel
    Left = 183
    Top = 6
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 11
    Visible = False
    object grpPreviewBasic: TGroupBox
      Left = 0
      Top = 0
      Width = 441
      Height = 41
      Caption = 'Preview Options'
      TabOrder = 0
      object chkPreviewEnable: TCheckBox
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Enable preview'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = chkPreviewEnableClick
      end
    end
    object grpPreviewLimits: TGroupBox
      Left = 0
      Top = 48
      Width = 441
      Height = 89
      Caption = 'Preview Size Limits'
      TabOrder = 1
      object lblPreviewLimit: TLabel
        Left = 24
        Top = 59
        Width = 73
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Limit:'
      end
      object lblPreviewLimitBytes: TLabel
        Left = 384
        Top = 59
        Width = 49
        Height = 13
        AutoSize = False
        Caption = 'Bytes'
      end
      object txtPreviewLimitSize: TLabel
        Left = 296
        Top = 59
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '1048576'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object optPreviewLimitNo: TRadioButton
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Do not limit size of detected files (not recommended)'
        TabOrder = 0
        OnClick = optPreviewLimitNoClick
      end
      object optPreviewLimitYes: TRadioButton
        Left = 8
        Top = 32
        Width = 425
        Height = 17
        Caption = 'Limit detection of files that can be previewed (recommended)'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = optPreviewLimitYesClick
      end
      object lstPreviewLimit: TComboBox
        Left = 104
        Top = 56
        Width = 185
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 2
        TabOrder = 2
        Text = 'Medium (Recommended)'
        OnChange = lstPreviewLimitChange
        Items.Strings = (
          'Very Low'
          'Low'
          'Medium (Recommended)'
          'High'
          'Very High')
      end
    end
    object grpPreviewDisplay: TGroupBox
      Left = 0
      Top = 144
      Width = 441
      Height = 57
      Caption = 'Preview Display Mode'
      TabOrder = 2
      object optPreviewDisplayFull: TRadioButton
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Original size with scrollbars (if needed)'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = optPreviewDisplayFullClick
      end
      object optPreviewDisplayStretch: TRadioButton
        Left = 8
        Top = 32
        Width = 425
        Height = 17
        Caption = 'Shrinked/Streched to preview panel'
        TabOrder = 1
        OnClick = optPreviewDisplayStretchClick
      end
    end
  end
  object tabLook: TPanel
    Left = 184
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
    Left = 184
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
    Left = 184
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
    Left = 184
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
    Left = 184
    Top = 8
    Width = 441
    Height = 281
    Caption = 'Types de fichiers'
    TabOrder = 4
    Visible = False
    object imgAssocIcon: TImage
      Left = 160
      Top = 80
      Width = 32
      Height = 32
      Enabled = False
      Transparent = True
    end
    object lblAssocInfo: TLabel
      Left = 144
      Top = 16
      Width = 289
      Height = 41
      AutoSize = False
      Caption = 
        'Select the extensions Dragon UnPACKer should open when you will ' +
        'double-click them in the Explorer:'
      WordWrap = True
    end
    object lblAssocCurIcon: TLabel
      Left = 144
      Top = 56
      Width = 289
      Height = 17
      AutoSize = False
      Caption = 'Currently associated icon:'
      WordWrap = True
    end
    object imgAssocIcon16: TImage
      Left = 200
      Top = 80
      Width = 16
      Height = 16
      Enabled = False
      Transparent = True
    end
    object cmdTypesNone: TButton
      Left = 8
      Top = 16
      Width = 59
      Height = 25
      Caption = 'Aucunes'
      TabOrder = 0
      OnClick = cmdTypesNoneClick
      OnKeyDown = FormKeyDown
    end
    object cmdTypesAll: TButton
      Left = 72
      Top = 16
      Width = 57
      Height = 25
      Caption = 'Toutes'
      TabOrder = 1
      OnClick = cmdTypesAllClick
      OnKeyDown = FormKeyDown
    end
    object chkAssocOpenWith: TCheckBox
      Left = 144
      Top = 240
      Width = 289
      Height = 33
      Caption = 'Add Windows Explorer extension "Open with Dragon UnPACKer 5"'
      Checked = True
      State = cbChecked
      TabOrder = 7
      WordWrap = True
      OnClick = chkAssocOpenWithClick
      OnKeyDown = FormKeyDown
    end
    object txtAssocText: TEdit
      Left = 160
      Top = 216
      Width = 273
      Height = 21
      AutoSelect = False
      AutoSize = False
      Enabled = False
      TabOrder = 6
      Text = 'Dragon UnPACKer 5 Archive'
      OnChange = txtAssocTextChange
      OnKeyDown = FormKeyDown
    end
    object chkAssocText: TCheckBox
      Left = 144
      Top = 200
      Width = 289
      Height = 17
      Caption = 'Change the association text:'
      TabOrder = 5
      WordWrap = True
      OnClick = chkAssocTextClick
      OnKeyDown = FormKeyDown
    end
    object chkAssocCheckStartup: TCheckBox
      Left = 144
      Top = 120
      Width = 289
      Height = 17
      Caption = 'Verify associations at start-up'
      TabOrder = 2
      WordWrap = True
      OnClick = chkAssocCheckStartupClick
      OnKeyDown = FormKeyDown
    end
    object chkAssocExtIcon: TCheckBox
      Left = 144
      Top = 160
      Width = 289
      Height = 17
      Caption = 'Use external icon'
      TabOrder = 3
      WordWrap = True
      OnClick = chkAssocExtIconClick
      OnKeyDown = FormKeyDown
    end
    object txtAssocExtIcon: TEdit
      Left = 160
      Top = 176
      Width = 253
      Height = 21
      AutoSelect = False
      AutoSize = False
      Enabled = False
      TabOrder = 4
      OnChange = txtAssocExtIconChange
      OnKeyDown = FormKeyDown
    end
    object butAssocExtIconBrowse: TButton
      Left = 412
      Top = 176
      Width = 21
      Height = 21
      Caption = '+'
      Enabled = False
      TabOrder = 8
      OnClick = butAssocExtIconBrowseClick
    end
    object lstTypes: TCheckListBox
      Left = 8
      Top = 48
      Width = 121
      Height = 225
      ItemHeight = 13
      Sorted = True
      TabOrder = 9
      OnClick = lstTypesClick
    end
  end
  object cmdOk: TButton
    Left = 8
    Top = 264
    Width = 169
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
    Width = 169
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
      050000001E0000000500000005000000FFFFFFFFFFFFFFFF0000000002000000
      054261736963210000000F0000000F000000FFFFFFFFFFFFFFFF000000000000
      000008416476616E6365641C0000001000000010000000FFFFFFFFFFFFFFFF00
      00000000000000034C6F67200000000600000006000000FFFFFFFFFFFFFFFF00
      0000000300000007506C7567696E73200000000900000009000000FFFFFFFFFF
      FFFFFF000000000000000007436F6E76657274200000000A0000000A000000FF
      FFFFFFFFFFFFFF00000000000000000744726976657273240000000B0000000B
      000000FFFFFFFFFFFFFFFF00000000000000000B48797065725269707065721D
      0000000800000008000000FFFFFFFFFFFFFFFF0000000000000000044C6F6F6B
      250000000700000007000000FFFFFFFFFFFFFFFF00000000000000000C417373
      6F63696174696F6E73200000001100000011000000FFFFFFFFFFFFFFFF000000
      00000000000750726576696577}
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

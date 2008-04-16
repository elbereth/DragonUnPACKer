object frmConfig: TfrmConfig
  Left = 199
  Top = 241
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
      Top = 88
      Width = 441
      Height = 41
      Caption = 'Options for '#39'Open file'#39
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      object CheckBox2: TCheckBox
        Left = 8
        Top = 16
        Width = 425
        Height = 17
        Caption = 'Make '#39'Extract file... Without conversion'#39' the default option'
        Enabled = False
        TabOrder = 0
        OnClick = chkLogClick
      end
    end
    object grpAdvTemp: TGroupBox
      Left = 0
      Top = 0
      Width = 441
      Height = 81
      Caption = 'Temporary Directory'
      TabOrder = 1
      object chkTmpDefault: TCheckBox
        Left = 8
        Top = 24
        Width = 425
        Height = 17
        Caption = 'By default (detected automatically)'
        Checked = True
        Enabled = False
        State = cbChecked
        TabOrder = 0
        OnClick = chkLogClick
      end
      object txtTmpDir: TEdit
        Left = 24
        Top = 48
        Width = 385
        Height = 21
        Enabled = False
        ReadOnly = True
        TabOrder = 1
      end
      object butTmpDirSelect: TButton
        Left = 408
        Top = 48
        Width = 21
        Height = 21
        Caption = '+'
        Enabled = False
        TabOrder = 2
      end
    end
    object grpAdvBufferSize: TGroupBox
      Left = 0
      Top = 136
      Width = 441
      Height = 89
      Caption = 'Buffer memory'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 2
      object Label3: TLabel
        Left = 8
        Top = 16
        Width = 425
        Height = 13
        AutoSize = False
        Caption = 'Select the size of the extraction buffer:'
      end
      object Label4: TLabel
        Left = 168
        Top = 32
        Width = 265
        Height = 41
        AutoSize = False
        Layout = tlCenter
        WordWrap = True
      end
      object trackBufferSize: TTrackBar
        Left = 8
        Top = 40
        Width = 305
        Height = 33
        Enabled = False
        Min = 1
        PageSize = 1
        Position = 1
        TabOrder = 0
        OnChange = trackbarVerboseChange
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
      Visible = False
    end
    object Label1: TLabel
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
    object Label2: TLabel
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
      Visible = False
    end
    object grpAssoc1: TGroupBox
      Left = 392
      Top = 64
      Width = 41
      Height = 25
      Caption = 'Extensions associ'#233'es'
      TabOrder = 0
      Visible = False
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
    object cmdTypesAll: TButton
      Left = 72
      Top = 16
      Width = 57
      Height = 25
      Caption = 'Toutes'
      TabOrder = 2
      OnClick = cmdTypesAllClick
      OnKeyDown = FormKeyDown
    end
    object CheckBox1: TCheckBox
      Left = 144
      Top = 240
      Width = 289
      Height = 33
      Caption = 'Add Windows Explorer extension "Open with Dragon UnPACKer 5"'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 8
      WordWrap = True
      OnClick = chkLogClick
    end
    object Edit1: TEdit
      Left = 160
      Top = 216
      Width = 273
      Height = 21
      AutoSelect = False
      AutoSize = False
      Enabled = False
      ReadOnly = True
      TabOrder = 7
      Text = 'Game Ressource (Dragon UnPACKer)'
      Visible = False
      OnKeyDown = FormKeyDown
    end
    object CheckBox3: TCheckBox
      Left = 144
      Top = 200
      Width = 289
      Height = 17
      Caption = 'Change the association text:'
      Enabled = False
      TabOrder = 6
      WordWrap = True
      OnClick = chkLogClick
    end
    object CheckBox4: TCheckBox
      Left = 144
      Top = 120
      Width = 289
      Height = 17
      Caption = 'Verify associations at start-up'
      Enabled = False
      TabOrder = 3
      WordWrap = True
      OnClick = chkLogClick
    end
    object CheckBox5: TCheckBox
      Left = 144
      Top = 160
      Width = 289
      Height = 17
      Caption = 'Use external icon'
      Enabled = False
      TabOrder = 4
      WordWrap = True
      OnClick = chkLogClick
    end
    object Edit2: TEdit
      Left = 160
      Top = 176
      Width = 273
      Height = 21
      AutoSelect = False
      AutoSize = False
      Enabled = False
      ReadOnly = True
      TabOrder = 5
      Text = 'Game Ressource (Dragon UnPACKer)'
      Visible = False
      OnKeyDown = FormKeyDown
    end
    object lstTypes: TJvCheckListBox
      Left = 8
      Top = 48
      Width = 121
      Height = 225
      ItemHeight = 13
      Sorted = True
      TabOrder = 9
      OnClick = lstTypesClickCheck
      HorScrollbar = False
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
      040000001E0000000500000005000000FFFFFFFFFFFFFFFF0000000002000000
      054261736963210000000F0000000F000000FFFFFFFFFFFFFFFF000000000000
      000008416476616E6365641C0000001000000010000000FFFFFFFFFFFFFFFF00
      00000000000000034C6F67200000000600000006000000FFFFFFFFFFFFFFFF00
      0000000300000007506C7567696E73200000000900000009000000FFFFFFFFFF
      FFFFFF000000000000000007436F6E76657274200000000A0000000A000000FF
      FFFFFFFFFFFFFF00000000000000000744726976657273240000000B0000000B
      000000FFFFFFFFFFFFFFFF00000000000000000B48797065725269707065721D
      0000000800000008000000FFFFFFFFFFFFFFFF0000000000000000044C6F6F6B
      250000000700000007000000FFFFFFFFFFFFFFFF00000000000000000C417373
      6F63696174696F6E73}
  end
  object tabPluginsInfos: TPanel
    Left = 183
    Top = 8
    Width = 449
    Height = 281
    BevelOuter = bvNone
    TabOrder = 10
    Visible = False
    object GroupBox2: TGroupBox
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
      object Label5: TLabel
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
      object Label7: TLabel
        Left = 8
        Top = 208
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
      object panPluginsConvert: TPanel
        Left = 8
        Top = 32
        Width = 425
        Height = 65
        BevelOuter = bvLowered
        Caption = 'panPluginsConvert'
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
      object Panel6: TPanel
        Left = 8
        Top = 128
        Width = 425
        Height = 65
        BevelOuter = bvLowered
        Caption = 'panPluginsConvert'
        TabOrder = 1
        object Label6: TLabel
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
      object Panel7: TPanel
        Left = 8
        Top = 224
        Width = 425
        Height = 49
        BevelOuter = bvLowered
        Caption = 'panPluginsConvert'
        TabOrder = 2
        object Label8: TLabel
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

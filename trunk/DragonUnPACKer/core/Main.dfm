object dup5Main: Tdup5Main
  Left = 504
  Top = 190
  HelpContext = 1
  AlphaBlendValue = 128
  AutoScroll = False
  Caption = 'Dragon UnPACKer v5'
  ClientHeight = 424
  ClientWidth = 667
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    000004040400010F00000C0C0C0008101B000231010003292D00133231002629
    29000798040008B2040009B205000AB3060000FF000009C6640071D36E007FD7
    7D006802C6007002D6004040FF0004AABD0006D7BE0004E3FE0003E4FE0003E4
    FF00F2F1F700F2FBF200FCFCFC00FEFFFE00FFFFFF0000000000000000000000
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
    000000010101010101010101010100000000000012121D121D0012121D01000A
    0A0A0A0A12121212011C00120000000A0B00000A0A0A0A1D1D1D1D0000000003
    071D12190A0A1D1D1D1D1D110100000018121212120A0A0F101A1D1101000000
    00121212120A0A1313130B0100000000140A0A18180C130A0A0A130000000000
    00051718181D1D000A021D1801000000180A0A150E1D1D0009041D0A01000000
    00080A0A0A1D1D1D0A1B1D000000000000180C0A0A0A1D1D0A1D1D0100000000
    0018180B0A0A0A0A0A0A000000000000000000000B0C0A0A0001000000000000
    000000001618060100000000000000000000000000000000000000000000F800
    00008000000000010000000300008001000080010000C003000080030000C001
    000080010000C0030000C0030000C0070000C00F0000F83F0000F8FF0000}
  Menu = mainMenu
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 113
    Top = 41
    Height = 279
    HelpContext = 2
    MinSize = 20
  end
  object SplitterBottom: TSplitter
    Left = 0
    Top = 320
    Width = 667
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    MinSize = 100
  end
  object SplitterPreview: TSplitter
    Left = 469
    Top = 41
    Height = 279
    HelpContext = 2
    Align = alRight
    MinSize = 20
  end
  object lstContent: TVirtualStringTree
    Left = 116
    Top = 41
    Width = 353
    Height = 279
    HelpContext = 11
    Align = alClient
    DragMode = dmAutomatic
    Header.AutoSizeIndex = -1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoShowSortGlyphs, hoVisible]
    Images = imgContents
    PopupMenu = Popup_Contents
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toMultiSelect]
    OnClick = lstContentClick
    OnCompareNodes = lstContentCompareNodes
    OnContextPopup = lstContentContextPopup
    OnFreeNode = lstContentFreeNode
    OnGetText = lstContentGetText
    OnGetImageIndex = lstContentGetImageIndex
    OnHeaderClick = lstContentHeaderClick
    OnInitNode = lstContentInitNode
    OnKeyUp = lstContentKeyUp
    OnMouseDown = lstContentMouseDown
    OnStartDrag = lstContentStartDrag
    Columns = <
      item
        Position = 0
        Width = 170
        WideText = 'Fichier'
      end
      item
        Alignment = taRightJustify
        Position = 1
        Width = 100
        WideText = 'Taille (Octets)'
      end
      item
        Alignment = taRightJustify
        Position = 2
        Width = 100
        WideText = 'Position'
      end
      item
        Position = 3
        Width = 150
        WideText = 'Description'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
        Position = 4
        WideText = 'Modification Type'
      end
      item
        Alignment = taRightJustify
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
        Position = 5
        Width = 100
        WideText = 'Data X'
      end
      item
        Alignment = taRightJustify
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
        Position = 6
        Width = 100
        WideText = 'Data Y'
      end>
  end
  object lstIndex: TVirtualStringTree
    Left = 0
    Top = 41
    Width = 113
    Height = 279
    HelpContext = 12
    Align = alLeft
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    Images = imgTheme16
    PopupMenu = Popup_Index
    TabOrder = 1
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.PaintOptions = [toHideSelection, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toRightClickSelect]
    OnCompareNodes = lstIndexCompareNodes
    OnContextPopup = lstIndexContextPopup
    OnFocusChanged = lstIndexFocusChanged
    OnFreeNode = lstIndexFreeNode
    OnGetText = lstIndexGetText
    OnGetImageIndex = lstIndexGetImageIndex
    Columns = <>
  end
  object panBottom: TPanel
    Left = 0
    Top = 323
    Width = 667
    Height = 101
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Status: TStatusBar
      Left = 0
      Top = 82
      Width = 667
      Height = 19
      HelpContext = 3
      Panels = <
        item
          Text = '0 objet(s)'
          Width = 230
        end
        item
          Text = '0 octet(s)'
          Width = 220
        end
        item
          Alignment = taCenter
          Bevel = pbRaised
          Text = '-'
          Width = 22
        end
        item
          Alignment = taCenter
          Text = '-'
          Width = 70
        end
        item
          Bevel = pbNone
          Width = 274
        end
        item
          Width = 50
        end>
      PopupMenu = Popup_Status
    end
    object richLog: TRichEdit
      Left = 0
      Top = 0
      Width = 667
      Height = 82
      Align = alClient
      HideScrollBars = False
      PopupMenu = Popup_Log
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
    object Percent: TProgressBar
      Left = 545
      Top = 84
      Width = 274
      Height = 16
      HelpContext = 5
      Smooth = True
      TabOrder = 2
    end
  end
  object panPreview: TPanel
    Left = 472
    Top = 41
    Width = 195
    Height = 279
    Align = alRight
    BevelOuter = bvLowered
    PopupMenu = Popup_Preview
    TabOrder = 3
    object scrollPreview: TScrollBox
      Left = 1
      Top = 1
      Width = 193
      Height = 277
      Align = alClient
      TabOrder = 0
      object imgPreview: TImage
        Left = 0
        Top = 0
        Width = 193
        Height = 175
        AutoSize = True
        Center = True
        PopupMenu = Popup_Preview
        Proportional = True
        Stretch = True
      end
    end
  end
  object panTop: TPanel
    Left = 0
    Top = 0
    Width = 667
    Height = 41
    Align = alTop
    TabOrder = 4
    object ToolBar: TToolBar
      Left = 1
      Top = 1
      Width = 296
      Height = 39
      HelpContext = 6
      Align = alLeft
      ButtonHeight = 38
      ButtonWidth = 39
      Caption = 'ToolBar'
      Constraints.MinWidth = 200
      EdgeBorders = []
      EdgeInner = esNone
      EdgeOuter = esNone
      Flat = True
      Images = imgTheme32
      Indent = 5
      TabOrder = 0
      Transparent = False
      Wrapable = False
      object Bouton_Nouveau: TToolButton
        Left = 5
        Top = 0
        Caption = 'Nouveau'
        ImageIndex = 14
        Visible = False
      end
      object Bouton_Ouvrir: TToolButton
        Left = 44
        Top = 0
        HelpContext = 7
        ImageIndex = 0
        OnClick = Bouton_OuvrirClick
      end
      object Bouton_Fermer: TToolButton
        Left = 83
        Top = 0
        HelpContext = 8
        Caption = '&Fermer'
        Enabled = False
        ImageIndex = 1
        OnClick = TDup5FileCloseExecute
      end
      object Separateur_1: TToolButton
        Left = 122
        Top = 0
        Width = 8
        HelpContext = 9
        Caption = 'Separateur_1'
        ImageIndex = 2
        Style = tbsSeparator
      end
      object Bouton_Options: TToolButton
        Left = 130
        Top = 0
        HelpContext = 10
        Caption = 'Bouton_Options'
        ImageIndex = 13
        OnClick = Bouton_OptionsClick
      end
      object Separateur_2: TToolButton
        Left = 169
        Top = 0
        Width = 8
        Caption = 'Separateur_2'
        ImageIndex = 14
        Style = tbsSeparator
      end
      object Bouton_Ajouter: TToolButton
        Left = 177
        Top = 0
        Caption = 'Bouton_Ajouter'
        ImageIndex = 14
        Visible = False
      end
      object Bouton_Remplacer: TToolButton
        Left = 216
        Top = 0
        Caption = 'Bouton_Remplacer'
        ImageIndex = 15
        Visible = False
      end
      object Bouton_Supprimer: TToolButton
        Left = 255
        Top = 0
        Caption = 'Bouton_Supprimer'
        ImageIndex = 16
        Visible = False
      end
    end
  end
  object OpenDialog: TOpenDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 520
    Top = 72
  end
  object SaveDialog: TSaveDialog
    Left = 552
    Top = 72
  end
  object imgContents: TImageList
    BkColor = clWhite
    Masked = False
    Left = 552
    Top = 104
  end
  object imgContentsBig: TImageList
    Height = 32
    Masked = False
    Width = 32
    Left = 552
    Top = 136
  end
  object DropFileSource: TDropFileSource
    DragTypes = [dtMove]
    OnDrop = DropFileSourceDrop
    Left = 520
    Top = 136
  end
  object XPManifest: TXPManifest
    Left = 616
    Top = 72
  end
  object mainMenu: TMainMenu
    Images = imgTheme16
    Left = 520
    Top = 200
    object menuFichier: TMenuItem
      Caption = '&Fichier'
      object menuFichier_Nouveau: TMenuItem
        Caption = '&Nouveau'
        ImageIndex = 21
        ShortCut = 16462
        Visible = False
      end
      object menuFichier_Ouvrir: TMenuItem
        Caption = '&Ouvrir'
        ImageIndex = 0
        ShortCut = 16463
        OnClick = menuFichier_OuvrirClick
      end
      object menuFichier_Fermer: TMenuItem
        Caption = '&Fermer'
        Enabled = False
        ImageIndex = 1
        ShortCut = 16499
        OnClick = menuFichier_FermerClick
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object menuRecent: TMenuItem
        Tag = -1
        Caption = 'Ouvert &r'#233'cement'
        OnClick = menuRecentClick
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object menuFichier_HyperRipper: TMenuItem
        Caption = 'HyperRipper'
        ImageIndex = 2
        ShortCut = 16456
        OnClick = menuFichier_HyperRipperClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object menuFichier_Quitter: TMenuItem
        Caption = '&Quitter'
        ImageIndex = 3
        OnClick = menuFichier_QuitterClick
      end
    end
    object menuEdit: TMenuItem
      Caption = 'Edition'
      object menuEdit_Search: TMenuItem
        Caption = 'Rechercher'
        ImageIndex = 4
        ShortCut = 16467
        OnClick = menuEdit_SearchClick
      end
    end
    object menuOptions: TMenuItem
      Caption = 'Options'
      object menuOptions_Sub: TMenuItem
        Caption = 'G'#233'n'#233'rales'
        ImageIndex = 5
        object menuOptions_Basic: TMenuItem
          Caption = 'Basic'
          ImageIndex = 5
          OnClick = menuOptions_SubClick
        end
        object menuOptions_Advanced: TMenuItem
          Caption = 'Advanced'
          ImageIndex = 15
          OnClick = menuOptions_AdvancedClick
        end
        object menuOptions_Log: TMenuItem
          Caption = 'Log'
          ImageIndex = 16
          OnClick = menuOptions_LogClick
        end
      end
      object menuOptions_Plugins: TMenuItem
        Caption = 'Plugins'
        ImageIndex = 6
        object menuOptions_Convert: TMenuItem
          Caption = 'Convert'
          ImageIndex = 9
          OnClick = menuOptions_ConvertClick
        end
        object menuOptions_Drivers: TMenuItem
          Caption = 'Formats'
          ImageIndex = 10
          OnClick = menuOptions_DriversClick
        end
      end
      object menuOptions_Assoc: TMenuItem
        Caption = 'Associations'
        ImageIndex = 7
        OnClick = menuOptions_AssocClick
      end
      object menuOptions_Look: TMenuItem
        Caption = 'Look'
        ImageIndex = 8
        OnClick = MenuOptions_LookClick
      end
      object menuOptions_Preview: TMenuItem
        Caption = 'Preview'
        ImageIndex = 17
        OnClick = actionPreviewOptions
      end
    end
    object menuTools: TMenuItem
      Caption = 'Outils'
      object menuTools_List: TMenuItem
        Caption = 'Cr'#233'er une liste'
        OnClick = TDup5ToolsListExecute
      end
    end
    object menuAbout: TMenuItem
      Caption = '?'
      object menuAbout_NewVersions: TMenuItem
        Caption = 'Rechercher nouvelles versions sur Internet....'
        OnClick = menuAbout_NewVersionsClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object menuAbout_About: TMenuItem
        Caption = 'A Propos de...'
        ImageIndex = 12
        OnClick = menuAbout_AboutClick
      end
    end
  end
  object Popup_Contents: TPopupMenu
    AutoPopup = False
    Images = imgTheme16
    Left = 552
    Top = 200
    object Popup_Extrairevers: TMenuItem
      Caption = 'Extraire vers...'
      ImageIndex = 28
      object Popup_Extrairevers_Raw: TMenuItem
        Caption = 'Sans convertion'
        ImageIndex = 30
        OnClick = Popup_Extrairevers_RAWClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object Popup_Extrairevers_MODEL: TMenuItem
        Caption = 'Model'
        Visible = False
        OnClick = Popup_Extrairevers_MODELClick
      end
    end
    object Popup_Extrairemulti: TMenuItem
      Caption = 'Extraire les fichiers vers...'
      ImageIndex = 29
      object Popup_ExtraireMulti_RAW: TMenuItem
        Caption = 'Sans convertion'
        ImageIndex = 30
        OnClick = Popup_ExtraireMulti_RAWClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object Popup_ExtraireMulti_MODEL: TMenuItem
        Caption = 'Model'
        Visible = False
        OnClick = Popup_ExtraireMulti_MODELClick
      end
    end
    object Popup_Open: TMenuItem
      Caption = 'Ouvrir'
      Default = True
      ImageIndex = 27
      OnClick = PopUp_OpenClick
    end
  end
  object Popup_Index: TPopupMenu
    Images = imgTheme16
    Left = 584
    Top = 200
    object menuIndex_ExtractAll: TMenuItem
      Caption = 'Extraire tout...'
      ImageIndex = 25
      OnClick = menuIndex_ExtractAllClick
    end
    object menuIndex_ExtractDirs: TMenuItem
      Caption = 'Extraire les sous-r'#233'pertoires...'
      ImageIndex = 26
      Visible = False
      OnClick = menuIndex_ExtractDirsClick
    end
    object menuIndex_ExtractDirsNamedFolder: TMenuItem
      Caption = 'Extraire les sous-r'#233'pertoires vers %f...'
      ImageIndex = 26
      OnClick = menuIndex_ExtractDirsNamedFolderClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object menuIndex_Expand: TMenuItem
      Caption = 'D'#233'velopper tout'
      ImageIndex = 24
      OnClick = menuIndex_ExpandClick
    end
    object menuIndex_Collapse: TMenuItem
      Caption = 'Refermer tout'
      ImageIndex = 23
      OnClick = menuIndex_CollapseClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object menuIndex_Infos: TMenuItem
      Caption = 'Informations'
      ImageIndex = 22
      OnClick = menuIndex_InfosClick
    end
  end
  object TimerParam: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerParamTimer
    Left = 520
    Top = 168
  end
  object Popup_Log: TPopupMenu
    OnPopup = Popup_LogPopup
    Left = 584
    Top = 72
    object menuLog_CopyClipboard: TMenuItem
      Caption = 'Copy To Clipboard'
      OnClick = menuLog_CopyClipboardClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object menuLog_Hide: TMenuItem
      Caption = 'Cacher le journal...'
      OnClick = menuLog_HideClick
    end
    object menuLog_Show: TMenuItem
      Caption = 'Afficher le journal...'
      OnClick = menuLog_ShowClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object menuLog_Clear: TMenuItem
      Caption = 'Effacer le journal'
      OnClick = menuLog_ClearClick
    end
  end
  object TimerInit: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerInitTimer
    Left = 552
    Top = 168
  end
  object Popup_Preview: TPopupMenu
    Left = 584
    Top = 104
    object menuPreview_Hide: TMenuItem
      Caption = 'Hide preview'
      OnClick = actionPreviewHide
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object menuPreview_DisplayMode: TMenuItem
      Caption = 'Display mode'
      object menuPreview_Display_Full: TMenuItem
        Caption = 'Full size with scrollbars'
        Checked = True
        OnClick = menuPreview_Display_FullClick
      end
      object menuPreview_Display_Stretched: TMenuItem
        Caption = 'Streched/Shrinked to panel'
        OnClick = menuPreview_Display_StretchedClick
      end
    end
    object menuPreview_Options: TMenuItem
      Caption = 'Preview options...'
      OnClick = actionPreviewOptions
    end
  end
  object Popup_Status: TPopupMenu
    OnPopup = Popup_StatusPopup
    Left = 616
    Top = 104
    object menuStatus_PreviewHide: TMenuItem
      Caption = 'Hide Preview'
      OnClick = actionPreviewHide
    end
    object menuStatus_PreviewShow: TMenuItem
      Caption = 'Show Preview'
      OnClick = actionPreviewShow
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object menuStatus_LogShow: TMenuItem
      Caption = 'Show Log'
      OnClick = menuLog_ShowClick
    end
    object menuStatus_LogHide: TMenuItem
      Caption = 'Hide log'
      OnClick = menuLog_HideClick
    end
  end
  object imgTheme32: TImageList
    Height = 32
    Width = 32
    Left = 617
    Top = 202
  end
  object imgTheme16: TImageList
    Left = 617
    Top = 234
  end
end

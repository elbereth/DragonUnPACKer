object frmPackCfg: TfrmPackCfg
  Left = 51
  Top = 151
  BorderStyle = bsToolWindow
  Caption = 'Project parameters'
  ClientHeight = 294
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 281
    Height = 249
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Version'
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 136
        Height = 13
        Caption = 'Version number (xyzij format):'
      end
      object Label2: TLabel
        Left = 8
        Top = 56
        Width = 182
        Height = 13
        Caption = 'Version number as displayed by Duppi:'
      end
      object Label7: TLabel
        Left = 16
        Top = 104
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'x = Major version (0 to 10000)'
      end
      object Label8: TLabel
        Left = 16
        Top = 120
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'y = Minor version (0 to 9)'
      end
      object Label9: TLabel
        Left = 16
        Top = 136
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'z = Sub version (0 to 9)'
      end
      object Label10: TLabel
        Left = 16
        Top = 152
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'i = Release type (0 = Alpha, 1 = Beta, 2 = RC,'
      end
      object Label11: TLabel
        Left = 96
        Top = 168
        Width = 161
        Height = 13
        AutoSize = False
        Caption = '3 = Gold, 4/5/6 = Release,'
      end
      object Label12: TLabel
        Left = 96
        Top = 184
        Width = 161
        Height = 13
        AutoSize = False
        Caption = '7 = Fix, 8 = Patch, 9 = Special)'
      end
      object Label13: TLabel
        Left = 16
        Top = 200
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'j = Release number (0 to 9)'
      end
      object txtVersion: TEdit
        Left = 8
        Top = 24
        Width = 257
        Height = 21
        TabOrder = 0
        Text = '10000'
        OnChange = txtVersionChange
      end
      object lblVersion: TStaticText
        Left = 8
        Top = 72
        Width = 257
        Height = 17
        Alignment = taCenter
        AutoSize = False
        BevelInner = bvNone
        BevelKind = bkFlat
        Caption = 'v1.0.0 Alpha'
        TabOrder = 1
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Dragon UnPACKer'
      ImageIndex = 1
      object chkDUP5: TCheckBox
        Left = 8
        Top = 8
        Width = 265
        Height = 17
        Caption = 'Check Dragon UnPACKer 5 version:'
        TabOrder = 0
        OnClick = chkDUP5Click
      end
      object optCompSup: TRadioButton
        Left = 24
        Top = 24
        Width = 33
        Height = 17
        Caption = '>'
        Checked = True
        Enabled = False
        TabOrder = 1
        TabStop = True
        OnClick = optCompSupClick
      end
      object optCompInf: TRadioButton
        Left = 24
        Top = 40
        Width = 33
        Height = 17
        Caption = '<'
        Enabled = False
        TabOrder = 2
        OnClick = optCompInfClick
      end
      object optCompDiff: TRadioButton
        Left = 64
        Top = 40
        Width = 33
        Height = 17
        Caption = '<>'
        Enabled = False
        TabOrder = 3
        OnClick = optCompDiffClick
      end
      object optCompEqual: TRadioButton
        Left = 64
        Top = 24
        Width = 33
        Height = 17
        Caption = '='
        Enabled = False
        TabOrder = 4
        OnClick = optCompEqualClick
      end
      object txtDUP5Version: TEdit
        Left = 120
        Top = 32
        Width = 145
        Height = 21
        Enabled = False
        TabOrder = 5
        Text = '55'
        OnChange = txtDUP5VersionChange
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Infos'
      ImageIndex = 2
      object Label3: TLabel
        Left = 8
        Top = 8
        Width = 75
        Height = 13
        Caption = 'Package name:'
      end
      object Label4: TLabel
        Left = 8
        Top = 56
        Width = 139
        Height = 13
        Caption = 'Internet URL of the package:'
      end
      object Label5: TLabel
        Left = 8
        Top = 104
        Width = 109
        Height = 13
        Caption = 'Author of the package:'
      end
      object Label6: TLabel
        Left = 8
        Top = 152
        Width = 47
        Height = 13
        Caption = 'Comment:'
      end
      object txtName: TEdit
        Left = 8
        Top = 24
        Width = 257
        Height = 21
        TabOrder = 0
        OnChange = txtNameChange
      end
      object txtURL: TEdit
        Left = 8
        Top = 72
        Width = 257
        Height = 21
        TabOrder = 1
        OnChange = txtURLChange
      end
      object txtAuthor: TEdit
        Left = 8
        Top = 120
        Width = 257
        Height = 21
        TabOrder = 2
        OnChange = txtAuthorChange
      end
      object txtComment: TEdit
        Left = 8
        Top = 168
        Width = 257
        Height = 21
        TabOrder = 3
        OnChange = txtCommentChange
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Theme'
      ImageIndex = 3
      object chkImagePerso: TCheckBox
        Left = 8
        Top = 8
        Width = 257
        Height = 17
        Caption = 'Use custom Duppi picture:'
        Enabled = False
        TabOrder = 0
        OnClick = chkImagePersoClick
      end
      object txtImageFile: TEdit
        Left = 24
        Top = 24
        Width = 225
        Height = 21
        Enabled = False
        TabOrder = 1
        OnChange = txtImageFileChange
      end
      object butBrowseImage: TButton
        Left = 248
        Top = 24
        Width = 21
        Height = 21
        Caption = '+'
        Enabled = False
        TabOrder = 2
        OnClick = butBrowseImageClick
      end
    end
  end
  object butOk: TButton
    Left = 208
    Top = 264
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = butOkClick
  end
  object SaveDialog: TSaveDialog
    Filter = 'Windows BitMaP (*.BMP)|*.BMP'
    Title = 'Select custom Duppi picture...'
    Left = 8
    Top = 264
  end
end

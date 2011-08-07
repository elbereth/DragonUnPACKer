object frmProxy: TfrmProxy
  Left = 188
  Top = 98
  BorderStyle = bsToolWindow
  Caption = 'Proxy configuration'
  ClientHeight = 170
  ClientWidth = 213
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
  object strProxy: TLabel
    Left = 8
    Top = 8
    Width = 201
    Height = 13
    AutoSize = False
    Caption = 'Proxy:'
  end
  object strProxyPort: TLabel
    Left = 8
    Top = 48
    Width = 105
    Height = 13
    AutoSize = False
    Caption = 'Proxy port:'
  end
  object strProxyUser: TLabel
    Left = 8
    Top = 124
    Width = 73
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Username:'
  end
  object strProxyPass: TLabel
    Left = 8
    Top = 148
    Width = 73
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Password:'
  end
  object txtProxy: TEdit
    Left = 8
    Top = 24
    Width = 201
    Height = 21
    TabOrder = 0
  end
  object txtProxyPort: TEdit
    Left = 8
    Top = 64
    Width = 57
    Height = 21
    TabOrder = 1
    Text = '3128'
  end
  object cmdOk: TButton
    Left = 134
    Top = 60
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
    OnClick = cmdOkClick
  end
  object chkUserPass: TCheckBox
    Left = 8
    Top = 96
    Width = 201
    Height = 17
    Caption = 'Proxy needs Username/Password:'
    TabOrder = 3
    OnClick = chkUserPassClick
  end
  object txtProxyUser: TEdit
    Left = 88
    Top = 120
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 4
  end
  object txtProxyPass: TEdit
    Left = 88
    Top = 144
    Width = 121
    Height = 21
    Enabled = False
    PasswordChar = '*'
    TabOrder = 5
  end
end

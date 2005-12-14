object frmUTConfig: TfrmUTConfig
  Left = 596
  Top = 170
  BorderStyle = bsToolWindow
  Caption = 'UT Packages driver plugin - Configuration'
  ClientHeight = 194
  ClientWidth = 484
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
  object lblVersion: TLabel
    Left = 8
    Top = 175
    Width = 225
    Height = 11
    AutoSize = False
    Caption = 'UT Packages driver plugin v2.3.0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -9
    Font.Name = 'Small Fonts'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Bevel2: TBevel
    Left = 0
    Top = 168
    Width = 233
    Height = 10
    Shape = bsTopLine
  end
  object lstGames: TListView
    Left = 8
    Top = 8
    Width = 473
    Height = 150
    Columns = <
      item
        Caption = 'ID'
        Width = 30
      end
      item
        Caption = 'Directory'
        Width = 200
      end
      item
        Caption = 'Game'
        Width = 147
      end
      item
        Alignment = taCenter
        Caption = 'DA?'
        Width = 35
      end
      item
        Caption = 'GID'
        Width = 35
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = lstGamesSelectItem
  end
  object butRemove: TButton
    Left = 320
    Top = 164
    Width = 75
    Height = 25
    Caption = 'Remove'
    Enabled = False
    TabOrder = 2
    OnClick = butRemoveClick
  end
  object butOK: TButton
    Left = 400
    Top = 164
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = butOKClick
  end
  object butEdit: TButton
    Left = 240
    Top = 164
    Width = 75
    Height = 25
    Caption = 'Edit'
    Enabled = False
    TabOrder = 1
    OnClick = butEditClick
  end
end

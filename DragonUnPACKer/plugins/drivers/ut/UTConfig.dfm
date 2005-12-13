object frmUTConfig: TfrmUTConfig
  Left = 242
  Top = 92
  Width = 432
  Height = 216
  Caption = 'frmUTConfig'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 409
    Height = 150
    Columns = <
      item
        Caption = 'Directory'
        Width = 200
      end
      item
        Alignment = taCenter
        Caption = 'Ask?'
        Width = 40
      end
      item
        Caption = 'Game'
        Width = 147
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object Button1: TButton
    Left = 8
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Remove'
    TabOrder = 1
  end
end

object frmMsgBox: TfrmMsgBox
  Left = 814
  Top = 364
  BorderStyle = bsDialog
  Caption = 'Plugin DUDI v5 About Message Box Title'
  ClientHeight = 373
  ClientWidth = 442
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
  object butOK: TButton
    Left = 184
    Top = 344
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = butOKClick
  end
  object richText: TRichEdit
    Left = 0
    Top = 0
    Width = 441
    Height = 337
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
end

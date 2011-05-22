object frmExtTool: TfrmExtTool
  Left = 455
  Top = 723
  Width = 561
  Height = 365
  Caption = 'External Tools Convert Plugin v<version>'
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
  object Label1: TLabel
    Left = 480
    Top = 8
    Width = 54
    Height = 13
    Caption = 'Extensions:'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 280
    Width = 545
    Height = 9
    Shape = bsBottomLine
  end
  object lblExtra1: TLabel
    Left = 8
    Top = 296
    Width = 449
    Height = 13
    AutoSize = False
    Caption = 'test test'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblExtra2: TLabel
    Left = 8
    Top = 310
    Width = 449
    Height = 13
    AutoSize = False
    Caption = 'test test test'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 144
    Top = 12
    Width = 89
    Height = 13
    AutoSize = False
    Caption = 'Tool Name:'
  end
  object Label3: TLabel
    Left = 144
    Top = 36
    Width = 89
    Height = 13
    AutoSize = False
    Caption = 'Author:'
  end
  object Label4: TLabel
    Left = 144
    Top = 60
    Width = 89
    Height = 13
    AutoSize = False
    Caption = 'URL:'
  end
  object Label5: TLabel
    Left = 144
    Top = 84
    Width = 89
    Height = 13
    AutoSize = False
    Caption = 'Comment:'
  end
  object Label6: TLabel
    Left = 144
    Top = 108
    Width = 89
    Height = 13
    AutoSize = False
    Caption = 'Path:'
  end
  object Label7: TLabel
    Left = 144
    Top = 132
    Width = 89
    Height = 13
    AutoSize = False
    Caption = 'Parameters:'
  end
  object Label8: TLabel
    Left = 144
    Top = 156
    Width = 121
    Height = 13
    AutoSize = False
    Caption = 'Resulting extension:'
  end
  object shToolName: TShape
    Left = 456
    Top = 14
    Width = 9
    Height = 9
    Brush.Color = clBtnFace
  end
  object Label9: TLabel
    Left = 144
    Top = 228
    Width = 121
    Height = 13
    AutoSize = False
    Caption = 'Correct result value:'
  end
  object shToolPath: TShape
    Left = 456
    Top = 110
    Width = 9
    Height = 9
    Brush.Color = clBtnFace
  end
  object shToolCommand: TShape
    Left = 456
    Top = 134
    Width = 9
    Height = 9
    Hint = '"%i" for input file and "%o" for output file must be present'
    Brush.Color = clBtnFace
  end
  object shToolResultTest: TShape
    Left = 344
    Top = 158
    Width = 9
    Height = 9
    Hint = '"%i" for input file and "%o" for output file must be present'
    Brush.Color = clBtnFace
  end
  object shToolResultvalue: TShape
    Left = 368
    Top = 230
    Width = 9
    Height = 9
    Hint = '"%i" for input file and "%o" for output file must be present'
    Brush.Color = clBtnFace
  end
  object lstTools: TListView
    Left = 8
    Top = 8
    Width = 129
    Height = 241
    Checkboxes = True
    Columns = <
      item
        Caption = 'Tool'
        Width = 109
      end>
    ReadOnly = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = lstToolsClick
  end
  object txtToolname: TEdit
    Left = 240
    Top = 8
    Width = 209
    Height = 21
    TabOrder = 3
  end
  object txtToolAuthor: TEdit
    Left = 240
    Top = 32
    Width = 209
    Height = 21
    TabOrder = 4
  end
  object txtToolComment: TEdit
    Left = 240
    Top = 80
    Width = 209
    Height = 21
    TabOrder = 6
  end
  object txtToolPath: TEdit
    Left = 240
    Top = 104
    Width = 185
    Height = 21
    TabOrder = 7
  end
  object txtToolCommand: TEdit
    Left = 240
    Top = 128
    Width = 209
    Height = 21
    TabOrder = 8
  end
  object txtToolResultest: TEdit
    Left = 272
    Top = 152
    Width = 65
    Height = 21
    TabOrder = 9
  end
  object rgrpResultTest: TRadioGroup
    Left = 144
    Top = 176
    Width = 305
    Height = 41
    Caption = 'Correct Result Testing'
    Columns = 6
    ItemIndex = 0
    Items.Strings = (
      '='
      '>'
      '<'
      '>='
      '<='
      '<>')
    TabOrder = 10
  end
  object txtToolResultValue: TEdit
    Left = 272
    Top = 224
    Width = 89
    Height = 21
    TabOrder = 11
  end
  object lstExt: TListBox
    Left = 480
    Top = 80
    Width = 57
    Height = 169
    ItemHeight = 13
    MultiSelect = True
    Sorted = True
    TabOrder = 14
    OnClick = lstExtClick
  end
  object txtExt: TEdit
    Left = 480
    Top = 24
    Width = 57
    Height = 21
    TabOrder = 12
    OnChange = txtExtChange
  end
  object butExtAdd: TButton
    Left = 480
    Top = 48
    Width = 57
    Height = 25
    Caption = 'Add'
    Enabled = False
    TabOrder = 13
    OnClick = butExtAddClick
  end
  object butExit: TButton
    Left = 464
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Done'
    TabOrder = 18
    OnClick = butExitClick
  end
  object butToolAdd: TButton
    Left = 8
    Top = 256
    Width = 57
    Height = 25
    Caption = 'New'
    TabOrder = 1
  end
  object butExtRemove: TButton
    Left = 480
    Top = 256
    Width = 59
    Height = 25
    Caption = 'Remove'
    Enabled = False
    TabOrder = 15
    OnClick = butExtRemoveClick
  end
  object butToolRemove: TButton
    Left = 80
    Top = 256
    Width = 57
    Height = 25
    Caption = 'Remove'
    Enabled = False
    TabOrder = 2
  end
  object txtToolURL: TEdit
    Left = 240
    Top = 56
    Width = 209
    Height = 21
    TabOrder = 5
  end
  object Button1: TButton
    Left = 427
    Top = 104
    Width = 21
    Height = 21
    Caption = '+'
    TabOrder = 19
  end
  object butToolSave: TButton
    Left = 240
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 16
  end
  object butToolReset: TButton
    Left = 328
    Top = 260
    Width = 75
    Height = 17
    Caption = 'Reset'
    TabOrder = 17
  end
end

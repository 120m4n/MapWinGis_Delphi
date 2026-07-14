object AttributesForm: TAttributesForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Shape Attributes'
  ClientHeight = 320
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object panel1: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 8
    Align = alTop
    BevelOuter = bvNone
    Caption = ''
    TabOrder = 0
  end
  object flowLayoutPanel1: TFlowPanel
    Left = 0
    Top = 281
    Width = 520
    Height = 39
    Align = alBottom
    FlowStyle = fsRightLeftTopBottom
    TabOrder = 1
    object btnCancel: TButton
      Left = 434
      Top = 3
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOk: TButton
      Left = 353
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Ok'
      TabOrder = 1
      OnClick = btnOkClick
    end
  end
  object tableLayoutPanel1: TGridPanel
    Left = 0
    Top = 8
    Width = 520
    Height = 273
    Align = alClient
    BevelOuter = bvNone
    ColumnCollection = <
      item
        Value = 35.000000000000000000
      end
      item
        Value = 65.000000000000000000
      end>
    ControlCollection = <>
    RowCollection = <>
    TabOrder = 2
  end
end
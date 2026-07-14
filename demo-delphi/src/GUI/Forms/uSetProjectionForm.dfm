object SetProjectionForm: TSetProjectionForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Set Map Projection'
  ClientHeight = 248
  ClientWidth = 486
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
  object txtDefinition: TEdit
    Left = 16
    Top = 117
    Width = 458
    Height = 21
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 318
    Top = 210
    Width = 75
    Height = 23
    Caption = 'Ok'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 399
    Top = 210
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object optEmpty: TRadioButton
    Left = 16
    Top = 19
    Width = 219
    Height = 17
    Caption = 'Empty (will be grabbed from the first layer)'
    TabOrder = 3
    OnClick = OptionChanged
  end
  object optWellKnown: TRadioButton
    Left = 16
    Top = 52
    Width = 130
    Height = 17
    Caption = 'Well known projection'
    Checked = True
    TabOrder = 4
    TabStop = True
    OnClick = OptionChanged
  end
  object cboWellKnown: TComboBox
    Left = 168
    Top = 51
    Width = 268
    Height = 21
    Style = csDropDownList
    TabOrder = 5
  end
  object optDefinition: TRadioButton
    Left = 16
    Top = 85
    Width = 358
    Height = 17
    Caption = 'Enter projection definition in any form (e.g. PROJ4, WKT, EPSG code):'
    TabOrder = 6
    OnClick = OptionChanged
  end
end
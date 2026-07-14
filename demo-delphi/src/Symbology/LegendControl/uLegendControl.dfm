object LegendControl: TLegendControl
  Left = 0
  Top = 0
  Width = 260
  Height = 400
  TabOrder = 0
  object lblTitle: TLabel
    Left = 0
    Top = 0
    Width = 260
    Height = 22
    Align = alTop
    Alignment = taCenter
    Caption = 'Legend'
    Layout = tlCenter
    ExplicitWidth = 36
  end
  object lstLayers: TListBox
    Left = 0
    Top = 22
    Width = 260
    Height = 378
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
  end
end
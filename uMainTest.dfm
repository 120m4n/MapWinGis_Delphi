object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 417
  ClientWidth = 782
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Map2: TMap
    Left = 0
    Top = 41
    Width = 782
    Height = 376
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 160
    ExplicitTop = 80
    ExplicitWidth = 100
    ExplicitHeight = 50
    ControlData = {
      31000C00D2500000DC26000000000000FFFFFF007B14AE47E17A943F00003333
      33333333D33F00000000001400000001000000000000000000E03F0000010000
      0000000001000000000100000002000000030000000600000001000000FFFFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000001010000000000000000010100000004000000FFFFFFFFFFFFFFFF
      000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 782
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 1
    ExplicitLeft = 336
    ExplicitTop = 128
    ExplicitWidth = 185
    object Button1: TButton
      Left = 352
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end

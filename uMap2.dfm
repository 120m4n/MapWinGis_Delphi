object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 407
  ClientWidth = 604
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 604
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object Button1: TButton
      Left = 16
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Map1: TMap
    Left = 0
    Top = 41
    Width = 604
    Height = 366
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 64
    ExplicitWidth = 588
    ExplicitHeight = 313
    ControlData = {
      31000C006D3E0000D425000000000000FFFFFF007B14AE47E17A943F00003333
      33333333D33F00000000001400000001000000000000000000E03F0000010000
      0000000001000000000100000002000000030000000600000001000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000001010000000000000000010100000004000000FFFFFFFFFFFFFFFF
      000000000000}
  end
end

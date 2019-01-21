object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 468
  ClientWidth = 575
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
  object Map1: TMap
    Left = 0
    Top = 57
    Width = 575
    Height = 411
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 63
    ExplicitWidth = 559
    ExplicitHeight = 397
    ControlData = {
      31000C006E3B00007A2A000000000000FFFFFF007B14AE47E17A943F00003333
      33333333D33F00000000001400000001000000000000000000E03F0000010000
      0000000001000000000100000002000000030000000600000001000000000000
      0002000000000000000000000000000000000000000000000000000000000000
      000000000001010000000000000000010100000004000000FFFFFFFFFFFFFFFF
      000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 575
    Height = 57
    Align = alTop
    TabOrder = 1
    object btnOpen: TButton
      Left = 16
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Add...'
      TabOrder = 0
      OnClick = btnOpenClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 496
    Top = 8
  end
end

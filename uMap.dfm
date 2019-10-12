object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 536
  ClientWidth = 1215
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1215
    Height = 57
    Align = alTop
    TabOrder = 0
    object btnOpen: TButton
      Left = 16
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Add...'
      TabOrder = 0
      OnClick = btnOpenClick
    end
    object Button1: TButton
      Left = 256
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Imagenes'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 136
      Top = 17
      Width = 75
      Height = 25
      Caption = 'GeoDatabase'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 376
      Top = 17
      Width = 75
      Height = 25
      Caption = 'OgrData'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 480
      Top = 17
      Width = 75
      Height = 25
      Caption = 'Borrar'
      TabOrder = 4
      OnClick = Button4Click
    end
    object CheckBox1: TCheckBox
      Left = 112
      Top = 21
      Width = 18
      Height = 17
      TabOrder = 5
    end
    object Button5: TButton
      Left = 591
      Top = 17
      Width = 75
      Height = 25
      Caption = 'WFS'
      TabOrder = 6
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 688
      Top = 17
      Width = 75
      Height = 25
      Caption = 'WMS'
      TabOrder = 7
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 792
      Top = 17
      Width = 75
      Height = 25
      Caption = 'LoadDB'
      TabOrder = 8
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 904
      Top = 17
      Width = 75
      Height = 25
      Caption = 'PostGis'
      TabOrder = 9
      OnClick = Button8Click
    end
  end
  object Map1: TMap
    Left = 177
    Top = 57
    Width = 1038
    Height = 479
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 183
    ExplicitTop = 63
    ControlData = {
      31000C00486B00008231000000000000FFFFFF007B14AE47E17A943F00003333
      33333333D33F00000000001400000001000001000000000000E03F0000010000
      0000000001000000000100000002000000030000000600000001000000FFFFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000001000000000000000000000100000004000000FFFFFFFFFFFFFFFF
      000000000000}
  end
  object ListBox1: TListBox
    Left = 0
    Top = 57
    Width = 177
    Height = 479
    Align = alLeft
    ItemHeight = 13
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    Left = 672
    Top = 136
  end
end

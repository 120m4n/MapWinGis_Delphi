object OgrConnectionForm: TOgrConnectionForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'OGR Connection'
  ClientHeight = 220
  ClientWidth = 380
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
  object lblHost: TLabel
    Left = 16
    Top = 20
    Width = 23
    Height = 13
    Caption = 'Host'
  end
  object lblPort: TLabel
    Left = 16
    Top = 52
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object lblDatabase: TLabel
    Left = 16
    Top = 84
    Width = 46
    Height = 13
    Caption = 'Database'
  end
  object lblUser: TLabel
    Left = 16
    Top = 116
    Width = 22
    Height = 13
    Caption = 'User'
  end
  object lblPassword: TLabel
    Left = 16
    Top = 148
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object edtHost: TEdit
    Left = 120
    Top = 16
    Width = 230
    Height = 21
    TabOrder = 0
  end
  object edtPort: TEdit
    Left = 120
    Top = 48
    Width = 230
    Height = 21
    TabOrder = 1
  end
  object edtDatabase: TEdit
    Left = 120
    Top = 80
    Width = 230
    Height = 21
    TabOrder = 2
  end
  object edtUser: TEdit
    Left = 120
    Top = 112
    Width = 230
    Height = 21
    TabOrder = 3
  end
  object edtPassword: TEdit
    Left = 120
    Top = 144
    Width = 230
    Height = 21
    PasswordChar = '*'
    TabOrder = 4
  end
  object btnOk: TButton
    Left = 190
    Top = 180
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 275
    Top = 180
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
end
object OgrLayerForm: TOgrLayerForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Add Database Layer'
  ClientHeight = 486
  ClientWidth = 581
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 497
    Top = 454
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 0
  end
  object listView1: TListView
    Left = 12
    Top = 33
    Width = 560
    Height = 232
    Columns = <
      item
        Caption = 'Layer Name'
        Width = 181
      end
      item
        Caption = 'Feature Count'
        Width = 98
      end
      item
        Caption = 'Geometry'
        Width = 120
      end
      item
        Caption = 'Projection'
        Width = 150
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = listView1DblClick
    OnSelectItem = listView1SelectItem
  end
  object btnChangeConnection: TButton
    Left = 12
    Top = 454
    Width = 130
    Height = 23
    Caption = 'Change Connection'
    TabOrder = 2
    OnClick = btnChangeConnectionClick
  end
  object btnAddLayer: TButton
    Left = 148
    Top = 454
    Width = 92
    Height = 23
    Caption = 'Add Layer'
    TabOrder = 3
    OnClick = btnAddLayerClick
  end
  object pnlBottom: TPanel
    Left = 12
    Top = 271
    Width = 560
    Height = 177
    BevelOuter = bvLowered
    Caption = ''
    TabOrder = 4
    object memDetails: TMemo
      Left = 1
      Top = 1
      Width = 558
      Height = 175
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object lblConnection: TLabel
    Left = 12
    Top = 12
    Width = 174
    Height = 13
    Caption = 'Connection: <not selected>'
  end
  object btnRefresh: TButton
    Left = 246
    Top = 454
    Width = 92
    Height = 23
    Caption = 'Refresh'
    TabOrder = 5
    OnClick = btnRefreshClick
  end
end
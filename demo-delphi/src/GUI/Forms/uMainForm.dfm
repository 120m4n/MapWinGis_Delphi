object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MapWinGIS Demo Delphi'
  ClientHeight = 820
  ClientWidth = 1280
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
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 42
    Align = alTop
    Caption = ''
    TabOrder = 0
    object tlbMain: TToolBar
      Left = 1
      Top = 1
      Width = 1278
      Height = 40
      Align = alClient
      ButtonHeight = 30
      ButtonWidth = 80
      Caption = 'tlbMain'
      ParentShowHint = False
      ShowCaptions = True
      ShowHint = True
      TabOrder = 0
      object toolOpen: TToolButton
        Left = 0
        Top = 0
        Caption = 'Open'
      end
      object toolLoadProject: TToolButton
        Left = 80
        Top = 0
        Caption = 'Load'
      end
      object toolSaveProject: TToolButton
        Left = 160
        Top = 0
        Caption = 'Save'
      end
      object toolSaveProjectAs: TToolButton
        Left = 240
        Top = 0
        Caption = 'Save As'
      end
      object toolAddDatabase: TToolButton
        Left = 320
        Top = 0
        Caption = 'Add DB'
      end
      object toolZoomIn: TToolButton
        Left = 400
        Top = 0
        Caption = 'Zoom In'
      end
      object toolZoomOut: TToolButton
        Left = 480
        Top = 0
        Caption = 'Zoom Out'
      end
      object toolPan: TToolButton
        Left = 560
        Top = 0
        Caption = 'Pan'
      end
      object toolZoomMax: TToolButton
        Left = 640
        Top = 0
        Caption = 'Zoom Max'
      end
      object toolEditLayer: TToolButton
        Left = 720
        Top = 0
        Caption = 'Edit'
      end
      object toolSaveLayerEdits: TToolButton
        Left = 800
        Top = 0
        Caption = 'Save Edits'
      end
      object toolSetProjection: TToolButton
        Left = 880
        Top = 0
        Caption = 'Projection'
      end
    end
  end
  object pnlLegend: TPanel
    Left = 0
    Top = 42
    Width = 260
    Height = 778
    Align = alLeft
    Caption = ''
    TabOrder = 1
  end
  object pnlClient: TPanel
    Left = 260
    Top = 42
    Width = 1020
    Height = 778
    Align = alClient
    Caption = ''
    TabOrder = 2
  end
end
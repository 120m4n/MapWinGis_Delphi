unit uCore.Contracts;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Menus,
  MapWinGIS_TLB,
  uCore.Types;

type
  IProject = interface
    ['{A0B67196-648E-41AE-A91D-1497D34E4606}']
    function IsEmpty: Boolean;
    function GetPath: string;
    function GetState: TProjectState;
    function Save: Boolean;
    procedure SaveAs;
    procedure Load(const AFileName: string);
    function TryClose: Boolean;
    procedure SetOnProjectChanged(const AHandler: TNotifyEvent);
  end;

  IMapApp = interface
    ['{F95F46E6-5031-469C-AB43-724FBE1F9C85}']
    function GetLegendHost: TWinControl;
    function GetMap: TMap;
    function GetProject: IProject;
    procedure RefreshUI;
    procedure AddMenu(AMenu: TMenuItem);
    procedure AddToolbar(AToolbar: TToolBar);
    procedure RunCommand(const ACommand: TAppCommand);
    property LegendHost: TWinControl read GetLegendHost;
    property Map: TMap read GetMap;
    property Project: IProject read GetProject;
  end;

implementation

end.
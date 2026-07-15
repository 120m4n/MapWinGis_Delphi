unit uMainForm;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  MapWinGIS_TLB,
  uCore.Contracts,
  uCore.Types,
  uAppDispatcher,
  uLegendControl,
  uMapForm;

type
  TMainForm = class(TForm, IMapApp)
    pnlTop: TPanel;
    pnlLegend: TPanel;
    pnlClient: TPanel;
    tlbMain: TToolBar;
    toolOpen: TToolButton;
    toolLoadProject: TToolButton;
    toolSaveProject: TToolButton;
    toolSaveProjectAs: TToolButton;
    toolAddDatabase: TToolButton;
    toolZoomIn: TToolButton;
    toolZoomOut: TToolButton;
    toolPan: TToolButton;
    toolZoomMax: TToolButton;
    toolEditLayer: TToolButton;
    toolSaveLayerEdits: TToolButton;
    toolUndoEdits: TToolButton;
    toolEditFields: TToolButton;
    toolClearSelection: TToolButton;
    toolSetProjection: TToolButton;
  private
    FDispatcher: TAppDispatcher;
    FMapForm: TMapForm;
    FLegend: TLegendControl;
    procedure ToolButtonClick(Sender: TObject);
    procedure ProjectChanged(Sender: TObject);
    procedure LegendLayerSelected(Sender: TObject; LayerHandle: Integer);
    procedure LegendLayerDoubleClick(Sender: TObject; LayerHandle: Integer);
    procedure UpdateLegend;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function GetLegendHost: TWinControl;
    function GetMap: TMap;
    function GetProject: IProject;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshUI;
    procedure AddMenu(AMenu: TMenuItem);
    procedure AddToolbar(AToolbar: TToolBar);
    procedure RunCommand(const ACommand: TAppCommand);
  end;

var
  MainForm: TMainForm;

implementation

uses
  uApp,
  uProject,
  uCore.MapExt;

{$R *.dfm}

constructor TMainForm.Create(AOwner: TComponent);
var
  Project: IProject;
begin
  inherited Create(AOwner);

  FDispatcher := TAppDispatcher.Create;

  FLegend := TLegendControl.Create(Self);
  FLegend.Parent := pnlLegend;
  FLegend.Align := alClient;
  FLegend.OnLayerSelected := LegendLayerSelected;
  FLegend.OnLayerDoubleClick := LegendLayerDoubleClick;

  FMapForm := TMapForm.Create(Self);
  FMapForm.Parent := pnlClient;
  FMapForm.Align := alClient;

  toolOpen.OnClick := ToolButtonClick;
  toolLoadProject.OnClick := ToolButtonClick;
  toolSaveProject.OnClick := ToolButtonClick;
  toolSaveProjectAs.OnClick := ToolButtonClick;
  toolAddDatabase.OnClick := ToolButtonClick;
  toolZoomIn.OnClick := ToolButtonClick;
  toolZoomOut.OnClick := ToolButtonClick;
  toolPan.OnClick := ToolButtonClick;
  toolZoomMax.OnClick := ToolButtonClick;
  toolEditLayer.OnClick := ToolButtonClick;
  toolSaveLayerEdits.OnClick := ToolButtonClick;
  toolUndoEdits.OnClick := ToolButtonClick;
  toolEditFields.OnClick := ToolButtonClick;
  toolClearSelection.OnClick := ToolButtonClick;
  toolSetProjection.OnClick := ToolButtonClick;

  Project := TProject.Create;
  TApp.Initialize(Self, Project);
  Project.SetOnProjectChanged(ProjectChanged);

  RefreshUI;
end;

destructor TMainForm.Destroy;
begin
  FDispatcher.Free;
  inherited Destroy;
end;

function TMainForm.GetLegendHost: TWinControl;
begin
  Result := FLegend;
end;

function TMainForm.GetMap: TMap;
begin
  Result := FMapForm.Map;
end;

function TMainForm.GetProject: IProject;
begin
  Result := TApp.Project;
end;

procedure TMainForm.AddMenu(AMenu: TMenuItem);
begin
end;

procedure TMainForm.AddToolbar(AToolbar: TToolBar);
begin
end;

procedure TMainForm.ProjectChanged(Sender: TObject);
begin
  RefreshUI;
end;

procedure TMainForm.LegendLayerSelected(Sender: TObject; LayerHandle: Integer);
begin
  TApp.SetSelectedLayerHandle(LayerHandle);
end;

procedure TMainForm.LegendLayerDoubleClick(Sender: TObject; LayerHandle: Integer);
var
  AMap: TMap;
begin
  TApp.SetSelectedLayerHandle(LayerHandle);
  AMap := GetMap;
  if Assigned(AMap) and (LayerHandle >= 0) then
  begin
    AMap.ZoomToLayer(LayerHandle);
    AMap.Redraw;
  end;
end;

function TMainForm.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TMainForm.RefreshUI;
begin
  UpdateLegend;
end;

procedure TMainForm.RunCommand(const ACommand: TAppCommand);
begin
  FDispatcher.Run(ACommand);
  RefreshUI;
end;

procedure TMainForm.ToolButtonClick(Sender: TObject);
var
  Command: TAppCommand;
begin
  if (Sender is TComponent) and FDispatcher.CommandFromName(TComponent(Sender).Name, Command) then
    RunCommand(Command);
end;

procedure TMainForm.UpdateLegend;
var
  Layers: TStringList;
  Handles: TList<Integer>;
  AMap: TMap;
  I: Integer;
  LayerHandle: Integer;
begin
  Layers := TStringList.Create;
  Handles := TList<Integer>.Create;
  try
    AMap := GetMap;
    if Assigned(AMap) then
      for I := 0 to AMap.NumLayers - 1 do
      begin
        LayerHandle := AMap.LayerHandle[I];
        Layers.Add(GetLayerDisplayName(AMap, LayerHandle));
        Handles.Add(LayerHandle);
      end;
    FLegend.RefreshLayers(Layers, Handles);
  finally
    Handles.Free;
    Layers.Free;
  end;
end;

function TMainForm._AddRef: Integer;
begin
  Result := -1;
end;

function TMainForm._Release: Integer;
begin
  Result := -1;
end;

end.
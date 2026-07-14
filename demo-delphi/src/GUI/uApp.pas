unit uApp;

interface

uses
  MapWinGIS_TLB,
  uCore.Contracts;

type
  TApp = class
  strict private
    class var FMainApp: IMapApp;
    class var FProject: IProject;
    class var FSelectedLayerHandle: Integer;
  public
    class procedure Initialize(const AMainApp: IMapApp; const AProject: IProject); static;
    class function MainApp: IMapApp; static;
    class function Map: TMap; static;
    class function Project: IProject; static;
    class function SelectedLayerHandle: Integer; static;
    class procedure SetSelectedLayerHandle(const ALayerHandle: Integer); static;
    class procedure RefreshUI; static;
    class procedure LoadMapState(const AFileName: string); static;
  end;

implementation

class procedure TApp.Initialize(const AMainApp: IMapApp; const AProject: IProject);
begin
  FMainApp := AMainApp;
  FProject := AProject;
end;

class function TApp.MainApp: IMapApp;
begin
  Result := FMainApp;
end;

class function TApp.Map: TMap;
begin
  if Assigned(FMainApp) then
    Result := FMainApp.Map
  else
    Result := nil;
end;

class function TApp.Project: IProject;
begin
  Result := FProject;
end;

class function TApp.SelectedLayerHandle: Integer;
begin
  Result := FSelectedLayerHandle;
end;

class procedure TApp.SetSelectedLayerHandle(const ALayerHandle: Integer);
begin
  FSelectedLayerHandle := ALayerHandle;
end;

class procedure TApp.RefreshUI;
begin
  if Assigned(FMainApp) then
    FMainApp.RefreshUI;
end;

class procedure TApp.LoadMapState(const AFileName: string);
var
  AMap: TMap;
begin
  AMap := Map;
  if Assigned(AMap) then
    AMap.LoadMapState(AFileName, nil);
end;

end.
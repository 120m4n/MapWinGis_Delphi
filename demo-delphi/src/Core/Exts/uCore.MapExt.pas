unit uCore.MapExt;

interface

uses
  System.SysUtils,
  MapWinGIS_TLB;

procedure InitDefaultMapSettings(const AMap: TMap);
function GetLayerDisplayName(const AMap: TMap; const ALayerHandle: Integer): string;

implementation

procedure InitDefaultMapSettings(const AMap: TMap);
begin
  if not Assigned(AMap) then
    Exit;

  AMap.Projection := PROJECTION_NONE;
  AMap.TileProvider := ProviderNone;
  AMap.SendMouseMove := True;
end;

function GetLayerDisplayName(const AMap: TMap; const ALayerHandle: Integer): string;
begin
  Result := '';
  if not Assigned(AMap) then
    Exit;

  Result := AMap.LayerName[ALayerHandle];
  if Result = '' then
    Result := ExtractFileName(AMap.LayerFilename[ALayerHandle]);
  if Result = '' then
    Result := Format('Layer %d', [ALayerHandle]);
end;

end.
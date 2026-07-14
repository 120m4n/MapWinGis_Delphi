unit uOgrHelper;

interface

uses
  MapWinGIS_TLB,
  uConnectionParams;

type
  TOgrHelper = class
  public
    class function OpenDatasource(const ADatasource: IOgrDatasource; const AConnection: TConnectionParams): Boolean; static;
  end;

implementation

uses
  uCore.MessageHelper;

class function TOgrHelper.OpenDatasource(const ADatasource: IOgrDatasource; const AConnection: TConnectionParams): Boolean;
begin
  Result := Assigned(ADatasource) and Assigned(AConnection);
  if not Result then
    Exit;

  Result := ADatasource.Open(AConnection.GetPostGisConnection);
  if not Result then
    Warn('Failed to open datasource: ' + ADatasource.GdalLastErrorMsg);
end;

end.
unit uCore.PathHelper;

interface

uses
  System.SysUtils;

function SettingsFolder: string;

implementation

function SettingsFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) + 'MapWinGIS.Demo.Delphi';
  ForceDirectories(Result);
end;

end.
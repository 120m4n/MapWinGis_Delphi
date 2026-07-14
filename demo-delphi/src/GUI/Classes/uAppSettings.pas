unit uAppSettings;

interface

uses
  System.SysUtils,
  uCore.PathHelper;

type
  TAppSettings = class
  public
    class function SettingsFileName: string; static;
  end;

implementation

class function TAppSettings.SettingsFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(SettingsFolder) + 'settings.xml';
end;

end.
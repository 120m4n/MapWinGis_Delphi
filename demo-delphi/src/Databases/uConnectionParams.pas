unit uConnectionParams;

interface

type
  TConnectionParams = class
  public
    Host: string;
    Port: Integer;
    Database: string;
    UserName: string;
    Password: string;
    procedure InitDefaultPostGis;
    function GetPostGisConnection: string;
  end;

implementation

uses
  System.SysUtils;

function TConnectionParams.GetPostGisConnection: string;
begin
  Result := Format('PG:host=%s port=%d dbname=%s user=%s password=%s',
    [Host, Port, Database, UserName, Password]);
end;

procedure TConnectionParams.InitDefaultPostGis;
begin
  Database := '';
  Password := '';
  Port := 5432;
  UserName := 'postgres';
  Host := '127.0.0.1';
end;

end.
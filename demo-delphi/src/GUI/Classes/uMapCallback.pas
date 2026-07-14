unit uMapCallback;

interface

uses
  Winapi.Windows,
  System.SysUtils;

type
  TMapCallback = class
  public
    procedure Progress(const APercent: Integer; const AMessage: string);
    procedure Error(const ASender, AMessage: string);
  end;

implementation

procedure TMapCallback.Error(const ASender, AMessage: string);
begin
  OutputDebugString(PChar(Format('[MapCallback][%s] %s', [ASender, AMessage])));
end;

procedure TMapCallback.Progress(const APercent: Integer; const AMessage: string);
begin
  OutputDebugString(PChar(Format('[MapCallback][%d%%] %s', [APercent, AMessage])));
end;

end.
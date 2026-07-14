unit uAppLogger;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows;

type
  TAppLogLevel = (alInfo, alWarning, alError);

  IAppLogger = interface
    ['{7EEFCC58-5375-4105-9A96-E7C47FF1CF9F}']
    procedure Log(const ALevel: TAppLogLevel; const ASource, AMessage: string);
    procedure Info(const ASource, AMessage: string);
    procedure Warning(const ASource, AMessage: string);
    procedure Error(const ASource, AMessage: string);
  end;

  TFileAppLogger = class(TInterfacedObject, IAppLogger)
  private
    FLogFileName: string;
    FLock: TObject;
    function LevelToText(const ALevel: TAppLogLevel): string;
    procedure WriteLine(const ALine: string);
  public
    constructor Create(const ALogFileName: string);
    destructor Destroy; override;
    procedure Log(const ALevel: TAppLogLevel; const ASource, AMessage: string);
    procedure Info(const ASource, AMessage: string);
    procedure Warning(const ASource, AMessage: string);
    procedure Error(const ASource, AMessage: string);
  end;

function AppLogger: IAppLogger;

implementation

var
  GAppLogger: IAppLogger;

function AppLogger: IAppLogger;
begin
  if not Assigned(GAppLogger) then
    GAppLogger := TFileAppLogger.Create(ChangeFileExt(ParamStr(0), '.log'));
  Result := GAppLogger;
end;

constructor TFileAppLogger.Create(const ALogFileName: string);
begin
  inherited Create;
  FLogFileName := ALogFileName;
  FLock := TObject.Create;
end;

destructor TFileAppLogger.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TFileAppLogger.Error(const ASource, AMessage: string);
begin
  Log(alError, ASource, AMessage);
end;

procedure TFileAppLogger.Info(const ASource, AMessage: string);
begin
  Log(alInfo, ASource, AMessage);
end;

function TFileAppLogger.LevelToText(const ALevel: TAppLogLevel): string;
begin
  case ALevel of
    alInfo:
      Result := 'INFO';
    alWarning:
      Result := 'WARN';
  else
    Result := 'ERROR';
  end;
end;

procedure TFileAppLogger.Log(const ALevel: TAppLogLevel; const ASource, AMessage: string);
var
  Line: string;
begin
  Line := Format('[%s] [%s] %s - %s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now), LevelToText(ALevel), ASource, AMessage]);
  WriteLine(Line);
  OutputDebugString(PChar(Line));
end;

procedure TFileAppLogger.Warning(const ASource, AMessage: string);
begin
  Log(alWarning, ASource, AMessage);
end;

procedure TFileAppLogger.WriteLine(const ALine: string);
var
  LWriter: TStreamWriter;
begin
  TMonitor.Enter(FLock);
  try
    LWriter := TStreamWriter.Create(FLogFileName, True, TEncoding.UTF8);
    try
      LWriter.WriteLine(ALine);
    finally
      LWriter.Free;
    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

initialization
  GAppLogger := nil;

finalization
  GAppLogger := nil;

end.

unit uProjectBase;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  MapWinGIS_TLB,
  uCore.Contracts,
  uCore.Types;

type
  TProjectBase = class(TInterfacedObject, IProject)
  private
    FFileName: string;
    FState: TProjectState;
    FOnProjectChanged: TNotifyEvent;
  protected
    function SaveToFile(const AFileName: string): Boolean; virtual;
    procedure DoProjectChanged;
  public
    constructor Create;
    function IsEmpty: Boolean;
    function GetPath: string;
    function GetState: TProjectState;
    function Save: Boolean;
    procedure SaveAs;
    procedure Load(const AFileName: string);
    function TryClose: Boolean;
    procedure SetOnProjectChanged(const AHandler: TNotifyEvent);
  end;

implementation

uses
  Vcl.Dialogs,
  uApp,
  uCore.FileHelper,
  uCore.MessageHelper;

constructor TProjectBase.Create;
begin
  inherited Create;
  FState := psEmpty;
end;

procedure TProjectBase.DoProjectChanged;
begin
  if Assigned(FOnProjectChanged) then
    FOnProjectChanged(Self);
end;

function TProjectBase.GetPath: string;
begin
  Result := FFileName;
end;

function TProjectBase.GetState: TProjectState;
begin
  Result := FState;
end;

function TProjectBase.IsEmpty: Boolean;
begin
  Result := FState = psEmpty;
end;

procedure TProjectBase.Load(const AFileName: string);
begin
  if (AFileName = '') or not FileExists(AFileName) then
    Exit;

  TApp.LoadMapState(AFileName);
  FFileName := AFileName;
  FState := psNoChanges;
  DoProjectChanged;
end;

function TProjectBase.Save: Boolean;
begin
  Result := False;
  if FFileName = '' then
  begin
    SaveAs;
    Result := FFileName <> '';
    Exit;
  end;

  Result := SaveToFile(FFileName);
end;

procedure TProjectBase.SaveAs;
var
  FileName: string;
begin
  if ShowSaveDialog(ftProject, FileName) then
  begin
    if SaveToFile(FileName) then
      FFileName := FileName;
  end;
end;

function TProjectBase.SaveToFile(const AFileName: string): Boolean;
var
  AMap: TMap;
begin
  AMap := TApp.Map;
  Result := Assigned(AMap) and AMap.SaveMapState(AFileName, True, True);
  if Result then
  begin
    FFileName := AFileName;
    FState := psNoChanges;
    DoProjectChanged;
  end;
end;

procedure TProjectBase.SetOnProjectChanged(const AHandler: TNotifyEvent);
begin
  FOnProjectChanged := AHandler;
end;

function TProjectBase.TryClose: Boolean;
var
  Choice: Integer;
begin
  Result := True;
  if FState <> psHasChanges then
    Exit;

  Choice := AskYesNoCancel('Project has unsaved changes. Save before closing?');
  case Choice of
    mrYes:
      Result := Save;
    mrNo:
      Result := True;
  else
    Result := False;
  end;

  if Result then
  begin
    FFileName := '';
    FState := psEmpty;
    DoProjectChanged;
  end;
end;

end.
unit uEditor;

interface

uses
  uCore.Contracts,
  uEditorCommand;

type
  TEditor = class
  strict private
    class var FDispatcher: TObject;
  public
    class function Init(const AApp: IMapApp): Boolean; static;
    class procedure RunCommand(const ACommand: TEditorCommand); static;
  end;

implementation

uses
  uEditorApp,
  uEditorDispatcher;

class function TEditor.Init(const AApp: IMapApp): Boolean;
begin
  Result := TEditorApp.Init(AApp);
  if Result and not Assigned(FDispatcher) then
    FDispatcher := TEditorDispatcher.Create;
end;

class procedure TEditor.RunCommand(const ACommand: TEditorCommand);
begin
  if Assigned(FDispatcher) then
    TEditorDispatcher(FDispatcher).Run(ACommand);
end;

end.
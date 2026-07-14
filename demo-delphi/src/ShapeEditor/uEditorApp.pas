unit uEditorApp;

interface

uses
  uCore.Contracts;

type
  TEditorApp = class
  strict private
    class var FApp: IMapApp;
  public
    class function Init(const AApp: IMapApp): Boolean; static;
    class function App: IMapApp; static;
  end;

implementation

class function TEditorApp.App: IMapApp;
begin
  Result := FApp;
end;

class function TEditorApp.Init(const AApp: IMapApp): Boolean;
begin
  FApp := AApp;
  Result := Assigned(FApp);
end;

end.
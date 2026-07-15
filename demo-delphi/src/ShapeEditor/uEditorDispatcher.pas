unit uEditorDispatcher;

interface

uses
  uEditorCommand;

type
  TEditorDispatcher = class
  public
    procedure Run(const ACommand: TEditorCommand);
  end;

implementation

uses
  uEditorHelper,
  uApp;

procedure TEditorDispatcher.Run(const ACommand: TEditorCommand);
begin
  case ACommand of
    ecEditLayer:
      TEditorHelper.ToggleEditLayer;
    ecSaveLayer:
      TEditorHelper.SaveLayerChanges;
    ecUndo:
      TEditorHelper.UndoLastEdit;
    ecClearSelection:
      TEditorHelper.ClearSelection;
    ecEditFields:
      TEditorHelper.EditSelectedShapeFields;
  end;
  TApp.RefreshUI;
end;

end.
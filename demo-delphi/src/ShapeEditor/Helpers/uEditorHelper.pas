unit uEditorHelper;

interface

type
  TEditorHelper = class
  public
    class function ToggleEditLayer: Boolean; static;
    class function SaveLayerChanges: Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  MapWinGIS_TLB,
  uApp,
  uCore.MessageHelper;

class function TEditorHelper.SaveLayerChanges: Boolean;
var
  LayerHandle: Integer;
  Sf: IShapefile;
begin
  Result := False;
  LayerHandle := TApp.SelectedLayerHandle;
  if LayerHandle < 0 then
  begin
    Warn('Select a layer first.');
    Exit;
  end;

  Sf := TApp.Map.Shapefile[LayerHandle];
  if not Assigned(Sf) then
  begin
    Warn('Selected layer is not a shapefile.');
    Exit;
  end;

  if TApp.Map.ShapeEditor.SaveChanges then
  begin
    if Sf.InteractiveEditing then
      Sf.StopEditingShapes(True, True, nil);
    TApp.Map.Redraw;
    Result := True;
  end;
end;

class function TEditorHelper.ToggleEditLayer: Boolean;
var
  LayerHandle: Integer;
  Sf: IShapefile;
begin
  Result := False;
  LayerHandle := TApp.SelectedLayerHandle;
  if LayerHandle < 0 then
  begin
    Warn('Select a layer first.');
    Exit;
  end;

  Sf := TApp.Map.Shapefile[LayerHandle];
  if not Assigned(Sf) then
  begin
    Warn('Selected layer is not a shapefile.');
    Exit;
  end;

  if Sf.InteractiveEditing then
  begin
    Result := Sf.StopEditingShapes(True, True, nil);
    TApp.Map.CursorMode := cmPan;
  end
  else
  begin
    Result := Sf.StartEditingShapes(True, nil);
    if Result then
    begin
      TApp.Map.CursorMode := cmEditShape;
      TApp.Map.ShapeEditor.EditorBehavior := ebVertexEditor;
    end;
  end;

  TApp.Map.Redraw;
end;

end.
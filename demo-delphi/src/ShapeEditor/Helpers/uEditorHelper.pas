unit uEditorHelper;

interface

type
  TEditorHelper = class
  public
    class function ToggleEditLayer: Boolean; static;
    class function SaveLayerChanges: Boolean; static;
    class function UndoLastEdit: Boolean; static;
    class function ClearSelection: Boolean; static;
    class function EditSelectedShapeFields: Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  MapWinGIS_TLB,
  uApp,
  uAttributesForm,
  uCore.MessageHelper;

class function TEditorHelper.UndoLastEdit: Boolean;
var
  AMap: TMap;
begin
  Result := False;
  AMap := TApp.Map;
  if not Assigned(AMap) then
    Exit;

  if not Assigned(AMap.UndoList) or (AMap.UndoList.UndoCount = 0) then
  begin
    Warn('Undo list is empty.');
    Exit;
  end;

  AMap.Undo;
  AMap.Redraw;
  Result := True;
end;

class function TEditorHelper.ClearSelection: Boolean;
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
  if Assigned(Sf) then
    Sf.SelectNone;

  TApp.Map.ShapeEditor.Clear;
  TApp.Map.Redraw;
  Result := True;
end;

class function TEditorHelper.EditSelectedShapeFields: Boolean;
var
  LayerHandle: Integer;
  I: Integer;
  Sf: IShapefile;
  ShapeIndex: Integer;
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

  if not Sf.InteractiveEditing then
  begin
    Warn('Enable layer editing first.');
    Exit;
  end;

  ShapeIndex := -1;
  for I := 0 to Sf.NumShapes - 1 do
    if Sf.ShapeSelected[I] then
    begin
      ShapeIndex := I;
      Break;
    end;

  if ShapeIndex < 0 then
  begin
    Warn('Select one shape first.');
    Exit;
  end;

  Result := ExecuteAttributesDialog(Sf, ShapeIndex, TApp.SelectedLayerHandle);
  if Result then
    TApp.Map.Redraw;
end;

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
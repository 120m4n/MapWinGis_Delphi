unit uAppDispatcher;

interface

uses
  uCore.CommandDispatcher,
  uCore.Types;

type
  TAppDispatcher = class(TCommandDispatcher)
  public
    procedure Run(const ACommand: TAppCommand); override;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  MapWinGIS_TLB,
  uApp,
  uCore.FileHelper,
  uCore.MessageHelper,
  uConnectionParams,
  uOgrHelper,
  uOgrConnectionForm,
  uOgrLayerForm,
  uEditor,
  uEditorCommand,
  uSetProjectionForm;

procedure TAppDispatcher.Run(const ACommand: TAppCommand);
var
  FileName: string;
  FileManager: IFileManager;
  LayerObject: OleVariant;
  LayerHandle: Integer;
begin
  case ACommand of
    acOpen:
      begin
        if not ShowOpenDialog(ftLayer, FileName) then
          Exit;
        FileManager := CoFileManager.Create;
        LayerObject := FileManager.Open(FileName, fosAutoDetect, nil);
        if not FileManager.LastOpenIsSuccess then
          raise Exception.Create('Failed to open layer source.');
        LayerHandle := TApp.Map.AddLayer(LayerObject, True);
        if LayerHandle <> -1 then
          TApp.Map.ZoomToLayer(LayerHandle);
        TApp.Map.Redraw;
        TApp.RefreshUI;
      end;
    acLoadProject:
      begin
        if ShowOpenDialog(ftProject, FileName) then
          TApp.Project.Load(FileName);
      end;
    acSaveProject:
      TApp.Project.Save;
    acSaveProjectAs:
      TApp.Project.SaveAs;
    acCloseProject:
      begin
        if TApp.Project.TryClose then
        begin
          TApp.Map.RemoveAllLayers;
          TApp.Map.Redraw;
          TApp.RefreshUI;
        end;
      end;
    acZoomIn:
      TApp.Map.CursorMode := cmZoomIn;
    acZoomOut:
      TApp.Map.CursorMode := cmZoomOut;
    acPan:
      TApp.Map.CursorMode := cmPan;
    acZoomMax:
      begin
        TApp.Map.ZoomToMaxExtents;
        TApp.Map.Redraw;
      end;
    acAddDatabase:
      ExecuteOgrLayerDialog(TApp.Map);
    acEditLayer:
      TEditor.RunCommand(ecEditLayer);
    acSaveLayerEdits:
      TEditor.RunCommand(ecSaveLayer);
    acSetProjection:
      if ExecuteSetProjectionDialog(TApp.Map) then
      begin
        TApp.Map.Redraw;
        TApp.RefreshUI;
      end;
  end;
end;

end.
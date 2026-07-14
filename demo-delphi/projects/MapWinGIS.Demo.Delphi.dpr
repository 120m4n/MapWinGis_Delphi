program MapWinGISDemoDelphi;

uses
  Vcl.Forms,
  MapWinGIS_TLB in 'C:\dev\MapWinGIS\MapWinGIS_TLB.pas',
  uCore.Types in '..\src\Core\uCore.Types.pas',
  uCore.Contracts in '..\src\Core\uCore.Contracts.pas',
  uCore.Events in '..\src\Core\Events\uCore.Events.pas',
  uCore.MapExt in '..\src\Core\Exts\uCore.MapExt.pas',
  uCore.CommandDispatcher in '..\src\Core\UI\uCore.CommandDispatcher.pas',
  uCore.FileHelper in '..\src\Core\UI\uCore.FileHelper.pas',
  uCore.MessageHelper in '..\src\Core\UI\uCore.MessageHelper.pas',
  uCore.PathHelper in '..\src\Core\UI\uCore.PathHelper.pas',
  uApp in '..\src\GUI\uApp.pas',
  uAppDispatcher in '..\src\GUI\Classes\uAppDispatcher.pas',
  uAppSettings in '..\src\GUI\Classes\uAppSettings.pas',
  uMapCallback in '..\src\GUI\Classes\uMapCallback.pas',
  uProjectBase in '..\src\GUI\Classes\uProjectBase.pas',
  uProject in '..\src\GUI\Classes\uProject.pas',
  uConnectionParams in '..\src\Databases\uConnectionParams.pas',
  uOgrHelper in '..\src\Databases\uOgrHelper.pas',
  uOgrConnectionForm in '..\src\Databases\Forms\uOgrConnectionForm.pas',
  uOgrLayerForm in '..\src\Databases\Forms\uOgrLayerForm.pas',
  uEditorCommand in '..\src\ShapeEditor\uEditorCommand.pas',
  uEditorApp in '..\src\ShapeEditor\uEditorApp.pas',
  uEditorHelper in '..\src\ShapeEditor\Helpers\uEditorHelper.pas',
  uEditorDispatcher in '..\src\ShapeEditor\uEditorDispatcher.pas',
  uEditor in '..\src\ShapeEditor\uEditor.pas',
  uAttributesForm in '..\src\ShapeEditor\Forms\uAttributesForm.pas',
  uLegendControl in '..\src\Symbology\LegendControl\uLegendControl.pas',
  uSetProjectionForm in '..\src\GUI\Forms\uSetProjectionForm.pas',
  uMapForm in '..\src\GUI\Forms\uMapForm.pas',
  uMainForm in '..\src\GUI\Forms\uMainForm.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
unit uCore.FileHelper;

interface

uses
  System.SysUtils,
  Vcl.Dialogs,
  uCore.Types;

function ShowOpenDialog(const AFileType: TFileType; out AFileName: string): Boolean;
function ShowSaveDialog(const AFileType: TFileType; out AFileName: string): Boolean;

implementation

function FilterForFileType(const AFileType: TFileType): string;
begin
  case AFileType of
    ftProject:
      Result := 'MapWinGIS Project (*.mwxml)|*.mwxml|All files (*.*)|*.*';
    ftImage:
      Result := 'Images (*.bmp;*.png;*.jpg)|*.bmp;*.png;*.jpg|All files (*.*)|*.*';
  else
      Result := 'Supported GIS files (*.shp;*.tif;*.tiff;*.gpkg;*.json;*.sqlite)|*.shp;*.tif;*.tiff;*.gpkg;*.json;*.sqlite|All files (*.*)|*.*';
  end;
end;

function ShowOpenDialog(const AFileType: TFileType; out AFileName: string): Boolean;
var
  Dialog: TOpenDialog;
begin
  AFileName := '';
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.InitialDir := ExtractFilePath(ParamStr(0));
    Dialog.Filter := FilterForFileType(AFileType);
    Result := Dialog.Execute;
    if Result then
      AFileName := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

function ShowSaveDialog(const AFileType: TFileType; out AFileName: string): Boolean;
var
  Dialog: TSaveDialog;
begin
  AFileName := '';
  Dialog := TSaveDialog.Create(nil);
  try
    Dialog.InitialDir := ExtractFilePath(ParamStr(0));
    Dialog.Filter := FilterForFileType(AFileType);
    if AFileType = ftProject then
      Dialog.DefaultExt := 'mwxml';
    Result := Dialog.Execute;
    if Result then
      AFileName := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

end.
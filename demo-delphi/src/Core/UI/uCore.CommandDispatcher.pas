unit uCore.CommandDispatcher;

interface

uses
  System.SysUtils,
  uCore.Types;

type
  TCommandDispatcher = class
  public
    function CommandFromName(const AName: string; out ACommand: TAppCommand): Boolean; virtual;
    procedure Run(const ACommand: TAppCommand); virtual; abstract;
  end;

implementation

function TCommandDispatcher.CommandFromName(const AName: string; out ACommand: TAppCommand): Boolean;
var
  Name: string;
begin
  Result := True;
  Name := LowerCase(AName);

  if Name = 'toolopen' then
    ACommand := acOpen
  else if Name = 'toolloadproject' then
    ACommand := acLoadProject
  else if Name = 'toolsaveproject' then
    ACommand := acSaveProject
  else if Name = 'toolsaveprojectas' then
    ACommand := acSaveProjectAs
  else if Name = 'toolcloseproject' then
    ACommand := acCloseProject
  else if Name = 'toolzoomin' then
    ACommand := acZoomIn
  else if Name = 'toolzoomout' then
    ACommand := acZoomOut
  else if Name = 'toolpan' then
    ACommand := acPan
  else if Name = 'toolzoommax' then
    ACommand := acZoomMax
  else if Name = 'tooladddatabase' then
    ACommand := acAddDatabase
  else if Name = 'tooleditlayer' then
    ACommand := acEditLayer
  else if Name = 'toolsavelayeredits' then
    ACommand := acSaveLayerEdits
  else if Name = 'toolundoedits' then
    ACommand := acUndoEdits
  else if Name = 'tooleditfields' then
    ACommand := acEditFields
  else if Name = 'toolclearselection' then
    ACommand := acClearSelection
  else if Name = 'toolsetprojection' then
    ACommand := acSetProjection
  else
  begin
    ACommand := acNone;
    Result := False;
  end;
end;

end.
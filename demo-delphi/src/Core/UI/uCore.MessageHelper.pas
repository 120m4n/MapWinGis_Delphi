unit uCore.MessageHelper;

interface

uses
  Vcl.Dialogs;

procedure Info(const AMessage: string);
procedure Warn(const AMessage: string);
function AskYesNoCancel(const AMessage: string): Integer;

implementation

procedure Info(const AMessage: string);
begin
  MessageDlg(AMessage, mtInformation, [mbOK], 0);
end;

procedure Warn(const AMessage: string);
begin
  MessageDlg(AMessage, mtWarning, [mbOK], 0);
end;

function AskYesNoCancel(const AMessage: string): Integer;
begin
  Result := MessageDlg(AMessage, mtConfirmation, [mbYes, mbNo, mbCancel], 0);
end;

end.
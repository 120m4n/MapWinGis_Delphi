unit uOgrConnectionForm;

interface

uses
  System.UITypes,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.StdCtrls,
  uConnectionParams;

type
  TOgrConnectionForm = class(TForm)
    lblHost: TLabel;
    lblPort: TLabel;
    lblDatabase: TLabel;
    lblUser: TLabel;
    lblPassword: TLabel;
    edtHost: TEdit;
    edtPort: TEdit;
    edtDatabase: TEdit;
    edtUser: TEdit;
    edtPassword: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
  private
    procedure LoadFromParams(AConnection: TConnectionParams);
    procedure SaveToParams(AConnection: TConnectionParams);
  end;

function ExecuteOgrConnectionDialog(AConnection: TConnectionParams): Boolean;

implementation

uses
  System.SysUtils;

{$R *.dfm}

procedure TOgrConnectionForm.LoadFromParams(AConnection: TConnectionParams);
begin
  edtHost.Text := AConnection.Host;
  edtPort.Text := IntToStr(AConnection.Port);
  edtDatabase.Text := AConnection.Database;
  edtUser.Text := AConnection.UserName;
  edtPassword.Text := AConnection.Password;
end;

procedure TOgrConnectionForm.SaveToParams(AConnection: TConnectionParams);
begin
  AConnection.Host := Trim(edtHost.Text);
  AConnection.Port := StrToIntDef(Trim(edtPort.Text), 5432);
  AConnection.Database := Trim(edtDatabase.Text);
  AConnection.UserName := Trim(edtUser.Text);
  AConnection.Password := edtPassword.Text;
end;

function ExecuteOgrConnectionDialog(AConnection: TConnectionParams): Boolean;
var
  Dlg: TOgrConnectionForm;
begin
  Result := False;
  if not Assigned(AConnection) then
    Exit;

  Dlg := TOgrConnectionForm.Create(nil);
  try
    Dlg.LoadFromParams(AConnection);

    if Dlg.ShowModal <> mrOk then
      Exit;

    Dlg.SaveToParams(AConnection);
    Result := True;
  finally
    Dlg.Free;
  end;
end;

end.
unit uSetProjectionForm;

interface

uses
  System.UITypes,
  Vcl.Forms,
  Vcl.StdCtrls,
  MapWinGIS_TLB;

type
  TSetProjectionForm = class(TForm)
    txtDefinition: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    optEmpty: TRadioButton;
    optWellKnown: TRadioButton;
    cboWellKnown: TComboBox;
    optDefinition: TRadioButton;
    procedure btnOkClick(Sender: TObject);
    procedure OptionChanged(Sender: TObject);
  private
    FMap: TMap;
    procedure RefreshControls;
  public
    property Map: TMap read FMap write FMap;
  end;

function ExecuteSetProjectionDialog(const AMap: TMap): Boolean;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs;

{$R *.dfm}

function ExecuteSetProjectionDialog(const AMap: TMap): Boolean;
var
  Form: TSetProjectionForm;
begin
  Result := False;
  Form := TSetProjectionForm.Create(nil);
  try
    Form.Map := AMap;
    Form.cboWellKnown.Items.Add('WGS 84 (decimal degrees)');
    Form.cboWellKnown.Items.Add('Google Mercator');
    Form.cboWellKnown.ItemIndex := 0;
    Form.RefreshControls;
    Result := Form.ShowModal = mrOk;
  finally
    Form.Free;
  end;
end;

procedure TSetProjectionForm.btnOkClick(Sender: TObject);
var
  Gp: IGeoProjection;
begin
  if not Assigned(FMap) then
    Exit;

  if FMap.NumLayers > 0 then
  begin
    MessageDlg('Can''t change projection when there are layers on the map.', mtInformation, [mbOK], 0);
    Exit;
  end;

  Gp := CoGeoProjection.Create;

  if optDefinition.Checked then
  begin
    if Trim(txtDefinition.Text) = '' then
    begin
      MessageDlg('Projection string is empty.', mtInformation, [mbOK], 0);
      Exit;
    end;

    if not Gp.ImportFromAutoDetect(txtDefinition.Text) then
    begin
      MessageDlg('Failed to identify projection.', mtInformation, [mbOK], 0);
      Exit;
    end;
  end;
  if optWellKnown.Checked then
  begin
    if cboWellKnown.ItemIndex = 0 then
      Gp.SetWgs84
    else if cboWellKnown.ItemIndex = 1 then
      Gp.SetGoogleMercator;
  end;

  FMap.GeoProjection := Gp;
  ModalResult := mrOk;
end;

procedure TSetProjectionForm.OptionChanged(Sender: TObject);
begin
  RefreshControls;
end;

procedure TSetProjectionForm.RefreshControls;
begin
  cboWellKnown.Enabled := optWellKnown.Checked;
  txtDefinition.Enabled := optDefinition.Checked;
end;

end.
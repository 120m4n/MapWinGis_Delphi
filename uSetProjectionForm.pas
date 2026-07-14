unit uSetProjectionForm;

interface

uses
  System.SysUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Dialogs,
  MapWinGIS_TLB;

function ExecuteSetProjectionDialog(const AMap: TMap): Boolean;

implementation

function ExecuteSetProjectionDialog(const AMap: TMap): Boolean;
var
  Dlg: TForm;
  RbEmpty: TRadioButton;
  RbWellKnown: TRadioButton;
  RbCustom: TRadioButton;
  CbWellKnown: TComboBox;
  EdCustom: TEdit;
  BtnOk: TButton;
  BtnCancel: TButton;
  GeoProj: IGeoProjection;
  CustomText: string;
begin
  Result := False;

  if not Assigned(AMap) then
    Exit;

  if AMap.NumLayers > 0 then
  begin
    MessageDlg('Projection can only be changed when no layers are loaded.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Dlg := TForm.Create(nil);
  try
    Dlg.Caption := 'Set Projection';
    Dlg.Position := poScreenCenter;
    Dlg.BorderStyle := bsDialog;
    Dlg.ClientWidth := 460;
    Dlg.ClientHeight := 210;

    RbEmpty := TRadioButton.Create(Dlg);
    RbEmpty.Parent := Dlg;
    RbEmpty.Left := 16;
    RbEmpty.Top := 16;
    RbEmpty.Width := 300;
    RbEmpty.Caption := 'Empty (grab from first layer)';
    RbEmpty.Checked := True;

    RbWellKnown := TRadioButton.Create(Dlg);
    RbWellKnown.Parent := Dlg;
    RbWellKnown.Left := 16;
    RbWellKnown.Top := 52;
    RbWellKnown.Width := 120;
    RbWellKnown.Caption := 'Well known';

    CbWellKnown := TComboBox.Create(Dlg);
    CbWellKnown.Parent := Dlg;
    CbWellKnown.Left := 150;
    CbWellKnown.Top := 50;
    CbWellKnown.Width := 200;
    CbWellKnown.Style := csDropDownList;
    CbWellKnown.Items.Add('WGS84');
    CbWellKnown.Items.Add('Google Mercator');
    CbWellKnown.ItemIndex := 0;

    RbCustom := TRadioButton.Create(Dlg);
    RbCustom.Parent := Dlg;
    RbCustom.Left := 16;
    RbCustom.Top := 88;
    RbCustom.Width := 120;
    RbCustom.Caption := 'Definition';

    EdCustom := TEdit.Create(Dlg);
    EdCustom.Parent := Dlg;
    EdCustom.Left := 150;
    EdCustom.Top := 86;
    EdCustom.Width := 290;
    EdCustom.TextHint := 'EPSG:4326 or WKT/Proj4 string';

    BtnOk := TButton.Create(Dlg);
    BtnOk.Parent := Dlg;
    BtnOk.Caption := 'OK';
    BtnOk.ModalResult := mrOk;
    BtnOk.Left := 270;
    BtnOk.Top := 160;
    BtnOk.Width := 80;

    BtnCancel := TButton.Create(Dlg);
    BtnCancel.Parent := Dlg;
    BtnCancel.Caption := 'Cancel';
    BtnCancel.ModalResult := mrCancel;
    BtnCancel.Left := 360;
    BtnCancel.Top := 160;
    BtnCancel.Width := 80;

    if Dlg.ShowModal <> mrOk then
      Exit;

    GeoProj := CoGeoProjection.Create;

    if RbEmpty.Checked then
    begin
      AMap.GeoProjection := GeoProj;
    end
    else if RbWellKnown.Checked then
    begin
      if CbWellKnown.ItemIndex = 0 then
      begin
        if not GeoProj.SetWgs84 then
          raise Exception.Create('Unable to set WGS84 projection.');
      end
      else
      begin
        if not GeoProj.SetGoogleMercator then
          raise Exception.Create('Unable to set Google Mercator projection.');
      end;
      AMap.GeoProjection := GeoProj;
    end
    else if RbCustom.Checked then
    begin
      CustomText := Trim(EdCustom.Text);
      if CustomText = '' then
        raise Exception.Create('Projection definition cannot be empty.');

      if not GeoProj.ImportFromAutoDetect(CustomText) then
        raise Exception.Create('Failed to identify custom projection definition.');

      AMap.GeoProjection := GeoProj;
    end;

    Result := True;
  finally
    Dlg.Free;
  end;
end;

end.

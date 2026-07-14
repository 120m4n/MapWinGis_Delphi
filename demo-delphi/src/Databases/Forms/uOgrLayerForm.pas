unit uOgrLayerForm;

interface

uses
  System.UITypes,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  MapWinGIS_TLB,
  uConnectionParams;

type
  TOgrLayerForm = class(TForm)
    btnCancel: TButton;
    listView1: TListView;
    btnChangeConnection: TButton;
    btnAddLayer: TButton;
    procedure btnChangeConnectionClick(Sender: TObject);
    procedure btnAddLayerClick(Sender: TObject);
    procedure listView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FDatasource: IOgrDatasource;
    FConnection: TConnectionParams;
    FMap: TMap;
    procedure ChangeConnection;
    procedure OpenDatasource;
    procedure PopulateList;
    procedure AddLayer;
  public
    property Map: TMap read FMap write FMap;
  end;

function ExecuteOgrLayerDialog(const AMap: TMap): Boolean;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  uOgrConnectionForm,
  uOgrHelper;

{$R *.dfm}

function ExecuteOgrLayerDialog(const AMap: TMap): Boolean;
var
  Form: TOgrLayerForm;
begin
  Result := False;
  Form := TOgrLayerForm.Create(nil);
  try
    Form.Map := AMap;
    Result := Form.ShowModal = mrOk;
  finally
    Form.Free;
  end;
end;

procedure TOgrLayerForm.FormShow(Sender: TObject);
begin
  ChangeConnection;
end;

procedure TOgrLayerForm.btnAddLayerClick(Sender: TObject);
begin
  AddLayer;
end;

procedure TOgrLayerForm.btnChangeConnectionClick(Sender: TObject);
begin
  ChangeConnection;
end;

procedure TOgrLayerForm.listView1DblClick(Sender: TObject);
begin
  AddLayer;
end;

procedure TOgrLayerForm.ChangeConnection;
begin
  if not Assigned(FConnection) then
  begin
    FConnection := TConnectionParams.Create;
    FConnection.InitDefaultPostGis;
  end;

  if ExecuteOgrConnectionDialog(FConnection) then
    OpenDatasource;
end;

procedure TOgrLayerForm.OpenDatasource;
begin
  FDatasource := CoOgrDatasource.Create;
  if not TOgrHelper.OpenDatasource(FDatasource, FConnection) then
    Exit;
  PopulateList;
end;

procedure TOgrLayerForm.PopulateList;
var
  I: Integer;
  Layer: IOgrLayer;
  Item: TListItem;
  Gp: IGeoProjection;
  Epsg: Integer;
  Srid: string;
begin
  listView1.Items.Clear;
  if not Assigned(FDatasource) then
    Exit;

  for I := 0 to FDatasource.LayerCount - 1 do
  begin
    Layer := FDatasource.GetLayer(I, False);
    if not Assigned(Layer) then
      Continue;

    Item := listView1.Items.Add;
    Item.Caption := Layer.Name;
    Item.Data := Pointer(NativeInt(I));
    Item.SubItems.Add(IntToStr(Layer.FeatureCount[False]));
    Item.SubItems.Add(IntToStr(Ord(Layer.ShapeType)));
    Gp := Layer.GeoProjection;
    if Assigned(Gp) and Gp.TryAutoDetectEpsg(Epsg) then
      Srid := IntToStr(Epsg)
    else if Assigned(Gp) then
      Srid := Gp.ExportToProj4
    else
      Srid := '';
    Item.SubItems.Add(Srid);
  end;
end;

procedure TOgrLayerForm.AddLayer;
var
  Index: Integer;
  Layer: IOgrLayer;
  LayerHandle: Integer;
begin
  if listView1.Selected = nil then
  begin
    MessageDlg('No layer is selected.', mtInformation, [mbOK], 0);
    Exit;
  end;

  Index := NativeInt(listView1.Selected.Data);
  Layer := FDatasource.GetLayer(Index, False);
  if not Assigned(Layer) then
  begin
    MessageDlg('Failed to initialize layer.', mtInformation, [mbOK], 0);
    Exit;
  end;

  LayerHandle := FMap.AddLayer(Layer, True);
  if LayerHandle <> -1 then
  begin
    FMap.ZoomToLayer(LayerHandle);
    FMap.Redraw;
    ModalResult := mrOk;
  end;
end;

end.
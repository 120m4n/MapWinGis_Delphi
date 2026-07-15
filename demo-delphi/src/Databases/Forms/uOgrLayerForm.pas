unit uOgrLayerForm;

interface

uses
  System.UITypes,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  MapWinGIS_TLB,
  uConnectionParams;

type
  TOgrLayerForm = class(TForm)
    btnCancel: TButton;
    listView1: TListView;
    btnChangeConnection: TButton;
    btnAddLayer: TButton;
    pnlBottom: TPanel;
    memDetails: TMemo;
    lblConnection: TLabel;
    btnRefresh: TButton;
    procedure btnChangeConnectionClick(Sender: TObject);
    procedure btnAddLayerClick(Sender: TObject);
    procedure listView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure listView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FDatasource: IOgrDatasource;
    FConnection: TConnectionParams;
    FMap: TMap;
    procedure ChangeConnection;
    procedure OpenDatasource;
    procedure PopulateList;
    procedure AddLayer;
    procedure UpdateConnectionInfo;
    procedure PopulateDetails;
    function ShapeTypeToText(const AShapeType: ShpfileType): string;
    function ProjectionToText(const AGp: IGeoProjection): string;
  public
    property Map: TMap read FMap write FMap;
  end;

function ExecuteOgrLayerDialog(const AMap: TMap): Boolean;

implementation

uses
  System.Math,
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

procedure TOgrLayerForm.listView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
    PopulateDetails;
end;

procedure TOgrLayerForm.btnRefreshClick(Sender: TObject);
begin
  OpenDatasource;
end;

procedure TOgrLayerForm.ChangeConnection;
begin
  if not Assigned(FConnection) then
  begin
    FConnection := TConnectionParams.Create;
    FConnection.InitDefaultPostGis;
  end;

  if ExecuteOgrConnectionDialog(FConnection) then
  begin
    UpdateConnectionInfo;
    OpenDatasource;
  end;
end;

procedure TOgrLayerForm.OpenDatasource;
begin
  if Assigned(FDatasource) then
    FDatasource.Close;
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
    Item.SubItems.Add(ShapeTypeToText(Layer.ShapeType));
    Item.SubItems.Add(ProjectionToText(Layer.GeoProjection));
  end;

  if listView1.Items.Count > 0 then
  begin
    listView1.ItemIndex := 0;
    PopulateDetails;
  end
  else
    memDetails.Lines.Text := 'No layers found for this connection.';
end;

procedure TOgrLayerForm.UpdateConnectionInfo;
begin
  if not Assigned(FConnection) then
  begin
    lblConnection.Caption := 'Connection: <not selected>';
    Exit;
  end;

  lblConnection.Caption := Format('Connection: %s:%d / %s',
    [FConnection.Host, FConnection.Port, FConnection.Database]);
end;

function TOgrLayerForm.ShapeTypeToText(const AShapeType: ShpfileType): string;
begin
  case AShapeType of
    SHP_NULLSHAPE:
      Result := 'Null';
    SHP_POINT, SHP_POINTM, SHP_POINTZ:
      Result := 'Point';
    SHP_MULTIPOINT, SHP_MULTIPOINTM, SHP_MULTIPOINTZ:
      Result := 'MultiPoint';
    SHP_POLYLINE, SHP_POLYLINEM, SHP_POLYLINEZ:
      Result := 'Polyline';
    SHP_POLYGON, SHP_POLYGONM, SHP_POLYGONZ:
      Result := 'Polygon';
  else
    Result := IntToStr(Ord(AShapeType));
  end;
end;

function TOgrLayerForm.ProjectionToText(const AGp: IGeoProjection): string;
var
  Epsg: Integer;
  Proj4: string;
begin
  Result := '';
  if not Assigned(AGp) then
    Exit;

  if AGp.TryAutoDetectEpsg(Epsg) then
    Exit(IntToStr(Epsg));

  Proj4 := Trim(AGp.ExportToProj4);
  if Proj4 = '' then
    Result := '<unknown>'
  else if Length(Proj4) > 54 then
    Result := Copy(Proj4, 1, 54) + '...'
  else
    Result := Proj4;
end;

procedure TOgrLayerForm.PopulateDetails;
var
  Index: Integer;
  Layer: IOgrLayer;
  Extents: IExtents;
  MinX, MinY, MaxX, MaxY: Double;
  HasExtents: Boolean;
begin
  memDetails.Clear;

  if (listView1.Selected = nil) or not Assigned(FDatasource) then
    Exit;

  Index := NativeInt(listView1.Selected.Data);
  Layer := FDatasource.GetLayer(Index, False);
  if not Assigned(Layer) then
    Exit;

  memDetails.Lines.Add('Name: ' + Layer.Name);
  memDetails.Lines.Add('Features: ' + IntToStr(Layer.FeatureCount[False]));
  memDetails.Lines.Add('Geometry: ' + ShapeTypeToText(Layer.ShapeType));
  memDetails.Lines.Add('Shape2D: ' + ShapeTypeToText(Layer.ShapeType2D));
  memDetails.Lines.Add('Projection: ' + ProjectionToText(Layer.GeoProjection));
  memDetails.Lines.Add('FID Column: ' + Layer.FIDColumnName);
  memDetails.Lines.Add('Dynamic Loading: ' + BoolToStr(Layer.DynamicLoading, True));
  memDetails.Lines.Add('Supports SaveAll: ' + BoolToStr(Layer.SupportsEditing[ostSaveAll], True));

  HasExtents := Layer.Extents[Extents, False] and Assigned(Extents);
  if HasExtents then
  begin
    MinX := Extents.xMin;
    MinY := Extents.yMin;
    MaxX := Extents.xMax;
    MaxY := Extents.yMax;
    memDetails.Lines.Add(Format('Extents: [%.6f, %.6f] - [%.6f, %.6f]',
      [MinX, MinY, MaxX, MaxY]));
    memDetails.Lines.Add(Format('Width/Height: %.6f / %.6f',
      [Abs(MaxX - MinX), Abs(MaxY - MinY)]));
  end
  else
    memDetails.Lines.Add('Extents: <not available>');
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
    FMap.LayerName[LayerHandle] := Layer.Name;
    FMap.ZoomToLayer(LayerHandle);
    FMap.Redraw;
    ModalResult := mrOk;
  end;
end;

end.
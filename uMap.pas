unit uMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  Data.DB,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, MapWinGIS_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.Activex, Vcl.Buttons, uAppLogger,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.Comp.Client, FireDAC.DApt, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.UI.Intf;

type
  TGisTempPoint = record
    X: Double;
    Y: Double;
    Temperature: Double;
  end;

type
  TForm2 = class(TForm)
    OpenDialog1: TOpenDialog;
    btnOpen: TButton;
    Panel1: TPanel;
    Button1: TButton;
    btnGeoDatabase: TButton;
    Button3: TButton;
    Button4: TButton;
    Map1: TMap;
    ListBox1: TListBox;
    CheckBox1: TCheckBox;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGeoDatabaseClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
    lasthandle: Integer;
    FProjectFileName: string;
    FProjectDirty: Boolean;
    function TryGetSelectedLayerHandle(out ALayerHandle: Integer): Boolean;
    function TryGetImageByHandle(const AHandle: Integer; out AImage: IImage): Boolean;
    procedure LogException(const AMethod: string; const E: Exception);
    procedure MarkProjectDirty;
    procedure RefreshLayerList;
    procedure LoadProjectFromFile(const AFileName: string);
    function SaveProjectToFile(const AFileName: string): Boolean;
    procedure SaveProjectWithPrompt;
    procedure SetProjectionInteractive;
    function ResolveDefaultDataDb: string;
    procedure LoadTemperatureData(const ADatabaseFile: string);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.MarkProjectDirty;
begin
  FProjectDirty := True;
end;

procedure TForm2.RefreshLayerList;
var
  I: Integer;
  LayerHandle: Integer;
  LayerName: string;
begin
  ListBox1.Items.BeginUpdate;
  try
    ListBox1.Clear;
    for I := 0 to Map1.NumLayers - 1 do
    begin
      LayerHandle := Map1.LayerHandle[I];
      LayerName := Map1.LayerName[LayerHandle];
      if LayerName = '' then
        LayerName := ExtractFileName(Map1.LayerFilename[LayerHandle]);
      ListBox1.Items.AddObject(Format('%d - %s', [LayerHandle, LayerName]), TObject(NativeInt(LayerHandle)));
    end;
  finally
    ListBox1.Items.EndUpdate;
  end;
end;

procedure TForm2.LoadProjectFromFile(const AFileName: string);
begin
  if not FileExists(AFileName) then
    raise Exception.Create('Project file does not exist.');

  Map1.LockWindow(lmLock);
  try
    if not Map1.LoadMapState(AFileName, nil) then
      raise Exception.Create('Failed to load map state: ' + AFileName);
    FProjectFileName := AFileName;
    FProjectDirty := False;
    RefreshLayerList;
    if Map1.NumLayers > 0 then
      Map1.ZoomToMaxExtents;
    Map1.Redraw;
  finally
    Map1.LockWindow(lmUnlock);
  end;
end;

function TForm2.SaveProjectToFile(const AFileName: string): Boolean;
begin
  Result := False;
  if AFileName = '' then
    Exit;

  if Map1.SaveMapState(AFileName, True, True) then
  begin
    FProjectFileName := AFileName;
    FProjectDirty := False;
    Result := True;
  end;
end;

procedure TForm2.SaveProjectWithPrompt;
var
  FileName: string;
  SaveDialog: TSaveDialog;
begin
  FileName := FProjectFileName;
  if FileName = '' then
  begin
    SaveDialog := TSaveDialog.Create(nil);
    try
      SaveDialog.InitialDir := ExtractFilePath(ParamStr(0));
      SaveDialog.Filter := 'MapWinGIS Project (*.mwxml)|*.mwxml';
      SaveDialog.DefaultExt := 'mwxml';
      if not SaveDialog.Execute(Handle) then
        Exit;
      FileName := SaveDialog.FileName;
    finally
      SaveDialog.Free;
    end;
  end;

  if not SaveProjectToFile(FileName) then
    raise Exception.Create('Failed to save project.');
end;

procedure TForm2.SetProjectionInteractive;
var
  InputValue: string;
  GeoProj: IGeoProjection;
  EpsgCode: Integer;
begin
  InputValue := 'wgs84';
  if not InputQuery('Set Projection', 'Use one of: empty, wgs84, google, epsg:4326', InputValue) then
    Exit;

  InputValue := Trim(LowerCase(InputValue));
  GeoProj := CoGeoProjection.Create;

  if InputValue = 'empty' then
  begin
    Map1.GeoProjection := GeoProj;
  end
  else if InputValue = 'wgs84' then
  begin
    if not GeoProj.SetWgs84 then
      raise Exception.Create('Unable to set WGS84 projection.');
    Map1.GeoProjection := GeoProj;
  end
  else if InputValue = 'google' then
  begin
    if not GeoProj.SetGoogleMercator then
      raise Exception.Create('Unable to set Google Mercator projection.');
    Map1.GeoProjection := GeoProj;
  end
  else if StartsText('epsg:', InputValue) then
  begin
    EpsgCode := StrToIntDef(Copy(InputValue, 6, MaxInt), -1);
    if (EpsgCode <= 0) or (not GeoProj.ImportFromEPSG(EpsgCode)) then
      raise Exception.Create('Invalid EPSG code.');
    Map1.GeoProjection := GeoProj;
  end
  else
  begin
    raise Exception.Create('Unknown projection command.');
  end;

  MarkProjectDirty;
  Map1.Redraw;
end;

function TForm2.ResolveDefaultDataDb: string;
const
  CandidateCount = 3;
var
  Candidates: array[0..CandidateCount - 1] of string;
  I: Integer;
begin
  Candidates[0] := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'data.db';
  Candidates[1] := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'data\data.db';
  Candidates[2] := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + '..\..\GisDEMO-sharp\GisMap\GisMap\bin\x86\Debug\data\data.db';

  Result := '';
  for I := Low(Candidates) to High(Candidates) do
  begin
    if FileExists(ExpandFileName(Candidates[I])) then
    begin
      Result := ExpandFileName(Candidates[I]);
      Exit;
    end;
  end;
end;

procedure TForm2.LoadTemperatureData(const ADatabaseFile: string);
var
  Conn: TFDConnection;
  QPoints: TFDQuery;
  Sf: IShapefile;
  Shp: IShape;
  Pnt: MapWinGIS_TLB.Point;
  LayerHandle: Integer;
begin
  Conn := TFDConnection.Create(nil);
  QPoints := TFDQuery.Create(nil);
  try
    Conn.LoginPrompt := False;
    Conn.Params.Clear;
    Conn.Params.Values['DriverID'] := 'SQLite';
    Conn.Params.Values['Database'] := ADatabaseFile;
    Conn.Connected := True;

    QPoints.Connection := Conn;
    QPoints.SQL.Text := 'SELECT x, y, temperature FROM Point ORDER BY temperature';
    QPoints.Open;

    Sf := CoShapefile.Create;
    if not Sf.CreateNewWithShapeID('', SHP_POINT) then
      raise Exception.Create('Failed to initialize in-memory point shapefile.');

    while not QPoints.Eof do
    begin
      Shp := CoShape.Create;
      if not Shp.Create(SHP_POINT) then
        raise Exception.Create('Failed to create point geometry.');

      Pnt := CoPoint.Create;
      Pnt.x := QPoints.FieldByName('x').AsFloat;
      Pnt.y := QPoints.FieldByName('y').AsFloat;
      if not Shp.InsertPoint(Pnt, 0) then
        raise Exception.Create('Failed to insert point geometry.');

      if Sf.EditAddShape(Shp) < 0 then
        raise Exception.Create('Failed to append point shape.');

      QPoints.Next;
    end;

    Map1.LockWindow(lmLock);
    try
      LayerHandle := Map1.AddLayer(Sf, True);
      if LayerHandle = -1 then
        raise Exception.Create('Failed to add temperature layer to map.');

      Map1.LayerName[LayerHandle] := 'Temperature Points';
      Map1.ShapeLayerDrawPoint[LayerHandle] := True;
      Map1.ShapeLayerPointSize[LayerHandle] := 6;
      Map1.ShapeLayerPointColor[LayerHandle] := clRed;
      Map1.ZoomToLayer(LayerHandle);
      Map1.Redraw;
    finally
      Map1.LockWindow(lmUnlock);
    end;

    RefreshLayerList;
    MarkProjectDirty;
  finally
    QPoints.Free;
    Conn.Free;
  end;
end;

procedure TForm2.LogException(const AMethod: string; const E: Exception);
begin
  AppLogger.Error('uMap.' + AMethod, E.ClassName + ': ' + E.Message);
end;

function TForm2.TryGetImageByHandle(const AHandle: Integer; out AImage: IImage): Boolean;
begin
  Result := False;
  AImage := nil;

  if AHandle < 0 then
  begin
    AppLogger.Warning('uMap.TryGetImageByHandle', 'Invalid image handle: ' + IntToStr(AHandle));
    Exit;
  end;

  try
    AImage := Map1.Image[AHandle];
    Result := Assigned(AImage);
    if not Result then
      AppLogger.Warning('uMap.TryGetImageByHandle', 'Map returned nil image for handle ' + IntToStr(AHandle));
  except
    on E: Exception do
      LogException('TryGetImageByHandle', E);
  end;
end;

function TForm2.TryGetSelectedLayerHandle(out ALayerHandle: Integer): Boolean;
begin
  Result := False;
  ALayerHandle := -1;

  if ListBox1.Items.Count = 0 then
  begin
    AppLogger.Warning('uMap.TryGetSelectedLayerHandle', 'No layers in list');
    Exit;
  end;

  if (ListBox1.ItemIndex < 0) or (ListBox1.ItemIndex >= ListBox1.Items.Count) then
  begin
    AppLogger.Warning('uMap.TryGetSelectedLayerHandle', 'Invalid selected index');
    Exit;
  end;

  try
    ALayerHandle := Map1.LayerHandle[ListBox1.ItemIndex];
    Result := ALayerHandle >= 0;
    if not Result then
      AppLogger.Warning('uMap.TryGetSelectedLayerHandle', 'Map returned invalid layer handle');
  except
    on E: Exception do
      LogException('TryGetSelectedLayerHandle', E);
  end;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
var
handlayer : integer;
begin
  try
    if not TryGetSelectedLayerHandle(handlayer) then
      Exit;

    map1.MoveLayerUp(map1.LayerPosition[handlayer]);
    map1.SetFocus;
    AppLogger.Info('uMap.BitBtn1Click', 'Layer moved up');
  except
    on E: Exception do
      LogException('BitBtn1Click', E);
  end;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
var
handlayer : integer;
begin
  try
    if not TryGetSelectedLayerHandle(handlayer) then
      Exit;

    map1.MoveLayerDown(map1.LayerPosition[handlayer]);
    map1.SetFocus;
    AppLogger.Info('uMap.BitBtn2Click', 'Layer moved down');
  except
    on E: Exception do
      LogException('BitBtn2Click', E);
  end;
end;

procedure TForm2.BitBtn3Click(Sender: TObject);
var
  img: IImage;
  x,y:Integer;
  nband:Integer;
  value: double;
  raster:GdalRasterBand;
begin
  try
    img := CoImage.Create;
    if not Assigned(img) then
      Exit;

    if img.Open('C:\Users\USER\Desktop\open_elevation\data\n05_w073_1arc.tif',TIFF_FILE,True,Nil) then
    begin
      nband := img.NoBands;
      if nband <= 0 then
        Exit;

      raster := img.Band[nband];
      if not Assigned(raster) then
        Exit;

      img.ProjectionToImage(-72.893393,5.931346,x,y);
      if raster.Value[x,y,value] then
        ShowMessage('x: ' + inttostr(x) + ' y: ' + inttostr(y)+'  valor es: ' + floattostr(value));
    end;
  except
    on E: Exception do
      LogException('BitBtn3Click', E);
  end;
end;

procedure TForm2.BitBtn4Click(Sender: TObject);
var
  img: IImage;
  x,y,nband:Integer;
  value: double;
  raster:GdalRasterBand;

begin
  try
    if not TryGetImageByHandle(lasthandle, img) then
      Exit;

    nband := img.NoBands;
    if nband <= 0 then
    begin
      AppLogger.Warning('uMap.BitBtn4Click', 'Image has no bands');
      Exit;
    end;

    raster := img.Band[nband];
    if not Assigned(raster) then
    begin
      AppLogger.Warning('uMap.BitBtn4Click', 'Failed to get raster band');
      Exit;
    end;

    img.ProjectionToImage(-72.893393,5.931346,x,y);
    if raster.Value[x,y,value] then
      ShowMessage('x: ' + inttostr(x) + ' y: ' + inttostr(y)+'  valor es: ' + floattostr(value));
  except
    on E: Exception do
      LogException('BitBtn4Click', E);
  end;
end;

procedure TForm2.btnOpenClick(Sender: TObject);
var
  Fm: IFileManager;
  LayerObject: OleVariant;
  fName: string;
  HandleLayer: Integer;
begin
  try
    Fm := CoFileManager.Create;
    if not Assigned(Fm) then
      Exit;

    OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
    OpenDialog1.Filter := Fm.CdlgFilter;
    if (not OpenDialog1.Execute) or (OpenDialog1.FileName = '') then
      Exit;

    fName := OpenDialog1.FileName;
    LayerObject := Fm.Open(fName, fosAutoDetect, nil);
    if not Fm.LastOpenIsSuccess then
      raise Exception.Create('Failed to open layer source: ' + fName);

    Map1.LockWindow(lmLock);
    try
      HandleLayer := Map1.AddLayer(LayerObject, True);
      if HandleLayer = -1 then
        raise Exception.Create('Map rejected layer: ' + fName);
      Map1.ZoomToLayer(HandleLayer);
      Map1.Redraw;
    finally
      Map1.LockWindow(lmUnlock);
    end;

    RefreshLayerList;
    MarkProjectDirty;
  finally
    Map1.SetFocus;
  end;
end;


procedure TForm2.Button1Click(Sender: TObject);
var
  ProjectFile: string;
begin
  try
    ProjectFile := '';
    with TOpenDialog.Create(nil) do
      try
        InitialDir := ExtractFilePath(ParamStr(0));
        Filter := 'MapWinGIS Project (*.mwxml)|*.mwxml|All files (*.*)|*.*';
        if Execute(Handle) then
          ProjectFile := FileName;
      finally
        Free;
      end;

    if ProjectFile = '' then
      Exit;

    LoadProjectFromFile(ProjectFile);
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('Button1Click', E);
  end;
end;

procedure TForm2.btnGeoDatabaseClick(Sender: TObject);
begin
  try
    SaveProjectWithPrompt;
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('btnGeoDatabaseClick', E);
  end;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  try
    SetProjectionInteractive;
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('Button3Click', E);
  end;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  try
    Map1.LockWindow(lmLock);
    try
      Map1.RemoveAllLayers;
      Map1.Redraw;
      ListBox1.Items.Clear;
      lasthandle := -1;
      FProjectFileName := '';
      FProjectDirty := False;
    finally
      Map1.LockWindow(lmUnlock);
    end;
    Map1.SetFocus;
  finally
  end;
end;

procedure TForm2.Button5Click(Sender: TObject);
begin
  try
    Map1.CursorMode := cmZoomIn;
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('Button5Click', E);
  end;
end;

procedure TForm2.Button6Click(Sender: TObject);
begin
  try
    Map1.CursorMode := cmZoomOut;
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('Button6Click', E);
  end;
end;

procedure TForm2.Button7Click(Sender: TObject);
begin
  try
    Map1.CursorMode := cmPan;
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('Button7Click', E);
  end;
end;

procedure TForm2.Button8Click(Sender: TObject);
var
  DbPath: string;
begin
  try
    DbPath := ResolveDefaultDataDb;
    if DbPath = '' then
    begin
      with TOpenDialog.Create(nil) do
        try
          InitialDir := ExtractFilePath(ParamStr(0));
          Filter := 'SQLite database (*.db;*.db3;*.sqlite)|*.db;*.db3;*.sqlite|All files (*.*)|*.*';
          if Execute(Handle) then
            DbPath := FileName;
        finally
          Free;
        end;
    end;

    if DbPath = '' then
      Exit;

    LoadTemperatureData(DbPath);
    Map1.SetFocus;
  except
    on E: Exception do
      LogException('Button8Click', E);
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  gs: GlobalSettings;
begin
  try
    gs := CoGlobalSettings.Create;
    gs.ShapefileFastMode := True;
    gs.ZoomToFirstLayer := True;
    gs.OgrLayerMaxFeatureCount := 25000;
    gs.AllowLayersWithoutProjections := True;
    gs.AllowProjectionMismatch := False;
    gs.ReprojectLayersOnAdding := False;

    Map1.Projection := PROJECTION_NONE;
    Map1.TileProvider := ProviderNone;
    Map1.SendMouseMove := True;

    btnOpen.Caption := 'Add Layer';
    Button1.Caption := 'Load Project';
    btnGeoDatabase.Caption := 'Save Project';
    Button3.Caption := 'Projection';
    Button4.Caption := 'New Project';
    Button5.Caption := 'Zoom In';
    Button6.Caption := 'Zoom Out';
    Button7.Caption := 'Pan';
    Button8.Caption := 'LoadData';
    CheckBox1.Visible := False;

    FProjectFileName := '';
    FProjectDirty := False;
    lasthandle := -1;
    AppLogger.Info('uMap.FormCreate', 'Map initialized');
  except
    on E: Exception do
      LogException('FormCreate', E);
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  try
    RefreshLayerList;
    map1.SetFocus;
  except
    on E: Exception do
      LogException('FormShow', E);
  end;
end;



end.

unit uMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, MapWinGIS_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.Activex, Vcl.Buttons, uAppLogger;

type
  TForm2 = class(TForm)
    OpenDialog1: TOpenDialog;
    btnOpen: TButton;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
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
    procedure Button2Click(Sender: TObject);
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
    function TryGetSelectedLayerHandle(out ALayerHandle: Integer): Boolean;
    function TryGetImageByHandle(const AHandle: Integer; out AImage: IImage): Boolean;
    procedure LogException(const AMethod: string; const E: Exception);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

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
  shp:IShapefile;
  fName : string;
  HandleLayer: Integer;
begin
  try
    Map1.LockWindow(lmLock);
    OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
    if (opendialog1.Execute) and (opendialog1.FileName <> '') then
    begin
      fName := opendialog1.FileName;
      shp := CoShapefile.Create;
      if Assigned(shp) and shp.Open(fName, nil) then
      begin
        if shp.HasSpatialIndex then
          shp.UseSpatialIndex := True;
        HandleLayer := Map1.AddLayer(shp,True);
        if HandleLayer <> -1 then
          Map1.ZoomToLayer(HandleLayer);
      end
      else if Assigned(shp) then
      begin
        ShowMessage(shp.ErrorMsg[shp.LastErrorCode]);
        AppLogger.Error('uMap.btnOpenClick', shp.ErrorMsg[shp.LastErrorCode]);
      end;
    end;
  except
    on E: Exception do
      LogException('btnOpenClick', E);
  finally
    Map1.LockWindow(lmUnlock);
    Map1.Redraw;
    Map1.SetFocus;
  end;
end;


procedure TForm2.Button1Click(Sender: TObject);
var
  selectedFile: string;
  dlg: TOpenDialog;
  img: IImage;
begin
  try
    selectedFile := '';
    dlg := TOpenDialog.Create(nil);
    try
      img := CoImage.Create;
      dlg.InitialDir := ExtractFilePath(ParamStr(0));
      dlg.Filter := img.CdlgFilter;
      if dlg.Execute(Handle) then
       selectedFile := dlg.FileName;
    finally
      dlg.Free;
    end;

    if SameText(ExtractFileExt(selectedFile), '.tif') then
    begin
      Map1.LockWindow(lmLock);
      try
       if Assigned(img) and img.Open(selectedFile,TIFF_FILE,True,Nil) then
       begin
         lasthandle := Map1.AddLayer(img,True);
         if lasthandle <> -1 then
           Map1.ZoomToLayer(lasthandle);
       end
       else
       begin
         ShowMessage(img.ErrorMsg[img.LastErrorCode]);
         AppLogger.Error('uMap.Button1Click', img.ErrorMsg[img.LastErrorCode]);
       end;
      finally
       Map1.LockWindow(lmUnlock);
       Map1.Redraw;
       map1.SetFocus;
      end;
    end;
  except
    on E: Exception do
      LogException('Button1Click', E);
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  ds : TOgrDatasource;
  count, I, HandleLayer: integer;
  lyr: OgrLayer;
  foldergdb: string;
begin
  try
    HandleLayer := -1;
    foldergdb := '';
    with TFileOpenDialog.Create(nil) do
      try
        Options := [fdoPickFolders];
        if Execute then
          foldergdb := FileName;
      finally
        Free;
      end;

    if foldergdb = '' then
      Exit;

    ds := TOgrDatasource.Create(Nil);
    try
      if not ds.Open(foldergdb) then
      begin
        ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
        AppLogger.Error('uMap.Button2Click', ds.GdalLastErrorMsg);
        Exit;
      end;

      Map1.LockWindow(lmLock);
      try
        count := ds.LayerCount;
        for I := 0 to count - 1 do
        begin
          lyr := ds.GetLayer(I, False);
          if not Assigned(lyr) then
            Continue;
          if CheckBox1.Checked then
            HandleLayer := map1.AddLayer(lyr, True);
          ListBox1.Items.Add(lyr.Name);
        end;
        if HandleLayer <> -1 then
          Map1.ZoomToLayer(HandleLayer);
        Map1.Redraw;
        Map1.SetFocus;
      finally
        Map1.LockWindow(lmUnlock);
      end;
    finally
      try
        ds.Close();
      except
      end;
      ds.Free;
    end;
  except
    on E: Exception do
      LogException('Button2Click', E);
  end;
end;

procedure TForm2.Button3Click(Sender: TObject);
var
  ds : TOgrDatasource;
  layer: string;
  count,I,HandleLayer: integer;
  lyr : OgrLayer;
  dlg: TOpenDialog;
  filter:string;
begin
  try
    filter := 'GeoPackage         (*.gpkg)|*.GPKG|'+
    'Esri Shapefile (*.shp)|*.SHP|'+
    'Vector GeoJSON files   (*.json)|*.JSON|'+
    'Sqlite Vector      (*.sqlite)|*.SQLITE|'+
    'Others Files Archives        (*.*)|*.*|';
    layer := '';
    HandleLayer := -1;
    dlg := TOpenDialog.Create(nil);
    try
      dlg.InitialDir := ExtractFilePath(ParamStr(0));
      dlg.Filter := filter;
      if dlg.Execute(Handle) then
       layer := dlg.FileName;
    finally
      dlg.Free;
    end;
    if layer = '' then
      Exit;

    ds := TOgrDatasource.Create(Nil);
    try
      if not ds.Open(layer) then
      begin
        ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
        AppLogger.Error('uMap.Button3Click', ds.GdalLastErrorMsg);
        Exit;
      end;

      Map1.LockWindow(lmLock);
      try
        count := ds.LayerCount;
        for I := 0 to count - 1 do
        begin
          lyr := ds.GetLayer(I,False);
          if not Assigned(lyr) then
            Continue;
          HandleLayer := map1.AddLayer(lyr,True);
          ListBox1.Items.Add(lyr.Name);
        end;
        if HandleLayer <> -1 then
          Map1.ZoomToLayer(HandleLayer);
        Map1.Redraw;
        Map1.SetFocus;
      finally
        Map1.LockWindow(lmUnlock);
      end;
    finally
      ds.Close();
      ds.Free;
    end;
  except
    on E: Exception do
      LogException('Button3Click', E);
  end;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  try
    Map1.LockWindow(lmLock);
    map1.RemoveAllLayers;
    ListBox1.Items.Clear;
    Map1.Redraw;
    Map1.Latitude := 7.12057;
    Map1.Longitude := -73.1194;
    Map1.SetFocus;
    lasthandle := -1;
  except
    on E: Exception do
      LogException('Button4Click', E);
  finally
    Map1.LockWindow(lmUnlock);
  end;
end;

procedure TForm2.Button5Click(Sender: TObject);
var
 ds : TOgrDatasource;
  count,HandleLayer: integer;
  lyr : OgrLayer;
  gs:GlobalSettings;
begin
  HandleLayer := -1;
  ds := TOgrDatasource.Create(Nil);
  try
    gs := CoGlobalSettings.Create;
    gs.ReprojectLayersOnAdding:= True;

    if not ds.Open('http://192.168.1.41:8080/geoserver/GIS/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=GIS%3Aapoyo&bbox=-73.130,7,-73.110,8&outputFormat=application%2Fjson') then
    begin
      ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
      AppLogger.Error('uMap.Button5Click', ds.GdalLastErrorMsg);
      Exit;
    end;

    Map1.LockWindow(lmLock);
    try
      count := ds.LayerCount;
      if count > 0 then
      begin
        lyr := ds.GetLayer(0,False);
        if Assigned(lyr) then
        begin
          HandleLayer := map1.AddLayer(lyr,True);
          ListBox1.Items.Add(lyr.Name);
        end;
      end;
      if HandleLayer <> -1 then
        Map1.ZoomToLayer(HandleLayer);
      Map1.Redraw;
      Map1.SetFocus;
    finally
      Map1.LockWindow(lmUnlock);
    end;
  finally
    try
      ds.Close();
    except
    end;
    ds.Free;
  end;
end;

procedure TForm2.Button6Click(Sender: TObject);
var
  layerhandle:integer;
  wmslayer: IWmsLayer;
  ext:IExtents;
begin
  try
    layerhandle := -1;
    WmsLayer := CoWmsLayer.Create;
    ext := CoExtents.Create;
    if (not Assigned(WmsLayer)) or (not Assigned(ext)) then
      Exit;
    ext.SetBounds(-20037508.3,-20037508.3,0,20037508.3,20037508.3,0);
    WmsLayer.BaseUrl := 'http://192.168.1.15:8080/services/wms';
    wmslayer.BoundingBox := ext;
    wmslayer.Contrast := 1.0;
    wmsLayer.DoCaching := false;
    wmsLayer.Epsg := 3857;
    wmsLayer.Format := 'image%2Fpng';
    wmsLayer.Gamma := 1.0;
    wmsLayer.Layers := 'osm-bright-2';
    wmsLayer.Name := 'osm-bright-2';
    wmsLayer.Opacity := 255;
    wmsLayer.UseCache := false;
    wmsLayer.Id := 1;
    wmsLayer.UseTransparentColor := false;
    wmsLayer.Key := inttostr(wvAuto);
    layerHandle := Map1.AddLayer(wmsLayer, true);
    if layerHandle = -1 then
      AppLogger.Warning('uMap.Button6Click', 'Failed to add WMS layer');
    map1.SetFocus;
  except
    on E: Exception do
      LogException('Button6Click', E);
  end;
end;

procedure TForm2.Button7Click(Sender: TObject);
var
  gs: GlobalSettings;
  conn,sqlOrLayerName: string;
  handle: integer;
  lyr:OgrLayer;
begin
  try
    conn := 'PG:host=192.168.1.41 port=5432 user=alex ****** dbname=gis';
    sqlOrLayerName := 'SELECT * FROM apoyo';
    handle := map1.AddLayerFromDatabase(conn, sqlOrLayerName, true);
    if handle = -1 then
    begin
      gs := CoGlobalSettings.Create;
      showmessage('Last GDAL error: ' + gs.GdalLastErrorMsg);
      AppLogger.Error('uMap.Button7Click', gs.GdalLastErrorMsg);
    end
    else
    begin
      lyr := map1.OgrLayer[handle];
      if Assigned(lyr) then
      begin
        Map1.ZoomToLayer(handle);
        Map1.Redraw;
        Map1.LockWindow(lmUnlock);
        Map1.SetFocus;
      end;
    end;
  except
    on E: Exception do
      LogException('Button7Click', E);
  end;
end;

procedure TForm2.Button8Click(Sender: TObject);
var
  ds : TOgrDatasource;
  count,HandleLayer: integer;
  lyr : OgrLayer;
begin
  try
    HandleLayer := -1;
    ds := TOgrDatasource.Create(Nil);
    try
      if not ds.Open('PG:host=192.168.1.41 port=5432 user=alex ****** dbname=gis') then
      begin
        ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
        AppLogger.Error('uMap.Button8Click', ds.GdalLastErrorMsg);
      end
      else
      begin
        Map1.LockWindow(lmLock);
        try
          count := ds.LayerCount;
          if count > 0 then
          begin
            lyr := ds.GetLayer(0,False);
            if Assigned(lyr) then
            begin
              HandleLayer := map1.AddLayer(lyr,True);
              ListBox1.Items.Add(lyr.Name);
            end;
          end;
          if HandleLayer <> -1 then
            Map1.ZoomToLayer(HandleLayer);
          Map1.Redraw;
          Map1.SetFocus;
        finally
          Map1.LockWindow(lmUnlock);
        end;
      end;
    finally
      ds.Close();
      ds.Free;
    end;
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
    gs.RandomColorSchemeForGrids := True;
    gs.TilesThreadPoolSize := 3;
    Map1.TileProvider := $FFFFFFFF;
    map1.KnownExtents := keColombia;
    lasthandle := -1;
    AppLogger.Info('uMap.FormCreate', 'Map initialized');
  except
    on E: Exception do
      LogException('FormCreate', E);
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  objProj:IGeoProjection;
begin
  try
    objProj := CoGeoProjection.Create;
    objProj.ImportFromEPSG(4326);
    Map1.GeoProjection := objProj;
    map1.SetFocus;
  except
    on E: Exception do
      LogException('FormShow', E);
  end;
end;



end.

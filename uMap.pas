unit uMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, MapWinGIS_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.Activex, Vcl.Buttons;

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
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.BitBtn1Click(Sender: TObject);
var
handlayer : integer;
begin
if ListBox1.Items.Count > 0 then
begin
   handlayer := map1.LayerHandle[listbox1.ItemIndex];
  map1.MoveLayerUp (map1.LayerPosition[handlayer]);
  map1.SetFocus;
end;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
var
handlayer : integer;
begin
  if ListBox1.Items.Count > 0 then
  begin
     handlayer := map1.LayerHandle[listbox1.ItemIndex];
    map1.MoveLayerDown(map1.LayerPosition[handlayer]);
    map1.SetFocus;
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
  img := CoImage.Create;
  if img.Open('C:\Users\USER\Desktop\open_elevation\data\n05_w073_1arc.tif',TIFF_FILE,True,Nil) then
  begin
     nband := img.NoBands;
    raster := img.Band[nband];

    img.ProjectionToImage(-72.893393,5.931346,x,y);
    //value := img.Value[x,y];
    if raster.Value[x,y,value] then
     ShowMessage('x: ' + inttostr(x) + ' y: ' + inttostr(y)+'  valor es: ' + floattostr(value));

  end;

end;

procedure TForm2.BitBtn4Click(Sender: TObject);
var
  img: IImage;
  x,y,nband:Integer;
  value: double;
  raster:GdalRasterBand;

begin
  raster := CoGdalRasterBand.Create;


  img := map1.Image[lasthandle];
  nband := img.NoBands;
  raster := img.Band[nband];

  img.ProjectionToImage(-72.893393,5.931346,x,y);
  //value := img.Value[x,y];
  if raster.Value[x,y,value] then
   ShowMessage('x: ' + inttostr(x) + ' y: ' + inttostr(y)+'  valor es: ' + floattostr(value));


end;

procedure TForm2.btnOpenClick(Sender: TObject);
var
  shp:IShapefile;
  fName : string;
  HandleLayer: Integer;
begin
  Map1.LockWindow(lmLock);
  //Map1.RemoveAllLayers;

  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
  //SetCurrentDir(ExtractFileDir(ParamStr(0)));
  if (opendialog1.Execute) and (opendialog1.FileName <> '') then
  begin

    fName := opendialog1.FileName;
    shp := CoShapefile.Create;
    if shp.Open(fName, nil)then
   begin
     if shp.HasSpatialIndex then shp.UseSpatialIndex := True; // showmessage('hast index');
     //else
        //shp.CreateSpatialIndex(fName);
     HandleLayer := Map1.AddLayer(shp,True);
     Map1.ZoomToLayer(HandleLayer)
   end
   else
   begin
    ShowMessage(shp.ErrorMsg[shp.LastErrorCode]);
   end;
  end;
  Map1.LockWindow(lmUnlock);
  Map1.Redraw;
  Map1.SetFocus;
end;


procedure TForm2.Button1Click(Sender: TObject);
var
  shp:IShapefile;
  utils: TUtils;
  HandleLayer: Integer;
  gdalUtils : TGdalUtils;
  options : array[0..3] of string;
  b:PSafeArray;
  aObjects: PSafeArray;
  selectedFile: string;
  dlg: TOpenDialog;
  position : Integer;
  img: IImage;
begin
  selectedFile := '';
  dlg := TOpenDialog.Create(nil);
  try
    img := CoImage.Create;
    dlg.InitialDir := ExtractFilePath(ParamStr(0));
    dlg.Filter := img.CdlgFilter; //'Imagen tif (*.tif)|*.TIF|Png Image (*.png)|*.PNG';
    if dlg.Execute(Handle) then
      selectedFile := dlg.FileName;
  finally
    dlg.Free;
  end;

   if selectedFile <> '' then
   begin
    if ExtractFileExt(selectedFile) = '.tif' then
    begin
       Map1.LockWindow(lmLock);

       if img.Open(selectedFile,TIFF_FILE,True,Nil) then
       begin
          lasthandle := Map1.AddLayer(img,True);
          Map1.ZoomToLayer(lasthandle)
       end
       else
       begin
         ShowMessage(img.ErrorMsg[img.LastErrorCode]);
       end;

       Map1.LockWindow(lmUnlock);
       Map1.Redraw;
       map1.SetFocus;
    end;
 
   end;


end;

procedure TForm2.Button2Click(Sender: TObject);
var
 ds : TOgrDatasource;
  layer: string;
  count,I,HandleLayer: integer;
  lyr : OgrLayer;
   dlg: TOpenDialog;
   filter,foldergdb:string;

begin
with TFileOpenDialog.Create(nil) do
  try
    Options := [fdoPickFolders];
    if Execute then
      foldergdb := FileName;
  finally
    Free;
  end;

  ds := TOgrDatasource.Create(Nil);
  if not ds.Open(foldergdb) then
  begin
    ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
  end
  else
  begin
    Map1.LockWindow(lmLock);
    //Map1.RemoveAllLayers;
    count := ds.LayerCount;
    //lasthandle := map1.LayerHandle[0];
    for I := 0 to count-1 do
      begin
        lyr := ds.GetLayer(I,False);
      if CheckBox1.Checked  then map1.AddLayer(lyr,True);
        ListBox1.Items.Add(lyr.Name);
      end;
    Map1.ZoomToLayer(HandleLayer);
    Map1.Redraw;
    Map1.LockWindow(lmUnlock);
    Map1.SetFocus;
    ds.Close();
    ds.Free;
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
  //layer := 'D:\Bibliotecas\Documentos\Embarcadero\Studio\Projects\MapWinGis_Delphi\Win32\Debug\vector.json';
  filter := 'GeoPackage         (*.gpkg)|*.GPKG|'+
  'Esri Shapefile (*.shp)|*.SHP|'+
  'Vector GeoJSON files   (*.json)|*.JSON|'+
  'Sqlite Vector      (*.sqlite)|*.SQLITE|'+
  'Others Files Archives        (*.*)|*.*|';
  layer := '';
  dlg := TOpenDialog.Create(nil);
  try

    dlg.InitialDir := ExtractFilePath(ParamStr(0));
    dlg.Filter := filter;
    if dlg.Execute(Handle) then
     layer := dlg.FileName;
  finally
    dlg.Free;
  end;
  ds := TOgrDatasource.Create(Nil);
  if not ds.Open(layer) then
  begin
    ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
  end
  else
  begin
    Map1.LockWindow(lmLock);
    //Map1.RemoveAllLayers;
    count := ds.LayerCount;
    //lasthandle := map1.LayerHandle[0];
    for I := 0 to count-1 do
      begin
        lyr := ds.GetLayer(I,False);
        HandleLayer := map1.AddLayer(lyr,True);
        ListBox1.Items.Add(lyr.Name);
      end;
    Map1.ZoomToLayer(HandleLayer);
    Map1.Redraw;
    Map1.LockWindow(lmUnlock);
    Map1.SetFocus;
    ds.Close();
  end;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  Map1.LockWindow(lmLock);
  //map1.Clear;
  map1.RemoveAllLayers;
  ListBox1.Items.Clear;
  Map1.Redraw;
  Map1.LockWindow(lmUnlock);
    Map1.Latitude := 7.12057;
    Map1.Longitude := -73.1194;
  Map1.SetFocus;

end;

procedure TForm2.Button5Click(Sender: TObject);
var
 ds : TOgrDatasource;
  layer: string;
  count,I,HandleLayer: integer;
  lyr : OgrLayer;
   dlg: TOpenDialog;
   filter,foldergdb:string;
   gs:GlobalSettings;
begin
  ds := TOgrDatasource.Create(Nil);
  gs := CoGlobalSettings.Create;
  gs.ReprojectLayersOnAdding:= True;

  //if not ds.Open('WFS:http://webgis.regione.sardegna.it/geoserver/ows') then
  //if not ds.Open('WFS:http://192.168.1.41:8080/geoserver/GIS/ows') then
  if not ds.Open('http://192.168.1.41:8080/geoserver/GIS/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=GIS%3Aapoyo&bbox=-73.130,7,-73.110,8&outputFormat=application%2Fjson') then


  begin
    ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
  end
  else
  begin
    Map1.LockWindow(lmLock);
    count := ds.LayerCount;
     lyr := ds.GetLayer(0,False);
     HandleLayer := map1.AddLayer(lyr,True);
     ListBox1.Items.Add(lyr.Name);
      //end;
    Map1.ZoomToLayer(HandleLayer);
    Map1.Redraw;
    Map1.LockWindow(lmUnlock);
    Map1.SetFocus;
    ds.Close();
    ds.Free;
  end;
end;

procedure TForm2.Button6Click(Sender: TObject);
var
  layerhandle:integer;
  wmslayer: IWmsLayer;
  ext:IExtents;
begin
  layerhandle:=-1;
  WmsLayer := CoWmsLayer.Create;
  ext := CoExtents.Create;
  ext.SetBounds(-20037508.3,-20037508.3,0,20037508.3,20037508.3,0);
  //minx="-20037508.342789" miny="-20037508.342789" maxx="20037508.342789" maxy="20037508.342789"
  //WmsLayer.BaseUrl := 'http://192.168.1.41:8080/geoserver/GIS/wms';
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
  map1.SetFocus;



end;

procedure TForm2.Button7Click(Sender: TObject);
var
  gs: GlobalSettings;
  conn,sqlOrLayerName: string;
  handle: integer;
  lyr:OgrLayer;
  //ext:IExtents;
  xmin,ymin,zmin,xmax,ymax,zmax:Double;

begin
  conn := 'PG:host=192.168.1.41 port=5432 user=alex password=password dbname=gis';
  //ext := CoExtents.Create;

  //map1.Extents.GetBounds(xmin,ymin,zmin,xmax,ymax,zmax);
  //ext.GetBounds();

  //sqlOrLayerName := 'SELECT * FROM apoyo WHERE ST_X(geom)>'+floattostr(xmin)+' and ST_X(geom) < '+floattostr(xmax)+''+' and ST_Y';
  sqlOrLayerName := 'SELECT * FROM apoyo';
  handle := map1.AddLayerFromDatabase(conn, sqlOrLayerName, true);
  if handle = -1 then
  begin
     //showmessage('Failed to open layer: ' + map1.FileManager.get_ErrorMsg(map1.FileManager.LastErrorCode));
     gs := CoGlobalSettings.Create;
    showmessage('Last GDAL error: ' + gs.GdalLastErrorMsg);
  end
  else
  begin
    lyr := map1.OgrLayer[handle];
    if Assigned(lyr)  then
    begin
      //showmessage('Number of features: '+ inttostr(lyr.FeatureCount[false] ));
      Map1.ZoomToLayer(handle);
      Map1.Redraw;
      Map1.LockWindow(lmUnlock);
      Map1.SetFocus;
    end;
  end;
  //gs := CoGlobalSettings.Create;
end;

procedure TForm2.Button8Click(Sender: TObject);
var
  ds : TOgrDatasource;
  layer: string;
  count,I,HandleLayer: integer;
  lyr : OgrLayer;
   dlg: TOpenDialog;
   filter:string;
begin
  ds := TOgrDatasource.Create(Nil);
  if not ds.Open('PG:host=192.168.1.41 port=5432 user=alex password=password dbname=gis') then
  begin
    ShowMessage('Failed to establish connection; '+ ds.GdalLastErrorMsg);
  end
  else
  begin
    Map1.LockWindow(lmLock);
    //Map1.RemoveAllLayers;
    count := ds.LayerCount;
    //lasthandle := map1.LayerHandle[0];
    //for I := 0 to count-1 do
      ///begin
        lyr := ds.GetLayer(0,False);
        HandleLayer := map1.AddLayer(lyr,True);
        ListBox1.Items.Add(lyr.Name);
     // end;
    Map1.ZoomToLayer(HandleLayer);
    Map1.Redraw;
    Map1.LockWindow(lmUnlock);
    Map1.SetFocus;
    ds.Close();
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  gs: GlobalSettings;
  ext:IExtents;
begin

 gs := CoGlobalSettings.Create;
 //ext := CoExtents.Create;
 gs.ShapefileFastMode := True;
 gs.RandomColorSchemeForGrids := True;
 //gs.AllowLayersWithoutProjections := True;
 //gs.ReprojectLayersOnAdding := True ;
//gs.StartLogTileRequests('TilesReport.txt',False);
  gs.TilesThreadPoolSize := 3;
 Map1.TileProvider := $FFFFFFFF;
 //map1.GrabProjectionFromData := True;
 map1.KnownExtents := keColombia ;
 //ext.SetBounds(-75,4,0,-72,9,0);
 //if map1.SetGeographicExtents(ext) then showmessage('ok');

end;

procedure TForm2.FormShow(Sender: TObject);
var
  objProj:IGeoProjection;
  providers : ITileProviders;
  providerId : Integer;
  //error : Boolean;
begin
  objProj := CoGeoProjection.Create;
  objProj.ImportFromEPSG(4326);
  Map1.GeoProjection := objProj;
   //map1.Projection := PROJECTION_GOOGLE_MERCATOR;

   {map1.TileProvider :=  $FFFFFFFF;

     providers := CoTileProviders.Create;
   providers := Map1.Tiles.Providers;
   providerId := ProviderCustom + 1;  }
   //providers.Add(providerId, 'MyProvider', 'http://192.168.0.219/mapas/tiles/{zoom}/{x}/{y}.png',SphericalMercator, 0, 20,'openstreet');

    //Map1.Projection := PROJECTION_GOOGLE_MERCATOR;
     {
    Map1.TileProvider := ProviderNone;
    Map1.Tiles.ProviderId := providerId;

    Map1.Latitude := 7.12057;
    Map1.Longitude := -73.1194;
    Map1.CurrentZoom := 8;


    Map1.Tiles.DiskCacheFilename := 'mapatiles.db3';
    Map1.Tiles.DoCaching[RAM] := true;
    Map1.Tiles.DoCaching[Disk] := true;
    Map1.Tiles.UseCache[Disk] := true;
    Map1.Tiles.MinScaleToCache := 1;
    Map1.Tiles.MaxScaleToCache := 15;
    map1.ZoomBarMinZoom := 1;
    map1.ZoomBarMaxZoom := 19; }

    map1.SetFocus;


end;



end.

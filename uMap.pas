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
  filter := 'Esri Shapefile (*.shp)|*.SHP|'+
  'Vector GeoJSON files   (*.json)|*.JSON|'+
  'Sqlite Vector      (*.sqlite)|*.SQLITE|'+
  'GeoPackage         (*.gpkg)|*.GPKG|'+
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
  map1.Clear;
  map1.RemoveAllLayers;
  ListBox1.Items.Clear;
  Map1.Redraw;
  Map1.LockWindow(lmUnlock);
  Map1.SetFocus;

end;

procedure TForm2.FormCreate(Sender: TObject);
var
  gs: GlobalSettings;
begin

 gs := CoGlobalSettings.Create;
 gs.ShapefileFastMode := True;
 gs.RandomColorSchemeForGrids := True;
 gs.AllowLayersWithoutProjections := True;


end;

procedure TForm2.FormShow(Sender: TObject);
var
  objProj:IGeoProjection;
  providers : ITileProviders;
  providerId : Integer;
  error : Boolean;
begin
  objProj := CoGeoProjection.Create;
  objProj.ImportFromEPSG(3116);
  Map1.GeoProjection := objProj;


   {  providers := CoTileProviders.Create;
   providers := Map1.Tiles.Providers;
   providerId := ProviderCustom + 1; }
   //providers.Add(providerId, 'MyProvider', 'http://192.168.0.219/maps/{zoom}/{x}/{y}.png',SphericalMercator, 1, 15,'openstreet');

    //Map1.Projection := PROJECTION_GOOGLE_MERCATOR;
    //Map1.TileProvider := ProviderNone;
    //Map1.Tiles.ProviderId := providerId;

    //Map1.Latitude := 7.0761;
    //Map1.Longitude := -73.2989;
    //Map1.CurrentZoom := 8;


    //Map1.Tiles.DiskCacheFilename := 'mwtiles.db3';
    //Map1.Tiles.DoCaching[RAM] := true;
    //Map1.Tiles.DoCaching[Disk] := true;
    //Map1.Tiles.UseCache[Disk] := true;
    //Map1.Tiles.MinScaleToCache := 1;
    //Map1.Tiles.MaxScaleToCache := 15;
    //map1.ZoomBarMinZoom := 5;
    //map1.ZoomBarMaxZoom := 19;

    map1.SetFocus;


end;



end.

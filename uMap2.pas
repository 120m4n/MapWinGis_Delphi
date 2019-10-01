unit uMap2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.OleCtrls,
  MapWinGIS_TLB, Vcl.StdCtrls;

type
  TForm3 = class(TForm)

    Panel1: TPanel;
    Map1: TMap;
    Button1: TButton;
    procedure Map1TilesLoaded(ASender: TObject; SnapShot: WordBool;
      const Key: WideString; fromCache: WordBool);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
var
providers : ITileProviders;
providerId : Integer;
begin
   providers := CoTileProviders.Create;
   providers := Map1.Tiles.Providers;
   providerId := ProviderCustom + 1;
   providers.Add(providerId, 'MyProvider', 'http://192.168.0.219/maps/{zoom}/{x}/{y}.png',SphericalMercator, 1, 15,'openstreet');

    Map1.Projection := PROJECTION_GOOGLE_MERCATOR;
    Map1.TileProvider := ProviderCustom;
    Map1.Tiles.ProviderId := providerId;

    Map1.Latitude := 7.0761;
    Map1.Longitude := -73.2989;
    Map1.CurrentZoom := 8;


    Map1.Tiles.DiskCacheFilename := 'mwtiles.db3';
    //Map1.Tiles.DoCaching[RAM] := true;
    Map1.Tiles.DoCaching[Disk] := true;
    Map1.Tiles.UseCache[Disk] := true;
    Map1.Tiles.MinScaleToCache := 1;
    Map1.Tiles.MaxScaleToCache := 15;

    map1.SetFocus;
end;

procedure TForm3.FormShow(Sender: TObject);
var
t: ITiles;
gs: GlobalSettings;

error:boolean;
begin
  {gs := CoGlobalSettings.Create;
  error := gs.StartLogTileRequests('tile.log',False);
  //t := CoTiles.Create;
  Map1.Tiles.ProviderId := OpenStreetMap;
  map1.Projection :=  }

  //Map1.Tiles.Providers.Add(1030, 'LocalOSM', 'http://192.168.0.219/maps/{z}/{x}/{y}.png', SphericalMercator, 1, 15,'MyProvider');
  //Map1.TileProvider := ProviderCustom;
  //Map1.Tiles.ProviderId := 1030;




end;

procedure TForm3.Map1TilesLoaded(ASender: TObject; SnapShot: WordBool;
  const Key: WideString; fromCache: WordBool);
begin
ShowMessage('Tiles load');
end;

end.

unit uMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, MapWinGIS_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    Map1: TMap;
    OpenDialog1: TOpenDialog;
    btnOpen: TButton;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.btnOpenClick(Sender: TObject);
var
  shp:IShapefile;
  fName : string;
  HandleLayer: Integer;
begin
  Map1.LockWindow(lmLock);
  Map1.RemoveAllLayers;

  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0)) + 'Maps\';
  SetCurrentDir(ExtractFileDir(ParamStr(0)) + 'Maps\');
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


procedure TForm2.FormShow(Sender: TObject);
var
objProj:IGeoProjection;
begin
objProj := CoGeoProjection.Create;
objProj.ImportFromEPSG(4326);
Map1.GeoProjection := objProj;
map1.Tiles.UseCache[1] := True;
Map1.Tiles.MaxCacheSize[1] := 12000;

//Map1.Projection := PROJECTION_WGS84;

end;

end.

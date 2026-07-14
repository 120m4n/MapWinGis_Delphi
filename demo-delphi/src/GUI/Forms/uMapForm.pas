unit uMapForm;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  MapWinGIS_TLB;

type
  TMapForm = class(TFrame)
    Map1: TMap;
  private
    procedure MapShapeIdentified(ASender: TObject; LayerHandle: Integer; ShapeIndex: Integer; pointX: Double; pointY: Double);
  public
    constructor Create(AOwner: TComponent); override;
    property Map: TMap read Map1;
  end;

implementation

uses
  uCore.MapExt,
  uAttributesForm;

{$R *.dfm}

constructor TMapForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitDefaultMapSettings(Map1);
  Map1.OnShapeIdentified := MapShapeIdentified;
end;

procedure TMapForm.MapShapeIdentified(ASender: TObject; LayerHandle: Integer; ShapeIndex: Integer; pointX: Double; pointY: Double);
var
  Sf: IShapefile;
begin
  Sf := Map1.Shapefile[LayerHandle];
  if not Assigned(Sf) then
    Exit;

  ExecuteAttributesDialog(Sf, ShapeIndex, LayerHandle);
end;

end.
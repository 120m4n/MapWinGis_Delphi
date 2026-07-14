unit uLegendControl;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls;

type
  TLegendLayerEvent = procedure(Sender: TObject; LayerHandle: Integer) of object;

  TLegendControl = class(TFrame)
    lblTitle: TLabel;
    lstLayers: TListBox;
  private
    FLayerHandles: TList<Integer>;
    FOnLayerSelected: TLegendLayerEvent;
    FOnLayerDoubleClick: TLegendLayerEvent;
    procedure LayersClick(Sender: TObject);
    procedure LayersDblClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshLayers(const ALayers: TStrings; const AHandles: TList<Integer>);
    function SelectedLayerHandle: Integer;
    property OnLayerSelected: TLegendLayerEvent read FOnLayerSelected write FOnLayerSelected;
    property OnLayerDoubleClick: TLegendLayerEvent read FOnLayerDoubleClick write FOnLayerDoubleClick;
  end;

implementation

{$R *.dfm}

constructor TLegendControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLayerHandles := TList<Integer>.Create;
  lstLayers.OnClick := LayersClick;
  lstLayers.OnDblClick := LayersDblClick;
end;

destructor TLegendControl.Destroy;
begin
  FLayerHandles.Free;
  inherited Destroy;
end;

procedure TLegendControl.LayersClick(Sender: TObject);
var
  LayerHandle: Integer;
begin
  LayerHandle := SelectedLayerHandle;
  if (LayerHandle >= 0) and Assigned(FOnLayerSelected) then
    FOnLayerSelected(Self, LayerHandle);
end;

procedure TLegendControl.LayersDblClick(Sender: TObject);
var
  LayerHandle: Integer;
begin
  LayerHandle := SelectedLayerHandle;
  if (LayerHandle >= 0) and Assigned(FOnLayerDoubleClick) then
    FOnLayerDoubleClick(Self, LayerHandle);
end;

procedure TLegendControl.RefreshLayers(const ALayers: TStrings; const AHandles: TList<Integer>);
var
  I: Integer;
begin
  lstLayers.Items.Assign(ALayers);
  FLayerHandles.Clear;
  if Assigned(AHandles) then
    for I := 0 to AHandles.Count - 1 do
      FLayerHandles.Add(AHandles[I]);
end;

function TLegendControl.SelectedLayerHandle: Integer;
begin
  Result := -1;
  if (lstLayers.ItemIndex >= 0) and (lstLayers.ItemIndex < FLayerHandles.Count) then
    Result := FLayerHandles[lstLayers.ItemIndex];
end;

end.
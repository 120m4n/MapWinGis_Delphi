unit uAttributesForm;

interface

uses
  System.Variants,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  MapWinGIS_TLB;

type
  TAttributesForm = class(TForm)
    tableLayoutPanel1: TGridPanel;
    flowLayoutPanel1: TFlowPanel;
    btnCancel: TButton;
    btnOk: TButton;
    panel1: TPanel;
    procedure btnOkClick(Sender: TObject);
  private
    FSf: IShapefile;
    FShapeIndex: Integer;
    FLayerHandle: Integer;
    procedure Populate;
    function Save: Boolean;
    function DefaultValue(const AType: FieldType): string;
  public
    property Shapefile: IShapefile read FSf write FSf;
    property ShapeIndex: Integer read FShapeIndex write FShapeIndex;
    property LayerHandle: Integer read FLayerHandle write FLayerHandle;
  end;

function ExecuteAttributesDialog(const ASf: IShapefile; const AShapeIndex, ALayerHandle: Integer): Boolean;

implementation

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Controls,
  Vcl.Dialogs;

{$R *.dfm}

function ExecuteAttributesDialog(const ASf: IShapefile; const AShapeIndex, ALayerHandle: Integer): Boolean;
var
  Form: TAttributesForm;
begin
  Result := False;
  if not Assigned(ASf) then
    Exit;

  Form := TAttributesForm.Create(nil);
  try
    Form.Shapefile := ASf;
    Form.ShapeIndex := AShapeIndex;
    Form.LayerHandle := ALayerHandle;
    Form.Populate;
    Result := Form.ShowModal = mrOk;
  finally
    Form.Free;
  end;
end;

procedure TAttributesForm.Populate;
var
  I: Integer;
  Lbl: TLabel;
  Edit: TEdit;
  Value: OleVariant;
begin
  while tableLayoutPanel1.ControlCount > 0 do
    tableLayoutPanel1.Controls[0].Free;

  tableLayoutPanel1.RowCollection.Clear;
  tableLayoutPanel1.ColumnCollection.Clear;
  tableLayoutPanel1.ColumnCollection.Add;
  tableLayoutPanel1.ColumnCollection.Add;
  tableLayoutPanel1.ColumnCollection[0].Value := 35;
  tableLayoutPanel1.ColumnCollection[1].Value := 65;

  for I := 0 to FSf.NumFields - 1 do
  begin
    tableLayoutPanel1.RowCollection.Add;

    Lbl := TLabel.Create(tableLayoutPanel1);
    Lbl.Parent := tableLayoutPanel1;
    Lbl.Caption := FSf.Field[I].Name;
    Lbl.AlignWithMargins := True;
    tableLayoutPanel1.ControlCollection.AddControl(Lbl, 0, I);

    Edit := TEdit.Create(tableLayoutPanel1);
    Edit.Parent := tableLayoutPanel1;
    Edit.AlignWithMargins := True;
    Edit.Tag := I;
    Value := FSf.CellValue[I, FShapeIndex];
    if VarIsNull(Value) or VarIsEmpty(Value) then
      Edit.Text := DefaultValue(FSf.Field[I].Type_)
    else
      Edit.Text := VarToStr(Value);
    Edit.ReadOnly := not FSf.InteractiveEditing;
    tableLayoutPanel1.ControlCollection.AddControl(Edit, 1, I);
  end;
end;

function TAttributesForm.DefaultValue(const AType: FieldType): string;
begin
  case AType of
    INTEGER_FIELD:
      Result := '0';
    DOUBLE_FIELD:
      Result := '0';
  else
    Result := '';
  end;
end;

function TAttributesForm.Save: Boolean;
var
  I: Integer;
  FieldIndex: Integer;
  Edit: TEdit;
  IntValue: Integer;
  FloatValue: Double;
begin
  Result := True;
  for I := 0 to tableLayoutPanel1.ControlCount - 1 do
  begin
    if not (tableLayoutPanel1.Controls[I] is TEdit) then
      Continue;

    Edit := TEdit(tableLayoutPanel1.Controls[I]);
    if Edit.ReadOnly then
      Continue;

    FieldIndex := Edit.Tag;
    case FSf.Field[FieldIndex].Type_ of
      STRING_FIELD:
        FSf.EditCellValue(FieldIndex, FShapeIndex, Edit.Text);
      INTEGER_FIELD:
        begin
          if not TryStrToInt(Edit.Text, IntValue) then
          begin
            MessageDlg('Failed to parse integer value: ' + Edit.Text, mtInformation, [mbOK], 0);
            Edit.SetFocus;
            Exit(False);
          end;
          FSf.EditCellValue(FieldIndex, FShapeIndex, IntValue);
        end;
      DOUBLE_FIELD:
        begin
          if not TryStrToFloat(Edit.Text, FloatValue) then
          begin
            MessageDlg('Failed to parse double value: ' + Edit.Text, mtInformation, [mbOK], 0);
            Edit.SetFocus;
            Exit(False);
          end;
          FSf.EditCellValue(FieldIndex, FShapeIndex, FloatValue);
        end;
    end;
  end;
end;

procedure TAttributesForm.btnOkClick(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

end.
unit uAttributesForm;

interface

uses
  System.Variants,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
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
    function OgrFidName: string;
    function IsProtectedField(const AFieldName: string): Boolean;
    function GetShortFieldType(const AType: FieldType): string;
    function BuildEditor(const AFieldIndex: Integer; const AFieldType: FieldType; const AValue: OleVariant): TControl;
  public
    property Shapefile: IShapefile read FSf write FSf;
    property ShapeIndex: Integer read FShapeIndex write FShapeIndex;
    property LayerHandle: Integer read FLayerHandle write FLayerHandle;
  end;

function ExecuteAttributesDialog(const ASf: IShapefile; const AShapeIndex, ALayerHandle: Integer): Boolean;

implementation

uses
  uApp,
  System.SysUtils,
  System.UITypes,
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
  NameLabel: TLabel;
  TypeLabel: TLabel;
  Editor: TControl;
  Value: OleVariant;
  FieldName: string;
begin
  while tableLayoutPanel1.ControlCount > 0 do
    tableLayoutPanel1.Controls[0].Free;

  tableLayoutPanel1.RowCollection.Clear;
  tableLayoutPanel1.ColumnCollection.Clear;
  tableLayoutPanel1.ColumnCollection.Add;
  tableLayoutPanel1.ColumnCollection.Add;
  tableLayoutPanel1.ColumnCollection.Add;
  tableLayoutPanel1.ColumnCollection[0].Value := 40;
  tableLayoutPanel1.ColumnCollection[1].Value := 52;
  tableLayoutPanel1.ColumnCollection[2].Value := 8;

  for I := 0 to FSf.NumFields - 1 do
  begin
    tableLayoutPanel1.RowCollection.Add;
    FieldName := FSf.Field[I].Name;

    NameLabel := TLabel.Create(tableLayoutPanel1);
    NameLabel.Parent := tableLayoutPanel1;
    NameLabel.Caption := UpperCase(FieldName);
    NameLabel.AlignWithMargins := True;
    NameLabel.Layout := tlCenter;
    tableLayoutPanel1.ControlCollection.AddControl(NameLabel, 0, I);

    Value := FSf.CellValue[I, FShapeIndex];
    Editor := BuildEditor(I, FSf.Field[I].Type_, Value);
    Editor.Enabled := FSf.InteractiveEditing and not IsProtectedField(FieldName);
    tableLayoutPanel1.ControlCollection.AddControl(Editor, 1, I);

    TypeLabel := TLabel.Create(tableLayoutPanel1);
    TypeLabel.Parent := tableLayoutPanel1;
    TypeLabel.Caption := GetShortFieldType(FSf.Field[I].Type_);
    TypeLabel.AlignWithMargins := True;
    TypeLabel.Layout := tlCenter;
    tableLayoutPanel1.ControlCollection.AddControl(TypeLabel, 2, I);
  end;
end;

function TAttributesForm.GetShortFieldType(const AType: FieldType): string;
begin
  case AType of
    INTEGER_FIELD:
      Result := 'i';
    DOUBLE_FIELD:
      Result := 'd';
    BOOLEAN_FIELD:
      Result := 'b';
    DATE_FIELD:
      Result := 'dt';
  else
    Result := 's';
  end;
end;

function TAttributesForm.BuildEditor(const AFieldIndex: Integer; const AFieldType: FieldType; const AValue: OleVariant): TControl;
var
  Edit: TEdit;
  Check: TCheckBox;
  Picker: TDateTimePicker;
  Txt: string;
  ParsedDate: TDateTime;
begin
  case AFieldType of
    BOOLEAN_FIELD:
      begin
        Check := TCheckBox.Create(tableLayoutPanel1);
        Check.Parent := tableLayoutPanel1;
        Check.AlignWithMargins := True;
        Check.Tag := AFieldIndex;
        Check.Caption := '';
        if VarIsNull(AValue) or VarIsEmpty(AValue) then
          Check.Checked := False
        else
          Check.Checked := SameText(VarToStr(AValue), '1') or SameText(VarToStr(AValue), 'true') or SameText(VarToStr(AValue), 'yes');
        Result := Check;
      end;
    DATE_FIELD:
      begin
        Picker := TDateTimePicker.Create(tableLayoutPanel1);
        Picker.Parent := tableLayoutPanel1;
        Picker.AlignWithMargins := True;
        Picker.Tag := AFieldIndex;
        Picker.Kind := dtkDate;
        if VarIsNull(AValue) or VarIsEmpty(AValue) then
          Picker.Date := Date
        else
        begin
          Txt := VarToStr(AValue);
          if TryStrToDate(Txt, ParsedDate) then
            Picker.Date := ParsedDate
          else
            Picker.Date := Date;
        end;
        Result := Picker;
      end;
  else
    Edit := TEdit.Create(tableLayoutPanel1);
    Edit.Parent := tableLayoutPanel1;
    Edit.AlignWithMargins := True;
    Edit.Tag := AFieldIndex;
    if VarIsNull(AValue) or VarIsEmpty(AValue) then
      Edit.Text := DefaultValue(AFieldType)
    else
      Edit.Text := VarToStr(AValue);
    Result := Edit;
  end;
end;

function TAttributesForm.DefaultValue(const AType: FieldType): string;
begin
  case AType of
    INTEGER_FIELD:
      Result := '0';
    DOUBLE_FIELD:
      Result := '0.0';
    BOOLEAN_FIELD:
      Result := 'False';
    DATE_FIELD:
      Result := DateToStr(Date);
  else
    Result := '';
  end;
end;

function TAttributesForm.OgrFidName: string;
var
  AMap: TMap;
  Layer: IOgrLayer;
begin
  Result := '';
  AMap := TApp.Map;
  if (FLayerHandle < 0) or not Assigned(AMap) then
    Exit;

  Layer := AMap.OgrLayer[FLayerHandle];
  if Assigned(Layer) then
    Result := Layer.FIDColumnName;
end;

function TAttributesForm.IsProtectedField(const AFieldName: string): Boolean;
var
  Fid: string;
begin
  Fid := OgrFidName;
  Result := SameText(AFieldName, 'mwshapeid') or
    ((Fid <> '') and SameText(AFieldName, Fid));
end;

function TAttributesForm.Save: Boolean;
var
  I: Integer;
  FieldIndex: Integer;
  Ctrl: TControl;
  Edit: TEdit;
  Check: TCheckBox;
  Picker: TDateTimePicker;
  IntValue: Integer;
  FloatValue: Double;
begin
  Result := True;
  for I := 0 to tableLayoutPanel1.ControlCount - 1 do
  begin
    Ctrl := tableLayoutPanel1.Controls[I];
    if not (Ctrl is TEdit) and not (Ctrl is TCheckBox) and not (Ctrl is TDateTimePicker) then
      Continue;

    if not Ctrl.Enabled then
      Continue;

    FieldIndex := Ctrl.Tag;
    case FSf.Field[FieldIndex].Type_ of
      STRING_FIELD:
        begin
          if Ctrl is TEdit then
            FSf.EditCellValue(FieldIndex, FShapeIndex, TEdit(Ctrl).Text);
        end;
      INTEGER_FIELD:
        begin
          if not (Ctrl is TEdit) then
            Continue;
          Edit := TEdit(Ctrl);
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
          if not (Ctrl is TEdit) then
            Continue;
          Edit := TEdit(Ctrl);
          if not TryStrToFloat(Edit.Text, FloatValue) then
          begin
            MessageDlg('Failed to parse double value: ' + Edit.Text, mtInformation, [mbOK], 0);
            Edit.SetFocus;
            Exit(False);
          end;
          FSf.EditCellValue(FieldIndex, FShapeIndex, FloatValue);
        end;
      BOOLEAN_FIELD:
        begin
          if Ctrl is TCheckBox then
          begin
            Check := TCheckBox(Ctrl);
            FSf.EditCellValue(FieldIndex, FShapeIndex, Check.Checked);
          end;
        end;
      DATE_FIELD:
        begin
          if Ctrl is TDateTimePicker then
          begin
            Picker := TDateTimePicker(Ctrl);
            FSf.EditCellValue(FieldIndex, FShapeIndex, DateToStr(Picker.Date));
          end;
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
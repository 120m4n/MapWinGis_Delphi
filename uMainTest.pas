unit uMainTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, MapWinGIS_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm3 = class(TForm)
    Map2: TMap;
    Panel1: TPanel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  fm: IFileManager;
  obj: Variant;
  hndl:integer;
  dlg : TOpenDialog;
  selectedFile:string;
begin
    try
      fm := CoFileManager.Create;
      dlg := TOpenDialog.Create(nil);

      dlg.InitialDir := ExtractFilePath(ParamStr(0));
      dlg.Filter := fm.CdlgFilter;
      if dlg.Execute(Handle) then
        selectedFile := dlg.FileName;
    finally
      dlg.Free;
    end;
    obj := fm.Open(selectedFile,fosAutoDetect,Nil);
    if (fm.LastOpenIsSuccess) then
    begin
       hndl := Map2.AddLayer(obj,true);
       if hndl <> -1 then
       begin
       ShowMessage('Layer was added to the map. Open strategy:' + inttostr(ord(fm.LastOpenStrategy)));

       end;
    end
    else
    begin

    end;
    map2.SetFocus;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  gs: GlobalSettings;
begin

 gs := CoGlobalSettings.Create;
 gs.ShapefileFastMode := True;
 gs.RandomColorSchemeForGrids := True;
 //gs.AllowLayersWithoutProjections := True;
 gs.ReprojectLayersOnAdding := True;
end;

end.

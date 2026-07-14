unit uMainTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, MapWinGIS_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls, uAppLogger;

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
  selectedFile := '';
  hndl := -1;
  try
    fm := CoFileManager.Create;
    if not Assigned(fm) then
      Exit;

    dlg := TOpenDialog.Create(nil);
    try
      dlg.InitialDir := ExtractFilePath(ParamStr(0));
      dlg.Filter := fm.CdlgFilter;
      if dlg.Execute(Handle) then
        selectedFile := dlg.FileName;
    finally
      dlg.Free;
    end;

    if selectedFile = '' then
      Exit;

    obj := fm.Open(selectedFile,fosAutoDetect,Nil);
    if fm.LastOpenIsSuccess then
    begin
      hndl := Map2.AddLayer(obj,true);
      if hndl <> -1 then
      begin
        ShowMessage('Layer was added to the map. Open strategy:' + inttostr(ord(fm.LastOpenStrategy)));
        AppLogger.Info('uMainTest.Button1Click', 'Layer loaded: ' + selectedFile);
      end;
    end
    else
      AppLogger.Warning('uMainTest.Button1Click', 'Open failed for: ' + selectedFile);
    map2.SetFocus;
  except
    on E: Exception do
    begin
      AppLogger.Error('uMainTest.Button1Click', E.ClassName + ': ' + E.Message);
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  gs: GlobalSettings;
begin
  try
    gs := CoGlobalSettings.Create;
    gs.ShapefileFastMode := True;
    gs.RandomColorSchemeForGrids := True;
    gs.ReprojectLayersOnAdding := True;
    AppLogger.Info('uMainTest.FormCreate', 'Form initialized');
  except
    on E: Exception do
      AppLogger.Error('uMainTest.FormCreate', E.ClassName + ': ' + E.Message);
  end;
end;

end.

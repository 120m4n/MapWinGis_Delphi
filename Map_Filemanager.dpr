program Map_Filemanager;

uses
  Vcl.Forms,
  uMap2 in 'uMap2.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

program Test;

uses
  Vcl.Forms,
  uMainTest in 'uMainTest.pas' {Form3},
  MapWinGIS_TLB in 'C:\dev\MapWinGIS\MapWinGIS_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

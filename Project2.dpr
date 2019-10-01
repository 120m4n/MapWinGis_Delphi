program Project2;

uses
  Vcl.Forms,
  uMap2 in 'uMap2.pas' {Form3},
  MapWinGIS_TLB in 'C:\dev\MapWinGIS\MapWinGIS_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

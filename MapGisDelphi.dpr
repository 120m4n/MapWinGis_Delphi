program MapGisDelphi;

uses
  Vcl.Forms,
  uMap in 'uMap.pas' {Form2},
  MapWinGIS_TLB in 'C:\dev\MapWinGIS\MapWinGIS_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

program test_GLSL;

uses
  Vcl.Forms,
  test_GLSL_Unit1 in 'test_GLSL_Unit1.pas' {Form1},
  BGLSLshaderToy in 'BGLSLshaderToy.pas',
  BFileTools in 'BFileTools.pas',
  BStrTools in 'BStrTools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

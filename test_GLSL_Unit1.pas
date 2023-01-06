unit test_GLSL_Unit1;

interface

uses
  BFileTools,
  BGLSLshaderToy,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var {ShaderFrag:ansistring;
    ShaderVert:ansistring;
    SHToy:ansistring;
    SHToyC:ansistring;
    hhh:BShaderToyStruct; }
    ST:BTShaderToy;


procedure TForm1.Button1Click(Sender: TObject);


begin
(*
    hhh.finish := true;
    OpenDialog1.execute;
       FileLoadEx(OpenDialog1.Files[0],ShToy);
       FileLoadEx(BFileTools.ExtractFileName(OpenDialog1.Files[0])+'_common.txt',ShToyC);

    if length(shtoy)= 0  then
    begin

    ShToy := 'void mainImage(out vec4 fragColor, in vec2 fragCoord)'+#13#10+'{'+
             'vec2 uv = fragCoord.xy / iResolution.xy;'+#13#10+
             'vec3 col =  vec3(sin(uv.x*3),uv.x,cos(uv.y * uv.x));'+#13#10+
             ' fragColor = vec4(col,1.0);'+#13#10+'}'+#13#10;

    if ParamCount <> 0  then
    begin
       FileLoad(Paramstr(1),ShToy);
    end;
    end;

    BGLSLshaderToyTr(ShToy,ShToyC,'','',ShaderFrag);

    ShaderVert := '';

    hhh.Xres := 640;
    hhh.Yres := 480;
    hhh.Time := 0;
    hhh.CpuTime := GetTickCount;
    hhh.TimeAcm := 0;
    hhh.finish := false;

    BGLSLrun(Panel1.handle,640,480,2,ShaderFrag,ShaderVert,@BGLSLshaderToyCB,longword(@hhh));
    *)
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
//    hhh.finish := true;
end;

procedure TForm1.Button3Click(Sender: TObject);
var ShToy,ShToyC:ansistring;
begin
   st.Reset;
   OpenDialog1.execute;
     FileLoadEx(OpenDialog1.Files[0],ShToy);
     FileLoadEx(BFileTools.ExtractFileName(OpenDialog1.Files[0])+'_common.txt',ShToyC);
   st.LoadMainScript(string(ShToy));
   st.LoadCommonScript(string(ShToyC));
   st.Compile;
   Memo1.text := st.GetCompilerError;
   Memo2.text := st.GetScript(1);
   st.LoadTexture(0,'aaa');
   st.LoadTexture(1,'aaa');
   st.LoadTexture(2,'aaa');
   st.LoadTexture(3,'aaa');
   st.Run;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 st.Stop;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  st := BTShaderToy.Create(Panel1.handle,640,480,2);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  st.free;
end;

end.

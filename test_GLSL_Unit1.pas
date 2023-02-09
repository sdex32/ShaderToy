unit test_GLSL_Unit1;

interface

uses
  BStrTools,
  BFileTools,
  BGLSLshaderToy,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    compile: TButton;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Timer1: TTimer;
    TabControl1: TTabControl;
    RichEdit1: TRichEdit;
    Button2: TButton;
    Button5: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel6: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure compileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    pause_resume:longword;
    ShaderFileName:string;
    ImageText:string;
    full_screen:boolean;
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
   if pause_resume  = 0  then
   begin
      st.Pause;
      Button1.Caption := 'play';
   end else begin
     st.Resume;
      Button1.Caption := 'pause';
   end;

   pause_resume := pause_resume xor 1;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   st.Stop;
   st.Reset;
   ShaderFilename := '';
   ImageText := '';
   //clear editor
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   st.Reset;
   ShaderFilename := '';
   if OpenDialog1.execute then
   begin
     ShaderFilename := OpenDialog1.Files[0];
     compileClick(nil);
   end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   full_screen:=true; // rerun
   compileClick(nil);
end;

procedure TForm1.compileClick(Sender: TObject);
var ShToy,ShToyC:ansistring;
    ShImage:string;
begin  //compile
   st.Reset;
   ShToy := '';
   if length(ShaderFileName)> 0 then
   begin
     FileLoadEx(ShaderFileName,ShToy);
     ShImage := string(ShToy);
     FileLoadEx(BFileTools.ExtractFileName(OpenDialog1.Files[0])+'_common.txt',ShToyC);
   end else begin
     ShImage := ImageText; //
   end;





   st.LoadScript(ShImage);
  // st.LoadCommonScript(string(ShToyC));


   st.LoadTexture(0,'tex00.jpg');
   st.LoadTexture(1,'tex01.jpg');
   st.LoadTexture(2,'tex02.jpg');
   st.LoadTexture(3,'tex07.jpg');
   st.Run(full_screen);
   full_screen:=false;
   Memo1.text := st.GetCompilerError;
   RichEdit1.text := st.GetScript(1);
   Label1.Caption := 'compile time '+ToStr(trunc(st.GetProp(1)))+'ms';
   st.TexturePreview(panel2.handle,0,0,90,90,0);
   st.TexturePreview(panel3.handle,0,0,90,90,1);
   st.TexturePreview(panel4.handle,0,0,90,90,2);
   st.TexturePreview(panel6.handle,0,0,90,90,3);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  st := BTShaderToy.Create(Panel1.handle,2);
  pause_resume := 0;
  Button1.Caption := 'pause';
  ShaderFileName:='';
  ImageText := '';
  RichEdit1.text := '';
  full_screen:=false;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  st.free;
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var c:longint;
begin
   c := 0;
   if assigned(st) then st.SetMouseEvent(X,Y,c)

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   Label2.Caption := 'Frame:'+ToStr(trunc(st.GetProp(2)))+' FPS:'+ToStr(trunc(st.GetProp(3)));
end;

end.

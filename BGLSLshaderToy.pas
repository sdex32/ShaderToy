unit BGLSLshaderToy;

interface


// Work well
//TODO  - add common file
//      - To work with BufferA and BufferB and so on
//      - 100% compatoble with shadertoy.com
//      - mouse input keyboard input etc



type  BTShaderToy = class
         private
            aWin_hand:longword;
            aWin_proc:nativeUint;
            aDC:longword;
            aXlng,aYlng:single;
            aXlng2,aYlng2:single;
            aXlng2n,aYlng2n:single;
            aProgObj:longword;
            glCompileShaderARB : procedure(shaderObj :longword); stdcall;
            glUseProgram: procedure(programObj :longword); stdcall;
            glShaderSourceARB :procedure(shaderObj :longword; count :integer; _string: PAnsiChar; lengths: pointer);  stdcall;
            glLinkProgramARB :procedure(programObj :longword); stdcall;
            glDeleteObjectARB :procedure(Obj :longword); stdcall;
            glAttachObjectARB :procedure(programObj, shaderObj :longword); stdcall;
            glCreateShaderObjectARB :function(typ:longword):longword; stdcall;
            glCreateProgramObjectARB :function:longword; stdcall;
            glGetShaderiv:function(shader,pname:longword; var par:longint):longint; stdcall;
            glGetShaderInfoLog:procedure(shader:longword; maxLength: longint; var length: longint; infoLog: Pointer); stdcall;
            glUniform1fARB:procedure(location:longword; val:single); stdcall;
            glUniform2fARB:procedure(location:longword; val,val2:single); stdcall;
            glUniform3fARB:procedure(location:longword; val,val2,val3:single); stdcall;
            glUniform4fARB:procedure(location:longword; val,val2,val3,val4:single); stdcall;
            glGetUniformLocationARB:function(prog_o:longword; id:pansichar):longword; stdcall;
            glUniform1iARB:procedure(location:longword; val:longint); stdcall;
            aFrag_script :ansistring;
            aVert_script :ansistring;
            aMainScript:string;
            aCommonScript:string;
            aCompileError:string;
            aHaveST:boolean;
            aCpuTime:longword;
            aTime,aTimeDelta,aFrame:single;
//            aFinish:boolean;
            aInRun:boolean;
            aOGLgood:boolean;
            aFirstFrameGo:boolean;
            aTimer:longword;
            aChan_Width:array [0..3] of longword;
            aChan_Height:array [0..3] of longword;
            procedure   _BuildFrag;
//            procedure   _StopProg;
            procedure   _ResetSHvar;
         public
            constructor Create(win_hand,Xlng,Ylng,Flags:longword);
            destructor  Destroy; override;
            procedure   SetGLFragScript(const txt:string);
            procedure   SetGLVertScript(const txt:string);
            procedure   SetMouseEvent(X,Y:longint);
            procedure   LoadMainScript(const txt:string);
            procedure   LoadCommonScript(const txt:string);
            function    LoadTexture(channel:longword; const TextFileName:string):longint;
            procedure   Reset;
            function    Compile:boolean;
            function    GetCompilerError:string;
            function    GetScript(id:longword):string;
            procedure   DrawOneFrame;
            procedure   Run;
            procedure   Stop;
         end;

         //todo add texture add variable  set mouse




implementation

uses
   Windows,Messages;

const
   GL_QUADS = $0007;
   GL_FRAGMENT_SHADER_ARB = $8B30;
   GL_VERTEX_SHADER_ARB = $8B31;
   GL_COMPILE_STATUS = $8B81;

   GL_INFO_LOG_LENGTH = $8B84;
{
   GL_COLOR_BUFFER_BIT                 = $00004000; //?
   GL_DEPTH_BUFFER_BIT                 = $00000100;

   GL_DEPTH_TEST                       = $0B71; //?
   GL_NEVER                            = $0200;
   GL_LESS                             = $0201;
   GL_EQUAL                            = $0202;
   GL_LEQUAL                           = $0203;
   GL_GREATER                          = $0204;
   GL_NOTEQUAL                         = $0205;
   GL_GEQUAL                           = $0206;
   GL_ALWAYS                           = $0207;
}
   GL_TEXTURE_2D = $0DE1;
   GL_RGBA8 = $8058; //pixel internal format
   GL_RGBA = $1908; //pixel format
   GL_UNSIGNED_BYTE = $1401; //data type

   GL_TEXTURE_MAG_FILTER = $2800;
   GL_TEXTURE_MIN_FILTER = $2801;
   GL_LINEAR = $2601;


//  GL_RGB = $1907;
//  GL_BGRA = $80E1;

//mini OpenGL
procedure glLoadIdentity; stdcall; external 'OpenGL32.dll';
procedure glBegin(mode:longword); stdcall; external 'OpenGL32.dll';
procedure glEnd; stdcall; external 'OpenGL32.dll';
procedure glTexCoord2f(s,t:single); stdcall; external 'OpenGL32.dll';
procedure glVertex3f(x,y,z:single); stdcall; external 'OpenGL32.dll';
function  wglGetProcAddress(name:PAnsiChar):pointer; stdcall; external 'OpenGL32.dll';
//procedure glFlush; stdcall; external 'OpenGL32.dll';
//procedure glDepthFunc(f:longword); stdcall; external 'OpenGL32.dll';
//procedure glClearColor(a,r,g,b:single); stdcall; external 'OpenGL32.dll';
//procedure glClearDepth(v:single); stdcall; external 'OpenGL32.dll';
//procedure glClear(m:longword); stdcall; external 'OpenGL32.dll';


procedure glGenTextures(n:integer; texture:pointer); stdcall; external 'OpenGL32.dll';
procedure glBindTexture(target, textute:longword); stdcall; external 'OpenGL32.dll';
procedure glTexParameteri(target:longint; pname,pval:longword); stdcall; external 'OpenGL32.dll';
procedure glEnable(flag:Longword); stdcall; external 'OpenGL32.dll';
procedure glTexImage2D(target,level,internalformat,width, height, border:longint; format,_type:longword; Data: pointer); stdcall; external 'OpenGL32.dll';


//function  gluBuild2DMipmaps(target, components, width, height: longint; format, atype: longword; const Data: Pointer):longint; stdcall; external 'GLU32.dll';


function _PapaWindowProc(aWindow: HWnd; aMessage: UINT; WParam : WPARAM;
                         LParam: LPARAM): LRESULT; stdcall;
var se:BTShaderToy;
    obj:pointer;
    res:longint;
begin
   res := 0;
   se := BTShaderToy(GetProp(aWindow ,'ipSToy'));
   if assigned(se) then
   begin
      if aMessage = WM_TIMER then
      begin
         if wParam = 357 then se.DrawOneFrame;
      end;
   end;
   if res = 0 then
   begin
      obj := pointer(GetProp(aWindow,'ipSToyWinP'));
      if obj <> nil then res :=  CallWindowProc(pointer(Obj), aWindow, AMessage, WParam, LParam)
                    else res := DefWindowProc(aWindow, AMessage, WParam, LParam);
   end;
   Result := res;
end;




//------------------------------------------------------------------------------
constructor BTShaderToy.Create(win_hand,Xlng,Ylng,Flags:longword);
var pfd :TPixelFormatDescriptor;
    i :longint;

begin
   aWin_hand := Win_hand;


//   if win_hand = 0 then
//   begin
//      aDC := GetDC ( CreateWindowEx (0,'EDIT', NIL, WS_POPUP or WS_VISIBLE OR WS_MAXIMIZE, 0,0, Xlng, Ylng, 0,0,0, NIL ) );
//      ShowCursor ( FALSE );
//   end else

   aWin_Proc := GetWindowLong(aWin_hand,GWL_WNDPROC);
   SetProp(aWin_hand,'ipStoyWinP',aWin_Proc);
   SetProp(aWin_hand,'ipStoy',nativeUint(self));
   SetWindowLong(aWin_hand,GWL_WNDPROC,NativeUInt(@_PapaWindowProc));


   aDC := GetDc(win_hand);
   aXlng := Xlng;
   aYlng := Ylng;
   aProgObj := 0;
   aInRun := false;


   Reset;

   aOGLgood := false;
   pfd.dwFlags := PFD_DRAW_TO_WINDOW OR PFD_SUPPORT_OPENGL OR PFD_DOUBLEBUFFER;
   pfd.cColorBits := 32;
   SetPixelFormat ( aDC, ChoosePixelFormat ( aDC, @pfd ), @pfd );
   i := wglCreateContext ( aDC );
   if i = 0 then Exit;
   aOGLgood := true;

   wglMakeCurrent(aDC, i);

   // Must be after wglCreateContext
   glCompileShaderARB := wglGetProcAddress('glCompileShaderARB');
   glUseProgram := wglGetProcAddress('glUseProgram');
   glShaderSourceARB := wglGetProcAddress('glShaderSourceARB');
   glLinkProgramARB := wglGetProcAddress('glLinkProgramARB');
   glDeleteObjectARB := wglGetProcAddress('glDeleteObjectARB');
   glAttachObjectARB := wglGetProcAddress('glAttachObjectARB');
   glCreateShaderObjectARB := wglGetProcAddress('glCreateShaderObjectARB');
   glCreateProgramObjectARB := wglGetProcAddress('glCreateProgramObjectARB');
   glGetShaderiv := wglGetProcAddress('glGetShaderiv');
   glGetShaderInfoLog := wglGetProcAddress('glGetShaderInfoLog');
   glUniform1fARB := wglGetProcAddress('glUniform1fARB');
   glUniform2fARB := wglGetProcAddress('glUniform2fARB');
   glUniform3fARB := wglGetProcAddress('glUniform3fARB');
   glUniform4fARB := wglGetProcAddress('glUniform4fARB');
   glGetUniformLocationARB := wglGetProcAddress('glGetUniformLocationARB');
   glUniform1iARB := wglGetProcAddress('glUniform1iARB');

//TODO test for null

end;

//------------------------------------------------------------------------------
destructor  BTShaderToy.Destroy;
begin
   Stop;
   if aProgObj <> 0 then
   begin
      glUseProgram(0);
      glDeleteObjectARB(aProgObj);
   end;
   if aWin_hand <> 0 then
   begin
      SetWindowLong(aWin_hand,GWL_WNDPROC,aWin_proc); //restore
      ReleaseDc(aWin_hand,aDC);
   end;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.SetGLFragScript(const txt:string);
begin
   // todo remove non ansi chars
   aFrag_script := ansistring(txt);
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.SetGLVertScript(const txt:string);
begin
   // todo remove non ansi chars
   aVert_script := ansistring(txt);
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.LoadMainScript(const txt:string);
begin
   aMainScript := txt;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.LoadCommonScript(const txt:string);
begin
   aCommonScript := txt;
end;

//------------------------------------------------------------------------------
(*
procedure   BTShaderToy._StopProg;
begin
   if aInRun then
   begin
      aFinish := true;
      sleep(100);
      Stop;
   end;
   if aProgObj <> 0 then
   begin
      if aOGLgood then
      begin
         glUseProgram(0);
         glDeleteObjectARB(aProgObj);
      end;
   end;
   aProgObj := 0;
end;
*)
//------------------------------------------------------------------------------
procedure   BTShaderToy._ResetSHvar;
begin
   aTime := 0;
   aFrame := 0;
   aTimeDelta := 0;
   aCpuTime := 0;
//   aFinish := False;
   aFirstFrameGo := false;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.Reset;
begin
   aFrag_script := '';
   aVert_script := '';
   aMainScript := '';
   aCommonScript := '';
   aCompileError := '';
   Stop;
 //  _StopProg;
   _ResetSHvar;
end;

//------------------------------------------------------------------------------
function    BTShaderToy.GetScript(id:longword):string;
begin
   Result := '';
   case id of
      1: Result := aFrag_script;
      2: Result := aVert_script;
      3: Result := aMainScript;
      4: Result := aCommonScript;
   end;
end;


//------------------------------------------------------------------------------
function    BTShaderToy.GetCompilerError:string;
var i,j,k:longword;
    c :char;
begin
   Result := '';
   j := length(aCompileError);
   if j > 0 then
   begin
      for i := 1 to j do
      begin
         c := aCompileError[i];
         if c <> #0 then
         begin
            if c = #10 then Result := Result + #13#10
                       else Result := Result + c;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTShaderToy.Compile:boolean;
var m:longword;

   function CreateAndCompileShader(prog, sh_typ:longword; const Sh_txt:ansistring):longint;
   var ii,i:longint;
       errlog:ansistring;
       pp:pointer;
       Shader:longword;
   begin
      aCompileError := '';
      Result := 0;
      Shader := glCreateShaderObjectARB( sh_typ);
      i := length(Sh_txt);
      glShaderSourceARB(Shader,1,@Sh_txt,@i);
      glCompileShaderARB(Shader);
      glGetShaderiv(Shader,GL_COMPILE_STATUS,ii);
      if ii = 0 {GL_FALSE} then
      begin
         Result := -1;
         glGetShaderiv(Shader,GL_INFO_LOG_LENGTH,ii);
         setlength(errlog,ii);
         pp := @errlog[1];
         glGetShaderInfoLog(Shader,ii,ii,pp);
         aCompileError := string(errlog);
      end;
      //todo get error info
      glAttachObjectARB(Prog,Shader);
      glDeleteObjectARB(Shader);
   end;

begin
   Result := false; // fail
   if not aOGLgood then Exit;
   Stop;
//   _StopProg;
   if aProgObj <> 0 then
   begin
      glUseProgram(0);
      glDeleteObjectARB(aProgObj);
   end;

   _ResetSHvar;
   aCompileError := '';
   aProgObj := 0;
   _BuildFrag;

   aProgObj:= glCreateProgramObjectARB;
   m := CreateAndCompileShader(aProgObj, GL_FRAGMENT_SHADER_ARB, aFrag_script);
   if (m = 0) and (length(aVert_script) > 0) then m := CreateAndCompileShader(aProgObj, GL_VERTEX_SHADER_ARB, aVert_script);
   if m = 0  then
   begin
      glLinkProgramARB(aProgObj);
      glUseProgram(aProgObj);
      Result := true;
   end else begin
      //error
      glUseProgram(0);
      glDeleteObjectARB(aProgObj);
      aProgObj := 0;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.DrawOneFrame;
var w,loc:longword;

   procedure ShaderToyVarsUpdate;
   begin
      if aHaveST then // we have shader toy script do vars
      begin
        w := GetTickCount - aCpuTime;
      if w = 0 then w := 1;
      aCpuTime := GetTickCount;
      aTimeDelta := W / 1000;
      aTime := aTime + aTimeDelta;
      aFrame := aFrame + 1;
      loc := glGetUniformLocationARB(aProgObj,'iResolution');
      glUniform2fARB(loc,aXlng,aYlng);
      loc := glGetUniformLocationARB(aProgObj,'iTime');
      glUniform1fARB(loc,aTime);
      loc := glGetUniformLocationARB(aProgObj,'iFrame');
      glUniform1fARB(loc,aFrame);
      end;
   end;

begin

   if not aOGLgood then Exit;
   if not aFirstFrameGo then
   begin  //first frame set up
      aFirstFrameGo := true;
      aCpuTime := GetTickCount;
      aXlng2 := aXlng / 2;
      aYlng2 := aYlng / 2;
      aXlng2n := aXlng2 * -1;
      aYlng2n := aYlng2 * -1;
      ShaderToyVarsUpdate;
      //set up some textures
      loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[0]');
      glUniform2fARB(loc,aChan_Width[0],aChan_Height[0]);
      loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[1]');
      glUniform2fARB(loc,aChan_Width[1],aChan_Height[1]);
      loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[2]');
      glUniform2fARB(loc,aChan_Width[2],aChan_Height[2]);
      loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[3]');
      glUniform2fARB(loc,aChan_Width[3],aChan_Height[3]);
      loc := glGetUniformLocationARB(aProgObj,'iChanel0');
      glUniform1iARB(loc,0);
      loc := glGetUniformLocationARB(aProgObj,'iChanel1');
      glUniform1iARB(loc,1);
      loc := glGetUniformLocationARB(aProgObj,'iChanel2');
      glUniform1iARB(loc,2);
      loc := glGetUniformLocationARB(aProgObj,'iChanel3');
      glUniform1iARB(loc,3);
   end;

//   glClearColor(0.0, 0.0, 0.0, 1.0);
//   glClearDepth(1.0);
//   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
//
//   glEnable(GL_DEPTH_TEST);
//   glDepthFunc(GL_GREATER);


   glLoadIdentity;
   glBegin ( GL_QUADS );
{
      glTexCoord2f ( 0.0, 0.0 ); glVertex3f ( -320, -240, 0 );
      glTexCoord2f ( 1.0, 0.0 ); glVertex3f (  320, -240, 0 );
      glTexCoord2f ( 1.0, 1.0 ); glVertex3f (  320,  240, 0 );
      glTexCoord2f ( 0.0, 1.0 ); glVertex3f ( -320,  240, 0 );
}

      glTexCoord2f ( 0.0, 0.0 ); glVertex3f ( aXlng2n, aYlng2n, 0 );
      glTexCoord2f ( 1.0, 0.0 ); glVertex3f ( aXlng2 , aYlng2n, 0 );
      glTexCoord2f ( 1.0, 1.0 ); glVertex3f ( aXlng2 , aYlng2 , 0 );
      glTexCoord2f ( 0.0, 1.0 ); glVertex3f ( aXlng2n, aYlng2 , 0 );

   glEnd;
//        glFlush; //??? did i need it
   SwapBuffers ( aDC );

   ShaderToyVarsUpdate;
end;




//------------------------------------------------------------------------------
procedure   BTShaderToy.Run;
var msg:tagMSG;
begin
   if not aOGLgood then Exit;
   aInRun := true;
//   aFinish := false;
   aTimer := SetTimer(aWin_hand,357,10,0);
(*
   repeat

      //ne boti
//      if (Flags and 2) <> 0 then
//      begin

      while PeekMessage(msg,0,0,0,PM_REMOVE) do
      begin
//            if (Msg.message <> 275) and (Msg.message< 160) and (msg.message>176) then
//            begin
         if Msg.message = WM_CLOSE then aFinish := true;
//            end;
         TranslateMessage(msg);
         DispatchMessage(msg);
      end;
//      end;

       DrawOneFrame;

//       if (Flags and 1) = 0 then
       //  if GetAsyncKeyState ( 27 ) <> 0 then Finish := true;


   until aFinish = true;

   aInRun := false;
*)
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.Stop;
begin
   if not aOGLgood then Exit;
//   aFinish := true;
//   sleep(500);
   KillTimer(aWin_hand,357);
   aInRun := false;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy._BuildFrag;
var s:string;
begin // build frag code for shader toy

   if length(aFrag_Script) <> 0 then Exit; // I have forced frag script

//   s :=  '#version 300 es' +#13#10+ //330 core  120 130 140 150 330  400 410
   s :=
        'uniform vec2 iResolution;' +#13#10+  // setup uniform variables for ShaderToy script
        'uniform float iTime;' +#13#10+
        'uniform float iTimeDelta;' +#13#10+
        'uniform float iFrame;' +#13#10+
        'uniform float iChanelTime[4];' +#13#10+
        'uniform vec4  iMouse;' +#13#10+
        'uniform vec4  iDate;' +#13#10+
   //     'uniform float iSampleRate;' +#13#10+  //Sound
        'uniform vec2  iChannelResolution[4];' +#13#10+
        'uniform sampler2D iChannel0;' +#13#10+
        'uniform sampler2D iChannel1;' +#13#10+
        'uniform sampler2D iChannel2;' +#13#10+
        'uniform sampler2D iChannel3;' +#13#10 +


        '#ifdef GL_ES' +#13#10+
        'precision highp float;' +#13#10+
        'precision highp int;' +#13#10+
        '#endif' +#13#10+
        'vec4 texture(sampler2D   s, vec2 c)          { return texture2D(s,c); }' +#13#10+
        'vec4 texture(sampler2D   s, vec2 c, float b) { return texture2D(s,c,b); }' +#13#10+
        'vec4 texture(samplerCube s, vec3 c )         { return textureCube(s,c); }' +#13#10+
        'vec4 texture(samplerCube s, vec3 c, float b) { return textureCube(s,c,b); }' +#13#10+
        'float round( float x ) { return floor(x+0.5); }' +#13#10+
        'vec2 round(vec2 x) { return floor(x + 0.5); }' +#13#10+
        'vec3 round(vec3 x) { return floor(x + 0.5); }' +#13#10+
        'vec4 round(vec4 x) { return floor(x + 0.5); }' +#13#10+
        'float trunc( float x, float n ) { return floor(x*n)/n; }' +#13#10+
        'mat3 transpose(mat3 m) { return mat3(m[0].x, m[1].x, m[2].x, m[0].y, m[1].y, m[2].y, m[0].z, m[1].z, m[2].z); }' +#13#10+
        'float determinant( in mat2 m ) { return m[0][0]*m[1][1] - m[0][1]*m[1][0]; }' +#13#10+
        'float determinant( mat4 m ) { float b00 = m[0][0] * m[1][1] - m[0][1] * m[1][0], b01 = m[0][0] * m[1][2] - ' +
           'm[0][2] * m[1][0], b02 = m[0][0] * m[1][3] - m[0][3] * m[1][0], b03 = m[0][1] * m[1][2] - m[0][2] * m[1][1], ' +
           'b04 = m[0][1] * m[1][3] - m[0][3] * m[1][1], b05 = m[0][2] * m[1][3] - m[0][3] * m[1][2], b06 = m[2][0] * ' +
           'm[3][1] - m[2][1] * m[3][0], b07 = m[2][0] * m[3][2] - m[2][2] * m[3][0], b08 = m[2][0] * m[3][3] - m[2][3] * ' +
           'm[3][0], b09 = m[2][1] * m[3][2] - m[2][2] * m[3][1], b10 = m[2][1] * m[3][3] - m[2][3] * m[3][1], b11 = m[2][2] * ' +
           'm[3][3] - m[2][3] * m[3][2];  return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;}' +#13#10+
        'mat2 inverse(mat2 m) { float det = determinant(m); return mat2(m[1][1], -m[0][1], -m[1][0], m[0][0]) / det; }' +#13#10+
        'mat4 inverse(mat4 m ) { float inv0 = m[1].y*m[2].z*m[3].w - m[1].y*m[2].w*m[3].z - m[2].y*m[1].z*m[3].w + m[2].y*m[1].' +
           'w*m[3].z + m[3].y*m[1].z*m[2].w - m[3].y*m[1].w*m[2].z; float inv4 = -m[1].x*m[2].z*m[3].w + m[1].x*m[2].w*m[3].z + ' +
           'm[2].x*m[1].z*m[3].w - m[2].x*m[1].w*m[3].z - m[3].x*m[1].z*m[2].w + m[3].x*m[1].w*m[2].z; float inv8 = m[1].x*m[2].y*m[3].w - ' +
           'm[1].x*m[2].w*m[3].y - m[2].x  * m[1].y * m[3].w + m[2].x  * m[1].w * m[3].y + m[3].x * m[1].y * m[2].w - ' +
           'm[3].x * m[1].w * m[2].y; float inv12 = -m[1].x  * m[2].y * m[3].z + m[1].x  * m[2].z * m[3].y +m[2].x  * ' +
           'm[1].y * m[3].z - m[2].x  * m[1].z * m[3].y - m[3].x * m[1].y * m[2].z + m[3].x * m[1].z * m[2].y; ' +
           'float inv1 = -m[0].y*m[2].z * m[3].w + m[0].y*m[2].w * m[3].z + m[2].y  * m[0].z * m[3].w - m[2].y  * m[0].w * m[3].z - ' +
           'm[3].y * m[0].z * m[2].w + m[3].y * m[0].w * m[2].z; float inv5 = m[0].x  * m[2].z * m[3].w - m[0].x  * m[2].w * m[3].z - ' +
           'm[2].x  * m[0].z * m[3].w + m[2].x  * m[0].w * m[3].z + m[3].x * m[0].z * m[2].w - m[3].x * m[0].w * m[2].z; ' +
           'float inv9 = -m[0].x  * m[2].y * m[3].w +  m[0].x  * m[2].w * m[3].y + m[2].x  * m[0].y * m[3].w - m[2].x  * m[0].w * ' +
           'm[3].y - m[3].x * m[0].y * m[2].w + m[3].x * m[0].w * m[2].y; float inv13 = m[0].x  * m[2].y * m[3].z - m[0].x  * ' +
           'm[2].z * m[3].y - m[2].x  * m[0].y * m[3].z + m[2].x  * m[0].z * m[3].y + m[3].x * m[0].y * m[2].z - ' +
           'm[3].x * m[0].z * m[2].y; float inv2 = m[0].y  * m[1].z * m[3].w - m[0].y  * m[1].w * m[3].z - m[1].y  * ' +
           'm[0].z * m[3].w + m[1].y  * m[0].w * m[3].z + m[3].y * m[0].z * m[1].w - m[3].y * m[0].w * m[1].z; ' +
           'float inv6 = -m[0].x  * m[1].z * m[3].w + m[0].x  * m[1].w * m[3].z + m[1].x  * m[0].z * m[3].w - m[1].x  * ' +
           'm[0].w * m[3].z - m[3].x * m[0].z * m[1].w + m[3].x * m[0].w * m[1].z; float inv10 = m[0].x  * m[1].y * ' +
           'm[3].w - m[0].x  * m[1].w * m[3].y - m[1].x  * m[0].y * m[3].w + m[1].x  * m[0].w * m[3].y + m[3].x * m[0].y * ' +
           'm[1].w - m[3].x * m[0].w * m[1].y; float inv14 = -m[0].x  * m[1].y * m[3].z + m[0].x  * m[1].z * m[3].y + ' +
           'm[1].x  * m[0].y * m[3].z - m[1].x  * m[0].z * m[3].y - m[3].x * m[0].y * m[1].z + m[3].x * m[0].z * m[1].y; ' +
           'float inv3 = -m[0].y * m[1].z * m[2].w + m[0].y * m[1].w * m[2].z + m[1].y * m[0].z * m[2].w - m[1].y * m[0].w * ' +
           'm[2].z - m[2].y * m[0].z * m[1].w + m[2].y * m[0].w * m[1].z; float inv7 = m[0].x * m[1].z * m[2].w - m[0].x * ' +
           'm[1].w * m[2].z - m[1].x * m[0].z * m[2].w + m[1].x * m[0].w * m[2].z + m[2].x * m[0].z * m[1].w - m[2].x * m[0].w * ' +
           'm[1].z; float inv11 = -m[0].x * m[1].y * m[2].w + m[0].x * m[1].w * m[2].y + m[1].x * m[0].y * m[2].w - m[1].x * ' +
           'm[0].w * m[2].y - m[2].x * m[0].y * m[1].w + m[2].x * m[0].w * m[1].y; float inv15 = m[0].x * m[1].y * m[2].z - ' +
           'm[0].x * m[1].z * m[2].y - m[1].x * m[0].y * m[2].z + m[1].x * m[0].z * m[2].y + m[2].x * m[0].y * m[1].z - m[2].x * ' +
           'm[0].z * m[1].y; float det = m[0].x * inv0 + m[0].y * inv4 + m[0].z * inv8 + m[0].w * inv12; det = 1.0 / det; ' +
           'return det*mat4( inv0, inv1, inv2, inv3,inv4, inv5, inv6, inv7,inv8, inv9, inv10, inv11,inv12, inv13, inv14, inv15);}' +#13#10+
        'float sinh(float x)  { return (exp(x)-exp(-x))/2.; }' +#13#10+
        'float cosh(float x)  { return (exp(x)+exp(-x))/2.; }' +#13#10+
        'float tanh(float x)  { return sinh(x)/cosh(x); }' +#13#10+
        'float coth(float x)  { return cosh(x)/sinh(x); }' +#13#10+
        'float sech(float x)  { return 1./cosh(x); }' +#13#10+
        'float csch(float x)  { return 1./sinh(x); }' +#13#10+
        'float asinh(float x) { return    log(x+sqrt(x*x+1.)); }' +#13#10+
        'float acosh(float x) { return    log(x+sqrt(x*x-1.)); }' +#13#10+
        'float atanh(float x) { return .5*log((1.+x)/(1.-x)); }' +#13#10+
        'float acoth(float x) { return .5*log((x+1.)/(x-1.)); }' +#13#10+
        'float asech(float x) { return    log((1.+sqrt(1.-x*x))/x); }' +#13#10+
        'float acsch(float x) { return    log((1.+sqrt(1.+x*x))/x); }' +#13#10+
        '#define outColor gl_FragColor' +#13#10;




   //add ShaderToy part //void mainImage( out vec4 fragColor, in vec2 fragCord );
   if length(aCommonScript)> 0 then s := s + aCommonScript +#13#10;

   aHaveST := false;
   if length(aMainScript) > 0 then
   begin
      aHaveST := true; // we have Shader Toy type script
      s := s + aMainScript + #13#10;
   end;

   // add main code
//   if Pos(' main(',s) = 0 then
//   begin
      s:=s+'void main()' +#13#10+
           '{' +#13#10+
           ' mainImage(gl_FragColor, gl_FragCoord.xy);' +#13#10+
           '}' +#13#10;
//   end;

   if not aHaveST then s:= '';

   SetGLFragScript(s);
end;

type warr = array[0..0] of longword;
//------------------------------------------------------------------------------
function    BTShaderToy.LoadTexture(channel:longword; const TextFileName:string):longint;
var TexID,Width,Height,loc,x,y,i,xo,r,g,b:longword;
    Data:pointer;
    p:^warr;
begin
   Result := -1; // fail

   Width := 256;
   Height := 256;
   data := nil;
   ReallocMem(data,256*256*4);
   p := Data;
   i := 0;
   for y := 0 to height -1 do
   for x := 0 to width -1 do
   begin
     xo := x xor y;
     r := (xo * 2) and $FF;
     g := (xo * 4) and $FF;
     b := (xo * 8) and $FF;
     p[i] := r or (g shl 8) or (b shl 24) or $FF000000;
     inc(i);
   end;


 //  glEnable(GL_TEXTURE_2D);
   glGenTextures(1, @TexID);
   glBindTexture(GL_TEXTURE_2D, TexID);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // Linear Min Filter
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); // Linear Mag Filter


   glTexImage2D(GL_TEXTURE_2D,0, {4}GL_RGBA, Width, Height,0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
//   if gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA8, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, Data) = 0 then
//   begin // good texture
      aChan_Width[channel] := width;
      aChan_Height[channel] := Height;

   Result := 0;
//   end;
end;


//------------------------------------------------------------------------------
procedure   BTShaderToy.SetMouseEvent(X,Y:longint);
begin

end;

end.

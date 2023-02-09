unit BGLSLshaderToy;

interface

//version
//rewrited version  now i can start two shaders at once

type  BTShaderToy = class
         private
            aOGL_thread_H:nativeUInt;
            aOGL_thread_ID:Cardinal;
            aWin_hand:nativeUInt;
            aDC:nativeUInt;

            aFullScreen:boolean;
            aFPS:longword;
            aStopRunner:boolean;
            aPauseRunner:boolean;
            aCompileTime:longword;
            aCompileStatus:longint;
            aEngineStatus:longword;

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
            glActiveTexture:procedure(id:longword); stdcall;
            glBindSampler:procedure(sampid,sampl:longword); stdcall;
            glBindFramebuffer:procedure(target, buffer:longword); stdcall;
            aFrag_script :ansistring;
            aVert_script :ansistring;
            aMainScript:string;
            aCommonScript:string;
            aBufferAScript:string;
            aBufferBScript:string;
            aBufferCScript:string;
            aCompileError:string;

            aCpuTime:longword;
            aMouseX,aMouseY:single;
            aCMouseX,aCMouseY:single;
            aMouseClick :boolean;
            aTime,aTimeDelta:single;
            aFrame:integer;

            aFramebufferName:longword;

            aTexData :array [0..3] of pointer;
            aChan_Width:array [0..3] of longword;
            aChan_Height:array [0..3] of longword;
            procedure   _BuildFrag(frsid:longword);
            procedure   _InitOGL;
            procedure   _CloseOGL;
            procedure   _Compile;
            procedure   _Run;
            procedure   _InitUniform;
            procedure   _UpdateUniform;
            procedure   _LoadTexture(c:longword);
            procedure   _CreateRenderTarget(c:longword);
         public
            constructor Create(win_hand :NativeUInt; Flags:longword);
            destructor  Destroy; override;
            procedure   SetGLFragScript(const txt:string);
            procedure   SetGLVertScript(const txt:string);
            procedure   SetMouseEvent(X,Y,Clicked:longint);
            procedure   LoadScript(const txt:string);
            function    LoadTexture(channel:longword; const TextFileName:string):longint;
            procedure   TexturePreview(hwnd :NativeUint; Xpos,Ypos :longint; Xlng,Ylng,channel:longword);
            procedure   Reset;
            function    GetCompilerError:string;
            function    GetScript(id:longword):string;
            procedure   SetScript(id:longword; const txt:string);

            function    Run(FullScreen:boolean=false):boolean; //compile and run
            procedure   Stop;
            procedure   Pause;
            procedure   Resume;
            function    GetProp(id:longword):longword;
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

   GL_COLOR_BUFFER_BIT                 = $00004000;
{
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
   GL_CW = $0900;
   GL_CCW = $0901;

   GL_TEXTURE0 = $84C0; //+0..15
   GL_TEXTURE_2D = $0DE1;
   GL_RGBA8 = $8058; //pixel internal format
   GL_RGBA = $1908; //pixel format
   GL_RGB = $1907;

   GL_UNSIGNED_BYTE = $1401; //data type

   GL_TEXTURE_MAG_FILTER = $2800;
   GL_TEXTURE_MIN_FILTER = $2801;
   GL_LINEAR = $2601;
   GL_NEAREST = $2600;
   GL_TEXTURE_WRAP_S = $2802;
   GL_TEXTURE_WRAP_T = $2803;
   GL_CLAMP_TO_EDGE = $812F;

   GL_FRAMEBUFFER = $8D40;
   GL_COLOR_ATTACHMENT0 = $8CE0; //+0..15

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
procedure glClearColor(a,r,g,b:single); stdcall; external 'OpenGL32.dll';
//procedure glClearDepth(v:single); stdcall; external 'OpenGL32.dll';
procedure glClear(m:longword); stdcall; external 'OpenGL32.dll';
procedure glViewport(x,y,width,height:longint);  stdcall; external 'OpenGL32.dll';


procedure glGenTextures(n:integer; texture:pointer); stdcall; external 'OpenGL32.dll';
procedure glBindTexture(target, textute:longword); stdcall; external 'OpenGL32.dll';
procedure glTexParameteri(target:longint; pname,pval:longword); stdcall; external 'OpenGL32.dll';
procedure glTexParameterf(target:longint; pname:longword; pval:single); stdcall; external 'OpenGL32.dll';
procedure glEnable(flag:Longword); stdcall; external 'OpenGL32.dll';
procedure glTexImage2D(target,level,internalformat,width, height, border:longint; format,_type:longword; Data: pointer); stdcall; external 'OpenGL32.dll';

procedure glGenFramebuffers(n:integer; buffer:pointer); stdcall; external 'OpenGL32.dll';
procedure glBindFramebuffer(target, buffer:longword); stdcall; external 'OpenGL32.dll';
procedure glFramebufferTexture(target , attachment, texture, level: longword); stdcall; external 'OpenGL32.dll';
procedure glDrawBuffers(n:longword; bufs:pointer); stdcall; external 'OpenGL32.dll';


//procedure glFramebufferParameteri(

//function  gluBuild2DMipmaps(target, components, width, height: longint; format, atype: longword; const Data: Pointer):longint; stdcall; external 'GLU32.dll';

//------------------------------------------------------------------------------
function  OGLrunnerEngine(objp:NativeUInt):longint; stdcall;
var obj:BTShaderToy;
    getout:boolean;
begin

   Result := 0;
   obj := BTShaderToy(objp);
   try
      obj.aEngineStatus := 0;
      obj._InitOGL;
      obj._Compile;
      obj._Run;
      obj._CloseOGL;
   except
      Result := 0;
   end;
end;



//------------------------------------------------------------------------------
constructor BTShaderToy.Create(win_hand :NativeUInt; Flags:longword);
var windowsize:TRect;
begin
   aWin_hand := Win_hand;
   GetWindowRect(aWin_hand, windowsize);
   aXlng := windowsize.Right - windowsize.Left + 1;  // to adjust windows 125% screen
   aYlng := windowsize.Bottom - windowsize.Top + 1;
   aFullscreen := false;
   aTexData[0] := nil;
   aTexData[1] := nil;
   aTexData[2] := nil;
   aTexData[3] := nil;

   //Init vars
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTShaderToy.Destroy;
var i:longword;
begin
   Stop; // if it runs;
   for i := 0 to  3 do if aTexData[i] <> nil then ReallocMem(aTexData[i],0);
   inherited;
end;



//------------------------------------------------------------------------------
procedure   BTShaderToy._InitOGL;
var pfd :TPixelFormatDescriptor;
    i :longint;
begin
   aProgObj := 0;

   //Init OGL
   aDC := GetDc(aWin_hand);
   pfd.dwFlags := PFD_DRAW_TO_WINDOW OR PFD_SUPPORT_OPENGL OR PFD_DOUBLEBUFFER;
   pfd.iPixelType := PFD_TYPE_RGBA;
   pfd.cColorBits := 32;
   SetPixelFormat ( aDC, ChoosePixelFormat ( aDC, @pfd ), @pfd );
   i := wglCreateContext ( aDC );
   if i = 0 then Exit;


   wglMakeCurrent(aDC, i); // make context current

   // Must be after wglCreateContext ????
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

   glActiveTexture := wglGetProcAddress('glActiveTexture');
   glBindSampler := wglGetProcAddress('glBindSampler');

   glBindFramebuffer := wglGetProcAddress('glBindFramebuffer');
//todo test nil

   aEngineStatus := 1;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy._CloseOGL;
begin
   if aEngineStatus <> 0 then
   begin
      if aProgObj <> 0 then
      begin
         glUseProgram(0);
         glDeleteObjectARB(aProgObj);
      end;
      aEngineStatus := 16; //end;
   end;
end;



//------------------------------------------------------------------------------
procedure   BTShaderToy._BuildFrag(frsid:longword);
var HaveST:boolean;
begin // build frag code for shader toy

   if length(aFrag_Script) <> 0 then Exit; // I have forced frag script


        aFrag_Script :=
        '#version 300 es'+#13#10+
        'precision highp float;'+#13#10+
        'precision highp int;'+#13#10+
        'precision highp sampler2D;'+#13#10+

        'uniform vec3  iResolution;' +#13#10+  // setup uniform variables for ShaderToy script
        'uniform float iTime;' +#13#10+
        'uniform float iGlobalTime;' +#13#10+
        'uniform float iTimeDelta;' +#13#10+
        'uniform int   iFrame;' +#13#10+
        'uniform float iChanelTime[4];' +#13#10+
        'uniform vec4  iMouse;' +#13#10+
        'uniform vec4  iDate;' +#13#10+
   //     'uniform float iSampleRate;' +#13#10+  //Sound
        'uniform vec3  iChannelResolution[4];' +#13#10+
        'uniform sampler2D iChannel0;' +#13#10+
        'uniform sampler2D iChannel1;' +#13#10+
        'uniform sampler2D iChannel2;' +#13#10+
        'uniform sampler2D iChannel3;' +#13#10;



   //add ShaderToy part //void mainImage( out vec4 fragColor, in vec2 fragCord );
   if length(aCommonScript)> 0 then aFrag_Script := aFrag_Script + aCommonScript +#13#10;

   HaveST := false;
   if length(aMainScript) > 0 then
   begin
      HaveST := true; // we have Shader Toy type script
      aFrag_Script := aFrag_Script + aMainScript + #13#10;
   end;

   // add main code
   aFrag_Script := aFrag_Script+'out vec4 bst_FragColor1;'+#13#10+
           'void main()' +#13#10+
           '{' +#13#10+
           ' bst_FragColor1 = vec4(0,0,0,1);'+#13#10+
           ' mainImage(bst_FragColor1, gl_FragCoord.xy);' +#13#10+
           ' clamp(bst_FragColor1,vec4(0),vec4(1));'+#13#10+
           '}' +#13#10;


   if not HaveST then aFrag_Script:= '';
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy._Compile;
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


   if aEngineStatus = 1 then
   begin
      aCompileTime := GetTickCount;

      if aProgObj <> 0 then
      begin
         glUseProgram(0);
         glDeleteObjectARB(aProgObj);
      end;

      aCompileError := '';
      aProgObj := 0;
      _BuildFrag(0);
      if length(aFrag_script) > 0 then
      begin
         aProgObj:= glCreateProgramObjectARB;
         m := CreateAndCompileShader(aProgObj, GL_FRAGMENT_SHADER_ARB, aFrag_script);
         if (m = 0) and (length(aVert_script) > 0) then m := CreateAndCompileShader(aProgObj, GL_VERTEX_SHADER_ARB, aVert_script);
         if m = 0  then
         begin
            glLinkProgramARB(aProgObj);
//            glUseProgram(aProgObj);  //in run
            aCompileStatus := 0;
            aEngineStatus := 2;
         end else begin
            //error
            glUseProgram(0);
            glDeleteObjectARB(aProgObj);
            aProgObj := 0;
            aCompileStatus := -1;
            aEngineStatus := 10;
         end;
      end;
      aCompileTime := GetTickCount - aCompileTime;
   end;

end;


//------------------------------------------------------------------------------
procedure   BTShaderToy._InitUniform;
var loc:longword;
begin
   aTime := 0;
   aFrame := 0;
   aTimeDelta := 0;

   aXlng2 := aXlng / 2;
   aYlng2 := aYlng / 2;
   aXlng2n := aXlng2 * -1;
   aYlng2n := aYlng2 * -1;

   aCpuTime := GetTickCount;
   _UpdateUniform;

   //set up some textures
   loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[0]');
   glUniform3fARB(loc,aChan_Width[0],aChan_Height[0],0);
   loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[1]');
   glUniform3fARB(loc,aChan_Width[1],aChan_Height[1],0);
   loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[2]');
   glUniform3fARB(loc,aChan_Width[2],aChan_Height[2],0);
   loc := glGetUniformLocationARB(aProgObj,'iChannelResolution[3]');
   glUniform3fARB(loc,aChan_Width[3],aChan_Height[3],0);
   loc := glGetUniformLocationARB(aProgObj,'iChanel0');
   glUniform1iARB(loc,0); //set texture unit
   loc := glGetUniformLocationARB(aProgObj,'iChanel1');
   glUniform1iARB(loc,1);
   loc := glGetUniformLocationARB(aProgObj,'iChanel2');
   glUniform1iARB(loc,2);
   loc := glGetUniformLocationARB(aProgObj,'iChanel3');
   glUniform1iARB(loc,3);
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy._UpdateUniform;
var w,loc:longword;
begin
   w := GetTickCount - aCpuTime;
   if w = 0 then w := 1;
   aCpuTime := GetTickCount;
   aTimeDelta := W / 1000;
   aTime := aTime + aTimeDelta;
   inc(aFrame);
   loc := glGetUniformLocationARB(aProgObj,'iResolution');
   glUniform3fARB(loc,aXlng,aYlng,0);
   loc := glGetUniformLocationARB(aProgObj,'iTime');
   glUniform1fARB(loc,aTime);
   loc := glGetUniformLocationARB(aProgObj,'iGlobalTime');
   glUniform1fARB(loc,aTime);
   loc := glGetUniformLocationARB(aProgObj,'iTimeDelta');
   glUniform1fARB(loc,aTimeDelta);

   loc := glGetUniformLocationARB(aProgObj,'iFrame');
   glUniform1iARB(loc,aFrame);
   loc := glGetUniformLocationARB(aProgObj,'iMouse');
   //                                 down     click      - first down cord
   glUniform4fARB(loc,aMouseX,aMouseY,aCMouseX,aCMouseY);
   if aCMouseY > 0 then aCmouseY := aCMouseY * -1; // just send click
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy._Run;
var w:longword;
begin


   aStopRunner := false;
   aPauseRunner := false;
   if aEngineStatus = 2 then
   begin

      for w := 0 to 3 do _LoadTexture(w);
      aEngineStatus := 3;

      glActiveTexture(GL_TEXTURE0 + 15); //set active texture unit default

      _InitUniform;
      repeat
         while aPauseRunner do
         begin
            if aStopRunner then Exit;
            sleep(100);
            aCpuTime := GetTickCount;
         end;
         w := GetTickCount;

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        // Render on the whole framebuffer, complete from the lower left corner to the upper right
 		    glViewport(0,0,trunc(aXlng),trunc(aYlng));



        glClearColor(0.0, 0.0, 0.0, 1.0);
 //   glClearDepth(1.0);
        glClear(GL_COLOR_BUFFER_BIT); // or GL_DEPTH_BUFFER_BIT);

        if aProgObj <> 0 then glUseProgram(aProgObj);

//

//   glEnable(GL_DEPTH_TEST);
 //  glEnable(GL_CCW);
//   glDepthFunc(GL_GREATER);
        if GetAsyncKeyState(27) <> 0 then aStopRunner := true; //pres ESC exit for full screen


        glLoadIdentity;
        glBegin ( GL_QUADS );

         glTexCoord2f ( 0.0, 0.0 ); glVertex3f ( aXlng2n, aYlng2n, 0 );
         glTexCoord2f ( 1.0, 0.0 ); glVertex3f ( aXlng2 , aYlng2n, 0 );
         glTexCoord2f ( 1.0, 1.0 ); glVertex3f ( aXlng2 , aYlng2 , 0 );
         glTexCoord2f ( 0.0, 1.0 ); glVertex3f ( aXlng2n, aYlng2 , 0 );

         glEnd;



//        glFlush; //??? did i need it
         SwapBuffers ( aDC );
         _UpdateUniform;
         w := GetTickCount - w;
         if w = 0 then w := 1;

         aFPS := 1000 div w;
      until aStopRunner;
   end;
   aEngineStatus := 5;
end;


//------------------------------------------------------------------------------

type warr = array[0..0] of longword;

procedure   BTShaderToy._LoadTexture(c:longword);
var TexID:longword;
begin
   c := c and 3;
   if aTexData[c] <> nil then
   begin
//      glEnable(GL_TEXTURE_2D);
      glActiveTexture(GL_TEXTURE0 + c); //set active texture unit
      glGenTextures(1 , @TexID);
      glBindTexture(GL_TEXTURE_2D, TexID);
 //     glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
///      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); // Linear Min Filter
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); // Linear Mag Filter


//      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // Linear Min Filter
//      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST); // Linear Mag Filter

      glTexImage2D(GL_TEXTURE_2D,0, {4}GL_RGBA, aChan_Width[c], aChan_Height[c],0, GL_RGBA, GL_UNSIGNED_BYTE, aTexData[c]);
//   if gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA8, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, Data) = 0 then
//   begin // good texture

//   glBindSampler(cannel,
   end else begin
   end;

end;

//------------------------------------------------------------------------------
procedure   BTShaderToy._CreateRenderTarget(c:longword);
var TexID:longword;
    DrawBuffers:array[0..3] of longword;
begin
   c := c and 3;
   glGenFramebuffers(1, @aFramebufferName);
   glBindFramebuffer(GL_FRAMEBUFFER, aFramebufferName);
   // The texture we're going to render to
   glGenTextures(1 , @TexID);
   glBindTexture(GL_TEXTURE_2D, TexID);

   // Give an empty image to OpenGL ( the last "0" means "empty" )
 	 glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1024, 1024, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

   // Poor filtering
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

   // Set "renderedTexture =texID" as our colour attachement #0
 	 glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 +c, TexID, 0);

   DrawBuffers[0] := GL_COLOR_ATTACHMENT0 + c;
   glDrawBuffers(1, @DrawBuffers);
end;




//------------------------------------------------------------------------------
procedure   BTShaderToy.Reset;
begin
   Stop; // if run stop
   aMouseClick := false;
   aFrag_script := '';
   aVert_script := '';
   aMainScript := '';
   aCommonScript := '';
   aBufferAscript := '';
   aBufferBscript := '';
   aBufferCscript := '';
   aCompileError := '';
   aOGL_thread_H := 0;
   aEngineStatus := 0;
   aCompileStatus := 0;
   aCompileError := '';
end;


//------------------------------------------------------------------------------
function    BTShaderToy.GetCompilerError:string;
var i,j:longword;
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
function    BTShaderToy.Run(FullScreen:boolean=false):boolean;
var w:longword;
begin
   Result := false;
   Stop;
   aFullscreen := FullScreen;
   aOGL_thread_H := CreateThread(nil,0,@OGLrunnerEngine,pointer(self),0,aOGL_thread_ID);
   w := GetTickCount;
   repeat
      sleep(100);  // wait compile to finish
   until (aEngineStatus >= 2) or ((GetTickCount - w) > 10000);
   if aCompileStatus = 0 then Result := true;
//?!??!! status 3
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.Stop;
var w:longword;
begin
   if aEngineStatus = 3 then //in run
   begin
      aStopRunner := true;
      w := GetTickCount;
      repeat
         sleep(100);  // wait compile to finish
      until (aEngineStatus >= 3) or ((GetTickCount - w) > 10000);
   end;

   if aOGL_thread_H <> 0 then
   begin
      TerminateThread(aOGL_thread_H,0);
      CloseHandle(aOGL_thread_H);
   end;
   aOGL_thread_H := 0;
   aEngineStatus := 0;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.Pause;
begin
   if aEngineStatus = 3 then aPauseRunner := true;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.Resume;
begin
   if aEngineStatus = 3 then aPauseRunner := false;
end;





//------------------------------------------------------------------------------

// micro GDI + to load eny format picture jpg bmp png
type
   TGPGdiplusStartupInput = packed record
      GdiplusVersion          : Cardinal;  // Must be 1
      DebugEventCallback      : pointer; //TGPDebugEventProc;
      SuppressBackgroundThread: boolean; //BOOL;
      SuppressExternalCodecs  : boolean; //BOOL;
   end;
   PGdiplusStartupInput = ^TGPGdiplusStartupInput;


   TGPGdiplusStartupOutput = packed record
      NotificationHook  : pointer; //TGPNotificationHookProc;
      NotificationUnhook: pointer; //TGPNotificationUnhookProc;
   end;
   PGdiplusStartupOutput = ^TGPGdiplusStartupOutput;


function GdiplusStartup(out token: longword {ULONG}; input: PGdiplusStartupInput; output: PGdiplusStartupOutput) : longint; stdcall;  external 'gdiplus.dll' name 'GdiplusStartup';
procedure GdiplusShutdown(token: longword{ULONG}); stdcall;   external 'gdiplus.dll' name 'GdiplusShutdown';
function GdipLoadImageFromFileICM(filename: PWideCHAR; out image: nativeUint): longint; stdcall; external 'gdiplus.dll' name 'GdipLoadImageFromFileICM';
function GdipBitmapGetPixel(bitmap: nativeUint; x: Integer; y: Integer;  var color: longword): longint; stdcall;  external 'gdiplus.dll' name 'GdipBitmapGetPixel';
function GdipGetImageWidth(bitmap: nativeUint; var width: longint {UINT}): longint {GPSTATUS}; stdcall;  external 'gdiplus.dll' name 'GdipGetImageWidth';
function GdipGetImageHeight(bitmap: nativeUint; var height: longint): longint; stdcall; external 'gdiplus.dll' name 'GdipGetImageHeight';



function    BTShaderToy.LoadTexture(channel:longword; const TextFileName:string):longint;
var TexID,x,y,i,xo:longword;
    Width,Height:longint;
    p:^warr;
    bbm:nativeUint;
    fn:widestring;
    StartupInput :TGPGdiplusStartupInput;
    gdiplusToken :longword;
    StartupOutput :TGPGdiplusStartupOutput;
    BMINFO :array[0..12] of longword;
begin
   Result := 0; // fail
   channel := channel and 3;

   if aTexData[channel] <> nil then ReallocMem(aTexData[channel],0);
   aTexData[channel] := nil;

      // Initialize GDI+
   StartupInput.DebugEventCallback := nil;
   StartupInput.SuppressBackgroundThread := True;
   StartupInput.SuppressExternalCodecs   := False;
   StartupInput.GdiplusVersion := 1;
   if GdiplusStartup(gdiplusToken, @StartupInput, @StartupOutput) = 0 then
   begin
      fn := widestring(TextFileName) + #0;
      if  GdipLoadImageFromFileICM(@fn[1],bbm) = 0 then
      begin
         // get picture dimentions
         GdipGetImageWidth(bbm, Width);
         GdipGetImageHeight(bbm, Height);

         aTexData[channel] := nil;
         ReallocMem(aTexData[channel],Width*Height*4);
         if aTexData[channel] <> nil then
         begin
            p := aTexData[channel];

            i := 0;
            for y := 0 to Height - 1do
            begin
               for x := 0 to  Width -1 do
               begin
                  GdipBitmapGetPixel(bbm,x,y,xo); // not very nice slow

                  p[i] := ((xo shr 16) and $FF )
                       or ((xo and $00FF00))
                       or ((xo and $FF) shl 16);
                  //income = $XXRRGGBB
                  //openGL = $xxBBGGRR
                  inc(i);
               end;
            end;
            aChan_Width[channel] := width;
            aChan_Height[channel] := Height;
         end;
      end;
      GdiplusShutdown(gdiplusToken);
   end;
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
procedure   BTShaderToy.LoadScript(const txt:string);
var i,j,k,m:longword;
    c:char;
    b:boolean;
    s,code:string;
begin
   Reset;
   b := false;
   j := length(txt);
   m := 0;
   s := '';
   for i := 1 to j do
   begin // test first char must be  '['  from [ShaderToy]
      c := txt[i];
      if c <= #32 then continue;
      if m = 0 then
      begin
         if c = '[' then //first char in text
         begin
            m := 1;
         end else break; //get out
      end else begin
         if c = ']' then
         begin //the end
            if s = 'ShaderToy' then
            begin
               b := true; // we have
               break;
            end;
         end else s := s + c; //acum
      end;
   end;
   if b then
   begin // ve have all in one file [ShaderToy] [Common] [BufferA] [Image]
      s := '';
      code := '';
      k := 0;
      for i := 1 to j do
      begin
         c := txt[i];
         if c = '[' then k := i;
         if m <> 0 then
         begin
            case m of
               1: code := code + c;
               2: aCommonScript := aCommonScript + c;
               3: aBufferAscript := aBufferAscript + c;
               4: aBufferBscript := aBufferBscript + c;
               5: aBufferCscript := aBufferCscript + c;
               6: aMainScript := aMainScript + c;
            end;
         end;

         code := code + c;
         //line collector;
         if c = #13 then
         begin
            if s = '[ShaderToy]' then k := 1;
            if s = '[Common]' then k := 2;
            if s = '[BufferA]' then k := 3;
            if s = '[BufferB]' then k := 4;
            if s = '[BufferC]' then k := 5;
            if s = '[Image]' then k := 6;
            case m of
               1: code := code + c;
               2: aCommonScript := aCommonScript + c;
               3: aBufferAscript := aBufferAscript + c;
               4: aBufferBscript := aBufferBscript + c;
               5: aBufferCscript := aBufferCscript + c;
               6: aMainScript := aMainScript + c;
            end;

            m := k;
         end;
         if c > #32 then s := s + c;
      end;
   end else aMainScript := txt;
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
      5: Result := aBufferAscript;
      6: Result := aBufferBscript;
      7: Result := aBufferCscript;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTShaderToy.SetScript(id:longword; const txt:string);
begin
   case id of
      1: aFrag_script := txt;
      2: aVert_script := txt;
      3: aMainScript := txt;
      4: aCommonScript := txt;
      5: aBufferAscript := txt;
      6: aBufferBscript := txt;
      7: aBufferCscript := txt;
   end;
end;



//------------------------------------------------------------------------------
procedure   BTShaderToy.SetMouseEvent(X,Y,Clicked:longint);
begin
   Y := trunc(aYlng) - Y;
   aMouseX := X;
   aMouseY := Y;
   if Clicked <> 0 then
   begin
      if not aMouseClick then
      begin
         aCMouseX := X;
         aCMouseY := Y;
         aMouseClick := true;
      end;
   end else begin
      aCMouseX := X * -1;
      aCMouseY := Y * -1;
      aMouseClick := false;
   end;
end;

//------------------------------------------------------------------------------
function    BTShaderToy.GetProp(id:longword):longword;
begin
   Result := 0;
   case id of
      1: Result := aCompileTime;
      2: Result := aFrame;
      3: Result := aFPS;
   end;
end;

//------------------------------------------------------------------------------
const BM_INFO :array[0..12] of longword =
      (  40,  //bmiHeader.biSize cardinal = 40
         0,  //bmiHeader.biWidth integer = Xlng
         0,  //bmiHeader.biHeight integer = -Ylng >> start from 0,0 left,top
         $00200001,  //bmiHeader.biPlanes = 1 word   , biBitCount = 32 word
         3,  //bmiHeader.biCompression cardinal = 3  BI_BITFIELDS
         0,  //bmiHeader.biSizeImage  cardinal
         0,  //bmiHeader.biXpelsPerMeter integer
         0,  //bmiHeader.biYpelsPerMeter integer
         0,  //bmiHeader.biClrUsed cardinal
         0,  //bmiHeader.biClrImportant cardinal
         $0000FF,  //bmiColors[0]
         $00FF00,  //bmiColors[1]
         $FF0000   //bmiColors[2]
       );

procedure   BTShaderToy.TexturePreview(hwnd :NativeUint; Xpos,Ypos :longint; Xlng,Ylng,channel:longword);
var dc:NativeUint;
    BI:array[0..12] of longword;
begin
   dc := GetDC(hwnd);
   channel := channel and 3;
   move(BM_INFO,BI,sizeof(BM_INFO));
   BI[1] := aChan_Width[channel];
   BI[2] := -aChan_Height[channel];
   SetStretchBltMode(dc, HALFTONE);
   StretchDibits(dc, Xpos, Ypos, Xlng, Ylng,
                 0,0,aChan_Width[channel],aChan_Height[channel], aTexData[channel] , bitmapinfo((@BI)^),
                 DIB_RGB_COLORS,SRCCOPY);
   ReleaseDC(hwnd,dc);
   DeleteDC(dc);
end;


end.

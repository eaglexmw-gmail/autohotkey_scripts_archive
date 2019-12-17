;+-------------------------------------------------------------------------------------+
;¦ Dlg version 5.02 par/by majkinetor.                                                 ¦
;¦ Voir/See http://www.autohotkey.com/forum/topic17230.html.                           ¦
;¦ Sous licence/Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>. ¦
;+-------------------------------------------------------------------------------------+

Dlg_Color(ByRef Color,hGui=0){
clr:=((Color&0xFF)<<16)+(Color&0xFF00)+((Color>>16)&0xFF)
VarSetCapacity(CHOOSECOLOR,0x24,0),VarSetCapacity(CUSTOM,64,0)
,NumPut(0x24,CHOOSECOLOR,0)
,NumPut(hGui,CHOOSECOLOR,4)
,NumPut(clr,CHOOSECOLOR,12)
,NumPut(&CUSTOM,CHOOSECOLOR,16)
,NumPut(0x00000103,CHOOSECOLOR,20)
nRC:=DllCall("comdlg32\ChooseColorA",str,CHOOSECOLOR)
if (errorlevel<>0)||(nRC=0)
return false
clr:=NumGet(CHOOSECOLOR,12)
oldFormat:=A_FormatInteger
SetFormat,integer,hex
Color:=(clr&0xff00)+((clr&0xff0000)>>16)+((clr&0xff)<<16)
StringTrimLeft,Color,Color,2
loop,% 6-strlen(Color)
Color=0%Color%
Color=0x%Color%
SetFormat,integer,%oldFormat%
return true
}
Dlg_Find(hGui,Handler,Flags="d",FindText=""){
static FINDMSGSTRING="commdlg_FindReplace"
static FR_DOWN=1,FR_MATCHCASE=4,FR_WHOLEWORD=2,FR_HIDEMATCHCASE=0x8000,FR_HIDEWHOLEWORD=0x10000,FR_HIDEUPDOWN=0x4000
static buf,FR,len
if len=
VarSetCapacity(FR,40,0),VarSetCapacity(buf,len:=256)
ifNotEqual,FindText,,SetEnv,buf,%FindText%
f:=0
,InStr(flags,"d") ? f|=FR_DOWN:""
,InStr(flags,"c") ? f|=FR_MATCHCASE:""
,InStr(flags,"w") ? f|=FR_WHOLEWORD:""
,InStr(flags,"-d") ? f|=FR_HIDEUPDOWN:""
,InStr(flags,"-w") ? f|=FR_HIDEWHOLEWORD:""
,InStr(flags,"-c") ? f|=FR_HIDEMATCHCASE:""
NumPut(40,FR,0)
,NumPut(hGui,FR,4)
,NumPut(f,FR,12)
,NumPut(&buf,FR,16)
,NumPut(len,FR,24)
if !IsFunc(Handler)
return A_ThisFunc ">Invalid handler: " Handler
Dlg_callback(Handler,"","","")
OnMessage(DllCall("RegisterWindowMessage","str",FINDMSGSTRING),"Dlg_callback")
return DllCall("comdlg32\FindTextA","str",FR)
}
Dlg_Replace(hGui,Handler,Flags="",FindText="",ReplaceText=""){
static FINDMSGSTRING="commdlg_FindReplace"
static FR_MATCHCASE=4,FR_WHOLEWORD=2,FR_HIDEMATCHCASE=0x8000,FR_HIDEWHOLEWORD=0x10000,FR_HIDEUPDOWN=0x4000
static buf_f,buf_r,FR,len
if len =
len:=256,VarSetCapacity(FR,40,0),VarSetCapacity(buf_f,len),VarSetCapacity(buf_r,len)
f:=0
f|=InStr(flags,"c") ? FR_MATCHCASE:0
f|=InStr(flags,"w") ? FR_WHOLEWORD:0
f|=InStr(flags,"-w") ? FR_HIDEWHOLEWORD:0
f|=InStr(flags,"-c") ? FR_HIDEMATCHCASE:0
ifNotEqual,FindText,,SetEnv,buf_f,%FindText%
ifNotEqual,ReplaceText,,SetEnv,buf_r,%ReplaceText%
NumPut(40,FR,0)
,NumPut(hGui,FR,4)
,NumPut(f,FR,12)
,NumPut(&buf_f,FR,16)
,NumPut(&buf_r,FR,20)
,NumPut(len,FR,24)
,NumPut(len,FR,26)
Dlg_callback(Handler,"","","")
OnMessage(DllCall("RegisterWindowMessage","str",FINDMSGSTRING),"Dlg_callback")
return DllCall("comdlg32\ReplaceTextA","str",FR)
}
Dlg_Font(ByRef Name,ByRef Style,ByRef Color,Effects=true,hGui=0){
LogPixels:=DllCall("GetDeviceCaps","uint",DllCall("GetDC","uint",hGui),"uint",90)
VarSetCapacity(LOGFONT,128,0)
Effects:=0x041+(Effects ? 0x100:0)
DllCall("RtlMoveMemory","uint",&LOGFONT+28,"Uint",&Name,"Uint",32)
clr:=((Color&0xFF)<<16)+(Color&0xFF00)+((Color>>16)&0xFF)
if InStr(Style,"bold")
NumPut(700,LOGFONT,16)
if InStr(Style,"italic")
NumPut(255,LOGFONT,20,1)
if InStr(Style,"underline")
NumPut(1,LOGFONT,21,1)
if InStr(Style,"strikeout")
NumPut(1,LOGFONT,22,1)
if RegExMatch(Style,"s[1-9][0-9]*",s){
StringTrimLeft,s,s,1
s:=-DllCall("MulDiv","int",s,"int",LogPixels,"int",72)
NumPut(s,LOGFONT,0,"Int")
}
else NumPut(16,LOGFONT,0)
VarSetCapacity(CHOOSEFONT,60,0)
,NumPut(60,CHOOSEFONT,0)
,NumPut(hGui,CHOOSEFONT,4)
,NumPut(&LOGFONT,CHOOSEFONT,12)
,NumPut(Effects,CHOOSEFONT,20)
,NumPut(clr,CHOOSEFONT,24)
r:=DllCall("comdlg32\ChooseFontA","uint",&CHOOSEFONT)
if !r
return false
VarSetCapacity(Name,32)
DllCall("RtlMoveMemory","str",Name,"Uint",&LOGFONT+28,"Uint",32)
Style:="s" NumGet(CHOOSEFONT,16) // 10
old:=A_FormatInteger
SetFormat,integer,hex
Color:=NumGet(CHOOSEFONT,24)
SetFormat,integer,%old%
Style =
VarSetCapacity(s,3)
DllCall("RtlMoveMemory","str",s,"Uint",&LOGFONT+20,"Uint",3)
if NumGet(LOGFONT,16) >= 700
Style.="bold "
if NumGet(LOGFONT,20,"UChar")
Style.="italic "
if NumGet(LOGFONT,21,"UChar")
Style.="underline "
if NumGet(LOGFONT,22,"UChar")
Style.="strikeout "
s:=NumGet(LOGFONT,0,"Int")
Style.="s" Abs(DllCall("MulDiv","int",abs(s),"int",72,"int",LogPixels))
oldFormat:=A_FormatInteger
SetFormat,integer,hex
Color:=(Color&0xff00)+((Color&0xff0000)>>16)+((Color&0xff)<<16)
StringTrimLeft,Color,Color,2
loop,% 6-strlen(Color)
Color=0%Color%
Color=0x%Color%
SetFormat,integer,%oldFormat%
return 1
}
Dlg_Icon(ByRef Icon,ByRef Index,hGui=0){
VarSetCapacity(wIcon,1025,0)
If (Icon) && !DllCall("MultiByteToWideChar","UInt",0,"UInt",0,"Str",Icon,"Int",StrLen(Icon),"UInt",&wIcon,"Int",1025)
return false
r:=DllCall(DllCall("GetProcAddress","Uint",DllCall("LoadLibrary","str","shell32.dll"),"Uint",62),"uint",hGui,"uint",&wIcon,"uint",1025,"intp",--Index)
Index++
IfEqual,r,0,return false
VarSetCapacity(Icon,len:=DllCall("lstrlenW","UInt",&wIcon))
r:=DllCall("WideCharToMultiByte" ,"UInt",0,"UInt",0,"UInt",&wIcon,"Int",len,"Str",Icon,"Int",len,"UInt",0,"UInt",0)
IfEqual,r,0,return false
Return True
}
Dlg_Open(hGui=0,Title="",Filter="",DefaultFilter="",Root="",DefaultExt="",Flags="FILEMUSTEXIST HIDEREADONLY"){
static OFN_S:=0,OFN_ALLOWMULTISELECT:=0x200,OFN_CREATEPROMPT:=0x2000,OFN_DONTADDTORECENT:=0x2000000,OFN_EXTENSIONDIFFERENT:=0x400,OFN_FILEMUSTEXIST:=0x1000,OFN_FORCESHOWHIDDEN:=0x10000000,OFN_HIDEREADONLY:=0x4,OFN_NOCHANGEDIR:=0x8,OFN_NODEREFERENCELINKS:=0x100000,OFN_NOVALIDATE:=0x100,OFN_OVERWRITEPROMPT:=0x2,OFN_PATHMUSTEXIST:=0x800,OFN_READONLY:=0x1,OFN_SHOWHELP:=0x10,OFN_NOREADONLYRETURN:=0x8000,OFN_NOTESTFILECREATE:=0x10000
IfEqual,Filter,,SetEnv,Filter,All Files (*.*)
SplitPath,Root,rootFN,rootDir
hFlags:=0x80000
loop,parse,Flags,%A_TAB%%A_SPACE%,%A_TAB%%A_SPACE%
if A_LoopField !=
hFlags|=OFN_%A_LoopField%
ifEqual,hFlags,,return A_ThisFunc "> Some of the flags are invalid: " Flags
VarSetCapacity(FN,0xffff),VarSetCapacity(lpstrFilter,2*StrLen(filter))
if rootFN !=
DllCall("lstrcpyn","str",FN,"str",rootFN,"int",StrLen(rootFN)+1)
delta:=0
loop,Parse,Filter,|
{
desc:=A_LoopField,ext:=SubStr(A_LoopField,InStr(A_LoopField,"(")+1,-1)
lenD:=StrLen(A_LoopField)+1,lenE:=StrLen(ext)+1
DllCall("lstrcpyn","uint",&lpstrFilter+delta,"uint",&desc,"int",lenD)
DllCall("lstrcpyn","uint",&lpstrFilter+delta+lenD,"uint",&ext,"int",lenE)
delta += lenD+lenE
}
NumPut(0,lpstrFilter,delta,"UChar")
VarSetCapacity(OFN ,90,0)
,NumPut(76,OFN,0,"UInt")
,NumPut(hGui,OFN,4,"UInt")
,NumPut(&lpstrFilter,OFN,12,"UInt")
,NumPut(DefaultFilter,OFN,24,"UInt")
,NumPut(&FN,OFN,28,"UInt")
,NumPut(0xffff,OFN,32,"UInt")
,NumPut(&rootDir,OFN,44,"UInt")
,NumPut(&Title,OFN,48,"UInt")
,NumPut(hFlags,OFN,52,"UInt")
,NumPut(&DefaultExt,OFN,60,"UInt")
res:=SubStr(Flags,1,1)="S" ? DllCall("comdlg32\GetSaveFileNameA","Uint",&OFN):DllCall("comdlg32\GetOpenFileNameA","Uint",&OFN)
IfEqual,res,0,return
adr:=&FN,f:=d:=DllCall("MulDiv","Int",adr,"Int",1,"Int",1,"str"),res:=""
if StrLen(d) != 3
d.="\"
if ms:=InStr(Flags,"ALLOWMULTISELECT")
loop
if f:=DllCall("MulDiv","Int",adr += StrLen(f)+1,"Int",1,"Int",1,"str")
res.=d f "`n"
else{
IfEqual,A_Index,1,SetEnv,res,%d%
break
}
return ms ? SubStr(res,1,-1):SubStr(d,1,-1)
}
Dlg_Save(hGui=0,Title="",Filter="",DefaultFilter="",Root="",DefaultExt="",Flags=""){
return Dlg_Open(hGui,Title,Filter,DefaultFilter,Root,DefaultExt,"S " Flags)
}
Dlg_callback(wparam,lparam,msg,hwnd){
static FR_DIALOGTERM=0x40,FR_DOWN=1,FR_MATCHCASE=4,FR_WHOLEWORD=2,FR_HIDEMATCHCASE=0x8000,FR_HIDEWHOLEWORD=0x10000,FR_HIDEUPDOWN=0x4000,FR_REPLACE=0x10,FR_REPLACEALL=0x20,FR_FINDNEXT=8
static handler
ifEqual,hwnd,,return handler:=wparam
hFlags:=NumGet(lparam+12)
if (hFlags&FR_DIALOGTERM)
return %handler%("C","","","")
flags.=(hFlags&FR_MATCHCASE) && !(hFlags&FR_HIDEMATCHCASE) ? "c":
flags.=(hFlags&FR_WHOLEWORD) && !(hFlags&FR_HIDEWHOLEWORD) ? "w":
findText:=DllCall("MulDiv","Int",NumGet(lparam+16),"Int",1,"Int",1,"str")
if (hFlags&FR_FINDNEXT){
flags.=(hFlags&FR_DOWN) && !(hFlags&FR_HIDEUPDOWN) ? "d":
return %handler%("F",flags,findText,"")
}
if (hFlags&FR_REPLACE)||(hFlags&FR_REPLACEALL){
event:=(hFlags&FR_REPLACEALL) ? "A":"R"
replaceText:=DllCall("MulDiv","Int",NumGet(lparam+20),"Int",1,"Int",1,"str")
return %handler%(event,flags,findText,replaceText)
}
}
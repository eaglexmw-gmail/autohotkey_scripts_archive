;+----------------------------------------------------------------------------+
;¦ AHK wrapper version 4.0.0.4-3 by/par majkinetor                            ¦
;¦ Sous licence/Licenced under BSD <http://creativecommons.org/licenses/BSD/> ¦
;+----------------------------------------------------------------------------+

HE_Add(hGui,X,Y,W,H,Style="",DllPath="hie\HiEdit.dll"){
Static WS_CLIPCHILDREN=0x2000000,WS_VISIBLE=0x10000000,WS_CHILD=0x40000000,MODULEID
Static HSCROLL=0x8,VSCROLL=0x10,TABBED=4,HILIGHT=0x20,TABBEDBTOP=0x1,TABBEDHRZSB=0x2,TABBEDBOTTOM=0x4,SINGLELINE=0x40,FILECHANGEALERT=0x80
hStyle:=0
Loop,Parse,style,%A_Tab%%A_Space%
IfEqual,A_LoopField,,Continue
Else hStyle|=%A_LOOPFIELD%
If !MODULEID
MODULEID:=230909,DllCall("LoadLibrary","str",DllPath)
hCtrl:=DllCall("CreateWindowEx","Uint",0x200,"str","HiEdit","str",szAppName,"Uint",WS_CLIPCHILDREN|WS_CHILD|WS_VISIBLE|hStyle,"int",X,"int",Y,"int",W,"int",H,"Uint",hGui,"Uint",MODULEID,"Uint",0,"Uint",0,"Uint")
HE_SetTabsImageList(hCtrl)
Return hCtrl
}
HE_ReloadFile(hEdit,idx=-1){
static HEM_RELOADFILE=2027
SendMessage,HEM_RELOADFILE,0,idx,,ahk_id %hEdit%
Return ErrorLevel
}
HE_GetTextLength(hEdit){
static WM_GETTEXTLENGTH=14
SendMessage,WM_GETTEXTLENGTH,0,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_GetTextRange(hEdit,min=0,max=-1){
static EM_GETTEXTRANGE=1099
if (max=-1)
max:=HE_GetTextLength(hEdit)
VarSetCapacity(buf,max-min+2)
VarSetCapacity(RNG,12),NumPut(min,RNG),NumPut(max,RNG,4),NumPut(&buf,RNG,8)
SendMessage,EM_GETTEXTRANGE,0,&RNG,,ahk_id %hEdit%
VarSetCapacity(buf,-1)
Return buf
}
HE_GetLineCount(hEdit){
static EM_GETLINECOUNT=186
SendMessage,EM_GETLINECOUNT,0,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_LineLength(hEdit,idx=-1){
static EM_LINELENGTH=193
SendMessage,EM_LINELENGTH,He_LineIndex(hEdit,idx),0,,ahk_id %hEdit% 
Return ErrorLevel
}
HE_GetSelText(hEdit){
static EM_GETSELTEXT=1086
HE_GetSel(hEdit,s,e),VarSetCapacity(buf,e-s+2)
SendMessage,EM_GETSELTEXT,0,&buf,,ahk_id %hEdit% 
VarSetCapacity(buf,-1)
Return buf
}
HE_GetSel(hEdit,ByRef start_pos="@",ByRef end_pos="@"){
static EM_GETSEL=176
VarSetCapacity(s,4),VarSetCapacity(e,4)
SendMessage,EM_GETSEL,&s,&e,,ahk_id %hEdit% 
s:=NumGet(s),e:=NumGet(e)
if (start_pos != "@")
start_pos:=s
if (end_pos != "@")
end_pos:=e
Return s
}
HE_GetLine(hEdit,idx=-1){
static EM_GETLINE=196
If (idx=-1)
idx:=HE_LineFromChar(hEdit,HE_LineIndex(hEdit))
len:=HE_LineLength(hEdit,idx)
IfEqual,len,0,Return
VarSetCapacity(txt,len,0),NumPut(len=1 ? 2 : len,txt)
SendMessage,EM_GETLINE,idx,&txt,,ahk_id %hEdit%
If ErrorLevel=FAIL
{
Msgbox %A_ThisFunc% failed
Return
}
VarSetCapacity(txt,-1)
Return len=1 ? SubStr(txt,1,-1) : txt
}
HE_AutoIndent(hEdit,pState){
Static HEM_AUTOINDENT:=2042
SendMessage,HEM_AUTOINDENT,0,pState,,ahk_id %hEdit%
Return ErrorLevel
}
HE_CloseFile(hEdit,idx=-1){
Static HEM_CLOSEFILE:=2026
SendMessage,HEM_CLOSEFILE,0,idx,,ahk_id %hEdit%
Return ErrorLevel
}
HE_GetCurrentFile(hEdit){
Static HEM_GETCURRENTFILE:=2032
SendMessage,HEM_GETCURRENTFILE,0,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_GetFileCount(hEdit){
Static HEM_GETFILECOUNT:=2029
SendMessage,HEM_GETFILECOUNT,0,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_GetFileName(hEdit,idx=-1){
Static HEM_GETFILENAME:=2030
VarSetCapacity(fileName,512)
SendMessage,HEM_GETFILENAME,&fileName,idx,,ahk_id %hEdit%
Return fileName
}
HE_LineFromChar(hEdit,ich){
Static EM_LINEFROMCHAR=201
SendMessage,EM_LINEFROMCHAR,ich,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_LineIndex(hedit,idx=-1){
Static EM_LINEINDEX=187
SendMessage,EM_LINEINDEX,idx,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_LineNumbersBar(hEdit,state="show",linw=40,selw=10){
Static HEM_LINENUMBERSBAR:=2036
Static LNB_HIDE=0,LNB_SHOW=1,LNB_AUTOMAXSIZE=2,LNB_AUTOSIZE=4
If state Is Not Integer
state:=LNB_%state%
SendMessage,HEM_LINENUMBERSBAR,state,selw<<16 | linw,,ahk_id %hEdit%
Return ErrorLevel
}
HE_NewFile(hEdit){
Static HEM_NEWFILE:=2024
SendMessage,HEM_NEWFILE,0,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_OpenFile(hEdit,pFileName,flag=0){
Static HEM_OPENFILE:=2025
SendMessage,HEM_OPENFILE,flag,&pFileName,,ahk_id %hEdit%
Return ErrorLevel
}
HE_Redo(hEdit){
Static EM_REDO:=1108
SendMessage,EM_REDO,,,,ahk_id %hEdit%
Return ErrorLevel
}
HE_ReplaceSel(hEdit, text=""){
static  EM_REPLACESEL=194
SendMessage, EM_REPLACESEL, 0, &text,, ahk_id %hEdit% 
Return ErrorLevel
}
HE_SaveFile(hEdit,pFileName,idx=-1){
Static HEM_SAVEFILE:=2028
SendMessage,HEM_SAVEFILE,&pFileName,idx,,ahk_id %hEdit%
Return Errorlevel
}
HE_ScrollCaret(hEdit){
Static EM_SCROLLCARET=183
SendMessage,EM_SCROLLCARET,0,0,,ahk_id %hEdit%
Return ErrorLevel
}
HE_SetColors(hEdit,colors,fRedraw=true){
Static HEM_SETCOLORS:=2037
Static names:="Text,Back,SelText,ActSelBack,InSelBack,LineNumber,SelBarBack,NonPrintableBack,Number"  ; ,Operator,Comment,String"
at:=A_AutoTrim
AutoTrim,on
Loop,Parse,colors,`,`,
{
name:=SubStr(A_LoopField,1,i:=InStr(A_LoopField,"=")-1),val:=SubStr(A_LoopField,i+2)
name=%name%
val=%val%
If Name Not In %names%
Return "Nom de couleur invalide : '" name "'"
If val Is Not Integer
Return "Valeur de couleur invalide : '" val "'"
n%name%:=val
}
AutoTrim,%at%
VarSetCapacity(COLORS,36,0)
NumPut(nText,COLORS,0)
NumPut(nBack,COLORS,4)
NumPut(nSelText,COLORS,8)
NumPut(nActSelBack,COLORS,12)
NumPut(nInSelBack,COLORS,16)
NumPut(nLineNumber,COLORS,20)
NumPut(nSelBarBack,COLORS,24)
NumPut(nNonPrintableBack,COLORS,28)
NumPut(nNumber,COLORS,32)
SendMessage,HEM_SETCOLORS,&COLORS,fRedraw,,ahk_id %hEdit%
Return ErrorLevel
}
HE_SetCurrentFile(hEdit,idx){
Static HEM_SETCURRENTFILE:=2033
SendMessage,HEM_SETCURRENTFILE,0,idx,,ahk_id %hEdit%
Return ErrorLevel
}
HE_SetFont(hEdit,pFont=""){
Static WM_SETFONT:=0x30
italic:=InStr(pFont,"italic") ? 1:0 
underline:=InStr(pFont,"underline") ? 1:0 
strikeout:=InStr(pFont,"strikeout") ? 1:0 
weight:=InStr(pFont,"bold") ? 700:400 
RegExMatch(pFont,"(?<=[S|s])(\d{1,2})(?=[ ,])",height)
If (height="")
height:=10 
RegRead,LogPixels,HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI,LogPixels
height:=-DllCall("MulDiv","int",Height,"int",LogPixels,"int",72)
RegExMatch(pFont,"(?<=,).+",fontFace)
If (fontFace!="")
fontFace:=RegExReplace(fontFace,"(^\s*)|(\s*$)")
Else fontFace:="MS Sans Serif"
hFont:=DllCall("CreateFont","int",height,"int",0,"int",0,"int",0,"int",weight,"Uint",italic,"Uint",underline,"uint",strikeOut,"Uint",nCharSet,"Uint",0,"Uint",0,"Uint",0,"Uint",0,"str",fontFace) 
SendMessage,WM_SETFONT,hFont,TRUE,,ahk_id %hEdit%
Return ErrorLevel
}
HE_SetKeywordFile(pFile){
Return DllCall("hie\HiEdit.dll\SetKeywordFile","str",pFile)
}
HE_SetSel(hEdit,nStart=0,nEnd=-1){
Static EM_SETSEL=0x0B1
SendMessage,EM_SETSEL,nStart,nEnd,,ahk_id %hEdit%
Return ErrorLevel  
}
HE_SetTabWidth(hEdit,pWidth,pRedraw=true){
Static HEM_SETTABWIDTH:=2041
SendMessage,HEM_SETTABWIDTH,pWidth,pRedraw,,ahk_id %hEdit%
Return ErrorLevel
}
HE_SetTabsImageList(hEdit,pImg=""){
Static LR_LOADFROMFILE:=0x10,LR_CREATEDIBSECTION:=0x2000,HEM_SETTABSIMAGELIST:=2043,toolbarBMP:="424de60000000000000076000000280000001c00000007000000010004000000000070000000000000000000000010000000000000000000000000008000008000000080800080000000800080008080000080808000c0c0c0000000ff0000ff000000ffff00ff000000ff00ff00ffff0000ffffff00fddddfdddddfdddfdddddfddddfd0000fdddffddddffdddffddddffdddfd0000fddfffdddfffdddfffdddfffddfd0000fdffffddffffdddffffddffffdfd0000fddfffdddfffdddfffdddfffddfd0000fdddffddddffdddffddddffdddfd0000fddddfdddddfdddfdddddfddddfd0000"
If (pImg=""){
pImg:="___he_bar.bmp",deleteFile:=true
HE_writeFile(pImg,toolbarBMP)
}
hImlTabs:=DllCall("comctl32.dll\ImageList_LoadImage","uint",0,"str",pImg,"int",7,"int",4,"uint",0x0FF00FF,"uint",IMAGE_BITMAP,"uint",LR_CREATEDIBSECTION|LR_LOADFROMFILE)
If (deleteFile)
FileDelete,%pImg%
SendMessage,HEM_SETTABSIMAGELIST,0,hImlTabs,,ahk_id %hEdit%
}
HE_ShowFileList(hEdit,X=0,Y=0){
Static HEM_SHOWFILELIST:=2044
SendMessage,HEM_SHOWFILELIST,X,Y,,ahk_id %hEdit%
}
HE_Undo(hEdit){
Static WM_UNDO:=772
SendMessage,WM_UNDO,,,,ahk_id %hEdit%
Return ErrorLevel
}
HE_writeFile(file,data){
Handle:=DllCall("CreateFile","str",file,"Uint",0x40000000 ,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0)
Loop { 
If StrLen(data)=0
Break
StringLeft,Hex,data,2
StringTrimLeft,data,data,2
Hex=0x%Hex%
DllCall("WriteFile","UInt",Handle,"UChar *",Hex,"UInt",1,"UInt *",UnusedVariable,"UInt",0)
} 
DllCall("CloseHandle","Uint",Handle)
Return
}
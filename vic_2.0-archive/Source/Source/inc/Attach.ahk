;##############################################################################
;# AHK Attach version 1.0 par/by majkinetor                                   #
;# Sous licence/Licensed under BSD <http://creativecommons.org/licenses/BSD/> #
;##############################################################################

Attach(hCtrl="",aDef=""){
Attach_(hCtrl,aDef,"","")
}
Attach_(hCtrl,aDef,Msg,hParent){
Static
If (aDef=""){
If IsFunc(hCtrl)
Return Handler:=hCtrl
hParent:=hCtrl != "" ? hCtrl+0:hGui
Loop,Parse,%hParent%,%A_Space%
{
hCtrl:=A_LoopField,SubStr(%hCtrl%,1,1),aDef:=SubStr(%hCtrl%,1,1)="-" ? SubStr(%hCtrl%,2):%hCtrl%,%hCtrl%:=""
GoSub Attach_GetPos
Loop,Parse,aDef,%A_Space%
{
StringSplit,z,A_LoopField,:
%hCtrl%.=A_LoopField="r" ? "r ":(z1 ":" z2 ":" c%z1% " ")
}
%hCtrl%:=SubStr(%hCtrl%,1,-1)
}
Reset:=1
}
If (hParent=""){
If !adrSetWindowPos
adrSetWindowPos:=DllCall("GetProcAddress",uint,DllCall("GetModuleHandle",str,"user32"),str,"SetWindowPos"),adrWindowInfo:=DllCall("GetProcAddress",uint,DllCall("GetModuleHandle",str,"user32"),str,"GetWindowInfo"),OnMessage(5,A_ThisFunc),VarSetCapacity(B,60),NumPut(60,B),adrB:=&B
hGui:=hParent:=DllCall("GetParent","uint",hCtrl,"Uint")
IfEqual,aDef,-,Return SubStr(%hCtrl%,1,1)!="-" ? %hCtrl%:="-" %hCtrl%:
Else If (aDef="+")
SubStr(%hCtrl%,1,1)!="-" ? Return:%hCtrl%:=SubStr(%hCtrl%,2),enable:=1 
Else {
GoSub Attach_GetPos
%hCtrl%:=""
Loop,Parse,aDef,%A_Space%
{
l:=A_LoopField,f:=SubStr(l,1,1),k:=StrLen(l)=1 ? 1:SubStr(l,2)
If (j:=InStr(l,"/"))
k:=SubStr(l,2,j-2)/SubStr(l,j+1)
%hCtrl% .= f ":" k ":" c%f% " "
}
Return %hCtrl%:=SubStr(%hCtrl%,1,-1),%hParent% .= InStr(%hParent%,hCtrl) ? "":(%hParent%="" ? "":" ") hCtrl
}
}
If !reset && !enable {
%hParent%_pw:=aDef & 0xFFFF,%hParent%_ph:=aDef>>16
IfEqual,%hParent%_ph,0,Return
}
If (%hParent%_s="")||Reset
%hParent%_s:=%hParent%_pw " " %hParent%_ph,Reset:=0
StringSplit,s,%hParent%_s,%A_Space%
Loop,Parse,%hParent%,%A_Space%
{
hCtrl:=A_LoopField,aDef:=%hCtrl%,uw:=uh:=ux:=uy:=r:=0,hCtrl1:=SubStr(%hCtrl%,1,1)
IfEqual,hCtrl1,-,Continue
GoSub Attach_GetPos
Loop,Parse,aDef,%A_Space%
{
StringSplit,z,A_LoopField,:
IfEqual,z1,r,SetEnv,r,%z2%
c%z1%:=z3+z2*(z1="x"||z1="w" ? %hParent%_pw-s1:%hParent%_ph-s2),u%z1%:=true
}
flag:=4|(r=1 ? 0x100:0)|(uw OR uh ? 0:1)|(ux OR uy ? 0:2)
DllCall(adrSetWindowPos,"uint",hCtrl,"uint",0,"uint",cx,"uint",cy,"uint",cw,"uint",ch,"uint",flag)
r+0=2 ? Attach_redrawDelayed(hCtrl):
}
Return Handler!="" ? %Handler%(hParent):"",enable:=0
Attach_GetPos:
DllCall(adrWindowInfo,"uint",hParent,"uint",adrB),lx:=NumGet(B,20),ly:=NumGet(B,24),DllCall(adrWindowInfo,"uint",hCtrl,"uint",adrB),cx:=NumGet(B,4),cy:=NumGet(B,8),cw:=NumGet(B,12)-cx,ch:=NumGet(B,16)-cy,cx-=lx,cy-=ly
Return
}
Attach_redrawDelayed(hCtrl){
Static s
s.=!InStr(s,hCtrl) ? hCtrl " ":""
SetTimer,%A_ThisFunc%,-100
Return
Attach_redrawDelayed:
Loop,Parse,s,%A_Space%
WinSet,Redraw,,ahk_id %A_LoopField%
Return,s:=""
}
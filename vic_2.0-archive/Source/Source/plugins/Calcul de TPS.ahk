;###################################
;# Calcul de la TPS ################
;###################################

#NoEnv
#SingleInstance,Force
#NoTrayIcon
SetTitleMatchMode, 2
WinActivate, - Vic

Gui,24:Default
Gui,1:+Disabled
Gui,Add,Text,yp+16 W46 Right,&Montant :
Gui,Add,Edit,xp+50 yp-3 vMNT Right W100
Gui,Add,Text,xp+104 yp+3,$
Gui,Add,Text,xp-128 yp+32 W63 Right,TPS (5 `%) :
Gui,Add,Edit,xp+68 yp-3 vTPS Right W55 ReadOnly
Gui,Add,Text,xp+60 yp+3,$
Gui,Add,Text,xp-127 yp+32,TVQ (8,5 `%) :
Gui,Add,Edit,xp+68 yp-3 vTVQ Right W55 ReadOnly
Gui,Add,Text,xp+60 yp+3,$
Gui,Add,Text,xp-139 yp+32,&Total :
Gui,Add,Edit,xp+34 yp-3 vTTL Right W100
Gui,Add,Text,xp+104 yp+3,$
Gui,Add,Button,xp-148 yp+40 W70,&Effacer
Gui,Add,Button,xp+76 yp W70 Default,&Calculer
Gui,Show,W178 H194,Calcul de TPS
Return

24GuiEscape:
24ButtonEffacer:
ControlSetText,Edit1
ControlSetText,Edit2
ControlSetText,Edit3
ControlSetText,Edit4
Return

24GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

24ButtonCalculer:
SetFormat,Float,0.2
GuiControlGet,Montant,,Edit1
StringReplace,Montant,Montant,`,,.,1
Montant:=Montant/1
If Montant <>
{
 ControlSetText,Edit1,%Montant%
 TPS:=Round(Montant*0.05,2)
 ControlSetText,Edit2,%TPS%
 TVQ:=Round((TPS+Montant)*0.085,2)
 ControlSetText,Edit3,%TVQ%
 Total:=Round(Montant+TPS+TVQ,2)
 ControlSetText,Edit4,%Total%
}
Else
{
 GuiControlGet,Total,,Edit4
 StringReplace,Total,Total,`,,.,1
 Total:=Total/1
 ControlSetText,Edit4,%Total%
 Montant:=Round(Total*100/113.925,2)
 ControlSetText,Edit1,%Montant%
 TPS:=Round(Montant*0.05,2)
 ControlSetText,Edit2,%TPS%
 TVQ:=Round((TPS+Montant)*0.085,2)
 ControlSetText,Edit3,%TVQ%
}
Return

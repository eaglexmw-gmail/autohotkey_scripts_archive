; Vic
; © Normand Lamoureux, 2010-2011
; Version : 1.5.1
; Publié le : 2011-07-16
; normand.lamoureux@gmail.com

; Expérimental FW: (!^W)

#NoEnv
#SingleInstance,Force
#NoTrayIcon
#Include %A_ScriptDir%\lng\Vic.lang
#IfWinActive,Vic ahk_class AutoHotkeyGUI    ; Lier les raccourcis à Vic
AutoTrim,Off
Menu,Tray,Icon,doc\img\Vic.ico
SetBatchLines,-1
SetControlDelay,-1
SetWinDelay,-1
SetTitleMatchMode,2
SendMode,Input
Process,Priority,,A
CoordMode,Mouse,Screen
SysGet,GUIW,61     ; GUI Max Width
SysGet,GUIH,62     ; GUI Max Height
Loop,51
 IniRead,p%A_Index%,Vic.ini,Options,p%A_Index%
SysGet,Cptn,4
SysGet,Brdr,33
SysGet,MnBr,15
p7-=Brdr+Brdr                ; Gui W
p8-=Brdr+Cptn+MnBr+Brdr      ; Gui H
RC:="0",XR:="0",RP:="0"      ; Valeurs initiales
hdc:=DllCall("GetDC",UInt,0) ; Facteur PPP
dpi:=DllCall("GetDeviceCaps",UInt,hdc,Int,90)/96
DllCall("ReleaseDC",UInt,0,UInt,hdc)
X10:=10*dpi,X12:=12*dpi,X20:=20*dpi,X24:=24*dpi,X26:=26*dpi,X32:=32*dpi,X37:=37*dpi,X50:=50*dpi,X54:=54*dpi,X58:=58*dpi,X70:=70*dpi,X90:=90*dpi,X94:=94*dpi,X100:=100*dpi,X110:=110*dpi,X130:=130*dpi,X140:=140*dpi,X150:=150*dpi,X182:=182*dpi,X190:=190*dpi,X210:=210*dpi,X248:=248*dpi,X260:=260*dpi,X590:=590*dpi
Xp:=p1>15 ? 14:p1-2
Xq:=p1>13 ? 13:p1-2     ; Limite la taille
If dpi>1
 Xq:=p1>13 ? 11:p1-2

;--------------------------------------------------------
; Interface

Gui,+LastFound +Resize
hwnd:=WinExist()
; Fichier
Menu,F,Add,%FB%,FA
Menu,F,Add,%FC%,FB
Menu,F,Add,%FD%,FC
Menu,F,Add
Menu,F,Add,%FE%,FD
Menu,F,Add,%FF%,FE
Menu,F,Add
Menu,F,Add,%FG%,FF
Menu,F,Add,%FH%,FG
Menu,F,Add,%FI%,FH
Menu,F,Add,%FJ%,FI
Menu,F,Add
Menu,F,Add,%FM%,FL
Menu,F,Add
Menu,F,Add,%FO%,FT
Menu,F,Add,%FP%,FU
Menu,F,Add,%FQ%,FV
Menu,F,Add
Menu,F,Add,&1. %p37%,FM
Menu,F,Add,&2. %p38%,FN
Menu,F,Add,&3. %p39%,FO
Menu,F,Add,&4. %p40%,FP
Menu,F,Add,&5. %p41%,FQ
Menu,F,Add,&6. %p42%,FR
Menu,F,Add
Menu,F,Add,%FR%,FW
Menu,F,Add,%FS%,FX
Menu,F,Add
Menu,F,Add,%FN%,FS
; Édition
Menu,E,Add,%EB%,EA
Menu,E,Add,%EC%,EB
Menu,E,Add
Menu,E,Add,%EO%,EN
Menu,E,Add,%EP%,EO
Menu,E,Add
Menu,E,Add,%ED%,EC
Menu,E,Add,%EE%,ED
Menu,E,Add,%EF%,EE
Menu,E,Add,%EG%,EF
Menu,E,Add
Menu,E,Add,%EQ%,EP
Menu,E,Add
Menu,E,Add,%EH%,EG
Menu,E,Add,%EI%,EH
Menu,E,Add,%EJ%,EI
Menu,E,Add
Menu,E,Add,%EK%,EJ
Menu,E,Add,%EL%,EK
Menu,E,Add,%EM%,EL
Menu,E,Add
Menu,E,Add,%EN%,EM
; Affichage
Menu,A,Add,%AB%,AA
Menu,A,Add,%AC%,AB
Menu,A,Add,%AD%,AC
Menu,A,Add,%AE%,AD
Menu,A,Add,%AF%,AE
Menu,A,Add
Menu,A,Add,%AG%,AF
Menu,A,Add,%AP%,AO
Menu,A,Add,%AH%,AG
Menu,A,Add,%AI%,AH
Menu,A,Add,%AJ%,AI
Menu,A,Add,%AK%,AJ
Menu,A,Add,%AL%,AK
Menu,A,Add
Menu,A,Add,%AM%,AL
Menu,A,Add,%AN%,AM
Menu,A,Add,%AO%,AN
Menu,A,Add
Menu,A,Add,%AT%,AS
Menu,A,Add,%AU%,AT
Menu,A,Add,%AV%,AU
Menu,A,Add,%AW%,AV
Menu,A,Add
Menu,A,Add,%AR%,AQ
Menu,A,Add,%AS%,AR
Menu,A,Add
Menu,A,Add,%AQ%,AP
; Insertion
Menu,I,Add,%JI%,JH
Menu,I,Add,%JJ%,JI
Menu,I,Add,%JK%,JJ
Menu,I,Add
Menu,I,Add,%JW%,JV
Menu,I,Add
Menu,I,Add,%JL%,JK
Menu,I,Add,%JM%,JL
Menu,I,Add,%JN%,JM
Menu,I,Add,%JO%,JN
Menu,I,Add,%JP%,JO
Menu,I,Add,%JQ%,JP
Menu,I,Add
Menu,I,Add,%JU%,JT
Menu,I,Add,%JV%,JU
Menu,I,Add
Menu,I,Add,%JB%,JA
Menu,I,Add,%JC%,JB
Menu,I,Add,%JD%,JC
Menu,I,Add,%JE%,JD
Menu,I,Add,%JF%,JE
Menu,I,Add,%JG%,JF
Menu,I,Add
Menu,I,Add,%JH%,JG
Menu,I,Add
Menu,I,Add,%JR%,JQ
Menu,I,Add,%JS%,JR
Menu,I,Add,%JT%,JS
; Outils
Menu,T,Add,%TB%,TA
Menu,T,Add,%TC%,TB
Menu,T,Add
Menu,T,Add,%TG%,TG
Menu,T,Add,%TH%,TH
Menu,T,Add,%TI%,TI
Menu,T,Add
Menu,T,Add,%TD%,TC
Menu,T,Add,%TE%,TD
Menu,T,Add,%TF%,TE
Menu,T,Add
Menu,T,Add,%TX%,TW
Menu,T,Add,%TV%,TJ
Menu,T,Add,%TJ%,TK
Menu,T,Add,%TU%,TV
Menu,T,Add
Menu,T,Add,%TK%,TL
Menu,T,Add,%TL%,TM
Menu,T,Add,%TM%,TN
Menu,T,Add,%TN%,TO
Menu,T,Add,%TO%,TP
Menu,T,Add
Menu,T,Add,%TY%,TX
Menu,T,Add,%TZ%,TY
Menu,T,Add,%TT%,TU
Menu,T,Add,%TW%,TF
; HTML
Menu,H,Add,%HB%,HA
Menu,H,Add,%HC%,HB
Menu,H,Add,%HD%,HC
Menu,H,Add,%HE%,HD
Menu,H,Add,%HF%,HE
Menu,H,Add,%HG%,HF
Menu,H,Add
Menu,H,Add,%HH%,HG
Menu,H,Add,%HI%,HH
Menu,H,Add,%HJ%,HI
Menu,H,Add
Menu,H,Add,%HY%,HX
Menu,H,Add,%HZ%,HY
Menu,H,Add
Menu,H,Add,%HK%,HJ
Menu,H,Add,%HL%,HK
Menu,H,Add
Menu,H,Add,%H0%,HZ
Menu,H,Add,%HX%,HW
Menu,H,Add
Menu,H,Add,%HM%,HL
Menu,H,Add,%HN%,HM
Menu,H,Add,%HO%,HN
Menu,H,Add
Menu,H,Add,%HP%,HO
Menu,H,Add,%HQ%,HP
Menu,H,Add,%HR%,HQ
Menu,H,Add,%HS%,HR
Menu,H,Add
Menu,H,Add,%HT%,HS
Menu,H,Add,%HU%,HT
Menu,H,Add
Menu,H,Add,%HV%,HU
Menu,H,Add,%HW%,HV
; Signets
Menu,K,Add,%KB%,KA
Menu,K,Add
Menu,K,Add,%KC%,KB
Menu,K,Add,%KD%,KC
Menu,K,Add
Menu,K,Add,%KE%,KD
Menu,K,Add,%KF%,KE
Loop,%A_ScriptDir%\plugins\*.ahk
{
 StringTrimRight,AddMenuItemP,A_LoopFileName,4
 Menu,P,Add,&%AddMenuItemP%,PA
}
; ?
Menu,Z,Add,%VB%,ZA
Menu,Z,Add,%VC%,ZB
Menu,Z,Add,%VD%,ZC
Menu,Z,Add
Menu,Z,Add,%VE%,ZD
Menu,Z,Add
Menu,Z,Add,%VF%,ZE
; Barre de menus
Menu,B,Add,%FA%,:F
Menu,B,Add,%EA%,:E
Menu,B,Add,%AA%,:A
Menu,B,Add,%JA%,:I
Menu,B,Add,%TA%,:T
Menu,B,Add,%HA%,:H
Menu,B,Add,%KA%,:K
Menu,B,Add,%PA%,:P
Menu,B,Add,%VA%,:Z
Gui,Menu,B
; Menu contextuel
Menu,C,Add,%EO%,EN
Menu,C,Add,%JW%,JV
Menu,C,Add,%TI%,TI
Menu,C,Add
Menu,C,Add,%EB%,EA
Menu,C,Add,%EC%,EB
Menu,C,Add
Menu,C,Add,%ED%,EC
Menu,C,Add,%EE%,ED
Menu,C,Add,%EF%,EE
Menu,C,Add,%EG%,EF
Menu,C,Add
Menu,C,Add,%EN%,EM
; Barre d'état
Gui,Add,StatusBar,vBE
SB_SetParts(250,160,160)
SetTimer,MaJ,300
If (p45=0)
 GuiControl,Hide,BE

; Police : taille, style, famille
fStyle:="s" . p1 . " " . p2,fFace:=p3

; Fenêtre : largeur, hauteur, coloration, multi-onglets
hEdit:=HE_Add(hwnd,0,0,p7,p8,"HSCROLL VSCROLL HILIGHT " . p10 . " FILECHANGEALERT")
HE_SetFont(hEdit,fStyle "," fFace)

; Couleurs
If (p17=0)    ; 2e jeu = Non
 colors:="Text=" . p18 . ",Back=" . p19 . ",SelText=" . p20 . ",ActSelBack=" . p21 . ",InSelBack=" . p22 . ",LineNumber=" . p23 . ",SelBarBack=" . p24 . ",NonPrintableBack=" . p25 . ",Number=" . p26
Else
 colors:="Text=" . p27 . ",Back=" . p28 . ",SelText=" . p29 . ",ActSelBack=" . p30 . ",InSelBack=" . p31 . ",LineNumber=" . p32 . ",SelBarBack=" . p33 . ",NonPrintableBack=" . p34 . ",Number=" . p35
HE_SetColors(hEdit,colors)
HE_SetTabWidth(hEdit,p4)     ; Largeur de tabulation
HE_LineNumbersBar(hEdit,p12,p13,p14),p11    ; Numérotation, style, largeur, marge de sélection
HE_AutoIndent(hedit,p15),autoIndent:=p15

; Modifications au menu
If p9=HILIGHT
{
 Menu,A,Check,%AI%
 If p17=1
  HE_SetKeywordFile(A_ScriptDir "\hes\Coloration2.hes")
 Else
  HE_SetKeywordFile(A_ScriptDir "\hes\Coloration1.hes")
}
If p10=TABBEDHRZSB
 Menu,A,Check,%AK%
If p11=1
 Menu,A,Check,%AL%
If p15=1
 Menu,A,Check,%AJ%
If p16=1
 Menu,A,Check,%AH%
If p17=1
 Menu,A,Check,%AG%
If p45=1
 Menu,A,Check,%AP%

; Si Gui bouge
Attach(hEdit,"w h r2")
Gui,Show,x%p5% y%p6% w%p7% h%p8%,Vic
ControlFocus,,ahk_id %hEdit%
Return

GuiSize:
If (ErrorLevel=1)
 Return
NW:=A_GuiWidth
If (p45=1)
 BarEt:=MnBr  ; Barre d'état
Else
 BarEt=0
NH:=A_GuiHeight-BarEt
ControlMove,,,,%NW%,%NH%,ahk_id %hEdit%
Return

;### Glisser déposer
GuiDropFiles:
Loop,parse,A_GuiEvent,`n
{
 fn=%A_LoopField%
 GoSub,R9
}
Return

;### Menu contextuel
+F10 Up::
AppsKey Up::
Menu,C,Show,%A_CaretX%,%A_CaretY%
Return

RButton::
RButton Up::
Click
IfWinActive,- Vic ahk_class AutoHotkeyGUI
 Menu,C,Show,%CSX%,%CSY%
Return

;--------------------------------------------------------
MaJ:
GetKeyState,State,LButton
If (state=D)
 Return
GoSub,R5                     ; Position
NFO:=HE_GetFileCount(hEdit)  ; Nb fichiers
NLT:=HE_GetLineCount(hEdit)  ; Nb lignes
NTC:=HE_GetTextLength(hEdit) ; Nb caractères
NCT:=HE_LineLength(hEdit,-1)+1         ; Nb colonnes
NCS:=StrLen(HE_GetSelText(hEdit))      ; Nb sélectionnés
ControlGet,L,CurrentLine,,HiEdit1,Vic  ; Nº ligne
ControlGet,TLC,Line,%L%,HiEdit1,Vic    ; Ligne
StringMid,I,TLC,NCC,1        ; Caractère
I:=Asc(I)                    ; Nº ANSI
SB_SetText(SA . NLC . SB . NLT . SC . NCC . SB . NCT,1)
SB_SetText(SD . NCS . SB . NTC,2)
SB_SetText(SE . I,3)
SB_SetText(SF . NFO,4)
GoTo,R7
Return

;--------------------------------------------------------
; Fonctions

;### Fichier

FA: ;### Nouvel onglet
^N::
HE_NewFile(hEdit)
GoSub,R7 ; MàJ barre titre
Return

FB: ;### Ouvrir un fichier...
^O::
FileSelectFile,fn,M,,%WA%,%WB%
If (fn="")
 Return
RegExMatch(fn,"^[^`n]+",dir) ; Chemin
fn:=RegExReplace(fn,"s)^[^`n]+`n(.+)","$1") ; Nom
Loop,Parse,fn,`n
{
 fn:=dir . "\" . A_LoopField
 GoSub,R9 ; Ouvrir si pas ouvert
}
Return

FC: ;### Ouvrir une session...
!^O::
FileSelectFile,fn,3,,%WC%,%WB%
If (fn="")
 Return
N:=HE_GetFileCount(hEdit)    ; Nb fichiers ouverts
Loop,Read,%fn%     ; Pour chaque fichier à ouvrir
{
 Loop,%N%          ; Faire le tour de ceux qui sont ouverts
 {
  idx:=A_Index-1   ; Commencer à 0
  fn:=HE_GetFileName(hEdit,idx)
  IfInString,fn,%A_LoopReadLine%
   Break           ; Si là, aller au fichier à ouvrir suivant
  c:=A_Index
 }
 If (c=N)          ; Si pas là et tour fini, ouvrir
  HE_OpenFile(hEdit,A_LoopReadLine)
}
Return

FD: ;### Fermer l'onglet
^F4::    ; Si 1 seul à fermer
N=1
FTs:     ; Si plusieurs à fermer
Loop,%N%
{
 SendMessage,0xB8,0,-1,,ahk_id %hEdit%
 If (ErrorLevel)             ; Si le fichier a changé...
 {
  MsgBox,51,%MH%,%MI%        ; ...offrir d'enregistrer
  IfMsgBox,Yes               ;    ...si oui, enregistrer, fermer et continuer
  {
   GoSub,FF
   HE_CloseFile(hEdit,-1)
   Continue
  }
  IfMsgBox,No
  {
   HE_CloseFile(hEdit,-1)    ;    ...si non, fermer et continuer
   Continue
  }
  IfMsgBox,Cancel            ;    ...si annuler, ne plus fermer
  {
   Finir=0
   Return
  }
 }
 Else                        ; Si le fichier n'a pas changé...
 {
  IfNotInString,fn,*         ;    ...et qu'il a un nom, fermer
   HE_CloseFile(hEdit,-1)
  Else                       ;    ...et qu'il n'a  pas de nom...
  {
   If HE_GetFileCount(hEdit)<>1   ; ...et qu'il ne s'agit pas du dernier onglet, fermer
    HE_CloseFile(hEdit,-1)
   Else,Return                    ; ...sinon, ne rien faire
  }
 }
}
GoSub,R7 ; MàJ barre titre
Return

FE: ;### Fermer tous les onglets
^+F4::
N:=HE_GetFileCount(hEdit)
GoSub,FTs
Return

FF: ;### Enregistrer
^S::
fn:=HE_GetFileName(hEdit,-1)
IfInString,fn,*
 GoTo,FG
IfExist %fn%       ; Si le fichier existe
{
 FileGetAttrib,atrb,%fn%     ; Récupérer ses attributs
 IfInString,atrb,R           ; S'il est en lecture seule, avertir qu'on ne peut le modifier
 {                           ; et offrir de l'enregistrer sous un autre nom
  MsgBox,52,%MA%,%MB%
  IfMsgBox,Yes
   GoTo,FG
  IfMsgBox,No
   Return
 }
 IfNotInString,atrb,R        ; S'il n'est pas en lecture seule...
 {
  IfInString,atrb,H          ; ...mais qu'il est caché...
  {
   FileSetAttrib,-H,%fn%     ;   ...enlever l'attribut
   HE_SaveFile(hEdit,fn,-1)  ;   ...enregsitrer
   FileSetAttrib,+H,%fn%     ;   ...remettre l'attribut
  }
  IfNotInString,atrb,H       ; ...et qu'il n'est pas caché, enregistrer normalement
  {
   HE_SaveFile(hEdit,fn,-1)
   SendMessage,0xB9,ModifyFlag,0,,ahk_id %hEdit%
  }
 }
}
Else               ; Si le fichier n'existe pas, aller à Enregistrer sous...
 GoTo,FG
Return

FG: ;### Enregistrer sous...
^F12::
FileSelectFile,fn,S16,,%WE%,%WB%
If (Errorlevel=1)
 Return
Else
{
 HE_SaveFile(hEdit,fn,-1)
 SendMessage,0xB9,ModifyFlag,0,,ahk_id %hEdit%
 GoSub,R7 ; MàJ barre titre
 GoSub,R8 ; MàJ historique
}
Return

FH: ;### Enregistrer tous les onglets
^+S::
Z:=HE_GetCurrentFile(hEdit)
N:=HE_GetFileCount(hEdit)    ; Compter le nb de fichiers ouverts
Loop,%N%                     ; Pour chaque fichier à enregistrer
{
 idx:=A_Index-1
 HE_SetCurrentFile(hEdit,idx)
 fn:=HE_GetFileName(hEdit,-1)
 IfExist,%fn%      ; Si le fichier existe
 {
  FileGetAttrib,atrb,%fn%    ; Récupérer ses attributs
  IfInString,atrb,R          ; S'il est en lecture seule, avertir qu'on ne peut le modifier
  {                          ; et offrir de l'enregistrer sous un autre nom
   MsgBox,52,%MA%,%MB%
   IfMsgBox,Yes
    GoSub,FG
   IfMsgBox,No
    Continue
  }
  Else                       ; S'il n'est pas en lecture seule...
  {
   IfInString,atrb,H         ; ...mais qu'il est caché...
   {
    FileSetAttrib,-H,%fn%    ;   ...enlever l'attribut
    HE_SaveFile(hEdit,fn,-1) ;   ...enregsitrer
    FileSetAttrib,+H,%fn%    ;   ...remettre l'attribut
   }
   Else                      ; ...et qu'il n'est pas caché, enregistrer normalement
   {
    HE_SaveFile(hEdit,fn,-1)
    SendMessage,0xB9,ModifyFlag,0,,ahk_id %hEdit%
   }
  }
 }
 Else,GoSub,FG               ; Si le fichier n'existe pas, aller à Enregistrer sous
}
HE_SetCurrentFile(hEdit,Z)   ; Revient à l'onglet initial
Return

FI: ;### Enregistrer la session en cours...
!^S::
N:=HE_GetFileCount(hEdit)    ; Compter nb fichiers ouverts
If N<2
 Return
fl=
Loop,%N%           ; Pour chaque fichier à inscrire
{
 idx:=A_Index-1
 fn:=HE_GetFileName(hEdit,idx)
 IfNotExist %fn%   ; Si n'existe pas, éditer onglet et aller à Enregistrer sous...
 {
  HE_SetCurrentFile(hEdit,idx)
  GoSub,FG
 }
 fl.=fn . "`r`n"   ; Si existe, ajouter à la liste
}
Gui,+OwnDialogs    ; Pour finir, enregistrer la liste
FileSelectFile,fn,S24,,%WF%,%WB%
If (fn="")
 Return
WinWaitActive,Vic
FileAppend,%fl%,%fn%
If (ErrorLevel=1)  ; Si erreur, avertir
 MsgBox,%MO% %fn%.
Else               ; Si réussite, confirmer
 MsgBox,%MP%
Return

FL: ;### Imprimer
^P::
T:=HE_GetCurrentFile(hEdit)
FileAppend,%T%,Vic_Temp.txt
If (ErrorLevel=0)
 Run,RUNDLL32.EXE MSHTML.DLL`,PrintHTML "Vic_Temp.txt"
Else
 MsgBox,48,Désolé. Impossible d'imprimer ce document.
Return

FM: ;### Historique 1
fn:=p37
GoSub,R9
Return

FN: ;### Historique 2
fn:=p38
GoSub,R9
Return

FO: ;### Historique 3
fn:=p39
GoSub,R9
Return

FP: ;### Historique 4
fn:=p40
GoSub,R9
Return

FQ: ;### Historique 5
fn:=p41
GoSub,R9
Return

FR: ;### Historique 6
fn:=p42
GoSub,R9
Return

FS: ;### Quitter
!F4::
GuiClose:
Finir=1
GoSub,FE
If Finir=0
 Return
WinGetPos,p5,p6,p7,p8
Loop,51  ; MàJ fichier INI
{
 Val:=p%A_Index%
 IniWrite,%Val%,Vic.ini,Options,p%A_Index%
}
ExitApp
Return

FT: ;### Convertir les fins de lignes au format Mac (CR)
CapsLock & M::
KeyWait,CapsLock
N:=HE_GetFileCount(hEdit)
idx:=HE_GetCurrentFile(hEdit)
If (N>1)
{
 MsgBox,51,%MV%,%MW%
 IfMsgBox,Cancel
  Return
 IfMsgBox,No
  N=1
 IfMsgBox,Yes
  idx=0
}
Critical
Loop,%N%
{
HE_SetCurrentFile(hEdit,idx)
T:=HE_GetTextRange(hEdit,0,-1)
T:=RegExReplace(T,"`r`n","`r",1)
T:=RegExReplace(T,"`n","`r",1)
HE_SetSel(hEdit,0,-1)
HE_ReplaceSel(hEdit,T)
SendMessage,0xB1,0,0,,ahk_id %hEdit%   ; Remettre le curseur au début
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer la sélection
idx++
}
Return

FU: ;### Convertir les fins de lignes au format Unix (LF)
CapsLock & X::
KeyWait,CapsLock
N:=HE_GetFileCount(hEdit)
idx:=HE_GetCurrentFile(hEdit)
If (N>1)
{
 MsgBox,51,%MV%,%MW%
 IfMsgBox,Cancel
  Return
 IfMsgBox,No
  N=1
 IfMsgBox,Yes
  idx=0
}
Critical
Loop,%N%
{
HE_SetCurrentFile(hEdit,idx)
T:=HE_GetTextRange(hEdit,0,-1)
T:=RegExReplace(T,"`r`n","`n",1)
T:=RegExReplace(T,"`r","`n",1)
HE_SetSel(hEdit,0,-1)
HE_ReplaceSel(hEdit,T)
SendMessage,0xB1,0,0,,ahk_id %hEdit%   ; Remettre le curseur au début
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer la sélection
idx++
}
Return

FV: ;### Convertir les fins de lignes au format Windows (CR+LF)
CapsLock & W::
KeyWait,CapsLock
N:=HE_GetFileCount(hEdit)
idx:=HE_GetCurrentFile(hEdit)
If (N>1)
{
 MsgBox,51,%MV%,%MW%
 IfMsgBox,Cancel
  Return
 IfMsgBox,No
  N=1
 IfMsgBox,Yes
  idx=0
}
Critical
Loop,%N%
{
HE_SetCurrentFile(hEdit,idx)
T:=HE_GetTextRange(hEdit,0,-1)
T:=RegExReplace(T,"`n","`r`n",1)
T:=RegExReplace(T,"`r`r`n","`r`n",1)
T:=RegExReplace(T,"`r","`r`n",1)
T:=RegExReplace(T,"`r`n`n","`r`n",1)
HE_SetSel(hEdit,0,-1)
HE_ReplaceSel(hEdit,T)
SendMessage,0xB1,0,0,,ahk_id %hEdit%   ; Remettre le curseur au début
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer la sélection
idx++
}
Return

FW: ;### Recharger le fichier courant
!^W::
HE_SaveFile(hEdit,fn,-1)
HE_GetSel(hEdit,Deb,Fin)
HE_ReloadFile(hEdit,-1)
SendMessage,0xB1,Deb,Deb,,ahk_id %hEdit%   ; ...et placer le curseur
Return

FX: ;### Afficher la liste des fichiers ouvert
!^Z::
HE_ShowFileList(hEdit,x=0,y=0)
GoTo,R7  ; MàJ de la barre de titre
Return

;### Edition

EA: ;### Annuler
^Z::
HE_Undo(hEdit)
Return

EB: ;### Rétablir
^Y::
HE_Redo(hEdit)
Return

EC: ;### Couper
SendMessage,0x300,0,0,,ahk_id %hEdit%
Return

ED: ;### Copier
^C::
Sel:=HE_GetSelText(hEdit)
If Sel
 Clipboard:=Sel
Else
 Clipboard:=HE_GetFileName(hEdit,-1)
Return

EE: ;### Coller
SendMessage,0x302,0,0,,ahk_id %hEdit%
Return

EF: ;### Supprimer
SendMessage,0x303,0,0,,ahk_id %hEdit%
Return

EG: ;### Atteindre...
^G::
Gui,4:Default
Gui,+Owner1
Gui,1:+Disabled
GoSub,R5           ; Position courante
Gui,%CA%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,W%X70%,%WI%   ; Ligne
Gui,Font,s%Xp%,%p3%
Gui,Add,Edit,vLC W%X70% Number,%NLC%
Gui,Add,Text,xp+%x70% yp+2,/%NLT%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,x+50 ym W%X70%,%WJ%     ; Colonne
Gui,Font,s%Xp%,%p3%
Gui,Add,Edit,vCC W%X70% Number,%NCC%
Gui,Add,Text,xp+%X70% yp+2 W%X58% vNCC,/%NCT%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Button,W%X100% xs y+%X24% Default,OK
Gui,Show,,%WH% 
SetTimer,NbCol,300
Return

NbCol:
GuiControlGet,Nbr,4:,LC ; Nº ligne
idx:=Nbr-1
NCT:=HE_LineLength(hEdit,idx)+1   ; Nb colonnes dans ligne
GuiControl,4:,NCC,/%NCT%
Return

4GuiClose:
4GuiEscape:
Gui,1:-Disabled
Gui,Destroy
SetTimer,NbCol,Off
Return

4ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
SetTimer,NbCol,Off
If (CC<1 || LC<1)
 Return
L:=HE_LineIndex(hEdit,LC-1)+CC-1
HE_SetSel(hEdit,L,L)
HE_ScrollCaret(hEdit)
Return

EH: ;### Rechercher...
^F::
IfWinExist, 
{
 WinActivate
 Return
}
Gui,7:Default
Gui,%CA% +AlwaysOnTop
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,,%WL%
Gui,Font,s%Xp%,%p3%
If (XR=1)
 Rech:=RegExReplace(Rech,"^P\)?","",1) ; Ôte P) ou P
Gui,Add,Edit,vRech HScroll -WantReturn WantCtrlA W%X590% R3,%Rech%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Checkbox,Checked%RC% vRC gRC y+%X12%,%WM%     ; Respecter la casse
Gui,Add,Checkbox,Checked%XR% vXR gXR xp+%X182%,%WN%   ; Expression rationnelle
Gui,Add,Checkbox,Checked%RP% vRP xp+%X210%,%WO%       ; Tous les fichiers
Gui,Add,Button,W%X100% xm y+16 vUP,WP                 ; Précédent
GuiControl,,UP,%WP%
Gui,Add,Button,W%X100% xp+%X110% Default vPRE,WQ      ; Suivant
GuiControl,,PRE,%WQ%
Gui,Show,AutoSize,%WK%
Return

RC:
GuiControlGet,ETAT,,Button1
If (ETAT=1)
 GuiControl,Disable,XR
Else
 GuiControl,Enable,XR
Return

XR:
GuiControlGet,ETAT,,Button2
If (ETAT=1)
 GuiControl,Disable,RC
Else
 GuiControl,Enable,RC
Return

7GuiClose:
7GuiEscape:
Gui,Submit
Gui,Destroy
If (XR=0)
 StringReplace,Rech,Rech,`n,`r`n,A
Else,Rech:=RegExReplace(Rech,"^([imsxADJUS]+(?=\)))?\)?(.+)","P$1)$2")
Return

EI: ;### Remplacer...
^H::
IfWinExist, 
{
 WinActivate
 Return
}
Gui,5:Default
Gui,%CA% +AlwaysOnTop
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,,%WL% ; Rechercher
Gui,Font,s%Xp%,%p3%
If (XR=1)
 Rech:=RegExReplace(Rech,"^P\)?","",1) ; Ôte P) ou P
Gui,Add,Edit,vRech W%X590% R3 HScroll -WantReturn WantCtrlA,%Rech%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,,%WS% ; Remplacer
Gui,Font,s%Xp%,%p3%
Gui,Add,Edit,vRepl W%X590% R3 HScroll -WantReturn WantCtrlA,%Repl%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Checkbox,Checked%RC% vRC gRC y+%X12%,%WM%     ; Respecter la casse
Gui,Add,Checkbox,Checked%XR% vXR gXR xp+%X182%,%WN%   ; Expression rationnelle
Gui,Add,Checkbox,Checked%RP% vRP xp+%X210%,%WO%       ; Dans tous les onglets
Gui,Add,Button,W%X100% xm y+16 vUP,WP                 ; Précédent
GuiControl,,UP,%WP%
Gui,Add,Button,W%X100% xp+%X110% Default vUQ,WQ  ; Suivant
GuiControl,,UQ,%WQ%
Gui,Add,Button,W%X100% xp+%X110% vSub,WT         ; Remplacer
GuiControl,,Sub,%WT%
Gui,Add,Button,W%X140% xp+%X110% vWA,WU          ; Remplacer tout
GuiControl,,WA,%WU%
Gui,Show,AutoSize,%WR%
Return

5GuiClose:
5GuiEscape:
Gui,Submit
Gui,Destroy
If (XR=0)
{
 StringReplace,Rech,Rech,`n,`r`n,A
 StringReplace,Repl,Repl,`n,`r`n,A
}
Else     ; Ajoute P) ou P pour mode position
{
 Rech:=RegExReplace(Rech,"^([imsxADJUS]+(?=\)))?\)?(.+)","P$1)$2")
 StringReplace,Repl,Repl,`n,`r`n,A
}
Return

5ButtonWU:    ; Remplacer tout
Gui,Submit
Gui,Destroy
Critical
StringReplace,Repl,Repl,`n,`r`n,1
If (XR=0)
 StringReplace,Rech,Rech,`n,`r`n,1
Rech_:=Rech   ; Met les valeurs initiales à l'abri
Repl_:=Repl
NCG=0    ; Compteur
If (RP=1)
 GoTo,RP
Sel=0    ; Sélection
T:=HE_GetSelText(hEdit)
If (Strlen(T)<1)   ; Étendre au contenu
 T:=HE_GetTextRange(hEdit,0,-1)
Else     ; Limiter à la sélection
 Sel=1
If (RC=1)
 StringCaseSense,On
If (XR=1) ; Si expression rationnelle = oui
{
 T:=RegExReplace(T,Rech,Repl,C)
 NCG+=C   ; Compter le nb de remplacements
}
Else      ; Si expression rationnelle = non
{
 StringReplace,T,T,%Rech%,%Repl%,UseErrorLevel
 NCG+=ErrorLevel   ; Compter le nb de remplacements
}
If (Sel=1)    ; Remplacer la sélection
 SendMessage,0xC2,,&T,,ahk_id %hEdit%
Else
{        ; Remplacer le contenu
 ControlGet,numerus,Hwnd,,HiEdit1,Vic
 ControlSetText,,%T%,ahk_id %numerus%
}
If (NCG>0)    ; Annoncer le nb de remplacements
 MsgBox,64,%WR%,%MK% %NCG% %ML%
If (XR=1)
 Rech_:=RegExReplace(Rech_,"^([imsxADJUS]+(?=\)))?\)?(.+)","P$1)$2")
Rech:=Rech_   ; Récupérer les valeurs initiales
Repl:=Repl_
Return

RP: ;### Remplacer tout dans tous les onglets
N:=HE_GetFileCount(hEdit)
Critical
Loop,%N% ; Faire le tour des onglets
{
 idx:=A_Index-1    ; Commencer à zéro (0)
 HE_SetCurrentFile(hEdit,idx)
 T:=HE_GetTextRange(hEdit,0,-1)
 If (RC=1)
  StringCaseSense,On
 If (XR=1)    ; Si expression rationnelle = oui
 {
  T:=RegExReplace(T,Rech,Repl,C)
  NCG+=C ; Compter nb remplacements
 }
 Else    ; Si expression rationnelle = non
 {
  StringReplace,T,T,%Rech%,%Repl%,UseErrorLevel
  NCG+=ErrorLevel  ; Compter nb remplacements
 }       ; Remplacer contenu
 ControlGet,numerus,Hwnd,,HiEdit1,Vic
 ControlSetText,,%T%,ahk_id %numerus%
}
If (NCG>0)    ; Annoncer nb remplacements
 MsgBox,64,%WR%,%MK% %NCG% %ML%
Return

;### Rechercher l'occurrence précédente
5ButtonWP:
7ButtonWP:
Gui,Submit,NoHide
If (XR=0)
 StringReplace,Rech,Rech,`n,`r`n,1
Else,Rech:=RegExReplace(Rech,"^([imsxADJUS]+(?=\)))?\)?(.+)","P$1)$2")
EJ:
F2::
t:=HE_GetTextRange(hEdit,0,-1)
GoSub,R5 ; Position courante
Critical
If (XR=1)     ; Expression rationnelle = Oui
{
 Sel:=HE_GetSelText(hEdit)
 If (StrLen(Sel)>0)     ; Incrémenter Pos si texte sélectionné
  Pos:=Pos+StrLen(Sel)-1
 StringTrimRight,t,t,StrLen(t)-Pos+1   ; Construire chaîne où chercher
 Position=1
 Loop
 {
  Position:=RegExMatch(t,Rech,LONG,Position)
  If (Position=0)
  {
   If (A_Index=1)
   {
    If (RP=1)      ; ...et que Dans tous les onglets est coché
    {
     If (HE_GetCurrentFile(hEdit)!=0)
     {
      HE_SetCurrentFile(hEdit,HE_GetCurrentFile(hEdit)-1)
      SendMessage,0xB1,0,-1,,ahk_id %hEdit%
      SendMessage,0xB1,-1,0,,ahk_id %hEdit%
      GoTo,EJ
     }
     Return        ; ...continuer depuis le début de l'onglet suivant
    }
    Break
   }
   Break
  }
  Match:=Position
  LNG:=LONG
  Position++
 }
 SendMessage,0xB1,Match+LNG-1,Match-1,,ahk_id %hEdit%
}
Else     ; Expression rationnelle = Non
{
 Pos:=StrLen(t)-Pos+1
 If (RC=1)
  StringCaseSense,On
 StringGetPos,p,t,%Rech%,R,%Pos%
 If (ErrorLevel)
 {
  If (RP=1)        ; ...et que Dans tous les onglets est coché
  {
   If (HE_GetCurrentFile(hEdit)!=0)
   {
    HE_SetCurrentFile(hEdit,HE_GetCurrentFile(hEdit)-1)
    SendMessage,0xB1,0,-1,,ahk_id %hEdit%
    SendMessage,0xB1,-1,0,,ahk_id %hEdit%
    GoTo,EJ
   }     ; ...continuer depuis le début de l'onglet suivant
   Return
  }
  Return
 }
 SendMessage,0xB1,p+StrLen(Rech),p,,ahk_id %hEdit%
}
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer sélection
SendMessage,0x0A,0,0,,ahk_id %hEdit%   ; Rafraîchir affichage
Return

;### Rechercher l'occurrence suivante
5ButtonWQ:
7ButtonWQ:
Gui,Submit,NoHide
If (XR=0)
 StringReplace,Rech,Rech,`n,`r`n,1
If (XR=1)     ; Ajouter P) ou P
 Rech:=RegExReplace(Rech,"^([imsxADJUS]+(?=\)))?\)?(.+)","P$1)$2")
EK:
F3::
t:=HE_GetTextRange(hEdit,0,-1)
GoSub,R5 ; Calculer la position courante
Critical
t:=HE_GetTextRange(hEdit,0,-1)
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)>0) ; Incrémenter Pos si du texte est sélectionné
 Pos++
If (XR=1)     ; Expression rationnelle = Oui
{
 P:=RegExMatch(t,Rech,LONG,Pos)
 If (P=0)     ; Si pas d'occurrence suivante...
 {
  If (RP=1)   ; ...et que Dans tous les onglets est coché
  {
   If (HE_GetCurrentFile(hEdit)<HE_GetFileCount(hEdit)-1)
   {
    HE_SetCurrentFile(hEdit,HE_GetCurrentFile(hEdit)+1)
    SendMessage,0xB1,0,0,,ahk_id %hEdit%
    GoTo,EK
   }     ; ...continuer au début de l'onglet suivant
   Return
  }
  Return
 }       ; Sélectionner
 SendMessage,0xB1,P-1,P+LONG-1,,ahk_id %hEdit%
}
Else     ; Expression rationnelle = Non
{
 P:=InStr(t,Rech,RC,Pos)     ; RC <=> Respecter la casse
 If (P=0)     ; Si pas d'occurrence suivante...
 {
  If (RP=1)        ; ...et que Dans tous les onglets est coché
  {
   If (HE_GetCurrentFile(hEdit)<HE_GetFileCount(hEdit)-1)
   {
    HE_SetCurrentFile(hEdit,HE_GetCurrentFile(hEdit)+1)
    SendMessage,0xB1,0,0,,ahk_id %hEdit%
    GoTo,EK
   }     ; ...continuer au début de l'onglet suivant
   Return
  }
  Return
 }       ; Sélectionner
 SendMessage,0xB1,P-1,P+StrLen(Rech)-1,,ahk_id %hEdit%
}
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer sélection
SendMessage,0x0A,0,0,,ahk_id %hEdit%   ; Rafraîchir affichage
Return

EL: ;### Substituer par le texte de remplacement
F4::
5ButtonWT:
StringReplace,Repl,Repl,`n,`r`n,1
StringReplace,Repl,Repl,`r`r`n,`r`n,1
Sel:=HE_GetSelText(hEdit)
If StrLen(Sel)<1
 Return
GoSub,R5 ; Calculer la position courante
If (RC=1)
 StringCaseSense,On
If (XR=0)
 StringReplace,T,Sel,%Rech%,%Repl%
Else,T:=RegExReplace(Sel,Rech,Repl)
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(T)-1,,ahk_id %hEdit%
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer sélection
Return

EM: ;### Sélectionner tout
SendMessage,0xB1,0,-1,,ahk_id %hEdit%
Return

EN: ;### Ajouter au presse-papiers
^Ins::
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
 Return
Clipboard:=Clipboard . Sel
Return

EO: ;### Vider le presse-papiers
^+Ins::
Clipboard=
Return

EP: ;### Trouver l'autre membre de la paire
^J::
Paires:="(){}[]"        ; Définit les paires
GoSub,R5                ; Calcule la position du curseur
T:=HE_GetTextRange(hEdit,0,-1)
StringMid,K,T,Pos,1     ; Si le caractère à droite du curseur n'est pas pairable, arrêter
IfNotInString,Paires,%K%
 Return
If (K="(" || K=")")     ; Définit le contenu des variables Ouvrant et Fermant
{
 Ouvrant:="("
 Fermant:=")"
}
If (K="{" || K="}")
{
 Ouvrant:="{"
 Fermant:="}"
}
If (K="[" || K="]")
{
 Ouvrant:="["
 Fermant:="]"
}
If (K=Ouvrant)          ; Si le caractère est Ouvrant
{
 Sens:="Avant"          ;    lire de gauche à droite...
 Depart:=Pos+1          ;    ...à partir du caractère suivant
 Meme:=Ouvrant
 Oppo:=Fermant
}
If (K=Fermant)          ; Sinon, faire tout le contraire
{
 Sens:="Arrière"
 Depart:=Pos-1
 Meme:=Fermant
 Oppo:=Ouvrant
}
i=1
Loop
{
 StringMid,K,T,Depart,1 ; Va au caractère suivant
 If (K="" || Depart<1)  ; S'il n'y en a plus...
 {
  MsgBox,48,%MA%,%MC%   ; ...avertir et sortir
  Break
 }
 If (K=Meme)            ; S'il est identique, ajouter 1
  i++
 If (K=Oppo)            ; S'il est opposé, retrancher 1
 {
  i--
  If (i=0)              ; Rendu à 0, on a trouvé
   Break
 }
 If (Sens="Avant")      ; Avancer ou reculer
  Depart++
 If (Sens="Arrière")
  Depart--
}                       ; À la fin, sélectionne et montre
SendMessage,0xB1,Depart-1,Depart,,ahk_id %hEdit%
SendMessage,0xB7,0,0,,ahk_id %hEdit%
Return

;### Affichage

AA: ;### Couleurs...
^E::
Gui,10:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Font,s%Xq%,Tahoma
Gui,Add,GroupBox,W450 H350,%WW%
Gui,Add,Text,xm+2 yp+28 W310 right,%WY%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp18 W%X94% x+6 yp-2 Limit8,%p18%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%WZ%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp19 W%X94% x+6 yp-2 Limit8,%p19%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YA%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp20 W%X94% x+6 yp-2 Limit8,%p20%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YB%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp21 W%X94% x+6 yp-2 Limit8,%p21%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YC%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp22 W%X94% x+6 yp-2 Limit8,%p22%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YD%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp23 W%X94% x+6 yp-2 Limit8,%p23%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YE%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp24 W%X94% x+6 yp-2 Limit8,%p24%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YF%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp25 W%X94% x+6 yp-2 Limit8,%p25%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xs+2 y+8 W310 right,%YG%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp26 W%X94% x+6 yp-2 Limit8,%p26%
Gui,Font,s%Xq%,Tahoma
Gui,Add,GroupBox,xm+466 ys W450 H350,%WX%
Gui,Add,Text,xp+3 yp+28 W310 right,%WY%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp27 W%X94% x+6 yp-2 Limit8,%p27%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%WZ%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp28 W%X94% x+6 yp-2 Limit8,%p28%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YA%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp29 W%X94% x+6 yp-2 Limit8,%p29%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YB%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp30 W%X94% x+6 yp-2 Limit8,%p30%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YC%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp31 W%X94% x+6 yp-2 Limit8,%p31%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YD%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp32 W%X94% x+6 yp-2 Limit8,%p32%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YE%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp33 W%X94% x+6 yp-2 Limit8,%p33%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YF%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp34 W%X94% x+6 yp-2 Limit8,%p34%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Text,xp-316 y+8 W310 right,%YG%
Gui,Font,s%Xq%,%p3%
Gui,Add,Edit,vp35 W%X94% x+6 yp-2 Limit8,%p35%
Gui,Font,s%Xq%,Tahoma
Gui,Add,Picture,xm+110,doc\img\Couleurs.png
Gui,Add,Text,W695 center,%YH%
Gui,Add,Button,xm W100 Default,OK
Gui,Show,AutoSize,%WV% 
Return

10GuiEscape:
10GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

10ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
If (p17=0)    ; 1e choix
 colors:="Text=" . p18 . ",Back=" . p19 . ",SelText=" . p20 . ",ActSelBack=" . p21 . ",InSelBack=" . p22 . ",LineNumber=" . p23 . ",SelBarBack=" . p24 . ",NonPrintableBack=" . p25 . ",Number=" . p26
If (p17=1)    ; 2e choix
 colors:="Text=" . p27 . ",Back=" . p28 . ",SelText=" . p29 . ",ActSelBack=" . p30 . ",InSelBack=" . p31 . ",LineNumber=" . p32 . ",SelBarBack=" . p33 . ",NonPrintableBack=" . p34 . ",Number=" . p35
HE_SetColors(hEdit,colors)
Return

AB: ;### Langue...
^L::
Gui,11:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Radio,vp43 y+14 Checked%p43%,%YI%
Gui,Add,Radio,vp44 x+%X20% ys Checked%p44%,%YJ%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Button,W%X100% Default xs y+%X20%,OK
Gui,Show,AutoSize,%YK% 
Return

11GuiEscape:
11GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

11ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
If (p43=1)    ; English
{
 FileMove,lng\Vic.lang,lng\Fr.lang
 FileMove,lng\En.lang,lng\Vic.lang
}
If (p44=1)    ; Français
{
 FileMove,lng\Vic.lang,lng\En.lang
 FileMove,lng\Fr.lang,lng\Vic.lang
}
MsgBox,,%YK%/%MQ%,%MM%`n`n%MR%
Return

AC: ;### Marge de sélection...
^M::
Gui,9:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,y+14,%YM%
Gui,Font,s%Xp%,%p3%
Gui,Add,Edit,vp14 Number W%X37% Limit2 ys-2,%p14%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Button,W%X100% Default xs y+%X20%,OK
Gui,Show,AutoSize,%YL% 
Return

9GuiEscape:
9GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

9ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
HE_LineNumbersBar(hEdit,p12,p13,p14)
Return

AD: ;### Police...
^D::
If Dlg_Font(fFace,fStyle,pColor,true,hwnd)
{
 HE_SetFont(hEdit,fStyle "," fFace)
 RegExMatch(fStyle,"\d{1,3}",p1)
 RegExMatch(fStyle,"^.+ ",p2)
 p2=%p2%
 p3:=fFace
}
Return

AE: ;### Tabulation...
^T::
Gui,8:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,y+14,%YO%       ; Largeur de tabulation
Gui,Font,s%Xp%,%p3%
Gui,Add,Edit,vp4 Number W%X37% Limit2 ys-2,%p4%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Button,W%X100% Default xs y+%X20%,OK
Gui,Show,AutoSize,%YN% 
Return

8GuiEscape:
8GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

8ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
HE_SetTabWidth(hEdit,p4)
Return

AF: ;### 2e jeu de couleurs
Menu,A,ToggleCheck,%AG%
p17:=!p17
If (p17=0)    ; 2e jeu = Non
{
 colors:="Text=" . p18 . ",Back=" . p19 . ",SelText=" . p20 . ",ActSelBack=" . p21 . ",InSelBack=" . p22 . ",LineNumber=" . p23 . ",SelBarBack=" . p24 . ",NonPrintableBack=" . p25 . ",Number=" . p26
 HE_SetKeywordFile(A_ScriptDir "\hes\Coloration1.hes")
}
If (p17=1)    ; 2e jeu = Oui
{
 colors:="Text=" . p27 . ",Back=" . p28 . ",SelText=" . p29 . ",ActSelBack=" . p30 . ",InSelBack=" . p31 . ",LineNumber=" . p32 . ",SelBarBack=" . p33 . ",NonPrintableBack=" . p34 . ",Number=" . p35
 HE_SetKeywordFile(A_ScriptDir "\hes\Coloration2.hes")
}
HE_SetColors(hEdit,colors)
SendMessage,0x0A,0,0,,ahk_id %hEdit%   ; Rafraîchir affichage
Return

AO: ;### Barre d'état
Menu,A,ToggleCheck,%AP%
p45:=!p45
If (p45=0)
{
 GuiControl,Hide,BE
 NH:=NH+MnBr    ; Barre d'état
}
If (p45=1)
{
 GuiControl,Show,BE
 NH:=NH-MnBr    ; Barre d'état
}
ControlMove,,,,,%NH%,ahk_id %hEdit%
Return

AG: ;### Chemin et nom de fichier
Menu,A,ToggleCheck,%AH%
p16:=!p16
GoSub,R7
Return

AH: ;### Coloration syntaxique
Menu,A,ToggleCheck,%AI%
If (p9="")
{
 p9=HILIGHT
 If (p17=1)
  HE_SetKeywordFile( A_ScriptDir "\hes\Coloration2.hes")
 If (p17=0)
  HE_SetKeywordFile(A_ScriptDir "\hes\Coloration1.hes")
}
Else
{
 p9=
 HE_SetKeywordFile( A_ScriptDir "\hes\.hes")
}
SendMessage,0x0A,0,0,,ahk_id %hEdit%   ; Rafraîchir affichage
Return

AI: ;### Indentation automatique
Menu,A,ToggleCheck,%AJ%
He_AutoIndent(hEdit,autoIndent:=!autoIndent)
Return

AJ: ;### Multi-onglets
Menu,A,ToggleCheck,%AK%
p10:=p10="" ? "TABBEDHRZSB":""
MsgBox,%MM%
Return

AK: ;### Numérotation des lignes
Menu,A,ToggleCheck,%AL%
p11:=!p11
p12:=p11=1 ? "automaxsize":"hide"
HE_LineNumbersBar(hEdit,p12,p13,p14)
Return

AL: ;### Augmenter la taille de police
^++::
~Ctrl & WheelUp::
p1++
fStyle:="s" . p1 . " " . p2
HE_SetFont(hEdit,fStyle "," fFace)
HE_SetTabWidth(hEdit,p4)    ; Sinon, la largeur de tabulation ne suit pas
Xp:=p1>14 ? 14:p1-2
Xq:=p1>13 ? 13:p1-2
If (dpi>1)
 Xq:=p1>11 ? 11:p1-2
Return

AM: ;### Diminuer la taille de police
^-::
~Ctrl & WheelDown::
p1--
fStyle:="s" . p1 . " " . p2
HE_SetFont(hEdit,fStyle "," fFace)
HE_SetTabWidth(hEdit,p4)    ; Sinon, la largeur de tabulation ne suit pas
Xp:=p1>14 ? 14:p1-2
Xq:=p1>13 ? 13:p1-2
If (dpi>1)
 Xq:=p1>11 ? 11:p1-2
Return

AN: ;### Taille de police normale
^0::
p1=11
fStyle:="s" . p1 . " " . p2
HE_SetFont(hEdit,fStyle "," fFace)
HE_SetTabWidth(hEdit,p4)    ; Sinon, la largeur de tabulation ne suit pas
Xp:=p1>14 ? 14:p1-2
Xq:=p1>13 ? 13:p1-2
If (dpi>1)
 Xq:=p1>11 ? 11:p1-2
Return

AP: ;### Longueur de ligne...
^W::
Gui,13:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Text,y+14,%ZH%
Gui,Font,s%Xp%,%p3%
Gui,Add,Edit,vLL Number Limit4 W%X54% ys,%LL%
Gui,Font,s%Xp%,Tahoma
Gui,Add,Button,W%X100% xs y+%X20% Default,OK
Gui,Show,AutoSize,%ZI% 
Return

13GuiEscape:
13GuiClose:
14GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

13ButtonOK:
Gui,Submit
Gui,Destroy
GoSub,R10
Critical
If (LL<>"0" && LL<"20")
{
 GoSub,FIN
 Gui,1:-Disabled
 Return
}
T:=HE_GetTextRange(hEdit,0,-1)
T:=RegExReplace(T,"(\S)\n","$1 ",1)
T:=RegExReplace(T," \n"," ",1)
SendMessage,0xB1,0,-1,,ahk_id %hEdit%
SendMessage,0xC2,,&T,,ahk_id %hEdit%
If (LL="0")
{
 GoSub,FIN
 Gui,1:-Disabled
 Return
}
RF=      ; Résultat final
L=1
Val:=LL
NLT:=HE_GetLineCount(hEdit)  ; Nb de lignes
Loop,%NLT%
{
 ControlGet,TLC,Line,%L%,HiEdit1,Vic
 If (StrLen(TLC)<Val)
  RF.=TLC
 Else
 {
	Ciseau:
	coupe:=LL-1
	Loop
	{
	 StringMid,CCC,TLC,coupe,1  ; Caractère courant
	 If CCC Not In ,,, ,!,$,`%,),.,/,:,;,>,?,],},…,»,*,#,-,+,=,&,@
		coupe--
	 Else
		Break
	 If (coupe<"20")
	  Break
	}
	StringLeft,CG,TLC,coupe
	RF.=CG . "`n"
	StringTrimLeft,TLC,TLC,coupe
	If (StrLen(TLC)<Val)
	 RF.=TLC
	Else
	 GoTo,Ciseau
 }
 L++
 If (L="NLT")
  Break
}
RF:=RegExReplace(RF,"([^ ])(`n) ","$1$2")
SendMessage,0xB1,0,-1,,ahk_id %hEdit%
SendMessage,0xC2,,&RF,,ahk_id %hEdit%
FIN:
Gui,1:-Disabled
Gui,Destroy
Return

AQ: ;### Augmenter la transparence
!#Up::
If (N="")
 N=255
N:=N<127 ? 255:N-64     ; En boucle : 255-191-127-63
WinSet,Transparent,%N%,- Vic ahk_class AutoHotkeyGUI
Return

AR: ;### Diminuer la transparence
!#Down::
If (N="")
 N=255
N:=N>191 ? 63:N+64      ; En boucle : 63-127-191-255
WinSet,Transparent,%N%,- Vic ahk_class AutoHotkeyGUI
Return

;### Insertion

JA: ;### Attribut class
Ins & C::
GoSub,R5
T:=" class="""""
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+7,Pos+7,,ahk_id %hEdit%
Return

JB: ;### Attribut id
Ins & I::
GoSub,R5
T:=" id="""""
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+4,Pos+4,,ahk_id %hEdit%
Return

JC: ;### Attribut lang
Ins & L::
GoSub,R5
T:=" lang="""" xml:lang="""""
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+6,Pos+6,,ahk_id %hEdit%
Return

JD: ;### Attribut name
Ins & N::
GoSub,R5
T:=" name="""""
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+6,Pos+6,,ahk_id %hEdit%
Return

JE: ;### Attribut style
Ins & S::
GoSub,R5
T:=" style="""""
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+7,Pos+7,,ahk_id %hEdit%
Return

JF: ;### Attribut title
Ins & T::
GoSub,R5
T:=" title="""""
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+7,Pos+7,,ahk_id %hEdit%
Return

JG: ;### Caractère spécial...
Ins & P::
Run,%A_WinDir%\System32\Charmap.exe
WinWait,ahk_class MyDlgClass
Control,ChooseString,Courier New,ComboBox3,ahk_class MyDlgClass
Control,Check,,Button3,ahk_class MyDlgClass
Send !j{home}{down 19}
Return

JH: ;### Commentaire conditionnel
Ins & E::
GoSub,R5
T=<!--[if IE 6]><![endif]-->
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Pos+13,Pos+13,,ahk_id %hEdit%
Return

JI: ;### Commentaire CSS
Ins & F::
GoSub,R5
Sel:=HE_GetSelText(hEdit)
T=/* %Sel% */
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Long:=StrLen(T)
If Sel
 SendMessage,0xB1,Pos+Long-1,Pos+Long-1,,ahk_id %hEdit%
Else
 SendMessage,0xB1,Pos+(Long/2)-1,Pos+(Long/2)-1,,ahk_id %hEdit%
Return

JJ: ;### Commentaire HTML
Ins & G::
GoSub,R5
Sel:=HE_GetSelText(hEdit)
T=<!-- %Sel% -->
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Long:=StrLen(T)
If Sel
 SendMessage,0xB1,Pos+Long-1,Pos+Long-1,,ahk_id %hEdit%
Else
 SendMessage,0xB1,Pos+(Long/2),Pos+(Long/2),,ahk_id %hEdit%
Return

JK: ;### Doctype HTML 4.01 Strict
Ins & 1::
T=<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"`r`n  "http://www.w3.org/TR/html4/strict.dtd">
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Return

JL: ;### Doctype HTML 4.01 Transitional
Ins & 2::
T=<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"`r`n  "http://www.w3.org/TR/html4/loose.dtd">
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Return

JM: ;### Doctype HTML 4.01 Frameset
Ins & 3::
T=<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"`r`n  "http://www.w3.org/TR/html4/frameset.dtd">
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Return

JN: ;### Doctype XHTML 1.0  Strict
Ins & 4::
T=<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"`r`n  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Return

JO: ;### Doctype XHTML 1.0 Transitional
Ins & 5::
T=<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"`r`n  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Return

JP: ;### Doctype XHTML 1.0 Frameset
Ins & 6::
T=<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"`r`n  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
SendMessage,0xC2,,&T,,ahk_id %hEdit%
Return

JQ: ;### Saut de ligne de type Unix
Ins & Enter::
Send {Asc 010}
Return

JR: ;### Squelette HTML 4.01
Ins & F4::
TAG=<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">`r`n<html>`r`n<head>`r`n`t<meta http-equiv="content-type" content="text/html; charset=windows-1252">`r`n`t<title></title>`r`n`t<meta http-equiv="content-style-type" content="text/css">`r`n</head>`r`n<body lang="">`r`n`r`n</body>`r`n</html>
SendMessage,0xC2,,&TAG,,ahk_id %hEdit%  ; Substituer TAG
P:=RegExMatch(TAG,"sm)""""|></|\R+$")   ; Trouver le prochain stop
SendMessage,0xB1,P,P,,ahk_id %hEdit%
Return

JS: ;### Squelette XHTML 1.0
Ins & F1::
TAG=<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">`r`n<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="" lang="">`r`n<head>`r`n`t<meta http-equiv="content-type" content="text/html; charset=windows-1252" />`r`n`t<title></title>`r`n`t<meta http-equiv="content-style-type" content="text/css" />`r`n</head>`r`n<body>`r`n`r`n</body>`r`n</html>
SendMessage,0xC2,,&TAG,,ahk_id %hEdit%  ; Substituer TAG
P:=RegExMatch(TAG,"sm)""""|></|\R+$")   ; Trouver le prochain stop
SendMessage,0xB1,P,P,,ahk_id %hEdit%
Return

JT: ;### Date
Ins & D::
FormatTime,date,YYYYMMDDHH24MISS,yyyy-MM-dd
SendMessage,0xC2,,&date,,ahk_id %hEdit%
Return

JU: ;### Heure
Ins & H::
If (p44=1)
 FormatTime,heure,YYYYMMDDHH24MISS,HH' h 'mm
Else
 FormatTime,heure,YYYYMMDDHH24MISS,HH':'mm
SendMessage,0xC2,,&heure,,ahk_id %hEdit%
Return

JV: ;### Commenter/Décommenter bloc
Ins & `;::
GoSub,R1                                         ; Sélectionner le rectangle
SendMessage,0xB1,Pos-NCC,Pos-NCC+StrLen(T),,ahk_id %hEdit%
Sel:=HE_GetSelText(hEdit)                        ; Capter la sélection
Test:=RegExReplace(Sel,"m)^([ \t`;]+).*","$1")   ; Capter le premier caractère noir
IfInString,Test,`;                                    ; Si commenté...
 T:=RegExReplace(Sel,"m)^([ \t]*)`; (.*)","$1$2")     ; ...décommenter
Else,T:=RegExReplace(Sel,"m)^([ \t]*)(.*)","$1`; $2") ; Sinon, commenter
SendMessage,0xC2,,&T,,ahk_id %hEdit%             ; Insèrer le résultat
SendMessage,0xB7,0,0,,ahk_id %hEdit%             ; Montrer la sélection
Return

;### Outils

TA: ;### Augmenter le retrait
Tab::
Sel:=HE_GetSelText(hEdit)
ControlGet,L,CurrentLine,,,ahk_id %hEdit%
ControlGet,C,CurrentCol,,,ahk_id %hEdit%
ControlGet,T,Line,%L%,,ahk_id %hEdit%
If (StrLen(Sel)>0) ; Si sélection, indenter
{
 Sel:=RegExReplace(Sel,"m)^(.*)","	$1")     ; Ajoute 1 Tab au début de chaque ligne
 SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
 GoSub,R5
 LONG:=StrLen(Sel)
 SendMessage,0xB1,Pos-1,Pos-LONG-1,,ahk_id %hEdit%
}
Else          ; Si rien n'est sélectionné
 GoSub,TTI    ; Touche Tab intelligente
Return

TB: ;### Diminuer le retrait
+Tab::
Sel:=HE_GetSelText(hEdit)
S:=StrLen(Sel)
If (S<1)
{
 GoSub,R5
 Sel:=HE_GetSelText(hEdit)
 ControlGet,L,CurrentLine,,,ahk_id %hEdit%
 ControlGet,C,CurrentCol,,,ahk_id %hEdit%
 ControlGet,T,Line,%L%,,ahk_id %hEdit%
 StringMid,GCH,T,C-1,1
 If (GCH=" " || GCH="	")     ; Si espace ou tab, supprimer
 {
  Send {BS}
  Return
 }
 Else
  Return
}
If (S>0)
{
 Sel:=RegExReplace(Sel,"m)^\s?(.+)","$1")      ; Ôte 1 espace ou tab au début de chaque ligne
 SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
 LONG:=StrLen(Sel)
 GoSub,R5
 SendMessage,0xB1,Pos-1,Pos-LONG-1,,ahk_id %hEdit%
}
Return

RAlt & Tab::
Send,{Tab}
Return

TC: ;### Mettre en bas de casse
^+B::
GoSub,R5  ; Position
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
 GoTo,M1  ; Message
StringLower,Sel,Sel
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TD: ;### Mettre en haut de casse
^+H::
GoSub,R5  ; Position
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
 GoTo,M1  ; Message
StringUpper,Sel,Sel
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TE: ;### Mettre l'initiale de chaque mot en majuscule
^+I::
GoSub,R5 ; Position
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
 GoTo,M1 ; Message
StringLower,Sel,Sel,T
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TF: ;### Formater le code CSS...
!^Y::
j:=HE_GetSelText(hEdit)
If (StrLen(j)<1)
 GoTo,M1  ; Message
j:=RegExReplace(j,"^\R+|\R+$|(\R)+","$1")        ; Réduit les lignes multiples à une
j:=RegExReplace(j,"m)^[ \t]+|[ \t]+$","")        ; Ôte les blancs en début et fin de ligne
j:=RegExReplace(j,"\s*([{:;,}])\s*","$1")        ; Ôte les blancs inutiles autour des séparateurs
StringReplace,j,j,:,:%A_Space%,1                 ; Ajoute une espace après un : sauf...
j:=RegExReplace(j,": (link|visited|hover|active|focus|//|before|after|lang|left|right|first)",":$1")
j:=RegExReplace(j,"([^;])}","$1;}")              ; Ajoute un ; devant une }
StringReplace,j,j,`;,`;`r`n,1                    ; Ajoute un saut de ligne après un ;
StringReplace,j,j,`;`r`n*,`;*,1                  ; Remet les commentaires CSS sur la bonne ligne
MsgBox,36,%ZJ%,%ZK% ; Abréger le code?
Sleep,100
IfMsgBox,No         ; Non
 GoTo,Disposer
IfMsgBox,Yes        ; Oui
{
m:="1",n:="1",R:="" ; Valeurs initiales
Loop,parse,j,{
{
 If (m=1)
 {
  m=0
  R=%R%%A_LoopField%{
  Continue
 }
 L:=A_LoopField
 Loop,parse,L,}
 {
  If (n=0)
  {
   n=1
   R=%R%`r`n%A_LoopField%{
   Continue
  }
  n=0
  A:=A_LoopField
  A:=RegExReplace(A,"m)([^;])$","$1;") ; Ajoute un ; en fin de ligne si absent
  Loop
  {
   B:=RegExReplace(A,"sm)^([^:]+): [^;]+;(.*)^\1: ([^;]+);","$2$1: $3;")
   If (B=%A%)
    Break
   A:=B
  }
  StringReplace,A,A,:,%A_Space%:,1
  Sort,A
  StringReplace,A,A,%A_Space%:,:,1
  R=%R%`r`n%A%}
 }
 m=0
}
StringTrimRight,j,R,1
j:=RegExReplace(j,"url\(""([^""]+)""\)","url($1)")         ; Ôte les guillemets autour des URL
j:=RegExReplace(j,"i)[ :]\K0+(?=[1-9])|\.0+(?=[a-z%])|\.\d+?\K0+(?!\d)","0")   ; Ôte les 0 inutiles
j:=RegExReplace(j,"i)[ :]\K0+(?:em|px|%|ex|in|pc|pt|cm|mm)","0")   ; Ôte les unités de mesure inutiles
j:=RegExReplace(j,"i)#([0-9a-f]{6})","#$L1")     ; Met les couleurs en bas de casse
j:=RegExReplace(j,"#([0-9a-f])\1([0-9a-f])\2([0-9a-f])\3","#$1$2$3") ; Réduit #rrvvbb à #rvb
Loop
{                  ; Groupe les sélecteurs aux blocs de déclarations identiques
 B:=RegExReplace(j,"ms)^([^{]+){([^}]+)}(.*)^([^{]+){\2}","$1,$4 {$2}$3")
 If (B=%j%)
  Break
 j:=B
}
j:=RegExReplace(j,"\s*/\*.+?\*/;",";") ; Ôte les commentaires sur 1 ligne
j:=RegExReplace(j,"(background)-\S+([^;]+);`r`n(?:\1-\S+([^;]+);`r`n)?(?:\1-\S+([^;]+);`r`n)?(?:\1-\S+([^;]+);`r`n)?\1-\S+([^;]+);","$1:$2$3$4$5$6;")
j:=RegExReplace(j,"m)^([^-]+)-after: ([^;]+);`r`n\1-before: ([^;]+);","$1: $3 $2;")
j:=RegExReplace(j,"sU)(font)-family: ([^;]+);`r`n\1-size: ([^;]+);([^}]*)`r`n(line-height: )([^;]+);","$1: $3/$6 $2;$4")
j:=RegExReplace(j,"(font)-family: ([^;]+);`r`n\1-size: ([^;]+);","$1: $3 $2;")
j:=RegExReplace(j,"sU)(font):([^;]+);([^}]*)`r`n\1-weight: ([^;]+);","$1: $4$2;$3")
j:=RegExReplace(j,"sU)(font):([^;]+);([^}]*)`r`n\1-variant: ([^;]+);","$1: $4$2;$3")
j:=RegExReplace(j,"sU)(font):([^;]+);([^}]*)`r`n\1-style: ([^;]+);","$1: $4$2;$3")
j:=RegExReplace(j,"(list-style)-\S+([^;]+);`r`n(?:\1-\S+([^;]+);`r`n)?\1-\S+([^;]+);","$1:$2$3$4;")
j:=RegExReplace(j,"m)^(.+)-color: (\S+);`r`n\1-style: (\S+);`r`n\1-width: (\S+);","$1: $4 $3 $2;")
j:=RegExReplace(j,"m)^(.+)-bottom: (\S+);`r`n\1-left: (\S+);`r`n\1-right: (\S+);`r`n\1-top: (\S+);","$1: $5 $4 $2 $3;")
j:=RegExReplace(j,": (\S+) \1 \1 \1`;",": $1`;")
j:=RegExReplace(j,": (\S+) (\S+) \1 \2`;",": $1 $2`;")
j:=RegExReplace(j,": (\S+) (\S+) (\S+) \2`;",": $1 $2 $3`;")
}
Disposer:          ; Disposition compacte?
MsgBox,36,%ZJ%,%ZL%
Sleep,200
IfMsgBox,Yes       ; Oui
{
 j:=RegExReplace(j,"sU)/\*.+\*/","`r`n")         ; Ôte tout commentaire CSS
 j:=RegExReplace(j,"^\s+|\s+$","")               ; Ôte les blancs de début et de fin de ligne
 j:=RegExReplace(j,"\s*([{:;,}])\s*","$1")       ; Ôte les blancs autour des séparateurs
 StringReplace,j,j,`;},}`r`n,1                   ; Ôte les ; devant une }
 StringReplace,j,j,{,%A_Space%{,1                ; Met 1 espace devant une {
}
IfMsgBox,No        ; Non
{
 j:=RegExReplace(j,"\s*{\s*"," {`r`n`t")         ; Met 1 espace devant une { et 1 ligne + 1 tab après
 StringReplace,j,j,`;`r`n,`;`r`n%A_Tab%,1        ; Met 1 tab devant chaque déclaration...
 StringReplace,j,j,*/`r`n,*/`r`n%A_Tab%,1        ; ...même lorsque précédée d'un commentaire
 StringReplace,j,j,`,,`,%A_Space%,1              ; Met 1 espace après une ,
 StringReplace,j,j,`;`r`n`t/*,; /*,1             ; Met les commentaires courts sur leur ligne
 j:=RegExReplace(j,"\s*}\s*","`r`n}`r`n`r`n")    ; Met 1 saut de ligne devant une } et 2 après
}
SendMessage,0xC2,,&j,,ahk_id %hEdit%
ControlFocus,,ahk_id %hEdit%
Return

TG: ;### Déplacer vers le bas
^+Down::
GoSub,R1           ; Calcule le rectangle
If (StrLen(Sel)<1) ; Détermine la valeur
 i:=NLC+1          ; de la ligne suivante
Else               ; selon qu'il y a ou qu'il
 i:=j              ; n'y a pas de sélection
ControlGet,TLS,Line,%i%,,ahk_id %hEdit%  ; Stocke le texte de la ligne subséquente dans TLS
SendMessage,0xB1,Pos-NCC,Pos-NCC+StrLen(T)+StrLen(TLS),,ahk_id %hEdit%
T:=TLS . T                               ; Construit la chaîne
SendMessage,0xC2,,&T,,ahk_id %hEdit%     ; Insère le texte
SendMessage,0xB1,Pos-NCC+StrLen(TLS),Pos-NCC+StrLen(T),,ahk_id %hEdit%
Return                                   ; Positionne le curseur

TH: ;### Déplacer vers le haut
^+Up::
GoSub,R1                                 ; Calcule le rectangle
i:=NLC-1
ControlGet,TLP,Line,%i%,,ahk_id %hEdit%  ; Capte le texte de la ligne précédente
SendMessage,0xB1,Pos-NCC-StrLen(TLP),Pos-NCC+StrLen(T),,ahk_id %hEdit%
T:=T . TLP                               ; Construit la chaîne
SendMessage,0xC2,,&T,,ahk_id %hEdit%     ; Insère le texte
SendMessage,0xB1,Pos-NCC-StrLen(TLP),Pos-NCC+StrLen(T)-StrLen(TLP)-StrLen(TLP),,ahk_id %hEdit%
Return                                   ; Positionne le curseur

TI: ;### Dupliquer la sélection
^+L::
GoSub,R1                                 ; Calcule le rectangle
SendMessage,0xB1,Pos-NCC,Pos-NCC+StrLen(T),,ahk_id %hEdit%      ; Sélectionne le rectangle
T.=T                                     ; Double le texte
SendMessage,0xC2,,&T,,ahk_id %hEdit%     ; Insére le doublon
SendMessage,0xB1,Pos-NCC,Pos-NCC,,ahk_id %hEdit% ; Positionne le curseur
Return

TJ: ;### Prélever une couleur...
^+P::
SetTimer,Voir,100
Hotkey,$Enter,Noter,On
Hotkey,Esc,Sortir,On
Return

Voir:
MouseGetPos,X,Y
PixelGetColor,RVB,%X%,%Y%,RGB
RVB:=RegExReplace(RVB,"0x","#")
StringLower,RVB,RVB
ToolTip,%RVB%`nX=%X%`nY=%Y%
Return

Noter:
Clipboard:=RVB
Sortir:
SetTimer,Voir,Off
Hotkey,$Enter,Off
Hotkey,Esc,Off
ToolTip
Return

TK: ;### Remplacements automatiques...
^+R::
Gui,15:Default
Gui,+Owner1 +Resize
Gui,1:+Disabled
Gui,Font,s%Xq%,Tahoma
Gui,Add,CheckBox,vp46 gCCol Checked%p46% xm-6,%ZM%
Gui,Add,CheckBox,vp47 gLFV checked%p47% xm+255 yp,%Z3%
Gui,Font,s%Xq%,%p3%
Gui,Add,ListView,vLst gListe xm-6 y+10 w690 h280 grid sort,%ZN%
FileRead,Remplace,inc\Remplace.txt     ; `n pour supporter format Unix et (?!=::) pour supporter : dans Abréviation
Remplace:=RegExReplace(Remplace,"`nm)^:{1,2}([^:]*):(.+)(?!=::)::(.+)","$1	$2	$3")
StringReplace,Remplace,Remplace,````,``,A
Loop,Parse,Remplace,`n,`r
{
 Stringsplit,RA,A_LoopField,%A_Tab%
 LV_Add("",RA1,RA2,RA3)      ; Options | Abréviation | Texte de remplacement
}
Gui,Font,s%Xq%,Tahoma
If (p46=1)
 LV_ModifyCol(1,"AutoHdr")   ; Afficher
Else
 LV_ModifyCol(1,0)           ; Masquer
LV_ModifyCol(2,"Sort")       ; Classe en ordre croissant
LV_ModifyCol(3,"Auto")       ; Ajuste la largeur
Gui,Add,Button,vAjt gAjouter xm-6 ym+264 w%X100% Default,%ZO%     ; Ajouter
 GuiControl,,Ajt,%ZO%
Gui,Add,Button,vMdf gModifier w%X100% xp+%X110%,%ZP%              ; Modifier
 GuiControl,,Mdf,%ZP%
Gui,Add,Button,vSup gSupprimer w%X100% xp+%X110%,%ZQ%             ; Supprimer
 GuiControl,,Sup,%ZQ%
Gui,Add,Button,vOK w100 xm+475 ym+264,OK   ; OK
 GuiControl,,OK,&OK
Gui,Add,Button,vAnn w100 xp+110,%ZR%       ; Annuler
 GuiControl,,Ann,%ZR%
Gui,Show,x%p48% y%p49% w%p50% h%p51%,%ZS%
Return

CCol:
ControlGet,p46,Checked
If (p46=1)
 LV_ModifyCol(1,"AutoHdr")
Else
 LV_ModifyCol(1,0)
Return

Ajouter:
RB2:="",RB3:=""
Editer:
Gui,16:Default
Gui,+Owner15
Gui,15:+Disabled
Gui,1:+Disabled
Gui,Font,s%Xq%
Gui,Add,Tab,w420 h236,%Z6%
Gui,Add,Text,,%ZT%
Gui,Font,s%Xq%,%p1%
Gui,Add,Edit,w390 vAbbr -WantReturn WantCtrlA Multi R1 Limit40,%RB2%
Gui,Font,s%Xq%
Gui,Add,Text,yp+32,%ZU%
Gui,Font,s%Xq%,%p1%
Gui,Add,Edit,w390 h100 vTRpl HScroll -WantReturn WantCtrlA,%RB3%
Gui,Tab,2
Gui,Font,s%Xq%
Gui,Add,CheckBox,vOptA gOptnA x+12 y+16,%ZW%
Gui,Add,CheckBox,vOptI yp+26,%ZX%
Gui,Add,CheckBox,vOptB yp+26,%ZY%
Gui,Add,CheckBox,vOptC yp+26 gOptnC,%ZZ%
Gui,Add,CheckBox,vOpt1 yp+26 gOptn1,%Z0%
Gui,Add,CheckBox,vOptO yp+26 gOptnO,%Z1%
Gui,Add,CheckBox,vOptR yp+26,%Z2%
Gui,Tab
Gui,Add,Button,xm yp+46 r1 w110 default,&OK
Gui,Add,Button,xp+120 r1 w110,%ZR%   ; Annuler
Gui,Show,AutoSize,%Z4%
Return

16ButtonOK:
Gui,15:-Disabled
Gui,Submit
Gui,Destroy
OptA:=OptA=1 ? "*":""
OptI:=OptI=1 ? "?":""
OptB:=OptB=1 ? "B0":""
OptC:=OptC=1 ? "C":""
Opt1:=Opt1=1 ? "C1":""
OptO:=OptO=1 ? "O":""
OptR:=OptR=1 ? "R":""
Optn:=OptA . OptI . OptB . OptC . Opt1 . OptO . OptR
If (Abbr="" || TRpl="")
{
 MsgBox 48,%MA%,%MX%         ; Message d'erreur lorsqu'un champ est vide
 Return
}
Else
{
 StringReplace,TRpl,TRpl,``,````,A     ; Supporte espace, tabulation point-virgule et saut de ligne
 TRpl:=RegExReplace(TRpl,"m)(\s)$","$1``")
 StringReplace,Abbr,Abbr,``,````,A
 StringReplace,Abbr,Abbr,%A_Tab%,``t,A
 StringReplace,Abbr,Abbr,`n,,A         ; Ôte saut de ligne ds abréviation
 StringReplace,TRpl,TRpl,%A_Tab%,``t,A
 StringReplace,TRpl,TRpl,`n,``r,A
 StringReplace,TRpl,TRpl,`;,```;,A
 FileAppend,`r`n`:%Optn%`:%Abbr%`::%TRpl%,inc\Remplace.txt
}
Gui,1:-Disabled
WinActivate,%ZS%
Gui,15:Destroy
GoSub,TK
Return

OptnA:
GuiControlGet,ETAT,16:,Button1  ; Empêche de choisir en même temps * et O
If (ETAT=1)
 GuiControl,Disable,OptO
Else
 GuiControl,Enable,OptO
Return

OptnO:
GuiControlGet,ETAT,16:,Button6
If (ETAT=1)
 GuiControl,Disable,OptA
Else
 GuiControl,Enable,OptA
Return

OptnC:
GuiControlGet,ETAT,16:,Button4  ; Empêche de choisir en même temps C et C1
If (ETAT=1)
 GuiControl,Disable,Opt1
Else
 GuiControl,Enable,Opt1
Return

Optn1:
GuiControlGet,ETAT,16:,Button5
If (ETAT=1)
 GuiControl,Disable,OptC
Else
 GuiControl,Enable,OptC
Return

Liste:
If (A_GuiEvent=DoubleClick)  ; Offre de modifier la ligne double-cliquée
 GoSub,Modifier
Return

Modifier:
LnSel:=LV_GetNext(0,"F")     ; Capte le nº de la ligne sélectionnée
If (LnSel=0)
{
 MsgBox 48,%MA%,%MN%         ; Message d'erreur si rien n'est sélectionné
 Return
}                            ; Capte le texte de la ligne sélectionnée
ControlGet,Ligne,List,Focused,SysListView321,Remplacements automatiques
StringSplit,RB,Ligne,%A_Tab%
GoSub,Appliquer              ; Retire la ligne de la liste
StringReplace,RB3,RB3,``r,`r`n,A
StringReplace,RB3,RB3,``r,`n,A         ; Échapper espaces, tabulations...
StringReplace,RB3,RB3,``t,%A_Tab%,A    ; points-virgules et sauts de lignes
StringReplace,RB3,RB3,```;,`;,A
GoSub,Editer
StringReplace,RB1,RB1,C1,1   ; Pour distinguer l'option C1 de l'option C
IfInString,RB1,*
{
 GuiControl,,OptA,1
 GuiControl,Disable,OptO
}
IfInString,RB1,?
 GuiControl,,OptI,1
IfInString,RB1,B
 GuiControl,,OptB,1
IfInString,RB1,C
{
 GuiControl,,OptC,1
 GuiControl,Disable,Opt1
}
IfInString,RB1,1
{
 GuiControl,,Opt1,1
 GuiControl,Disable,OptC
}
IfInString,RB1,O
{
 GuiControl,,OptO,1
 GuiControl,Disable,OptA
}
IfInString,RB1,R
 GuiControl,,OptR,1
WinWaitActive,%Z4%
 WinSetTitle,%Z5%       ; Changer le titre de la fenêtre
Return

Supprimer:
LnSel:=LV_GetNext(0,"F")
If (LnSel=0)
{
 MsgBox 48,%MA%,%MN%    ; Message d'erreur si rien n'est sélectionné
 Return
}
MsgBox,4,Info,%MY%      ; Demande une confirmation avant de supprimer
IfMsgBox No
 Return
IfMsgBox Yes
{
 GuiControl,,Abbr,
 GuiControl,,TRpl,
 GoSub,Appliquer
}
Return

Appliquer:
LV_Modify(LnSel,"-focus")    ; Désélectionne
Loop
{
 L:=LV_GetNext(L-1)
 If not L
  Break
 LV_Delete(L)
}
ControlGet,Liste,List,,sysListView321,%ZS%       ; `n pour supporter les sauts de ligne Unix
Liste:=RegExReplace(Liste,"`nm)^([^	]*)	([^	]+)	?(.*)",":$1:$2::$3")
FileDelete,inc\Remplace.txt
FileAppend,%Liste%,inc\Remplace.txt
Return

16GuiEscape:
16GuiClose:
16ButtonAnnuler:
16ButtonCancel:
If (RB2<>"" || RB3<>"")      ; Si la modification n'a pas lieu, rajouter la ligne ôtée
{
 Ligne:=RegExReplace(Ligne,"`nm)^([^	]*)	([^	]+)	?(.*)",":$1:$2::$3")
 FileAppend,`r`n%Ligne%,inc\Remplace.txt
}
Gui,15:-Disabled
Gui,1:-Disabled
Gui,1:Default
WinActivate,%ZS%
Gui,15:Destroy
GoSub,TK
Return

15ButtonOK:
Gui,1:-Disabled
Gui,Destroy
LFV:     ; Limiter à la fenêtre Vic
ControlGet,p47,Checked,,Button2
IniWrite,%p47%,Vic.ini,Options,p47
Msgbox,324,,%MZ%
IfMsgBox,Yes
 Reload
IfMsgBox,No
 Return
Return

15GuiSize:
If (A_EventInfo=1)
 Return
GuiControl,Move,Lst,% "W" . (A_GuiWidth-14) . " H" . (A_GuiHeight-90)
GuiControl,Move,Ajt,% "Y" . (A_GuiHeight-38)
GuiControl,Move,MdF,% "Y" . (A_GuiHeight-38)
GuiControl,Move,Sup,% "Y" . (A_GuiHeight-38)
GuiControl,Move,OK ,% "Y" . (A_GuiHeight-38) . " X" . (A_GuiWidth-218)
GuiControl,Move,Ann,% "Y" . (A_GuiHeight-38) . " X" . (A_GuiWidth-108)
WinGetPos,p48,p49,p50,p51,%ZS%
SysGet,Cptn2,4
SysGet,Brdr2,33
p50-=Brdr2+Brdr2
p51-=Brdr2+Cptn2+Brdr2
x=48
Loop,4
{
 Val:=p%x%
 IniWrite,%Val%,Vic.ini,Options,p%x%
 x++
}
Return

15GuiClose:
15GuiEscape:
15ButtonAnnuler:
15ButtonCancel:
Gui,1:-Disabled
Gui,Destroy
Return

TL: ;### Remplacer les espaces initiales par des tabulations
^+A::
GoSub,R5
ControlGet,Sel,Selected,,,ahk_id %hEdit%
If (StrLen(Sel)<1)
 GoTo,M1
Loop
{
 Sel2:=RegExReplace(Sel,"m)^(	*) ","$1	",A)
 If (Sel2=Sel)
  Break
 Sel:=Sel2
}
SendMessage,0xC2,,&Sel2,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TM: ;### Remplacer les tabulations initiales par des espaces
^+E::
GoSub,R5
ControlGet,Sel,Selected,,,ahk_id %hEdit%
If (StrLen(Sel)<1)
 GoTo,M1
Loop
{
 Sel2:=RegExReplace(Sel,"m)^( *)	","$1 ",A)
 If (Sel2=Sel)
  Break
 Sel:=Sel2
}
SendMessage,0xC2,,&Sel2,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TN: ;### Supprimer les blancs de fin de ligne
^+F::
GoSub,R5
ControlGet,Sel,Selected,,,ahk_id %hEdit%
If (StrLen(Sel)<1)
 GoTo,M1
Sel:=RegExReplace(Sel,"m)\s+$","")
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TO: ;### Supprimer les lignes vides
^+K::
GoSub,R5
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
 GoTo,M1
Sel:=RegExReplace(Sel,"^\R+|\R+$|(\R){2,}","$1")
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TP: ;### Supprimer le HTML
^+M::
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
 GoTo,M1           ; Supprime tout commentaire et zone de script ou noscript
Sel:=RegExReplace(Sel,"si)<(!)?((?:no)?script|style|--).+?(?(1)-->|</\2>)","")
Sel:=RegExReplace(Sel,"s)<[^>]+>","")
Sel:=RegExReplace(Sel,"^\s+|\s+$","")
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
Return

;### TQ, TR, TS sont libres

TU: ;### Restituer le faux UTF-8 en ANSI
!^U::
StringCaseSense,On
N:=HE_GetFileCount(hEdit)
idx:=HE_GetCurrentFile(hEdit)
If (N>1)
{
 MsgBox,51,%MT%,%MU%
 IfMsgBox,Cancel
  Return
 IfMsgBox,No
  N=1
 IfMsgBox,Yes
  idx=0
}
Critical
Loop,%N%
{
HE_SetCurrentFile(hEdit,idx)
T:=HE_GetTextRange(hEdit,0,-1)
StringReplace,T,T,â`‚¬,€,1
StringReplace,T,T,â€š,‚,1
StringReplace,T,T,Æ’,ƒ,1
StringReplace,T,T,â€ž,„,1
StringReplace,T,T,â€¦,…,1
StringReplace,T,T,â€ ,†,1
StringReplace,T,T,â€¡,‡,1
StringReplace,T,T,Ë†,ˆ,1
StringReplace,T,T,Å ,Š,1
StringReplace,T,T,â€°,‰,1
StringReplace,T,T,â€¹,‹,1
StringReplace,T,T,Å’,Œ,1
StringReplace,T,T,Å½,Ž,1
StringReplace,T,T,â€˜,‘,1
StringReplace,T,T,â€™,’,1
StringReplace,T,T,â€œ,“,1
StringReplace,T,T,â€,”,1
StringReplace,T,T,â€¢,•,1
StringReplace,T,T,â€“,–,1
StringReplace,T,T,â€”,—,1
StringReplace,T,T,Ëœ,˜,1
StringReplace,T,T,â„¢,™,1
StringReplace,T,T,Å¡,š,1
StringReplace,T,T,â€º,›,1
StringReplace,T,T,Å“,œ,1
StringReplace,T,T,Å¾,ž,1
StringReplace,T,T,Å¸,Ÿ,1
StringReplace,T,T,Â , ,1
StringReplace,T,T,Â¡,¡,1
StringReplace,T,T,Â¢,¢,1
StringReplace,T,T,Â£,£,1
StringReplace,T,T,Â¤,¤,1
StringReplace,T,T,Â¥,¥,1
StringReplace,T,T,Â¦,¦,1
StringReplace,T,T,Â§,§,1
StringReplace,T,T,Â¨,¨,1
StringReplace,T,T,Â©,©,1
StringReplace,T,T,Âª,ª,1
StringReplace,T,T,Â«,«,1
StringReplace,T,T,Â¬,¬,1
StringReplace,T,T,Â­,­,1
StringReplace,T,T,Â®,®,1
StringReplace,T,T,Â¯,¯,1
StringReplace,T,T,Â°,°,1
StringReplace,T,T,Â±,±,1
StringReplace,T,T,Â²,²,1
StringReplace,T,T,Â³,³,1
StringReplace,T,T,Â´,´,1
StringReplace,T,T,Âµ,µ,1
StringReplace,T,T,Â¶,¶,1
StringReplace,T,T,Â·,·,1
StringReplace,T,T,Â¸,¸,1
StringReplace,T,T,Â¹,¹,1
StringReplace,T,T,Âº,º,1
StringReplace,T,T,Â»,»,1
StringReplace,T,T,Â¼,¼,1
StringReplace,T,T,Â½,½,1
StringReplace,T,T,Â¾,¾,1
StringReplace,T,T,Â¿,¿,1
StringReplace,T,T,Ã€,À,1
StringReplace,T,T,Ã,Á,1
StringReplace,T,T,Ã`‚,Â,1
StringReplace,T,T,Ãƒ,Ã,1
StringReplace,T,T,Ã„,Ä,1
StringReplace,T,T,Ã…,Å,1
StringReplace,T,T,Ã†,Æ,1
StringReplace,T,T,Ã‡,Ç,1
StringReplace,T,T,Ãˆ,È,1
StringReplace,T,T,Ã‰,É,1
StringReplace,T,T,ÃŠ,Ê,1
StringReplace,T,T,Ã‹,Ë,1
StringReplace,T,T,ÃŒ,Ì,1
StringReplace,T,T,Ã,Í,1
StringReplace,T,T,ÃŽ,Î,1
StringReplace,T,T,Ã,Ï,1
StringReplace,T,T,Ã,Ð,1
StringReplace,T,T,Ã‘,Ñ,1
StringReplace,T,T,Ã’,Ò,1
StringReplace,T,T,Ã“,Ó,1
StringReplace,T,T,Ã”,Ô,1
StringReplace,T,T,Ã•,Õ,1
StringReplace,T,T,Ã–,Ö,1
StringReplace,T,T,Ã—,×,1
StringReplace,T,T,Ã˜,Ø,1
StringReplace,T,T,Ã™,Ù,1
StringReplace,T,T,Ãš,Ú,1
StringReplace,T,T,Ã›,Û,1
StringReplace,T,T,Ãœ,Ü,1
StringReplace,T,T,Ã,Ý,1
StringReplace,T,T,Ãž,Þ,1
StringReplace,T,T,ÃŸ,ß,1
StringReplace,T,T,Ã ,à,1
StringReplace,T,T,Ã¡,á,1
StringReplace,T,T,Ã¢,â,1
StringReplace,T,T,Ã£,ã,1
StringReplace,T,T,Ã¤,ä,1
StringReplace,T,T,Ã¥,å,1
StringReplace,T,T,Ã¦,æ,1
StringReplace,T,T,Ã§,ç,1
StringReplace,T,T,Ã¨,è,1
StringReplace,T,T,Ã©,é,1
StringReplace,T,T,Ãª,ê,1
StringReplace,T,T,Ã«,ë,1
StringReplace,T,T,Ã¬,ì,1
StringReplace,T,T,Ã­,í,1
StringReplace,T,T,Ã®,î,1
StringReplace,T,T,Ã¯,ï,1
StringReplace,T,T,Ã°,ð,1
StringReplace,T,T,Ã±,ñ,1
StringReplace,T,T,Ã²,ò,1
StringReplace,T,T,Ã³,ó,1
StringReplace,T,T,Ã´,ô,1
StringReplace,T,T,Ãµ,õ,1
StringReplace,T,T,Ã¶,ö,1
StringReplace,T,T,Ã·,÷,1
StringReplace,T,T,Ã¸,ø,1
StringReplace,T,T,Ã¹,ù,1
StringReplace,T,T,Ãº,ú,1
StringReplace,T,T,Ã»,û,1
StringReplace,T,T,Ã¼,ü,1
StringReplace,T,T,Ã½,ý,1
StringReplace,T,T,Ã¾,þ,1
StringReplace,T,T,Ã¿,ÿ,1
StringReplace,T,T,charset=utf-8,charset=windows-1252
StringReplace,T,T,&Aacute`;,Á,1
StringReplace,T,T,&aacute`;,á,1
StringReplace,T,T,&Acirc`;,Â,1
StringReplace,T,T,&acirc`;,â,1
StringReplace,T,T,&acute`;,´,1
StringReplace,T,T,&AElig`;,Æ,1
StringReplace,T,T,&aelig`;,æ,1
StringReplace,T,T,&agrave`;,à,1
StringReplace,T,T,&Agrave`;,À,1
StringReplace,T,T,&amp`;,&,1
StringReplace,T,T,&aring`;,å,1
StringReplace,T,T,&Aring`;,Å,1
StringReplace,T,T,&Atilde`;,Ã,1
StringReplace,T,T,&atilde`;,ã,1
StringReplace,T,T,&auml`;,ä,1
StringReplace,T,T,&Auml`;,Ä,1
StringReplace,T,T,&bdquo`;,„,1
StringReplace,T,T,&brvbar`;,¦,1
StringReplace,T,T,&ccedil`;,ç,1
StringReplace,T,T,&Ccedil`;,Ç,1
StringReplace,T,T,&cedil`;,¸,1
StringReplace,T,T,&cent`;,¢,1
StringReplace,T,T,&circ`;,ˆ,1
StringReplace,T,T,&copy`;,©,1
StringReplace,T,T,&curren`;,¤,1
StringReplace,T,T,&dagger`;,†,1
StringReplace,T,T,&Dagger`;,‡,1
StringReplace,T,T,&deg`;,°,1
StringReplace,T,T,&divide`;,÷,1
StringReplace,T,T,&eacute`;,é,1
StringReplace,T,T,&Eacute`;,É,1
StringReplace,T,T,&Ecirc`;,Ê,1
StringReplace,T,T,&ecirc`;,ê,1
StringReplace,T,T,&Egrave`;,È,1
StringReplace,T,T,&egrave`;,è,1
StringReplace,T,T,&emsp`;,,1      ; Ne fait rien
StringReplace,T,T,&ensp`;,,1      ; Ne fait rien
StringReplace,T,T,&ETH`;,Ð,1
StringReplace,T,T,&eth`;,ð,1
StringReplace,T,T,&euml`;,ë,1
StringReplace,T,T,&Euml`;,Ë,1
StringReplace,T,T,&euro`;,€,1
StringReplace,T,T,&frac12`;,½,1
StringReplace,T,T,&frac14`;,¼,1
StringReplace,T,T,&frac34`;,¾,1
StringReplace,T,T,&gt`;,>,1
StringReplace,T,T,&Iacute`;,Í,1
StringReplace,T,T,&iacute`;,í,1
StringReplace,T,T,&Icirc`;,Î,1
StringReplace,T,T,&icirc`;,î,1
StringReplace,T,T,&iexcl`;,¡,1
StringReplace,T,T,&igrave`;,ì,1
StringReplace,T,T,&Igrave`;,Ì,1
StringReplace,T,T,&iquest`;,¿,1
StringReplace,T,T,&iuml`;,ï,1
StringReplace,T,T,&Iuml`;,Ï,1
StringReplace,T,T,&laquo`;,«,1
StringReplace,T,T,&ldquo`;,“,1
StringReplace,T,T,&lrm`;,,1       ; Ne fait rien
StringReplace,T,T,&lsaquo`;,‹,1
StringReplace,T,T,&lsquo`;,‘,1
StringReplace,T,T,&lt`;,<,1
StringReplace,T,T,&macr`;,¯,1
StringReplace,T,T,&mdash`;,—,1
StringReplace,T,T,&micro`;,µ,1
StringReplace,T,T,&middot`;,·,1
StringReplace,T,T,&nbsp`;, ,1
StringReplace,T,T,&ndash`;,–,1
StringReplace,T,T,&not`;,¬,1
StringReplace,T,T,&ntilde`;,ñ,1
StringReplace,T,T,&Ntilde`;,Ñ,1
StringReplace,T,T,&oacute`;,ó,1
StringReplace,T,T,&Oacute`;,Ó,1
StringReplace,T,T,&Ocirc`;,Ô,1
StringReplace,T,T,&ocirc`;,ô,1
StringReplace,T,T,&oelig`;,œ,1
StringReplace,T,T,&OElig`;,Œ,1
StringReplace,T,T,&Ograve`;,Ò,1
StringReplace,T,T,&ograve`;,ò,1
StringReplace,T,T,&ordf`;,ª,1
StringReplace,T,T,&ordm`;,º,1
StringReplace,T,T,&oslash`;,ø,1
StringReplace,T,T,&Oslash`;,Ø,1
StringReplace,T,T,&Otilde`;,Õ,1
StringReplace,T,T,&otilde`;,õ,1
StringReplace,T,T,&ouml`;,ö,1
StringReplace,T,T,&Ouml`;,Ö,1
StringReplace,T,T,&para`;,¶,1
StringReplace,T,T,&permil`;,‰,1
StringReplace,T,T,&plusmn`;,±,1
StringReplace,T,T,&pound`;,£,1
StringReplace,T,T,&quot`;,",1
StringReplace,T,T,&raquo`;,»,1
StringReplace,T,T,&rdquo`;,”,1
StringReplace,T,T,&reg`;,®,1
StringReplace,T,T,&rlm`;,,1       ; Ne fait rien
StringReplace,T,T,&rsaquo`;,›,1
StringReplace,T,T,&rsquo`;,’,1
StringReplace,T,T,&sbquo`;,‚,1
StringReplace,T,T,&scaron`;,š,1
StringReplace,T,T,&Scaron`;,Š,1
StringReplace,T,T,&sect`;,§,1
StringReplace,T,T,&shy`;,,1       ; Ne fait rien
StringReplace,T,T,&sup1`;,¹,1
StringReplace,T,T,&sup2`;,²,1
StringReplace,T,T,&sup3`;,³,1
StringReplace,T,T,&szlig`;,ß,1
StringReplace,T,T,&thinsp`;,,1    ; Ne fait rien
StringReplace,T,T,&THORN`;,Þ,1
StringReplace,T,T,&thorn`;,þ,1
StringReplace,T,T,&tilde`;,˜,1
StringReplace,T,T,&times`;,×,1
StringReplace,T,T,&uacute`;,ú,1
StringReplace,T,T,&Uacute`;,Ú,1
StringReplace,T,T,&Ucirc`;,Û,1
StringReplace,T,T,&ucirc`;,û,1
StringReplace,T,T,&Ugrave`;,Ù,1
StringReplace,T,T,&ugrave`;,ù,1
StringReplace,T,T,&uml`;,¨,1
StringReplace,T,T,&Uuml`;,Ü,1
StringReplace,T,T,&uuml`;,ü,1
StringReplace,T,T,&Yacute`;,Ý,1
StringReplace,T,T,&yacute`;,ý,1
StringReplace,T,T,&yen`;,¥,1
StringReplace,T,T,&yuml`;,ÿ,1
StringReplace,T,T,&Yuml`;,Ÿ,1
StringReplace,T,T,&zwj`;,,1       ; Ne fait rien
StringReplace,T,T,&zwnj`;,,1      ; Ne fait rien
StringCaseSense,Off
ControlGet,numerus,Hwnd,,HiEdit1,Vic
ControlSetText,,%T%,ahk_id %numerus%
SendMessage,0xB1,0,0,,ahk_id %hEdit%   ; Remettre le curseur au début
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer la sélection
idx++
}
Return

TV: ;### Trier...
^+T::
Gui,6:Default
Gui,+Owner1
Gui,1:+Disabled
GoSub,R5
Sel:=HE_GetSelText(hEdit)
If (StrLen(Sel)<1)
{
 Gui,1:-Disabled
 GoTo,M1
}
Gui,Font,s%Xp%,Tahoma
Gui,Add,GroupBox,W%X150% H%X90%,%YY%
Gui,Add,Radio,vBR1 Checked xp+%X12% yp+%X26%,%YZ%
Gui,Add,Radio,vBR2,%ZA%
Gui,Add,GroupBox,W%X150% H%X90% ys,%ZB%
Gui,Add,Radio,vBR3 Checked xp+%X12% yp+%X26%,%ZC%
Gui,Add,Radio,vBR4,%ZD%
Gui,Add,Text,vT xs+4 yp+%X50%,%ZE%
Gui,Add,Edit,vDx Limit1 W%X50% xp+%X248% Multi R1 yp-2
Gui,Add,Checkbox,vCB1 xs+2 yp+%X32%,%ZF%
Gui,Add,Button,vU6 W%X150% xp-2 y+%X20% Default,OK
Gui,Show,AutoSize,%YX% 
Return

6GuiClose:
6GuiEscape:
Gui,1:-Disabled
Gui,Destroy
Return

6ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
Opt=
If BR2=1
 Opt:="N"
If BR4=1
 Opt.="R"
If CB1=1
 Opt.="U"
If Dx<>
 Opt.="D" . Dx
Sort,Sel,%Opt%
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos+StrLen(Sel)-1,,ahk_id %hEdit%
Return

TW: ;### Calendrier perpétuel
^+C::
Gui,17:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Add,MonthCal,R3 W-4 ; R=nb rangées - W=nb colonnes
Gui,Show,AutoSize,Calendrier perpétuel
Return

17GuiClose:
17GuiEscape:
Gui,1:-Disabled
Gui,Destroy
Return

TX: ;### Compresser le HTML/XHTML
!^C::
N:=HE_GetFileCount(hEdit)
idx:=HE_GetCurrentFile(hEdit)
If (N>1)
{
 MsgBox,51,%Z8%,%Z9%
 IfMsgBox,Cancel
  Return
 IfMsgBox,No
  N=1
 IfMsgBox,Yes
  idx=0
}
Critical
T=
Tout=
Tronque=
Var=0
Loop,%N%
{
HE_SetCurrentFile(hEdit,idx)
T:=HE_GetTextRange(hEdit,0,-1)
T:=RegExReplace(T,"^[\r\n]+|[\r\n]+$","",1)
T:=RegExReplace(T,"s)<!--[^>]+>","",1)
IfInString,T,<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
 Var=1
Debut:
Position:=RegExMatch(T,"<pre")
If (Position > 0)
{
 StringTrimLeft,Tronque,T,% Position-1
 StringLeft,T,T,% Position-1
 GoSub Traitement
 Tout:=Tout . T
 Position:=RegExMatch(Tronque,"</pre")
 StringLeft,T,Tronque,% Position-1
 Tout:=Tout . T
 StringTrimLeft,T,Tronque,% Position-1
 GoTo Debut
}
Else
{
 GoSub Traitement
 Tout:=Tout . T
}
ControlGet,numerus,Hwnd,,HiEdit1,Vic
ControlSetText,,%Tout%,ahk_id %numerus%
SendMessage,0xB1,0,0,,ahk_id %hEdit%   ; Remettre le curseur au début
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer la sélection
idx++
}
Return

Traitement:
T:=RegExReplace(T,">[`r`n`t]+<","><",1)
T:=RegExReplace(T,"[ 	]+"," ",1)
If (Var=1)
 T:=RegExReplace(T,"=(?:""|')([-\w\.:]+)(?:""|')","=$1",1)
T:=RegExReplace(T,"[\r\n]++(.)"," $1",1)
Return

TY: ;### Convertir en HTML 4.01
!^x::
N:=HE_GetFileCount(hEdit)
idx:=HE_GetCurrentFile(hEdit)
If (N>1)
{
 MsgBox,51,%B0%,%B1%
 IfMsgBox,Cancel
  Return
 IfMsgBox,No
  N=1
 IfMsgBox,Yes
  idx=0
}
Critical
Loop,%N%
{
HE_SetCurrentFile(hEdit,idx)
T:=HE_GetTextRange(hEdit,0,-1)
IfInString,T,<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
{
 StringReplace,T,T,%A_Space%/>,>,1
 StringReplace,T,T,</colgroup>,,1
 StringReplace,T,T,</dd>,,1
 StringReplace,T,T,</dt>,,1
 StringReplace,T,T,</li>,,1
 StringReplace,T,T,</option>,,1
 StringReplace,T,T,</p>,,1
 StringReplace,T,T,selected="selected",selected,1
 StringReplace,T,T,</tbody>,,1
 StringReplace,T,T,</td>,,1
 StringReplace,T,T,</tfoot>,,1
 StringReplace,T,T,</th>,,1
 StringReplace,T,T,</thead>,,1
 StringReplace,T,T,</tr>,,1
 StringReplace,T,T,xml:lang=,lang=,1
 StringReplace,T,T,<body>,<body lang="">,1
 T:=RegExReplace(T,"U)<html [^>]+>","<html>",1)
 T:=RegExReplace(T,"U)xml:lang=""([^""]+)""","lang=""$1""",1)
 T:=RegExReplace(T,"U)lang=""([^""]+)"" lang=""\1""","lang=""$1""",1)
 T:=RegExReplace(T,"U)<!DOCTYPE [^>]+>","<!DOCTYPE html PUBLIC ""-//W3C//DTD HTML 4.01//EN"" ""http://www.w3.org/TR/html4/strict.dtd"">",1)
 ControlGet,numerus,Hwnd,,HiEdit1,Vic
 ControlSetText,,%T%,ahk_id %numerus%
}
SendMessage,0xB1,0,0,,ahk_id %hEdit%   ; Remettre le curseur au début
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; Montrer la sélection
idx++
}
Return

;### Signets
KA: ;### Placer un signet
!^M::
GoSub,R5           ; Calculer la position courante
Marks=             ; Liste des signets
fn:=HE_GetFileName(hEdit,-1)                     ; Créer la liste des signets
IfInString,fn,*
 MsgBox,48,%KP%,%KQ%                             ; Avertir si le fichier n'est pas enregistré
SplitPath,fn,,Dir,,Courant
URLMk:=Dir . "\" . Courant . ".mrk"              ; Construire l'URL du fichier où stocker la liste
IfExist,%URLMk%                                  ; ... si le fichier existe...
 FileRead,Marks,%URLMk%                          ; ...récupérer son contenu...
Marks:=Marks . "`n" . Pos-1                      ; Ajouter la position courante à la liste
Sort,Marks,NUZ                                   ; Trier la liste (N), ôter les doublons (U) et inclure le dernier nombre (Z)
Marks:=RegExReplace(Marks,"^[\r\n]++","")
FileDelete,%URLMk%                               ; Détruire l'ancien fichier
FileAppend,%Marks%,%URLMk%                       ; Créer le nouveau
FileSetAttrib,+H,*.mrk
Return

KB: ;### Signet suivant
!^J::
GoSub,R5                                         ; Stocker la position courante dans Pos
fn:=HE_GetFileName(hEdit,-1)
SplitPath,fn,,Dir,,Courant                       ; À partir du nom du fichier courant...
URLMk:=Dir . "\" . Courant . ".mrk"              ; ...construire l'URL du fichier des signets
FileRead,Marks,%URLMk%
If (ErrorLevel=1 || Marks="")
 Return                                          ;    Si le fichier est inexistant ou vide, rester là
Loop
{
 FileReadLine,mark,%URLMk%,%A_Index%             ;    S'il existe, lire les lignes une à une...
 If (mark>Pos)                                   ;    ...jusqu'à une position supérieure à Pos
  Break
 If (ErrorLevel=1)                               ;          S'il n'y en a pas...
 {
  FileReadLine,mark,%URLMk%,1                    ;         ...prendre la première position
  Break
 }
}
HE_SetSel(hEdit,mark,mark)                       ; Aller à la position trouvée
HE_ScrollCaret(hEdit)
Return

KC: ;### Signet précédent
!^+J::
GoSub,R5                                         ; Stocker la position courante dans Pos
fn:=HE_GetFileName(hEdit,-1)
SplitPath,fn,,Dir,,Courant                       ; À partir du nom du fichier courant...
URLMk:=Dir . "\" . Courant . ".mrk"              ; ...construire l'URL du fichier des signets
FileRead,Marks,%URLMk%
If (ErrorLevel=1 || Marks="")
 Return                                          ;    Si le fichier est inexistant ou vide, rester là
StringReplace,Marks,Marks,`n,`n,UseErrorLevel    ;    S'ils existe...
N:=ErrorLevel+1                                  ;    ...stocker le nombre de positions dans N
X:=N
Loop
{
 FileReadLine,mark,%URLMk%,%X%                   ;    Lire la dernière ligne...
 If (mark<Pos-1)                                 ;    ...si la position est inférieure à Pos-1
  Break
 X--
 If (X=0)                                        ;          S'il n'y en a pas...
 {
  FileReadLine,mark,%URLMk%,%N%                  ;         ...prendre la dernière position de la liste
  Break
 }
}
HE_SetSel(hEdit,mark,mark)                       ; Aller à la position trouvée
HE_ScrollCaret(hEdit)
Return

KD: ;### Supprimer le signet courant
!+M::
GoSub,R5                                         ; Stocker la position courante dans Pos
Pos--
fn:=HE_GetFileName(hEdit,-1)
SplitPath,fn,,Dir,,Courant                       ; À partir du nom du fichier courant...
URLMk:=Dir . "\" . Courant . ".mrk"              ; ...construire l'URL du fichier des signets
FileRead,Marks,%URLMk%                           ; Lire le contenu
IfNotInString,Marks,%Pos%                        ; Si Pos n'y figure pas, ne rien faire
 Return
Else                                             ; Si Pos figure, le retirer de la liste
{
 FileDelete,%URLMk%
 StringReplace,Marks,Marks,%Pos%,,1              ; Retire Pos de la liste et enlève les lignes vides
 Marks:=RegExReplace(Marks,"m)^[\r\n]++|([\r\n])++","$1")
 If Marks=                                       ; Empêche la création d'un fichier vide
  Return
 FileAppend,%Marks%,%URLMk%
 FileSetAttrib,+H,*.mrk                          ; Le fichier est créé, puis caché
}
Return

KE: ;### Supprimer tous les signets
!^+M::
N:=HE_GetFileCount(hEdit)
idx=-1
If (N>1)                                         ; S'il y a plusieurs onglets...
{
 MsgBox,51,%KN%,%KO%                             ; ...demander si on veut étendre la suppression à tous
 IfMsgBox,Cancel
  Return
 IfMsgBox,Yes                                    ;    Si oui, on fera le tour des onglets à partir du premier
  idx=0
 IfMsgBox,No                                     ;    Si non, on s'en tiendra à l'onglet courant
  N:=1
}
Loop,%N%                                         ; Traiter le ou les onglets visés comme suit
{
 fn:=HE_GetFileName(hEdit,idx)                   ;    Prendre l'URL de l'onglet de départ...
 SplitPath,fn,,Dir,,Courant                      ;    ...séparer le chemin et le nom...
 URLMk:=Dir . "\" . Courant . ".mrk"             ;    ...construire l'URL du fichier à cibler
 FileDelete,%URLMk%                              ;    ...l'effacer, puis faire de même avec l'onglet suivant si N>1
 idx++
}
Return

;### Extensions
PA:
StringTrimLeft,RunScript,A_ThisMenuItem,1
Run %A_AhkPath% "%A_ScriptDir%\plugins\%runscript%.ahk"
Return

;### ?

ZA: ;### Documentation
F1::
If (p44=1)    ; Fr
 Run,"doc\Vic.html"
If (p44=0)    ; En
 Run,"doc\Vic_En.html"
Return

ZB: ;### Expression rationnelle
F11::
Run,"doc\XR.html"
Return

ZC: ;### Table ASCII/ANSI
F12::
Gui,18:Default
Gui,+Owner1 %CA%
Gui,1:+Disabled
Gui,Font,s%Xp%,Tahoma
Gui,Add,Tab,,Decimal||Hexadecimal
Gui,Font,s%Xp%,Courier New
Gui,Add,Edit,x+-2 y+-2 -VScroll R16 ReadOnly,+------+-------------------------------------------+`n¦      ¦  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9  ¦`n+------+-------------------------------------------+`n¦   30 ¦        ! " # $ `% & ' ( ) * + , - . / 0 1  ¦`n¦   50 ¦  2 3 4 5 6 7 8 9 : `; < = > ? @ A B C D E  ¦`n¦   70 ¦  F G H I J K L M N O P Q R S T U V W X Y  ¦`n¦   90 ¦  Z [ \ ] ^ _ `` a b c d e f g h i j k l m  ¦`n¦  110 ¦  n o p q r s t u v w x y z { | } ~   €    ¦`n¦  130 ¦  ‚ ƒ „ … † ‡ ˆ ‰ Š ‹ Œ   Ž     ‘ ’ “ ” •  ¦`n¦  150 ¦  – —   ™ š › œ   ž Ÿ   ¡ ¢ £ ¤ ¥ ¦ § ¨ ©  ¦`n¦  170 ¦  ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½  ¦`n¦  190 ¦  ¾ ¿ À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ  ¦`n¦  210 ¦  Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å  ¦`n¦  230 ¦  æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù  ¦`n¦  250 ¦  ú û ü ý þ ÿ                              ¦`n+------+-------------------------------------------+
Gui,Tab,2
Gui,Add,Edit,x+-2 y+-2 -VScroll R16 ReadOnly,   ¦  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F`n---+------------------------------------------------`n20 ¦     !  "  #  $  `%  &  '  (  )  *  +  ,  -  .  /`n30 ¦  0  1  2  3  4  5  6  7  8  9  :  `;  <  =  >  ?`n40 ¦  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O`n50 ¦  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _`n60 ¦  ``  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o`n70 ¦  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~   `n80 ¦  €     ‚  ƒ  „  …  †  ‡  ˆ  ‰  Š  ‹  Œ     Ž   `n90 ¦     ‘  ’  “  ”  •  –  —     ™  š  ›  œ     ž  Ÿ`nA0 ¦     ¡  ¢  £  ¤  ¥  ¦  §  ¨  ©  ª  «  ¬  ­  ®  ¯`nB0 ¦  °  ±  ²  ³  ´  µ  ¶  ·  ¸  ¹  º  »  ¼  ½  ¾  ¿`nC0 ¦  À  Á  Â  Ã  Ä  Å  Æ  Ç  È  É  Ê  Ë  Ì  Í  Î  Ï`nD0 ¦  Ð  Ñ  Ò  Ó  Ô  Õ  Ö  ×  Ø  Ù  Ú  Û  Ü  Ý  Þ  ß`nE0 ¦  à  á  â  ã  ä  å  æ  ç  è  é  ê  ë  ì  í  î  ï`nF0 ¦  ð  ñ  ò  ó  ô  õ  ö  ÷  ø  ù  ú  û  ü  ý  þ  ÿ
Gui,Show,AutoSize,%Z7%
Return

18GuiEscape:
18GuiClose:
Gui,1:-Disabled
Gui,Destroy
Return

ZD: ;### Vérifier l'existence d'une mise à jour
UrlDownloadToFile,http://normandlamoureux.com/vic/Version.txt,Ver.txt
FileRead,VER,Ver.txt         ; Télécharger, lire et effacer le fichier...
FileDelete,Ver.txt           ; ...qui contient le dernier no de version
If (VER="")
{
 MsgBox,64,%KR%,%MF%         ; Si vide, avertir
 Return
}                            ; Capter le no de la version actuelle
RegExMatch(M2,"([0-9\.]+[a-c]?)",NOW)
If (NOW<VER)                 ; Si la version publique est supérieure, offrir de la télécharger
{
 MsgBox,68,%KR%,%KS% %Ver% %KT%
 IfMsgBox,Yes
  Run,http://normandlamoureux.com/vic/Vic_Installer.exe
 IfMsgBox,No
  Return
}
Else                         ; Sinon, dire que la version actuelle est à jour
 MsgBox,64,%KR%,%KU%
Return

ZE: ;### À propos...
MsgBox,64,%ZG%,%M2%
Return

;--------------------------------------------------------
; Routines

R1: ;### Sélectionne le rectangle
GoSub,R5                               ; Va chercher les valeurs requises
Critical
Sel:=HE_GetSelText(hEdit)              ; Capte la sélection courante
i=0
j=0 ; Réinitialise les variables
T=
If (StrLen(Sel)<1)                     ; S'il n'y a pas de texte sélectionné...
 ControlGet,T,Line,%L%,HiEdit1,Vic     ; ...mémoriser le texte de la ligne courante (N.B. HE_GetLine ignore CR/LF)
Else                                   ; Si du texte est sélectionné...
{
 j:=NLC
 Loop                                  ; ...construire le bloc de lignes
 {
  If (StrLen(Sel)+NCC-1>StrLen(T))     ;    Ajouter NCC pour couvrir les cas où la sélection
  {                                    ;    ne commencerait pas en début de ligne
   ControlGet,Txf,Line,%j%,,ahk_id %hEdit%
   T.=Txf
   j++                                 ; Stocke le no de la ligne subséquente dans j
  }
  Else
   Break
 }
}
Return

R2: ;### Balises html modèle 1 (h1, p, strong...)
Ajust=0
Indent=
HE_GetSel(hEdit,Deb,Fin)
ControlGet,Sel,Selected,,,ahk_id %hEdit%
P:=Deb+StrLen(A)+2
If StrLen(Sel)>0
 P:=P+StrLen(Sel)+StrLen(A)+3
T=<%A%>%Sel%</%A%>
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,P,P,,ahk_id %hEdit%
Return

R3: ;### Balises html modèle 2 (ul, ol, blockquote...)
Ajust=0
T:=HE_GetLine(hEdit,-1)                          ; Il faut avoir le texte de la ligne courante...
HE_GetSel(hEdit,Deb,Fin)                         ; ...savoir où est le curseur...
ControlGet,Sel,Selected,,,ahk_id %hEdit%         ; ...s'il y a une sélection...
Indent:=RegExReplace(T,"m)^([ \t]+)?.*","$1")    ; ...et comment indenter
If StrLen(Sel)<1   ; S'il n'y a pas de sélection :
{
 If (C="p" && A<>"blockquote")    ; Et qu'il s'agit d'ajouter <p>...
 {
  T=<p>            ;    ...construire le texte...
  P:=Deb+3         ;    ...et calculer où mettre le curseur
 }
 Else              ; De même s'il s'agit d'un autre type de bloc
 {
  T=<%A%>`r`n%Indent%%A_Tab%<%C%>`r`n%Indent%</%A%>
  P:=Deb+StrLen(Indent)+StrLen(A)+StrLen(C)+7
 }
}
Else               ; S'il y a une sélection :
{
 GoSub,R1                                        ; Sélectionner le rectangle
 SendMessage,0xB1,Pos-NCC,Pos-NCC+StrLen(T),,ahk_id %hEdit%
 ControlGet,Sel,Selected,,,ahk_id %hEdit%        ; Capter la nouvelle sélection
 T:=RegExReplace(Sel,"m)^[ 	]*\R+","")           ; Ôter les lignes vides
 T:=RegExReplace(T,"m)^([ \t]+)?(.*)","$1<C>$2") ; Former le corps
 StringReplace,T,T,<C>,<%C%>,1                   ; Mettre la balise de corps prévue
 If (C="p" && A<>"" || C<>"p")
 {           ; Et s'il ne s'agit pas de paragraphes...
  StringReplace,T,T,<,%A_Tab%<,1       ; ...augmenter le retrait du corps...
  T=%Indent%<%A%>`r`n%T%%Indent%</%A%> ; ...et ajouter les balises englobantes
 }
 P:=Deb+StrLen(T)  ; Le curseur sera mis à la fin du texte
}
SendMessage,0xC2,,&T,,ahk_id %hEdit%   ; Pour finir, insérer le texte...
SendMessage,0xB1,P,P,,ahk_id %hEdit%   ; ...placer le curseur...
SendMessage,0xB7,0,0,,ahk_id %hEdit%   ; ...et s'il est hors champ, le montrer.
Return

R4: ;### Ajouter le contrôle de formulaire
HE_GetSel(hEdit,Deb,Fin)
SendMessage,0xC2,,&T,,ahk_id %hEdit%
SendMessage,0xB1,Deb+StrLen(T)-P,Deb+StrLen(T)-P,,ahk_id %hEdit%
WinActivate,- Vic ahk_class AutoHotkeyGUI
Return

R5: ;### Calculer la position courante
ControlGet,NLC,CurrentLine,,,ahk_id %hEdit%      ; Nº ligne courante
SendMessage,0xBB,NLC-1,0,,ahk_id %hEdit%         ; Nb car. fin ligne précédente
Pos:=ErrorLevel
ControlGet,NCC,CurrentCol,,,ahk_id %hEdit%       ; Nº colonne courante
Pos:=Pos+NCC
Return

R6: ;### Nettoyer avant balisage
Sel:=HE_GetSelText(hEdit)
Sel:=RegExReplace(Sel,"m)^[ \t]+|[ \t]+$","")    ; Ôte les blancs de début et de fin de ligne
Sel:=RegExReplace(Sel,"^\R+|\R+$|(\R)+","$1")    ; Réduit les lignes multiples à une seule
Sel:=RegExReplace(Sel,"m)^[-*•+]+\s+","")        ; Ôte les puces
Sel:=RegExReplace(Sel,"m)^\d+[-.)]+\s+","")      ; Ôte les numéros
Sel:=RegExReplace(Sel,"m)^[o""|\d+\.]\t","")     ; Ôte les puces et numéros Word
Return

R7: ;### MàJ barre titre
fn:=HE_GetFileName(hEdit,-1)
If (p16=0)
 fn:=RegExReplace(fn,".+\\(.+)","$1") ; Nom de fichier seulement
WinSetTitle,Vic ahk_class AutoHotkeyGUI,,%fn% - Vic
Return

R8: ;### Historique des derniers fichiers ouverts
c=0      ; Compteur
n=6      ; Nb de fichiers à afficher
x=42     ; Index du dernier fichier
IfInString,fn,%p36%
 GoTo,R7 ; Si 1er, ne pas MàJ l'historique
p36:=fn
Loop,%n% ; Faire le tour
{
 T:=p%x%
 IfInString,fn,%T%
 {       ; Si dans la liste, noter lequel
  c:=A_Index-1
  Break
 }
 x--
}
x:=42-c  ; Commencer à
n:=n-c   ; Nº
Loop,%n%
{
 y:=x-1
 T:=p%x%
 U:=p%y% ; MàJ de l'historique
 Menu,F,Rename,&%n%. %T%,&%n%. %U%
 p%x%:=p%y%
 n--
 x--
}
Return

R9: ;### Vérifier si le fichier fn est ouvert
N:=HE_GetFileCount(hEdit)
Loop,%N% ; Faire le tour des onglets
{
 idx:=A_Index-1     ; Commencer à 0
 nf:=HE_GetFileName(hEdit,idx)
 IfInString,nf,%fn% ; Si ouvert...
 {
  HE_SetCurrentFile(hEdit,idx)
  Break            ; ...atteindre l'onglet et arrêter
 }
 If (N=A_Index)    ; Si le tour est fini, ouvrir
 {
  HE_OpenFile(hEdit,fn)
  If (ErrorLevel=0)  ; Si l'ouverture achoppe, avertir et arrêter
  {
   MsgBox,48,%MA%,%MG%
   Break
  }
  Else             ; Si l'ouverture réussit, faire les MàJ
  {
   GoSub,R8        ; MàJ de l'historique
   GoSub,R7        ; MàJ de la barre de titre
  }
 }
}
Return

R10: ;### Un moment, svp
Gui,14:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,-SysMenu +AlwaysOnTop
Gui,Font,s%Xp% Bold,Verdana
Gui,Add,Text,Center W330,%M0%
Gui,Show,AutoSize,%M1%
Return

;----------------------------
; Messages

M1: ;### Si pas de sélection
MsgBox,48,%MA%,%MN%
Return

;----------------------------
; Commandes clavier hors menu

;### Défilement
!Left::SendMessage,0x114,0,1,,ahk_id %hEdit%
!Right::SendMessage,0x114,1,0,,ahk_id %hEdit%
!Up::SendMessage,0x115,0,1,,ahk_id %hEdit%
!Down::SendMessage,0x115,1,0,,ahk_id %hEdit%

;### Onglet suivant
^Tab::
If (HE_GetCurrentFile(hEdit)<HE_GetFileCount(hEdit)-1)
 HE_SetCurrentFile(hEdit,HE_GetCurrentFile(hEdit)+1)
Else
 HE_SetCurrentFile(hEdit,0)
GoSub,R7
Return

;### Onglet précédent
^+Tab::
If (HE_GetCurrentFile(hEdit)!=0)
 HE_SetCurrentFile(hEdit,HE_GetCurrentFile(hEdit)-1)
Else
 HE_SetCurrentFile(hEdit,HE_GetFileCount(hEdit)-1)
GoSub,R7
Return

;### Majuscule+Entrée
+Enter::
GoSub,R5                               ; T = Contenu ligne courante
ControlGet,T,Line,%NLC%,,ahk_id %hEdit%
RegExMatch(T,"^\s+",IND)               ; IND = Blancs initiaux
StringMid,g,T,NCC-1,1                  ; g = Caractère à gauche du curseur
If (g=>)
{
 StringMid,d,T,NCC,2                   ; d = Caractère à droite du curseur
 If (d=</)
 {
  Puce:="`r`n" . IND . "`t" . "`r`n" . IND
  SendMessage,0xC2,,&Puce,,ahk_id %hEdit%
  SendMessage,0xB1,Pos+StrLen(IND)+2,Pos+StrLen(IND)+2,,ahk_id %hEdit%
  Return
 }
}
T:=RegExReplace(T,"^\s+","")           ; T = Ligne courante sans les blancs initiaux
RegExMatch(T,"^[-*–•—+]+[ 	]+",P)     ; P = Puce
RegExMatch(T,"^\d+[\d-. )	]+",Nb)      ; Nb= Numéro
If (Nb="" && P="")                     ; S'il n'y a ni puce ni numéro
{
 Send •%A_Space%
 Return
}
If (Nb<>)                              ; S'il y a un numéro
{
 IfInString,Nb,.
 {
  RegExMatch(Nb,"[^\d.]+$",Rst)
  StringSplit,N,Nb,.
  Nb:=N%N0%+1
  If N2 Is Not Integer
   Nb:=N1+1 . "."
  Else
  {
   Loop % N0-1
   P.=N%A_Index% . "."
  }
  P.=Nb . Rst
 }
 Else
 {
  RegExMatch(Nb,"^\d+",N)
  Rst:=RegExReplace(Nb,"^\d+(.*)","$1")
  N++
  P:=N . Rst
 }
}
P:="`r`n" . IND . P
SendMessage,0xC2,,&P,,ahk_id %hEdit%
SendMessage,0xB1,Pos+StrLen(P)-1,Pos+StrLen(P)-1,,ahk_id %hEdit%
Return

;#### Ctrl+Entrée
$^Enter::
Send {Enter}
Return

;### Touche Origine
$Home::
ControlGet,C,CurrentCol,,,ahk_id %hEdit%    ; Nº colonne
ControlGet,L,CurrentLine,,,ahk_id %hEdit%   ; Nº ligne
If (C=1)
{
 GoSub,R5
 ControlGet,T,Line,%L%,,ahk_id %hEdit%
 RegExMatch(T,"Pm)^\s+",LONG)
 SendMessage,0xB1,Pos+LONG-1,Pos+LONG-1,,ahk_id %hEdit%
 Return
}
Else,Send {home}
Return

;### Touche Retour arrière
!BS::
HE_GetSel(hEdit,Deb,Fin)     ; Ajust = Valeur à ajouter pour que le curseur soit au bon endroit
SendMessage,0xB1,Deb-StrLen(T)+StrLen(Indent)+Ajust+StrLen(A)+1,Deb-StrLen(T)+StrLen(Indent)+Ajust+StrLen(A)+1,,ahk_id %hEdit%
SendMessage,0xB7,0,0,,ahk_id %hEdit%
Indent=0
Ajust=0
T=0
A=0
Return

;### Touche Tab
TTI:
GoSub,R5
Critical
RegExMatch(T,"^\s+",IND)     ; Capte les blancs en début de ligne courante
Tmp:=HE_GetTextRange(hEdit,0,-1)
StringMid,GCH,T,C-1,1        ; Si vide puce ou blanc à gauche, insérer tab
If (C="1" || GCH="." || GCH="-"|| GCH="*"|| GCH="+"|| GCH=")" || GCH="•" || GCH=" " || GCH="	")
{
 Send {Tab}
 Return
}
StringMid,DRT,T,C,1          ; Si <> à gauche ou <" à droite, chercher prochain stop
If (GCH="<" || GCH=">" || DRT="<" || DRT="""")
{
 P:=RegExMatch(Tmp,"Pms)(?:""""|></|> |.$)",LONG,Pos+1)
 If P>0
  SendMessage,0xB1,P,P,,ahk_id %hEdit%
 SendMessage,0xB7,0,0,,ahk_id %hEdit%
 Return
}
AEE:="", ATR:="", ATT:="", B1:="", B2:="", B3:="1", B4:="", COR:="", LONG:="0"
StringLeft,g,T,C-1           ; Retenir le côté gauche de la ligne courante
DEB:=RegExMatch(g,"Pm)\S+$",LONG)
g:=SubStr(g,DEB,LONG)        ; Extraire le dernier mot
StringSplit,B,g,+            ; Séparer élément+attribut
LMN=%B1%
If B2<>            ; Construire l'attribut
 ATR:=" " . B2 . "="""""
If B4<>
 AEE:=" " . B4 . "="""""
If LMN=a
 ATT:=" href="""""
If LMN=abbr
 ATT:=" title="""""
If LMN=acronym
 ATT:=" title="""""
If LMN=area
 ATT:=" shape="""" coords="""" href="""" alt="""""
If LMN=base
 ATT:=" href="""""
If LMN=bdo
 ATR:=" dir="""""
If LMN=bq
 LMN:="blockquote"
If LMN=button
 ATT:=" id="""" name="""" type="""" value="""""
If LMN=dl
{
 Loop,%B3%
 {
  CO:=IND . "`t<dt></dt>`r`n" . IND . "`t<dd></dd>`r`n"
  COR:=COR . CO
 }
 COR:="`r`n" . COR . IND
}
If LMN=Doctype
{
 GoTo,R6
 Return
}
If LMN=fieldset
 COR:="`r`n" . IND . "`t<legend></legend>`r`n" . IND
If LMN=form
 ATT:=" action="""" method="""""
If LMN=iframe
 ATT:=" src="""" width="""" height="""" scrolling="""" frameborder="""""
If LMN=img
 ATT:=" src="""" width="""" height="""" alt="""""
If LMN=input
 ATT:=" id="""" name="""" type="""" size="""""
If LMN=label
 ATT:=" for="""""
If LMN=link
 ATR:=" rel="""" type="""" href="""""
If LMN=map
 ATR:=" id="""" name=""""", COR:="`r`n" . IND . "`r`n" . IND . "<img src="""" width="""" height="""" alt="""" usemap="""" />`r`n" . IND
If LMN=meta
 ATR:=" http-equiv="""" content="""""
If LMN=object
 ATT:=" id="""" classid="""" data="""" type="""""
If LMN=ol
{
 Loop,%B3%
 {
  CO:=IND . "`t<li" . AEE . "></li>`r`n"
  COR:=COR . CO
 }
 COR:="`r`n" . COR . IND
}
If LMN=optgroup
 ATT:=" label="""""
If LMN=option
 ATT:=" value="""""
If LMN=param
 ATT:=" id="""" name="""" value="""""
If LMN=script
 ATT:=" type=""""", COR:="`r`n" . IND . "<![CDATA[`r`n" . IND . "`t`r`n" . IND . "]]>`r`n" . IND
If LMN=select
 ATT:=" id="""" name="""" size="""""
If LMN=style
 ATR:=" type=""text/css"" media="""""
If LMN=table
 ATT:=" cellspacing=""""", COR:="`r`n" . IND . "`t<tr>`r`n" . IND . "`t`t<th></th><th></th>`r`n" . IND . "`t</tr>`r`n" . IND . "`t<tr>`r`n" . IND . "`t`t<td></td><td></td>`r`n" . IND . "`t</tr>`r`n" . IND
If LMN=textarea
 ATT:=" rows="""" cols="""""
If LMN=ul
{
 Loop,%B3%
 {
  CO:=IND . "`t<li" . AEE . "></li>`r`n"
  COR:=COR . CO
 }
 COR:="`r`n" . COR . IND
}
If LMN contains @
 TAG:="<a href=""mailto:" . LMN . """></a>"
If LMN not contains @
{
 If LMN contains .
 {
  TAG:="<a href=""http://" . LMN . """></a>"
  StringReplace,TAG,TAG,http://http://,http://,1
  StringReplace,TAG,TAG,&,&amp`;,1
  StringREplace,TAG,TAG,&amp`;amp`;,&amp`;,1
 }
 If LMN not contains .
 {
  If LMN in area,base,br,hr,img,input,link,meta
   TAG:="<" . LMN . ATR . ATT . " />"
  If LMN not in area,base,br,hr,img,input,link,meta ;,html4,xhtml
   TAG:="<" . LMN . ATR . ATT . ">" . COR . "</" . LMN . ">"
 }
}
SendMessage,0xB1,Pos-1-LONG,Pos-1,,ahk_id %hEdit% ; Sélectionner nom+attribut
SendMessage,0xC2,,&TAG,,ahk_id %hEdit%  ; Substituer TAG
P:=RegExMatch(TAG,"sm)""""|></|\R+$") ; Trouver le prochain stop
SendMessage,0xB1,Pos-LONG+P-1,Pos-LONG+P-1,,ahk_id %hEdit%
Return

#Include %A_ScriptDir%\inc\Attach.ahk
#Include %A_ScriptDir%\inc\Dlg.ahk
#Include %A_ScriptDir%\inc\HiEdit.ahk
If (p47=0)
 #IfWinActive  ; Ne pas limiter à Vic
#Include %A_ScriptDir%\inc\Remplace.txt

AT: ;### Minimiser/Restaurer
#Down::
WinGet,WEtat,MinMax,- Vic ahk_class AutoHotkeyGUI
If (WEtat=1)
 WinRestore,- Vic ahk_class AutoHotkeyGUI
Else
 WinMinimize,- Vic ahk_class AutoHotkeyGUI
Return

AU: ;### Maximiser à gauche
#Left::
WinGet,WEtat,MinMax,- Vic ahk_class AutoHotkeyGUI
If (WEtat<>-1)
 WinRestore,- Vic ahk_class AutoHotkeyGUI
Sleep,60
 WinMaximize,- Vic ahk_class AutoHotkeyGUI
Sleep,60
WinMove,- Vic ahk_class AutoHotkeyGUI,,,,GUIW/2
Return

AV: ;### Maximiser à droite
#Right::
WinGet,WEtat,MinMax,- Vic ahk_class AutoHotkeyGUI
If (WEtat<>-1)
 WinRestore,- Vic ahk_class AutoHotkeyGUI
Sleep,60
WinMaximize,- Vic ahk_class AutoHotkeyGUI
Sleep,60
WinMove,- Vic ahk_class AutoHotkeyGUI,,NW/2,,NW/2
Return

AS: ;### Maximiser/restaurer
#Up::
WinGet,WEtat,MinMax,- Vic ahk_class AutoHotkeyGUI
If (WEtat=-1)
{
 WinRestore,- Vic ahk_class AutoHotkeyGUI
  SendMessage,0x07,0,0,,ahk_id %hEdit%       ; Remet le focus dans la fenêtre
 Send,{Right}                               ; Astuce pour déparalyser le curseur
}
Else If (WEtat=1)
{
 WinRestore,- Vic ahk_class AutoHotkeyGUI
 WinMaximize,- Vic ahk_class AutoHotkeyGUI
}
Else
 WinMaximize,- Vic ahk_class AutoHotkeyGUI
Return

HA: ;### h1
CapsLock & 1::
A=h1
GoTo,R2
Return

HB: ;### h2
CapsLock & 2::
A=h2
GoTo,R2
Return

HC: ;### h3
CapsLock & 3::
A=h3
GoTo,R2
Return

HD: ;### h4
CapsLock & 4::
A=h4
GoTo,R2
Return

HE: ;### h5
CapsLock & 5::
A=h5
GoTo,R2
Return

HF: ;### h6
CapsLock & 6::
A=h6
GoTo,R2
Return

HG: ;### p
CapsLock & P::
A=
C=p
GoTo,R3
Return

HH: ;### br
CapsLock & Enter::
KeyWait,CapsLock
Send,<br>
Return

HI: ;### hr
CapsLock & Space::
KeyWait,CapsLock
Send,<hr>
Return

HJ: ;### ol
CapsLock & O::
A=ol
C=li
GoTo,R3
Return

HK: ;### ul
CapsLock & U::
A=ul
C=li
GoTo,R3
Return

HL: ;### blockquote
CapsLock & K::
A=blockquote
C=p
GoTo,R3
Return

HM: ;### cite
CapsLock & C::
A=cite
GoTo,R2
Return

HN: ;### q
CapsLock & Q::
A=q
GoTo,R2
Return

HO: ;### b
CapsLock & B::
A=b
GoTo,R2
Return

HP: ;### i
CapsLock & I::
A=i
GoTo,R2
Return

HQ: ;### strong
CapsLock & S::
A=strong
GoTo,R2
Return

HR: ;### em
CapsLock & E::
A=em
GoTo,R2
Return

HS: ;### Del
CapsLock & Del::
A=del
GoTo,R2
Return

HT: ;### ins
CapsLock & Ins::
A=ins
GoTo,R2
Return

HU: ;### sup
CapsLock & Up::
A=sup
GoTo,R2
Return

HV: ;### sub
CapsLock & Down::
A=sub
GoTo,R2
Return

HW: ;### Transformer en tableau HTML...
CapsLock & T::
Sel:=HE_GetSelText(hEdit)
j=
s=
t=
j:=RegExReplace(Sel,"^\R+|\R+$|(\r\n){2,}","$1") ; Ôte les lignes vides
IfInString,j,<
{
 j:=RegExReplace(j,"s)>\s+?<","><")              ; Linéarise le html
 t:=RegExReplace(j,"s)<tab.+<caption>([^<]+).+","$1")
 IfInString,t,<                                  ; t = titre
  t=
 s:=RegExReplace(j,"s)<tab.+summary=""([^""]+).+","$1")
 IfInString,s,<                                  ; s = sommaire
  s=
 j:=RegExReplace(j,"</t(d|h)><t(d|h).*?>","	")
 j:=RegExReplace(j,"s)<tabl.+?<tr>","`r`n")
 j:=RegExReplace(j,"<tr>","`r`n")
 j:=RegExReplace(j,"<.+?>","")                   ; Ôte le html qui reste
}
j:=RegExReplace(j,"m)^ +| +$","")
j:=RegExReplace(j,"m)^\R+|\R+$|(\r\n){2,}","$1")
Y=                                               ; Y = table des valeurs
StringReplace,j,j,%A_Tab%,%A_Tab%,UseErrorLevel
C:=ErrorLevel                                    ; j = sélection traitée
StringReplace,j,j,`r`n,%A_Tab%,UseErrorLevel
L:=ErrorLevel+1                                  ; L = Nb lignes
C:=C//L+1                                        ; C = Nb colonnes
StringSplit,Y,j,%A_Tab%
Gui,12:Default
Gui,+Owner1
Gui,1:+Disabled
Gui,%CA%
Gui,Font,s%Xp%,Tahoma
Gui,Add,GroupBox,W%X248% Section H%X130%,%YP%
Gui,Add,Text,xp+%X10% yp+%X32%,%YQ%
Gui,Add,Edit,xp+%X190% yp-3 W%X32% Number Limit2 vcol,%C%
Gui,Add,Text,xp-%X190% yp+%X32%,%YR%
Gui,Add,Edit,xp+%X190% yp-3 W%X32% Number Limit2 vlig,%L%
Gui,Add,GroupBox,xm+%X260% ym W%X248% H%X130%,%YS%
Gui,Add,Text,xp+%X10% yp+%X32%,%YT%
Gui,Add,Edit,xp+%X190% yp-3 W%X32% Number Limit2 vetc
Gui,Add,Text,xp-%X190% yp+%X32%,%YU%
Gui,Add,Edit,xp+%X190% yp-3 W%X32% Number Limit2 vetl
Gui,Add,Text,xp-%X190% yp+%X32%,%YV%
Gui,Add,Edit,xp+%X190% yp-3 W%X32% Number Limit2 vidt
Gui,Add,Button,vi121 xs yp+%X54% W%X100% Default,&OK
Gui,Show,AutoSize,%YW% 
Return

12GuiClose:
12GuiEscape:
Gui,1:-Disabled
Gui,Destroy
Return

12ButtonOK:
Gui,1:-Disabled
Gui,Submit
Gui,Destroy
Critical
GoSub,R5
If ((col="")||(lig=""))      ; S'il manque le nb de colonnes ou de lignes
{
 MsgBox,16,%MA%,%MS%
 GoTo,HW
}
If (etc="")        ; etc = en-têtes de colonnes
 etc=0
If (etl="")        ; etl = en-têtes de lignes
 etl=0
i:=1               ; ligne courante
j:=1               ; colonne courante
kk:=1
l:=etl+1
m:=1
N:=1
rcl:=col-etl       ; rcl = nb de colonnes restant
rlg:=lig-etc       ; rlg = nb de lignes restant
ww=<table          ; ww = tableau final
If ((etc>=2)||(etl>=2))
 ww=%ww% id="t%idt%"
ww=%ww% cellspacing="1"
If ((s<>"")||(etc>=2)||(etl>=2))
 ww=%ww% summary="%s%"
ww=%ww%>`r`n%A_Tab%<caption>%t%</caption>`r`n
If (etc>=1)
{
 ww=%ww%%A_Tab%<thead>`r`n
 Loop,%etc%
 {
  ww=%ww%%A_Tab%<tr>`r`n%A_Tab%%A_Tab%
  Loop,%col%
  {
   ww=%ww%<th
   If ((etc>=2)||(etl>=2))
   {
    ww=%ww% id="t%idt%l%i%c%j%"
    j++
   }
   Y:=Y%N%
   ww=%ww%>%Y%</th>
   N:=N+1
  }
  ww=%ww%`r`n%A_Tab%</tr>`r`n
  i++
  j:=1
 }
 ww=%ww%%A_Tab%</thead>`r`n%A_Tab%<tbody>`r`n
}
Loop,%rlg%
{
 ww=%ww%%A_Tab%<tr>`r`n%A_Tab%%A_Tab%
 Loop,%etl%
 {
  ww=%ww%<th
  If ((etc>=2)||(etl>=2))
  {
   ww=%ww% id="t%idt%l%i%c%j%"
   j++
  }
  Y:=Y%N%
  ww=%ww%>%Y%</th>
  N:=N+1
 }
 Loop,%rcl%
 {
  ww=%ww%<td
  If ((etc>=2)||(etl>=2))
  {
   ww=%ww% headers="
   Loop,%etc%
   {
    ww=%ww%t%idt%l%kk%c%l%%A_Space%
    kk++
   }
   kk:=1
   Loop,%etl%
   {
    ww=%ww%t%idt%l%i%c%m%%A_Space%
    m++
   }
   m:=1
   ww=%ww%"
  }
  Y:=Y%N%
  ww=%ww%>%Y%</td>
  N:=N+1
  l++
 }
 ww=%ww%`r`n%A_Tab%</tr>`r`n
 i:=A_Index+etc+1
 j:=1
 l:=etl+1
}
If (etc>=1)
 ww=%ww%%A_Tab%</tbody>`r`n
Sel=%ww%</table>
StringReplace,Sel,Sel,%A_Space%",",1
StringReplace,Sel,Sel,%A_Space%<,<,1
StringReplace,Sel,Sel,>%A_Space%,>,1
SendMessage,0xC2,,&Sel,,ahk_id %hEdit%
SendMessage,0xB1,Pos-1,Pos-1+StrLen(Sel),,ahk_id %hEdit%
Return

HX: ;### a
CapsLock & A::
HE_GetSel(hEdit,Deb,Fin)                         ; Il faut savoir où est le curseur...
ControlGet,Sel,Selected,,,ahk_id %hEdit%         ; ...et s'il y a une sélection
If (StrLen(Sel)<1) ; S'il n'y a pas de sélection :
{
 T=<a href=""></a> ;    ...construire le texte
 P:=Deb+9          ;    ...et calculer où mettre le curseur
 Ajust=9
}
Else               ; S'il y a une sélection :
{                  ;    Ôter les espaces inutiles, puis construire le texte...
 AutoTrim,On       ;    ...et calculer où mettre le curseur selon qu'il s'agit...
 IfInString,Sel,@  ;    ...d'une adresse courriel
 {
  T=<a href="mailto:%Sel%"></a>
  StringReplace,T,T,mailto:mailto:,mailto:,A
  P:=Deb+StrLen(T)-4
  Ajust=4
 }
 Else
 {
  IfInString,Sel,. ;    ...d'une adresse Web
  {
   T=<a href="http://%Sel%"></a>
   StringReplace,T,T,http://http://,http://,A
   StringReplace,T,T,&,&amp;,A
   P:=Deb+StrLen(T)-4
   Ajust=4
  }
  Else             ;    ...ou d'un libellé
  {
   T=<a href="">%Sel%</a>
   P:=Deb+9
   Ajust=9
  }
 }
}
SendMessage,0xC2,,&T,,ahk_id %hEdit%   ; Pour finir, insérer le texte...
SendMessage,0xB1,P,P,,ahk_id %hEdit%   ; ...et placer le curseur
Return

HY: ;### img
CapsLock & G::
HE_GetSel(hEdit,Deb,Fin)          ; On a besoin des positions...
fn:=HE_GetFileName(hEdit,-1)      ; ...et du nom du fichier courant
IfInString,fn,*
{
 MsgBox,48,%MA%,%KQ%              ; Si le fichier n'existe pas, avertir
 Return
}
FileSelectFile,f_Img,1,Filename,%MD%,%ME%        ; N'afficher que les formats .bmp .gif .ico .jpg .jpeg .png
If (f_Img="")      ; Si aucun fichier n'est sélectionné...
 Return            ; ...finir
Gui,20:default
Gui,Add,Picture,vpicture,%f_Img%
Gui,Add,Button,vbutton gGetSize Default,Size
Gui,Show,x-9999 y-9999,ImgVic     ; Positionner hors champs
SetTimer,ImgVic,10                ; Démarrer un compteur
Return

ImgVic:
IfWinExist,ImgVic       ; Dès que la fenêtre existe...
{
 WinActivate,ImgVic     ; ...l'activer...
 WinWaitActive          ; ...attendre qu'elle soit disponible...
 ControlClick,Button1   ; ...activer le bouton "Size"...
 SetTimer,ImgVic,Off    ; ...et arrêter le compteur
}
Return

GetSize:
ControlGetPos,,,w,h     ; Retourner la largeur et la hauteur de l'image...
Gui,Destroy             ; ...détruire la fenêtre hors champ...
parents=                ; ...et vider la variable parents
StringReplace,fn,fn,\,/,A
StringReplace,f_Img,f_Img,\,/,A
Loop
{
 fn:=RegExReplace(fn,"^(.*)/.*","$1")            ; Tronque à partir du dernier signe /
 IfInString,f_Img,%fn%                           ; Si le chemin vers le fichier courant est commun
 {                                               ; à celui de l'image...
  StringReplace,f_Img,f_Img,%fn%,,1              ;    ...ôter le trajet commun...
  f_Img:=RegExReplace(f_Img,"/?([^/]+)/","$1/")  ;    ...et formater la différence
  Break
 }
 Else
 {
  If StrLen(fn)=2
   Break
  parents.="../"                                 ; Sinon, chaque fois il faut remonter à un dossier parent
 }
}
T=<img src="%parents%%f_Img%" width="%w%" height="%h%" alt="">       ; Construire les valeurs requises
P:=Deb+StrLen(T)-2
Ajust=2
SendMessage,0xC2,,&T,,ahk_id %hEdit%   ; Pour finir, insérer le texte...
SendMessage,0xB1,P,P,,ahk_id %hEdit%   ; ...et placer le curseur
Return

HZ: ;### Formulaire
CapsLock & F::
Gui,19:Default
Gui,+Owner1
Gui,Add,Button,gForm,%GA%
Gui,Add,Button,gFieldset,%GB%
Gui,Add,Text,,%G0%
Gui,Add,Button,gLabel,%GC%
Gui,Add,Button,gText,%GD%
Gui,Add,Button,gRadio,%GE%
Gui,Add,Button,gCheckbox,%GF%
Gui,Add,Button,gDropList,%GG%
Gui,Add,Button,gTextarea,%GH%
Gui,Add,Text,,%G0%
Gui,Add,Button,gButton,%GI%
Gui,Add,Button,gReset,%GJ%
Gui,Add,Button,gSubmit,%GK%
Gui,Add,Text,,%G0%
Gui,Add,Button,gPassword,%GL%
Gui,Add,Button,gHidden,%GM%
Gui,Add,Button,gChoose,%GN%
Gui,Show,,%G1%
Return

Button:
T=<button type="" id="" name="" value=""></button>
P=34
GoTo,R4
Return

Checkbox:
T=<input type="checkbox" id="" name="">
P=10
GoTo,R4
Return

Choose:
T=<input type="file" id="" name="" size="">
P=18
GoTo,R4
Return

DropList:
T=<select id="" name="" size="">`r`n`t<optgroup label="">`r`n`t`t`t<option value=""></option>`r`n`t`t`t<option value=""></option>`r`n`t</optgroup>`r`n</select>
P=127
GoTo,R4
Return

Fieldset:
T=<fieldset>`r`n`t<legend></legend>`r`n`t`r`n</fieldset>
P=25
GoTo,R4
Return

Form:
T=<form action="" method="">`r`n`r`n</form>
P=23
GoTo,R4
Return

Hidden:
T=<input type="hidden" id="" name="">
P=10
GoTo,R4
Return

Label:
T=<label for=""></label>
P=10
GoTo,R4
Return

Password:
T=<input type="password" id="" name="" size="">
P=18
GoTo,R4
Return

Radio:
T=<input type="radio" id="" name="">
P=10
GoTo,R4
Return

Reset:
T=<input type="reset" id="" name="">
P=10
GoTo,R4
Return

Submit:
T=<input type="submit" id="" name="">
P=10
GoTo,R4
Return

Text:
T=<input type="text" id="" name="" size="">
P=18
GoTo,R4
Return

Textarea:
T=<textarea rows="" cols=""></textarea>
P=21
GoTo,R4
Return

19GuiClose:
19GuiEscape:
Gui,Destroy
Return

+Esc:: ;### Activer le dialogue Formulaire
IfWinExist,Formulaire ahk_class AutoHotkeyGUI
WinActivate
Return

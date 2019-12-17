;-------------------------------------------------------------------------------------------
; Title:	ChooseIconEx
;			*Advanced icon dialog*
;>
;			This is advanced version of system dialog CmnDlg_ChooseIcon (i.e. PickIcon).
;			With ChooseIcon, you can only open icon from file resource while this dialog
;			allows you to move trough file system folders and use anything as an icon. 
;			Furthermore, icon resource can be entered like it is a folder. 
;			If file is the icon resource, its name will have ">" at the end and you can open it.
;
;>
;			Dialog is modal, meaning that your script will stop until dialog is closed.
;			Additionaly, you can pass configuration file (ini) when opening dialog to let it store
;			state information in ChooseIconEx section, like dialog position and size, last folder/file
;			that was open, etc.
;
;>
;			Dialog is resizable, and have support for filters and icon size.
;
;-------------------------------------------------------------------------------------------
; Function: ChooseIconEx
;			Open the dialog
;
; Parameters: 
;			pFile	- File or folder to start with. By default empty, means that shell32.dll will be used
;					  unless you set pSettings and ChooseIconEx was previously used and saved previous session.
;					  If you specify file that is not an icon resource, its parent folder will be open and file will
;					  be selected. If file is icon-resource (like shell32.dll) it will be open. You can specify file index
;					  to be selected after the file name separated by ":" (shell32.dll:125)
;			pPos	- Position of gui in AHK syntax. By default empty, dialog will start at screen center, unless
;					  there is saved position of previous session (if pSettings is set)
;		  pSettings - Path of the ini file that will be used to store session information. Data is saved in ChooseIconEx section.
;					  If this file already exists with valid session information, those will be used to set pPos and pFile if they are left empty.
;			pGuiNum - GUI number to be used by the dialog, by default 69.
;
; Returns:
;			Path of the selected icon. If icon is in icon resource, its index is specified after the file name with ":" as separator, for instance
;			shell32.dll:12. 
;
; Remarks:	
;			Default window will be set as the parent of the dialog. Use Gui N:Default to set the correct parent before calling this function.
;			Parent will be disabled while the dialog is active. Dialog will not change the Default Gui.
;
;			Set CIE_IconSize before calling function for initial icon size. Minimal size is 24. User can set any size from the GUI any time.
;			User can also set relative paths in the file name field of the ChooseIconEx GUI, for instance "." to open current folder. 
;			If file name is empty, shell32.dll will be open, the same as in ChooseIcon standard OS dialog.
;
; Hotkeys:
;			Backspace	- Go to the parent folder
;			Enter		- Enter folder or icon resource
;
ChooseIconEx(pFile="", pPos="", pSettings="", pGuiNum=69){
	local GuiPos, GuiW, GuiH, w, h, res, oldFocus, bl, defGui
	static filter = "*||ico icl|exe dll| |show folders|hide folders| |icon size 24|icon size 32|icon size 48|icon size 64|icon size 92|icon size 128"

	bl := A_BatchLines
	SetBatchLines, -1

	CIE_settings := pSettings,   CIE_guiNum  := pGuiNum

	;set position and size
	GuiPos	:= pPos != "" ? CIE_CfgGet( "GuiPos" ) : pPos
	GuiW	:= CIE_CfgGet( "GuiW", 400)
	GuiH    := CIE_CfgGet( "GuiH", 500)
	pFile	.= pFile = "" ? CIE_CfgGet("File", A_WinDir "\system32\shell32.dll") : ""

	CIE_Filter	 := CIE_CfgGet("Filter", "*")
	CIE_IconSize := CIE_CfgGet("IconSize", "32") 
	CIE_Flags	 := CIE_CfgGet("Flags", "0")
	If CIE_IconSize < 24
		CIE_IconSize := 32

	Gui, +Lastfound
	CIE_prntHwnd := WinExist()

	defGui := CIE_DefaultGui()
	Gui, %CIE_guiNum%:Default
	Gui, +ToolWindow +Resize
	DllCall("EnableWindow", "uint", CIE_prntHwnd, "uint", 0)

	;add combo
	w := GuiW - 105
	Gui, Add, ComboBox, x0 w%w% g_CIE_OnCombo, %pFile%||
	Gui, Add, ComboBox, w100 x+5 g_CIE_OnFilter, %filter%

	;add listview
	h := GuiH - 30
	Gui, Add, ListView, x0 w%GuiW% h%h% -Multi AltSubmit Icons g_CIE_OnIconClick HWNDCIE_hLV, Icon|File name

	Gui, +LastFound	MinSize320x300
	CIE_hwnd := WinExist()

	Gui, +LabelCIE_
	
	;set hotkeys
	Hotkey, IfWinActive, ahk_id %CIE_hwnd%
	Hotkey, ~Backspace, _CIE_Hotkey_Backspace, on
	Hotkey, ~Enter,		_CIE_Hotkey_Enter, on

	;show it	
	Gui, Show, %GuiPos% w%GuiW% h%GuiH%, Choose Icons
	ControlFocus, SysListView321

	CIE_Scan(pfile)

	;do modal loop
    CIE_OnA(CIE_hwnd, CIE_prntHwnd,"set",0) 
	oldFocus := OnMessage(6, "CIE_OnA")
    WinWaitClose, ahk_id %CIE_hwnd% 
	OnMessage(6, oldFocus)
	DllCall("EnableWindow", "uint", CIE_prntHwnd, "uint", 1)

	res := CIE_result,  CIE_result := ""
	Winactivate, ahk_id %CIE_prntHwnd%
	CIE_prntHwnd := ""
	SetBatchLines, %bl%
	Gui, %defGui%:Default
	return res
}

CIE_OnFilter(){
	local t
	static NOFOLDERS=1

	ControlGetText, t,ComboBox2
	IfEqual, t,%A_Space%,return
	
	if (t="show folders")
		CIE_Flags &= !NOFOLDERS
	else if (t="hide folders")
		CIE_Flags |= NOFOLDERS
	else if InStr(t, "icon size ") {
		CIE_IconSize := SubStr(t, 11) 
		if CIE_IconSize < 24
			CIE_IconSize := 24		
	}
	else CIE_Filter := t


	CIE_Scan()
}

_CIE_OnFilter:
	CIE_Scanning := false
	ControlGet,_,Choice, , ComboBox2
	if _ != 
		CIE_OnFilter()
return

;-------------------------------------------------------------------------------------------
; Convert relative file name to the full file name
; Example can be 
CIE_GetFullName( fn ) {
	static buf, i
	if fn = >drives
		return fn

	if !i
		i := VarSetCapacity(buf, 512)
	DllCall("GetFullPathNameA", "str", fn, "uint", 512, "str", buf, "str*", 0)
	return buf
}


;-------------------------------------------------------------------------------------------
CIE_OnA(wparam, lparam, msg, hwnd){
    static hc, hp    
    
    if msg = set 
        return hc := wparam, hp := lparam 
        
    if (wparam & 0xFF) and (hwnd = hp) 
        WinActivate ahk_id %hc% 
}

;-------------------------------------------------------------------------------------------

_CIE_OnCombo:
	ControlGet,_,Choice, , ComboBox1
	if _ != 
	   CIE_Scan()
return


;-------------------------------------------------------------------------------------------
; Returns true if file has icons resources or if file is the folder.
;
CIE_HasIcons( pFile ){
	return InStr(FileExist(pFile), "D") ? 1 : DllCall("shell32\ExtractIconA", "UInt", 0, "Str", pFile, "UInt", -1) > 1
}

;------------------------------------------------------------------------------------------
; Add item to combo and select it, but only if it is not already there.
;
CIE_Add2Combo( item ) {
	ControlGet,_, FindString, %item%, ComboBox1		; add to the combobox if not already in it
	if !_
		GuiControl, ,  ComboBox1, %item%||
}

;-------------------------------------------------------------------------------------------
; Populates listview with icons from ther given file. If file name is empty, it will be taken from the ComboBox
; Check parameters, prepare GUI and see if pFile is folder or icon resource and call adequate function.
;
CIE_Scan( pFile="" ){
	local attrib, ListID, j, idx

	Gui, %CIE_guiNum%:Default		;hm.. ? why ? doesn't work without it 
	CIE_scanning := true

 ;prepare pFile argument
	if (pFile = "") {
		GuiControlGet, pFile, ,ComboBox1
		IfEqual, pFile,,SetEnv, pFile, %A_WinDir%\system32\shell32.dll
	}
	pFile := CIE_GetFullName( pFile )

 ;clear list of files
	LV_Delete()

 ;create new list of large images and replace and delete old one
	CIE_idIconList := CIE_ILCreate(100, 100)
	ListID := LV_SetImageList(CIE_idIconList)
    IL_Destroy(ListID)

 ;check for drives 
 	if (pFile = ">drives")
		return CIE_AddDrives()

 ;check for file:dix notation
	if (j:= InStr(pFile,":",0,0)) > 2
		idx := SubStr(pFile, j+1), pFile := SubStr( pFile, 1, j-1)

 ;check for wrong path
	if not attrib := FileExist(pFile)
		return LV_Add("","> Invalid path")

 ;everything is OK, add to combo and scan
	CIE_Add2Combo(pFile), CIE_File := pFile

	If attrib contains D
		CIE_ScanFolder( pFile )
	else  
	    if CIE_HasIcons( pFile )
			CIE_ScanFile( pFile ),  LV_Modify(idx+1, "vis select focus") 
		else {								;if no icon resource is given, browse parent and select icon in question
			j := InStr(pFile, "\", 0, 0)
			idx := SubStr(pFile, j+1), pFile := SubStr( pFile, 1 , j-1)
			CIE_ScanFolder( pFile )	
			ControlSendRaw, SysListView321, %idx%, ahk_id %CIE_hwnd%		;select the file
		}

	CIE_scanning := false
}

CIE_Scan:
	CIE_Scan( CIE_file )
return

CIE_ScanFile( file ) {
	local idx, folderIcon, shell32dll

	shell32dll := A_WINDIR "\system32\shell32.dll"
	folderIcon  := CIE_ILAdd(CIE_idIconList, shell32dll , 5)
	LV_Add("Icon" . folderIcon, ". .", file)

	;Search for 9999 icons in the selected file
	Loop, 9999
    {
		If !CIE_scanning
			break
     
		if idx := CIE_ILAdd(CIE_idIconList, File , A_Index)
			LV_Add("Icon" . idx, idx-1, File ":" idx-1)
		else break  
    }

	CIE_SetStatus()
}

CIE_ScanFolder( folder ){
	local idx, attrib, shell32dll, folderIcon, goUpIcon, folderCount=1, s
	static NOFOLDERS=1

	shell32dll := A_WINDIR "\system32\shell32.dll"


	CIE_SetStatus( "scaning folder ..." )
	folderIcon := CIE_ILAdd(CIE_idIconList, shell32dll, 4)
	goUpIcon   := CIE_ILAdd(CIE_idIconList, shell32dll, 5)
	LV_Add("Icon" . goUpIcon, ". .", folder)

 ;add folders
    If !(CIE_Flags & NOFOLDERS){
		Loop, %folder%\*, 2 
		{
			If !CIE_scanning
			   break	

		 ;don't add hiden and system
			FileGetAttrib, attrib , %A_LoopFileFullPath%
			If attrib contains H,S
				continue

			LV_Add("Icon" . folderIcon, A_LoopFileName, A_LoopFileFullPath)		
		}

		folderCount := LV_GetCount()-1
		s :=  foldercount " folder" (folderCount=1  ? "" : "s") ", "
	}

 ;files	  
	Loop, %folder%\*
	{
		If !CIE_scanning
		   break

		if (CIE_Filter != "*") and !InStr(CIE_Filter, A_LoopFileExt)
		   continue

		idx := CIE_ILAdd(CIE_idIconList, A_LoopFileFullPath,1)
		if !idx
			continue

		if  CIE_HasIcons( A_LoopFileFullPath )
			 LV_Add("Icon" . idx, A_LoopFileName ">", A_LoopFileFullPath)		
		else LV_Add("Icon" . idx, A_LoopFileName, A_LoopFileFullPath)

		; CIE_SetStatus("adding icon " . idx . " : " A_LoopFIleName)
	}

	_ := LV_GetCount()-foldercount-1
	CIE_SetStatus( (folderCount ? s : "") _ " file" (_=1  ? "" : "s"))
}

;-------------------------------------------------------------------------------------------
; Add drive icons in the list
;
CIE_AddDrives() 
{
	local icn, driveIcon, cdIcon, floppyIcon, shell, remoteIcon, drives, r

	shell		:= A_WINDIR "\system32\shell32.dll"
	driveIcon	:= CIE_ILAdd(CIE_idIconList, shell , 8)
	floppyIcon	:= CIE_ILAdd(CIE_idIconList, shell , 7)
	cdIcon		:= CIE_ILAdd(CIE_idIconList, shell , 12)
	remoteIcon	:= CIE_ILAdd(CIE_idIconList, shell , 11)

	DriveGet drives, List

	Loop, parse, drives
	{
		r := DllCall("GetDriveType", "str", A_LoopField ":")
		if r = 3	;cdrom
			icn := driveIcon
		else if r = 5
			icn := cdIcon
		else if r = 4
			icn := remoteIcon
		else if r = 2
			icn := floppyIcon

		LV_Add("Icon" . icn, A_LoopField ":", A_LoopField ":")
	}
	CIE_SetStatus("drives")

}
	
;---------------------------------------------------------------------------
CIE_SetStatus( s="" ){
	global
	WinSetTitle, ahk_id %CIE_hwnd%, ,% "Choose Icon  -  " (s="" ? LV_GetCount()-1 " icons" : s)
}

;---------------------------------------------------------------------------
; Handles icon click in ListView
;
CIE_OnIconClick(e){
	local file, j, txt

	Gui, %CIE_guiNum%:Default
	LV_GetText(file, e, 2) 	LV_GetText(txt, e, 1)
	IfEqual, file,, return		;happens if user clicks on "Invalid path" text.

	if (txt = ". ."){
		if StrLen(file) = 3
			file := ">drives"
		else {
			file := (j:=InStr(file, "\", 0, 0)) ? SubStr( file, 1,  j-1) : ">drives"
			if (StrLen(file)=2)		;drive
				file .= "\"
		}			
	}

	if (FileExist( file ) AND CIE_HasIcons( file )) OR (file = ">drives")
	{
		CIE_scanning := false  ;stop scaning if active
		CIE_file := file
		SetTimer, CIE_Scan, -50
		return
	}

	;its not the resource, not the folder, this is the icon to return
	CIE_result := file
	CIE_Exit()
}


_CIE_OnIconClick:
	critical			;!!!
	If A_GuiEvent = A
		CIE_OnIconClick(A_EventInfo)
return

;---------------------------------------------------------------------------

CIE_Anchor(c, a, r = false) { ; v3.5 - Titan
	static d
	GuiControlGet,  p, Pos, %c%
	If !A_Gui or ErrorLevel
		Return
	i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
	StringSplit, i, i, .
	d .= (n := !InStr(d, i9)) ? i9 : ""
	Loop, 4
		x := A_Index, j := i%x%, i6 += x = 3, k` := !RegExMatch(a, j . "([\d.]+)", v)
		+ (v1 ? v1 : 0), e := p%j% - i%i6% * k, d .= n ? e . i5 : "", RegExMatch(d
		, i9 . "(?:([\d.\-]+)/){" . x . "}", v), l .= InStr(a, j) ? j . v1 + i%i6% * k : ""
	r := r ? "Draw" : ""
	GuiControl, Move%r%, %c%, %l%
}


CIE_Size:
	CIE_Anchor("ComboBox1"       , "w")
	CIE_Anchor("ComboBox2"		 , "x")
	CIE_Anchor("SysListView321"  , "wh")
	SendMessage, 4118,,,, ahk_id %CIE_hLV%		;LVM_ARRANGE
Return


;---------------------------------------------------------------------------
; Save settings if present and exit
;
CIE_Exit(){
	local w, h, x, y, sRect
	
	if CIE_settings !=									 
	{
		VarSetCapacity(sRect, 16)
		DllCall("GetClientRect", "uint", CIE_hwnd, "uint", &sRect) 	
		w := NumGet(sRect, 8), 	h := NumGet(sRect, 12)
		CIE_CfgSet( "GuiW", w ), CIE_CfgSet( "GuiH", h )

		WinGetPos, x, y,,,ahk_id %CIE_hwnd%
		CIE_CfgSet( "GuiPos", "x" x " y" y )
		CIE_CfgSet( "File", CIE_File )

		CIE_CfgSet( "IconSize", CIE_IconSize )
		CIE_CfgSet( "Filter", CIE_Filter )
		CIE_CfgSet( "Flags", CIE_Flags )
	}

	_ := CIE_settings := CIE_hwnd := CIE_scanning := CIE_nextFile := CIE_guiNum := CIE_idIconList := CIE_file := CIE_hLV := CIE_Filter := ""
	Gui, Destroy
}

CIE_Close:
CIE_Escape:
	CIE_Exit()
Return

;---------------------------------------------------------------------------
; Get configuration entery from ini file (or registry, eventualy)
;
CIE_CfgGet( var, def="" ){
	global

	IniRead, var, %CIE_settings%, ChooseIconEx, %var%, %A_SPACE%
    if var =
      return def
	return var
}
;---------------------------------------------------------------------------
; Set configuration entery in ini file (or registry eventualy)
;
CIE_CfgSet( var, value ) {
	global
    IniWrite, %value%, %CIE_settings%, ChooseIconEx, %var%
}


;----------------------------------------------------------------------------
; Hotkey handlers
CIE_Hotkey_Enter() {
	local var

	ControlGetFocus, var, ahk_id %CIE_hwnd%

	if (var="Edit1")
		return CIE_Scan()

	if (var="Edit2")
		return CIE_OnFilter()

	if (var="SysListView321") {
		Gui, %CIE_guiNum%:Default		;hm.. ? why ? doesn't work without it 
		CIE_OnIconClick( LV_GetNext() )
		return
	}
}

CIE_Hotkey_Backspace(){
	local var
	ControlGetFocus, var, ahk_id %CIE_hwnd%
	if (var="SysListView321") and CIE_File != ">drives"
		CIE_OnIconClick( 1 )
}

_CIE_Hotkey_Enter:
	CIE_Hotkey_Enter()
return 

_CIE_Hotkey_Backspace:
	CIE_Hotkey_Backspace()
return

;----------------------------------------------------------------------------
; ImageList replacement
;
CIE_ILAdd(hIml, FileName, IconNumber) {
	local hIcon

	DllCall("PrivateExtractIcons"
            ,"str",Filename,"int",IconNumber-1,"int",CIE_IconSize,"int", CIE_IconSize
            ,"uint*",hIcon,"uint*",0,"uint",1,"uint",0,"int")

	res := DllCall("comctl32.dll\ImageList_ReplaceIcon", "uint", hIml, "int", -1, "uint", hIcon) 
	DllCall("DestroyIcon","uint",hIcon)

	return res + 1
}

CIE_ILCreate(InitialCount, GrowCount){
	global
	static  ILC_COLOR := 0, ILC_COLOR4 := 0x4, ILC_COLOR8 := 0x8, ILC_COLOR16 := 0x10, ILC_COLOR24 := 0x18, ILC_COLOR32 := 0x20 

	return DllCall("comctl32.dll\ImageList_Create"
	 ,"int", CIE_IconSize, "int", CIE_IconSize, "uint", ILC_COLOR24, "int", InitialCount, "int", GrowCount) 
}

;----------------------------------------------------------------------------

CIE_DefaultGui() { 
   if A_Gui != 
      return A_GUI 
   Gui, +LastFound 
   m := DllCall( "RegisterWindowMessage", Str, "GETDEFGUI") 
   OnMessage(m, "A_DefaultGui") 
   res := DllCall("SendMessageA", "uint", WinExist(), "uint", m, "uint", 0, "uint", 0) 
   OnMessage(m, "") 
   return res 
}

;--------------------------------------------------------------------------------------------------------------------- 
; Group: About 
;      o Ver 1.53 by majkinetor. See <http://www.autohotkey.com/forum/topic17299.html>
;      o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>
; http://www.autohotkey.com/board/topic/64736-lv-sortarrow-apply-sort-arrows-to-your-listview/
DebugBIF()
DllCall("ole32\CoInitialize", "UInt", 0)
;Gui, Add, ListView, r10 hwndhListView gListViewLabel, Sort Me|Sort Me 2
Gui, Add, ListView, r10  AltSubmit LV0x4423 0x06310049 E0x210 hwndhListView gListViewLabel, Sort Me|Sort Me 2
LV_ModifyCol(2, "Integer Left")
Loop 10
	LV_Add("", SubStr("abcdefghij", A_Index, 1), A_Index)
Gui, Add, Button, Section gButton1, Col1 up/asc
Gui, Add, Button, gButton2, Col1 down/desc
Gui, Add, Button, ys gButton3, Col2 up/asc
Gui, Add, Button, gButton4, Col2 down/desc
Gui, Show,, ListView Sort Arrows
Return

; this label will launch when a user interacts with our ListView.
ListViewLabel:
	If (A_GuiEvent = "ColClick") ; A_GuiEvent tells us what kind of event triggered the label.
;		LV_SortArrow(hListView, A_EventInfo) ; call the function if our column was clicked.
{
		r := LV_SortArrow(hListView, A_EventInfo) ; call the function if our column was clicked.
tooltip, Bingo! result=%r%
settimer, ttoff, -3000
}
Return

ttoff:
tooltip
return

Button1:
	LV_ModifyCol(1, "Sort"), LV_SortArrow(hListView, 1, "up")
return

Button2:
	LV_ModifyCol(1, "SortDesc"), LV_SortArrow(hListView, 1, "down")
return

Button3:
	LV_ModifyCol(2, "Sort"), LV_SortArrow(hListView, 2, "up")
return

Button4:
	LV_ModifyCol(2, "SortDesc"), LV_SortArrow(hListView, 2, "down")
return

GuiEscape:
GuiClose:
	ExitApp
;======================================================================

; LV_SortArrow by Solar. http://www.autohotkey.com/forum/viewtopic.php?t=69642
; h = ListView handle
; c = 1 based index of the column
; d = Optional direction to set the arrow. "asc" or "up". "desc" or "down".
LV_SortArrow(h, c, d="")
{
static ptr, ptrSize, lvColumn, LVM_GETCOLUMN, LVM_SETCOLUMN
if (!ptr)
	{
	ptr := A_PtrSize ? ("ptr", ptrSize := A_PtrSize) : ("uint", ptrSize := 4)
	LVM_GETCOLUMN := A_IsUnicode ? (4191, LVM_SETCOLUMN := 4192) : (4121, LVM_SETCOLUMN := 4122)
;	VarSetCapacity(lvColumn, ptrSize + 4)
	VarSetCapacity(lvColumn, 32)
	}
NumPut(1, lvColumn, 0, "uint")	; LVCF_FMT
c -= 1
DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", c, ptr, &lvColumn)
if ((fmt := NumGet(lvColumn, 4, "int")) & 0x400)	; HDF_SORTUP
	{
	if (d && d = "asc" || d = "up")
		return
	NumPut((fmt & ~0x400) | 0x200, lvColumn, 4, "int")
	}
else if (fmt & 0x200)	; HDF_SORTDOWN
	{
	if (d && d = "desc" || d = "down")
		return
	NumPut((fmt & ~0x200) | 0x400, lvColumn, 4, "int")
	}
else
	{
	; LVM_GETHEADER=0x101F, HDM_GETITEMCOUNT=0x1200
	Loop % DllCall("SendMessage", ptr, DllCall("SendMessage", ptr, h, "uint", 0x101F, "UInt", 0, "UInt", 0), "uint", 0x1200, "UInt", 0, "UInt", 0)
		if ((i := A_Index - 1) != c)
		{
		DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", i, ptr, &lvColumn)
		NumPut(NumGet(lvColumn, 4, "int") & ~0x600, lvColumn, 4, "int")
		if !DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", i, ptr, &lvColumn)
			msgbox, Error in LVM_SETCOLUMN() #1
		}
	NumPut(fmt | (d && d = "desc" || d = "down" ? 0x200 : 0x400), lvColumn, 4, "int")
	}
msgbox, LVM_GETCOLUMN=%LVM_GETCOLUMN% LVM_SETCOLUMN=%LVM_SETCOLUMN% fmt=%fmt% ptr=%ptr%
	return DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", c, ptr, &lvColumn)
}

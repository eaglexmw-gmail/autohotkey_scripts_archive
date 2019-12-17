#NoEnv
#SingleInstance force
SkinForm(Apply, A_ScriptDir . "\USkin.dll", A_ScriptDir . "\Milikymac.msstyles")
OnExit, GetOut
Gui, add, button,xm w100 h40, Button
Gui, add, edit, xm y+20 w100 h20, Edit
Gui, add, listbox,xm y+20, ListBox
Gui, add, checkbox,xm y+20, checkbox
Gui, add, DDL, xm y+20, DropDownList
Gui, Show, AutoSize, Test
return

GetOut:
GuiClose:
Gui, Hide
SkinForm(0)
ExitApp
return

SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
		}
}
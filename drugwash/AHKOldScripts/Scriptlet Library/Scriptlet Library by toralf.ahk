WinNameGui1 = Scriptlet Library v2
;requires AHK 1.0.37

Gui, 1:+Resize
Gui, 1:Add, Button, Section gBtnAdd, &Add
Gui, 1:Add, Button, ys vBtnDelete gBtnDelete Disabled, &Del
Gui, 1:Add, Button, x+100 ys vBtnSave gBtnSave Disabled, &Save changes
Gui, 1:Add, Button, ys gBtnCopy, Copy to &Clipboard
Gui, 1:Add, ListView, xs Section w100 h200 -Multi AltSubmit vLsbNames gLsbNames, Scriptlet Name|Internal ID
Internal_ID = 0
Loop, Read, %A_ScriptName%.ini
    {
        If A_LoopReadLine Contains <---Start_
            {
                Internal_ID++
                StringReplace, Name, A_LoopReadLine, <---Start_,
                LV_Add("",Name,Internal_ID)
                ItemInProcess := True
                Script%Internal_ID% =
            }
        Else If A_LoopReadLine Contains <---End_,
            {
                ItemInProcess := False
                StringTrimRight, Script%Internal_ID%, Script%Internal_ID%, 1
            }
        Else If ItemInProcess
                Script%Internal_ID% := Script%Internal_ID% . A_LoopReadLine . "`n"
    }
Gui, 1:Font, , Courier
Gui, 1:Add, Edit, ys w200 h200 Multi T8 vEditData,
IniRead, GuiSize1, %A_ScriptName%.ini, Settings, GuiSize1, %A_Space%
Gui, 1:Show, %GuiSize1%, %WinNameGui1%
WinGet, Gui1UniqueID, ID, %WinNameGui1%
GuiRolledUp := False
Return

$Rbutton::
  MouseGetPos, , , GuiID
  If ( Gui1UniqueID = GuiID )
    {
      If GuiRolledUp
        {
          GuiControl, 1:Move, LsbNames, h%LsbNamesH%
          Gui, 1:Show, AutoSize
        }
      Else
        {
          GuiControlGet, LsbNames, Pos, LsbNames
          WinMove, ahk_id %Gui1UniqueID%,,,,, 30
        }
      GuiRolledUp := not GuiRolledUp
    }
  Else
      Send, {Rbutton}
return

LsbNames:
    LV_GetText(ID, LV_GetNext(), 2)
    If ( ID <> "Internal ID" )
      {
        GuiControl,1:, EditData, % Script%ID%  ;%
        GuiControl,1: Enable, BtnDelete
        GuiControl,1: Enable, BtnSave
      }
    Else
      {
        GuiControl,1:, EditData
        GuiControl,1: Disable, BtnDelete
        GuiControl,1: Disable, BtnSave
      }
Return

BtnAdd:
    Gui, 1:+OwnDialogs
    Gui, 1:Submit, NoHide
    InputBox, Name, Enter Scriptlet Name:,,, 200, 90
    IfNotEqual, ErrorLevel, 0, Return
    IfEqual, Name,, Return
    Gui, 1:Submit, NoHide
    Internal_ID++
    LV_Add("Select",Name,Internal_ID)
    LV_ModifyCol(1, "Sort")
    Script%Internal_ID% = %EditData%
Return

BtnDelete:
    RowNumber := LV_GetNext()
    LV_GetText(Name, RowNumber, 1)
    MsgBox, 4, Delete Scriptlet?, Please confirm deletion`nof current scriptlet:`n%Name%
    IfMsgBox, Yes
        {
            LV_GetText(ID, RowNumber, 2)
            Script%ID% =
            LV_Delete(RowNumber)
        }
Return

BtnSave:
    Gui, 1:Submit, NoHide
    LV_GetText(ID, LV_GetNext(), 2)
    Script%ID% = %EditData%
Return

BtnCopy:
    Gui, 1:Submit, NoHide
    Clipboard = %EditData%
Return

GuiEscape:
GuiClose:
    If GuiRolledUp
        {
          GuiControl, 1:Move, LsbNames, h%LsbNamesH%
          Gui, 1:Show, AutoSize
        }
    FileDelete, %A_ScriptName%.ini
    WinGetPos, PosX, PosY, SizeW, SizeH, %WinNameGui1%
    IniWrite, x%PosX% y%PosY% w%SizeW% h%SizeH%, %A_ScriptName%.ini, Settings, GuiSize1
    FileAppend, `n`n, %A_ScriptName%.ini
    Loop, % LV_GetCount()  ;%
        {
            LV_GetText(Name, A_Index, 1)
            LV_GetText(ID, A_Index, 2)
            Script := Script%ID%
            FileAppend, <---Start_%Name%`n%Script%`n<---End_%Name%`n`n`n, %A_ScriptName%.ini
        }
    ExitApp
Return

GuiSize:
    new_w := (A_GuiWidth - 30 ) / 3
    new_h := A_GuiHeight - 41
    GuiControl, 1:Move, LsbNames, w%new_w% h%new_h%
    LV_ModifyCol(1, new_w)
    LV_ModifyCol(2, 0)
    new_x := new_w + 20
    new_w := new_w * 2
    GuiControl, 1:Move, EditData, w%new_w% h%new_h% x%new_x%
Return

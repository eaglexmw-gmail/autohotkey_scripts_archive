; --------------------------------------
; Drag&Drop Library for listbox
; by Dadepp
; Version 1.2.1
; http://www.autohotkey.com/forum/viewtopic.php?t=32660
; Thanks goes out to majkinetor for corrections and suggestions.
; --------------------------------------
;
; List of functions the User may call:
;
; --------------------------------------
; LBDDLib_Init(Options)
; Must be called or Drag&Drop won't work!
; Leave the Options blank to start with default values!
; The Options can be any of the following in any order, but musst be enclosed
; in a string and be seperated with a Space!
; The following three options specify function names. They will be called
; when the corresponding events take place. They will be called before any
; control specific similar option switches, and these functions ignore any
; return values as they are only there to inform, not to allow/disallow an action!
;   V: Specify v followed with the name of a function that will be
;      called when the Drag-Event starts.
;   H: Specify h followed with the name of a function that will be
;      called when the Drag-Event is taking place.
;   G: Specify g followed with the name of a function that will be
;      called when the Drop-Event takes place.
; The following two options are mutually exclusiv, and "UseEventNumbers"
; is the default value, if no such option is set.
;   "UseEventNames":
;      When "UseEventNames" is used the return value of the function
;      LBDDLib_UserVar("Event")
;      will be strings corresponding to the Event taking place, instead of numbers.
;     (See function below for more info!)
;   "UseEventNumbers":
;      When "UseEventNumbers" is used the return value of the function
;      LBDDLib_UserVar("Event")
;      will be numbers corresponding to the Event taking place, instead of strings.
;     (See function below for more info!)
;
; --------------------------------------
; LBDDLib_Add(hWnd, Switch, Options)
; Adds an existing control to the internal list of possible drop targets.
;
; The first parameter MUST be the handle to the control.
; To get the handle of a control see:
; http://www.autohotkey.com/docs/commands/Gui.htm#HwndOutputVar
;
; The second parameter can be one of the following:
;   "ddlb" or 0:
;      Identifies the handle as a handle to a listbox, and makes it Drag&Drop-able.
;      Note: This is the default, if the second parameter is omited!
;  "lb" or "target" or "droponly" or 1:
;      Identifies the handle as a handle to a listbox, and makes it
;      a Drop-Target ONLY, meaning u can't drag from it only onto it.
;  "eb" or "editbox" or "edit" or 2:
;      Identifies the handle as a handle to an EditBox, and makes it a Drop-Target ONLY.
;   "custom" or 3:
;      Identifies the handle as a handle to a not supported control,
;      and requires an User defined CallBack-Function.
;
; The third parameter MUST be a string if it is used, since it is optional!
; The possible options are:
; (Write the value directly after the Option-Switch, and seperate the options with a
; space.The order of the Option-Switches do not matter, they can be put in any order,
; and they are non case-sensitive! If you don't define an
; Option-Switch the default Value will be used instead!)
; For listboxes:
;   T: Specify T and afterwards a number greater than 0. This is the height in Pixel
;      for the Rect on Top of the listbox, that is used to indicate when the listbox
;      should be scrolled up.
;      Default value: 20
;   B: Specify T and afterwards a number greater than 0. This is the height in Pixel
;      for the Rect on the Bottom of the Listbox, that is used to indicate when the
;      listbox should be scrolled down.
;      (Same as the T-option, but for the bottom!)
;      Default value: 20
;   S: Specify S and afterwards either 0 or 1 or 2.
;      If you specified 0, it means the listbox accepts Drops from other listboxes,
;      and allows its own entries to be dragged onto other controls.
;      If you specified 1, the listbox ONLY accepts items from itself and allows
;      only for dragging its own item onto itself.
;      If you specified 2, the listbox accepts items from other listboxes, BUT ONLY
;      allows items to be dragged onto itself.
;      Default value: 0
;   Instead of using the S Option-Switch, the following substitutes can be used:
;      "global": Has the same effect as using S0
;      "OnlySelf": Has the same effect as using S1
;      "accept" or "drop": Has the same effect as using S2
;   I: Specify I and afterwards either 1 or 2 or 3.
;      If you specified 1, it means the listbox will draw an arrow as an insertion-mark.
;      If you specified 2, it means the listbox will draw a line as an insertion-mark.
;      If you specified 3, it means the listbox will draw both,
;      an arrow and a line as an insertion-mark.
;   Instead of using the I Option-Switch, the following substitutes can be used:
;      "InsArrow": Has the same effect as using I1
;      "InsArrow": Has the same effect as using I2
;      "InsArrowLine": Has the same effect as using I3
;   V: Specify V and afterwards a string containing the name of a Function (NOT a Label,
;      it must be a function), that will be called if a Drag-Event occurs!
;      The Function MUST return True if the Drag-Event is allowed, or False if the
;      Drag-Even is not allowed! The default behaviour (if no return is called or if an
;      invalid value is returned!) is False, meaning NO drag-event is started.
;      The Function MUST NOT have any parameters!
;      To retrieve information on what listbox the item comes from what number the
;      original item has, use the Provided function:
;      LBDDLib_UserVar. (refer below on how to use it!)
;      Default value: "" (meaning non-existant)
; Note: The Options for EditBoxes only apply if u don't use a custom function to handle
;       the drop event, meaning if u let the lib do the moving of the listbox item.
; For EditBoxes:
;   M: Specify M and afterwards either 0 or 1.
;      If you specified 0, the original text of the EditBox will be preserved and the
;      text of the Listbox's item will be added after (appended) the original EditBox text.
;      If you specified 1, the original text of the EditBox will be deleted, and
;      replaced with the listbox item's.
;      Default value: 1
;   Instead of using the M Option-Switch, the following substitutes can be used:
;      "add": Has the same effect as using M0
;      "del": Has the same effect as using M1
;   D: Used in conjuction with M1 or "add"!
;      Specify D and afterwards a string, that will be used as a Delimiter,
;      when text will be added to the EditBox. Can be a string of undefined length.
;      WARNING: Do not use a space character inside this string, or the options might
;      not be identified correctly. Use %A_Space% instead (inside the string),
;      like this: "D|%A_Space%|" would produce "| |" between the
;      EditBox's original text and the appended text (Note The "" are NOT included!)
;      Default value: " " (meaning A_Space!)
; Option-Switches that can be applied to any control:
;   O: Specify O and afterwards either 0 or 1.
;      (Note: This Option-Switch only applies if u use the lib's function to move item.
;             (Same note as with EditBoxes!!))
;      If you specified 0, the original listbox item will NOT be deleted if u drop it
;      onto the control that has this option set.
;      If you specified 1, the original listbox item will be deleted if u drop it onto
;      the control that has this option set.
;      Default value: 1
;   Instead of using the O Option-Switch, the following substitute can be used:
;      "NoRemove": Has the same effect as using O0
;      "Remove": Has the same effect as using O1
;   G: Specify G and afterwards a string containing the name of a Function (NOT a Label,
;      it must be a function), that will be called when the drop-event occurs!
;      The Function MUST NOT have any parameters!
;      (Note: You can specify different functions to different controls!)
;      To retrieve information on what listbox the item comes from, onto what control it's
;      item is dropped and what number the original item, and the insertion point has,
;      use the Provided function: LBDDLib_UserVar. (refer below on how to use it!)
;      If u only want to use this function to retrieve this info and don't want to do the
;      moving of the items yourself, use LBDDLib_CallBack at the end of your function.
;      Default value: "" (meaning non-existant)
; --------------------------------------
; LBDDLib_Modify(hWnd, Options)
; Modify the options that were set during adding of the control.
; Leave options blank to reset every option to its default value!
; --------------------------------------
; LBDDLib_ModifyGlobal(Options)
; Modify the Global Options set with LBDDLib_Init().
; --------------------------------------
; LBDDLib_UserVar(Switch)
; Retrieve information on which listbox the item, was dragged from, what number it has,
; which control will recieve the drop and if that is a listbox, the number to insert the item.
;
; Note: Only handels will be retrieved, NOT the Variable associated with the control!
;       To compare two handels declare the variable containing the controls hanlde as Global
;       inside the function, and use this method to comapre them:
;
;       Global VarContainingControlHandle
;       if (VarContainingControlHandle+0 == VarcontainingRetrievedHandle)
;
;       The +0 is needed, because AutoHotKey stores the handle as Hex values,
;       and my Lib stores them as normal decimal values!
;
; The param can be any of the following (a number or a non case-sensitive string)
;   "ThWnd" or 1:
;     With this parameter the function returns the handle of the control, onto which
;     the item is dropped.
;   "ShWnd" or 2:
;     With this parameter the function returns the handle of the listbox, from which
;     the item originates.
;   "ItemToMove" or 3:
;     Woth this parameter the function returns the position-number of the item,
;     that is being dragged.
;   "NewPosition" or 4:
;     If the target of the Drag&Drop event is a listbox, then this parameter returns
;     the position-number of the target's listbox, into which the dragged item is to
;     be inserted. Otherwise it return the value -10.
;   "event" or 5:
;     This is only used with the custom-function assigned in the the V Option-Switch!
;     This returns 0 if the custom function is called to allow/disallow the start of a
;     drag-event.
;     This returns 1 if the custom function is called to allow/disallow the current
;     drag-event to be droped onto the control specified with the param "ThWnd"!
;     Otherwise this returns -10.
;     Other return values: (only applies for the Global functions, defined in LBDDLib_Init())
;     (Note the numbers will be used as default, unless the "UseEventNames" options is used
;     within the LBDDLib_Init() options.)
;       -9 or "Verify":
;         This means the v-Label function is called at the start of the Drag-Event.
;       -8 or "Hover":
;         This means the h-Label function is called during the Drag-Event.
;         The mouse is over a valid control, that accepts drops.
;         (Note: If the listbox has the "OnlySelf" option set, LBDDLib_UserVar("NewPosition")
;                will return -10 )
;       -7 or "OutOfBounds":
;       The following returns are used only used for the g-Label functions!
;       -6 or "Drop":
;         This means a Drop-Event occured onto an valid target.
;       -5 or "DropOutOfBounds":
;         This means a Drop-Event occured onto an InValid target.
;       -4 or "DragCancel":
;         The user aborted the Drag-Event, by pressing ESC or the right mouse button.
; --------------------------------------
; LBDDLib_CallBack()
; If you specified a custom function that is called when the drop event occurs, but do not
; want to handle the moving of the item. The specified options will be considered this way!
; --------------------------------------
; LBDDLib_LBGetItemText(hWnd, Item)
; Wrapper function that retrieves the Text of an Item in an listbox, defined through its handle.
; --------------------------------------
; LBDDLib_LBDelItem(hWnd, Item)
; Wrapper function that deletes an Item in an listbox, defined through its handle.
; --------------------------------------
; LBDDLib_LBInsItem(hWnd, MyPos, MyText)
; Wrapper function that inserts an Item, defines through MyPos (the position to insert it)
; and MyText (the item-text) in an listbox, defined through its handle.





LBDDLib_Init(Options=0)
{
  Global
  Static DRAGLISTMSGSTRING="commctrl_DragListMsg"
  OnMessage(DllCall("RegisterWindowMessage", "str", DRAGLISTMSGSTRING), "LBDDLib_msgFunc")
  LBDDLib_resetOptionsMain()
  if (Options <> 0)
    LBDDLib_parseOptionsMain(Options)
}

LBDDLib_Add(hWnd, Switch=0, Options=0)
{
  Local ArrayMax
  hWnd := hWnd+0
  ArrayMax := LBDDLibArray_0
  ArrayMax ++
  LBDDLibArray_0 := ArrayMax
  if ((Switch = 0) || (Switch = "DDLB")){
    DllCall("MakeDragList", "Uint", hWnd)
    Switch := 1
  }
  else if ((Switch = "LB") || (Switch = "target") || (Switch = "droponly"))
    Switch := 1
  else if ((Switch = "EB") || (Switch = "editbox") || (Switch = "edit"))
    Switch := 2
  else if (Switch = "custom")
    Switch := 3
  LBDDLibArray_%ArrayMax%_Type := Switch
  LBDDLibArray_%ArrayMax% := hWnd
  LBDDLib_resetOptions(ArrayMax)
  if (Options == 0)
    return
  LBDDLib_parseOptions(ArrayMax, Options)
}

LBDDLib_Modify(hWnd, Options=0)
{
  ArrayNum := LBDDLib_isValidHandle(hWnd)
  if (ArrayNum == 0)
    return
  if (Options == 0)
    LBDDLib_resetOptions(ArrayNum)
  else
    LBDDLib_parseOptions(ArrayNum, Options)
}

LBDDLib_ModifyGlobal(Options=0)
{
  if (Options == 0)
    LBDDLib_resetOptionsMain()
  else
    LBDDLib_parseOptionsMain(Options)
}

LBDDLib_UserVar(Switch, param=0)
{
  Static TargethWnd, SourcehWnd, ItemToMove, NewPosition, VerifyEvent
  if ((Switch == 1) || (Switch = "ThWnd"))
    return TargethWnd
  else if ((Switch == 2) || (Switch = "ShWnd"))
    return SourcehWnd
  else if ((Switch == 3) || (Switch = "ItemToMove"))
    return ItemToMove
  else if ((Switch == 4) || (Switch = "NewPosition"))
    return NewPosition
  else if ((Switch == 5) || (Switch = "Event"))
    return VerifyEvent
  else if (Switch == -1)
    TargethWnd := param
  else if (Switch == -2)
    SourcehWnd := param
  else if (Switch == -3)
    ItemToMove := param
  else if (Switch == -4)
    NewPosition := param
  else if (Switch == -5)
    VerifyEvent := param
  else
    return
}

LBDDLib_CallBack(Init=0, ItemToMove=0, hWnd_source=0, ArrayNum=0)
{
  Static MyItemToMove, MyhWnd_source, MyArrayNum, MyNewPosition
  if (Init == 1){
    MyItemToMove := ItemToMove
    MyhWnd_source := hWnd_source
    MyArrayNum := ArrayNum
  }
  else if (Init == 2){
    MyNewPosition := ItemToMove
  }
  else
  {
    MyType := LBDDLib_getType(MyArrayNum)
    if (MyType == 1){
      LBDDLib_moveListBoxEntry2ListBox(MyItemToMove, MyNewPosition, MyhWnd_source, MyArrayNum)
    }
    else if (MyType == 2){
      LBDDLib_moveListBoxEntry2EditBox(MyItemToMove, MyhWnd_source, MyArrayNum)
    }
  }
}

LBDDLib_LBGetItemText(hWnd, Item)
{
  Static LB_GETTEXT=0x189, LB_GETTEXTLEN=0x18A
  SendMessage, LB_GETTEXTLEN, Item, 0,, ahk_id %hWnd%
  VarSetCapacity(TempVar, ErrorLevel)
  SendMessage, LB_GETTEXT, Item, &TempVar,, ahk_id %hWnd%
  return TempVar
}

LBDDLib_LBDelItem(hWnd, Item)
{
  Static LB_DELETESTRING=0x182
  SendMessage, LB_DELETESTRING, Item, 0,, ahk_id %hWnd%
}

LBDDLib_LBInsItem(hWnd, MyPos, MyText)
{
  Static LB_INSERTSTRING=0x181
  SendMessage, LB_INSERTSTRING, MyPos, &MyText,, ahk_id %hWnd%
}

;-----------------------------------------------------------------------------------------
; Below here are the private functions. Only call these if you know what you are doing!!!
;-----------------------------------------------------------------------------------------

LBDDLib_resetOptions(ArrayNum)
{
  Local Switch
  Switch := LBDDLibArray_%ArrayNum%_Type
  LBDDLibArray_%ArrayNum%_Func := "  "
  LBDDLibArray_%ArrayNum%_DeleteOrig := 1
  if (Switch == 1){
    LBDDLibArray_%ArrayNum%_LBT := 20
    LBDDLibArray_%ArrayNum%_LBB := 20
    LBDDLibArray_%ArrayNum%_OnlySelf := 0
    LBDDLibArray_%ArrayNum%_Insert := 1
  }
  else if (Switch == 2){
    LBDDLibArray_%ArrayNum%_AddModus := 1
    LBDDLibArray_%ArrayNum%_AddDelimiter := " "
  }
}

LBDDLib_resetOptionsMain()
{
  Global
  LBDDLibArray_0_Func := "   "
  LBDDLibArray_0_Options := 1
}

LBDDLib_parseOptionsMain(Options=0)
{
  Global
  Loop, Parse, Options, %A_Space%
  {
    if (A_LoopField = "UseEventNames")
      LBDDLibArray_0_Options := 0
    if (A_LoopField = "UseEventNumbers")
      LBDDLibArray_0_Options := 1
    if (SubStr(A_LoopField, 1, 1) = "g")
      LBDDLib_setFunc(0, SubStr(A_LoopField, 2), 0)
    if (SubStr(A_LoopField, 1, 1) = "v")
      LBDDLib_setFunc(0, SubStr(A_LoopField, 2), 1)
    if (SubStr(A_LoopField, 1, 1) = "h")
      LBDDLib_setFunc(0, SubStr(A_LoopField, 2), 2)
  }
}

LBDDLib_parseOptions(ArrayNum, Options=0)
{
  Local Switch
  Switch := LBDDLibArray_%ArrayNum%_Type
  Loop, Parse, Options, %A_Space%
  {
    if ((Switch == 1) && (A_LoopField = "global"))
      LBDDLibArray_%ArrayNum%_OnlySelf := 0
    else if ((Switch == 1) && (A_LoopField = "OnlySelf"))
      LBDDLibArray_%ArrayNum%_OnlySelf := 1
    else if ((Switch == 1) && (A_LoopField = "accept"))
      LBDDLibArray_%ArrayNum%_OnlySelf := 2
    else if ((Switch == 1) && (A_LoopField = "drop"))
      LBDDLibArray_%ArrayNum%_OnlySelf := 2
    else if ((Switch == 1) && (A_LoopField = "InsArrow"))
      LBDDLibArray_%ArrayNum%_Insert := 1
    else if ((Switch == 1) && (A_LoopField = "InsLine"))
      LBDDLibArray_%ArrayNum%_Insert := 2
    else if ((Switch == 1) && (A_LoopField = "InsArrowLine"))
      LBDDLibArray_%ArrayNum%_Insert := 3
    else if ((Switch == 2) && (A_LoopField = "add"))
      LBDDLibArray_%ArrayNum%_AddModus := 0
    else if ((Switch == 2) && (A_LoopField = "del"))
      LBDDLibArray_%ArrayNum%_AddModus := 1
    else if (A_LoopField = "noremove")
      LBDDLibArray_%ArrayNum%_DeleteOrig := 0
    else if (A_LoopField = "remove")
      LBDDLibArray_%ArrayNum%_DeleteOrig := 1
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "t"))
      LBDDLibArray_%ArrayNum%_LBT := SubStr(A_LoopField, 2)
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "b"))
      LBDDLibArray_%ArrayNum%_LBB := SubStr(A_LoopField, 2)
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "s"))
      LBDDLibArray_%ArrayNum%_OnlySelf := SubStr(A_LoopField, 2)
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "i"))
      LBDDLibArray_%ArrayNum%_Insert := SubStr(A_LoopField, 2)
    else if ((Switch == 2) && (SubStr(A_LoopField, 1, 1) = "m"))
      LBDDLibArray_%ArrayNum%_AddModus := SubStr(A_LoopField, 2)
    else if ((Switch == 2) && (SubStr(A_LoopField, 1, 1) = "d")){
      LBDDLibArray_%ArrayNum%_AddDelimiter := SubStr(A_LoopField, 2)
      StringReplace, LBDDLibArray_%ArrayNum%_AddDelimiter, LBDDLibArray_%ArrayNum%_AddDelimiter, `%A_Space`%, %A_Space%, A
    }
    else if (SubStr(A_LoopField, 1, 1) = "o")
      LBDDLibArray_%ArrayNum%_DeleteOrig := SubStr(A_LoopField, 2)
    else if (SubStr(A_LoopField, 1, 1) = "g")
      LBDDLib_setFunc(ArrayNum, SubStr(A_LoopField, 2), 0)
    else if (SubStr(A_LoopField, 1, 1) = "v")
      LBDDLib_setFunc(ArrayNum, SubStr(A_LoopField, 2), 1)
    else if (SubStr(A_LoopField, 1, 1) = "h")
      LBDDLib_setFunc(ArrayNum, SubStr(A_LoopField, 2), 2)
  }
}

LBDDLib_isValidHandle(hWnd)
{
  Global LBDDLibArray_0
  hWnd := hWnd+0
  res := 0
  Loop, %LBDDLibArray_0%
  {
    if (LBDDLibArray_%A_Index% == hWnd){
      res := A_Index
      break
    }
  }
  return res
}

LBDDLib_isValidRect(Mx, My)
{
  Global MyDLBArrayRects_0
  ArrayNum := 0
  VarSetCapacity(TempRect, 16, 0)
  Loop, %MyDLBArrayRects_0%
  {
    TempRect := MyDLBArrayRects_%A_Index%
    StringSplit, TempRect_, TempRect, |
    if (LBDDLib_ptInRect(TempRect_1, TempRect_2, TempRect_3, TempRect_4, Mx, My)){
      ArrayNum := TempRect_5
      break
    }
  }
  return ArrayNum
}

LBDDLib_initRects()
{
  Local Rect_Count=0, rcListBox, hWnd, MyRect, MyRect_Temp
  Static HWND_DESKTOP=0x0
  VarSetCapacity(rcListBox, 16, 0)
  Loop, %LBDDLibArray_0%
  {
    if (LBDDLibArray_%A_Index%_Type == 1){
      Rect_Count ++
      hWnd := LBDDLibArray_%A_Index%
      DllCall("GetClientRect", "UInt", hWnd, "UInt", &rcListBox)
      DllCall("MapWindowPoints", "UInt", hWnd, "UInt", HWND_DESKTOP, "UInt", &rcListBox, "Int", 2)
      MyRect_Temp := NumGet(rcListBox, 0, "Int")
      MyRect := MyRect_Temp
      MyRect_Temp := NumGet(rcListBox, 4, "Int")
      MyRect_Temp -= LBDDLibArray_%A_Index%_LBT
      MyRect_Temp ++
      MyRect .= "|"MyRect_Temp
      MyRect_Temp := NumGet(rcListBox, 8, "Int")
      MyRect .= "|"MyRect_Temp
      MyRect_Temp := NumGet(rcListBox, 12, "Int")
      MyRect_Temp += LBDDLibArray_%A_Index%_LBB
      MyRect_Temp --
      MyRect .= "|"MyRect_Temp
      MyRect .= "|"A_Index
      MyDLBArrayRects_%Rect_Count% := MyRect
    }
  }
  MyDLBArrayRects_0 := Rect_Count
}

LBDDLib_setFunc(ArrayNum, Value, Switch=0)
{
  Local pos1, pos2
  pos1 := InStr(LBDDLibArray_%ArrayNum%_Func, A_Space)
  pos2 := InStr(LBDDLibArray_%ArrayNum%_Func, A_Space, false, pos1+1)
  if (Switch == 0)
    LBDDLibArray_%ArrayNum%_Func := Value . A_Space . SubStr(LBDDLibArray_%ArrayNum%_Func, pos1+1)
  else if (Switch == 1)
    LBDDLibArray_%ArrayNum%_Func := SubStr(LBDDLibArray_%ArrayNum%_Func, 1, pos1) . Value . SubStr(LBDDLibArray_%ArrayNum%_Func, pos2)
  else if (Switch == 2)
    LBDDLibArray_%ArrayNum%_Func := SubStr(LBDDLibArray_%ArrayNum%_Func, 1, pos2) . Value
}

LBDDLib_getFunc(ArrayNum, Switch=0)
{
  pos1 := InStr(LBDDLibArray_%ArrayNum%_Func, A_Space)
  pos2 := InStr(LBDDLibArray_%ArrayNum%_Func, A_Space, false, pos1+1)
  if (Switch == 0)
    return SubStr(LBDDLibArray_%ArrayNum%_Func, 1, pos1-1)
  else if (Switch == 1)
    return SubStr(LBDDLibArray_%ArrayNum%_Func, pos1+1, pos2-pos1-1)
  else if (Switch == 2)
    return SubStr(LBDDLibArray_%ArrayNum%_Func, pos2+1)
}

LBDDLib_getHandle(ArrayNum)
{
  return LBDDLibArray_%ArrayNum%
}

LBDDLib_getType(ArrayNum)
{
  return LBDDLibArray_%ArrayNum%_Type
}

LBDDLib_getLBInfo(Switch, ArrayNum)
{
  if (Switch == 1)
    res := LBDDLibArray_%ArrayNum%_LBT
  else if (Switch == 2)
    res := LBDDLibArray_%ArrayNum%_LBB
  else if (Switch == 3)
    res := LBDDLibArray_%ArrayNum%_OnlySelf
  else if (Switch == 4)
    res := LBDDLibArray_%ArrayNum%_Insert
  else
    res := 0
  return res
}

LBDDLib_getMainOptions(Switch=0)
{
  Global
  if (Switch == 0)
    return LBDDLibArray_0_Options
}

LBDDLib_getVerifyEvent(EventNum)
{
  if (EventNum == -9)
    return "Verify"
  else if (EventNum == -8)
    return "Hover"
  else if (EventNum == -7)
    return "OutOfBounds"
  else if (EventNum == -6)
    return "Drop"
  else if (EventNum == -5)
    return "DropOutOfBounds"
  else if (EventNum == -4)
    return "DragCancel"
  else
    return -10
}

LBDDLib_drawInsert(hWnd, Switch, ArrayNum=0, ItemNum=0)
{
  Static LastUsedInsert, OldItemRect, OldLineRect, hArrow, syscolor
  Static LB_ERR=-1, LB_GETITEMRECT=0x198, LB_GETCOUNT=0x18B, LB_GETTOPINDEX=0x18E
  Static HWND_DESKTOP=0x0, RDW_INTERNALPAINT=0x2, RDW_ERASE=0x4, RDW_INVALIDATE=0x1, RDW_UPDATENOW=0x100
  Static PS_SOLID=0x0, COLOR_WINDOWTEXT=0x8
  Static DRAGICON_HOTSPOT_X=15, DRAGICON_HOTSPOT_Y=7, DRAGICON_HEIGHT=32

  if (Switch == 1){
    hArrow := DllCall("Shell32\ExtractIconA", "UInt", hWnd, "str", "comctl32.dll", "Int", 0)
    VarSetCapacity(OldItemRect, 16, 0)
    NumPut(0, OldItemRect, 0, "Int")
    NumPut(0, OldItemRect, 4, "Int")
    NumPut(0, OldItemRect, 8, "Int")
    NumPut(0, OldItemRect, 12, "Int")
    VarSetCapacity(OldLineRect, 16, 0)
    NumPut(0, OldLineRect, 0, "Int")
    NumPut(0, OldLineRect, 4, "Int")
    NumPut(0, OldLineRect, 8, "Int")
    NumPut(0, OldLineRect, 12, "Int")
    syscolor := DllCall("GetSysColor", "UInt", COLOR_WINDOWTEXT)
    return
  }
  else if (Switch == -1){
    DllCall("DestroyIcon", "UInt", hArrow)
    DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldItemRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldLineRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    return
  }
  else if (Switch == -2){
    if ((LastUsedInsert == 1) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldItemRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    if ((LastUsedInsert == 2) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldLineRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    return
  }

  LB_hWnd := LBDDLib_getHandle(ArrayNum)
  VarSetCapacity(rcItem, 16, 0)
  VarSetCapacity(rcListBox, 16, 0)
  VarSetCapacity(rcDragIcon, 16, 0)
  VarSetCapacity(rcDragLine, 16, 0)
  SendMessage, LB_GETCOUNT, 0, 0,, ahk_id %LB_hWnd%
  ItemCount := ErrorLevel-1
  if (ItemNum <= ItemCount)
    SendMessage, LB_GETITEMRECT, ItemNum, &rcItem,, ahk_id %LB_hWnd%
  else
    SendMessage, LB_GETITEMRECT, ItemCount, &rcItem,, ahk_id %LB_hWnd%
  if (ErrorLevel == LB_ERR)
    return
  if (ItemNum <= ItemCount)
    LB_ItemTop := NumGet(rcItem, 4, "Int")
  else
    LB_ItemTop := NumGet(rcItem, 12, "Int")
  if not DllCall("GetWindowRect", "UInt", LB_hWnd, "UInt", &rcListBox)
    return
  if not DllCall("MapWindowPoints", "UInt", LB_hWnd, "UInt", hWnd, "UInt", &rcItem, "Int", 2)
    return
  if not DllCall("MapWindowPoints", "UInt", HWND_DESKTOP, "UInt", hWnd, "UInt", &rcListBox, "Int", 2)
    return
  NumPut(NumGet(rcListBox, 0, "Int") - DRAGICON_HOTSPOT_X, rcDragIcon, 0, "Int")
  if (ItemNum <= ItemCount)
    NumPut(NumGet(rcItem, 4, "Int") - DRAGICON_HOTSPOT_Y, rcDragIcon, 4, "Int")
  else
    NumPut(NumGet(rcItem, 12, "Int") - DRAGICON_HOTSPOT_Y, rcDragIcon, 4, "Int")
  NumPut(NumGet(rcListBox, 0, "Int"), rcDragIcon, 8, "Int")
  NumPut(NumGet(rcDragIcon, 4, "Int") + DRAGICON_HEIGHT, rcDragIcon, 12, "Int")
  NumPut(NumGet(rcItem, 0, "Int"), rcDragLine, 0, "Int")
  NumPut(NumGet(rcItem, 4, "Int") - 3, rcDragLine, 4, "Int")
  NumPut(NumGet(rcItem, 8, "Int"), rcDragLine, 8, "Int")
  NumPut(NumGet(rcItem, 12, "Int") + 4, rcDragLine, 12, "Int")


  if (not DllCall("EqualRect", "UInt", &rcDragIcon, "UInt", &OldItemRect)){
    if ((LastUsedInsert == 1) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldItemRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    if ((LastUsedInsert == 2) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldLineRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    DllCall("CopyRect", "UInt", &OldItemRect, "UInt", &rcDragIcon)
    DllCall("CopyRect", "UInt", &OldLineRect, "UInt", &rcDragLine)
    if (ItemNum >= 0){
      InsertType := LBDDLib_getLBInfo(4, ArrayNum)
      LastUsedInsert := InsertType
      if ((InsertType == 1) || (InsertType == 3)){
        hdc := DllCall("GetDC", "Uint", hWnd)
        DllCall("DrawIcon", "UInt", hdc, "Int", NumGet(rcDragIcon, 0, "Int"), "Int", NumGet(rcDragIcon, 4, "Int"), "UInt", hArrow)
        DllCall("ReleaseDC", "UInt", hWnd, "UInt", hdc)
      }
      if ((InsertType == 2) || (InsertType == 3)){
        hdc := DllCall("GetDC", "Uint", LB_hWnd)
        hPen := DllCall("Gdi32\CreatePen", "UInt", PS_SOLID, "UInt", 1, "UInt", syscolor)
        DllCall("Gdi32\SelectObject", "UInt", hdc, "UInt", hPen)
        LB_Width := NumGet(rcDragLine, 8, "Int") - NumGet(rcDragLine, 0, "Int")
        ; InsertLine
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width, "Int", LB_ItemTop)
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop-1, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width, "Int", LB_ItemTop-1)
        ; Arrow on the left
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop-3, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 0, "Int", LB_ItemTop+3)
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 1, "Int", LB_ItemTop-2, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 1, "Int", LB_ItemTop+2)
        ; Arrow on the right
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-1, "Int", LB_ItemTop-3, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-1, "Int", LB_ItemTop+3)
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-2, "Int", LB_ItemTop-2, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-2, "Int", LB_ItemTop+2)
        ; cleanup
        DllCall("Gdi32\DeleteObject", "UInt", hPen)
        DllCall("ReleaseDC", "UInt", hWnd, "UInt", hdc)
      }
    }
  }
}

LBDDLib_ptInRect(RLeft, RTop, RRight, RBottom, PX, PY)
{
  return (((PX >= RLeft) && (PX <= RRight)) && ((PY >= RTop) && (PY <= RBottom)))
}

LBDDLib_itemFromPt(ArrayNum, Mx, My, bAutoScroll, dwInterval=300)
{
  Static dwScrollTime=0
  Static LB_ERR=-1, LB_GETITEMRECT=0x198, LB_GETCOUNT=0x18B, LB_GETTOPINDEX=0x18E, LB_SETTOPINDEX=0x197

  hWnd := LBDDLib_getHandle(ArrayNum)
  VarSetCapacity(rcItem, 16, 0)
  VarSetCapacity(rcListBox, 16, 0)
  VarSetCapacity(pt, 8, 0)
  NumPut(Mx, pt, 0, "Int")
  NumPut(My, pt, 4, "Int")
  DllCall("ScreenToClient", "UInt", hWnd, "UInt", &pt)
  DllCall("GetClientRect", "UInt", hWnd, "UInt", &rcListBox)
  SendMessage, LB_GETTOPINDEX, 0, 0,, ahk_id %hWnd%
  nIndex := ErrorLevel
  SendMessage, LB_GETCOUNT, 0, 0,, ahk_id %hWnd%
  ItemCount := ErrorLevel-1
  if (ItemCount == -1)
    return 0
  if (LBDDLib_ptInRect(NumGet(rcListBox, 0, "Int"), NumGet(rcListBox, 4, "Int"), NumGet(rcListBox, 8, "Int"), NumGet(rcListBox, 12, "Int"), NumGet(pt, 0, "Int"), NumGet(pt, 4, "Int")))
  {
    Loop,
    {
      SendMessage, LB_GETITEMRECT, nIndex, &rcItem,, ahk_id %hWnd%
      if (ErrorLevel == LB_ERR){
        res := -1
        break
      }
      if (LBDDLib_ptInRect(NumGet(rcItem, 0, "Int"), NumGet(rcItem, 4, "Int"), NumGet(rcItem, 8, "Int"), NumGet(rcItem, 12, "Int"), NumGet(pt, 0, "Int"), NumGet(pt, 4, "Int")))
      {
        res := nIndex
        break
      }
      nIndex ++
      if (nIndex > ItemCount){
        res := nIndex
        break
      }
    }
    return res
  }
  else
  {
    if ((NumGet(pt, 0, "Int") > NumGet(rcListBox, 8, "Int")) || (NumGet(pt, 0, "Int") < NumGet(rcListBox, 0, "Int")))
      return -1
    if ((NumGet(pt, 4, "Int") < 0) && (NumGet(pt, 4, "Int") > (0-LBDDLib_getLBInfo(1, ArrayNum)))){
      res := nIndex
      nIndex --
    }
    else
    {
      if ((NumGet(pt, 4, "Int") > NumGet(rcListBox, 12, "Int")) && (NumGet(pt, 4, "Int") < (NumGet(rcListBox, 12, "Int")+LBDDLib_getLBInfo(2, ArrayNum)))){
        tnIndex := nIndex
        Loop,
        {
          SendMessage, LB_GETITEMRECT, tnIndex, &rcItem,, ahk_id %hWnd%
          if (ErrorLevel == LB_ERR){
            tnIndex := -1
            break
          }
          if (tnIndex > ItemCount)
            break
          if (LBDDLib_ptInRect(NumGet(rcItem, 0, "Int"), NumGet(rcItem, 4, "Int"), NumGet(rcItem, 8, "Int"), NumGet(rcItem, 12, "Int"), NumGet(rcListBox, 0, "Int")+2, NumGet(rcListBox, 12, "Int")-2))
            break
          tnIndex ++
        }
        res := tnIndex+1
        nIndex ++
      }
      else
        res := -1
    }
    if (nIndex < 0)
      return 0
    if not bAutoScroll
      return res
    if ((A_TickCount - dwScrollTime) > dwInterval){
      dwScrollTime := A_TickCount
      SendMessage, LB_SETTOPINDEX, nIndex, 0,, ahk_id %hWnd%
    }
    return res
  }
  return -1
}

LBDDLib_msgFunc(wParam, lParam, uMsg, MsgParentWindow)
;Def of function parameters: http://www.autohotkey.com/docs/commands/OnMessage.htm
;Def of use of parameters: http://msdn.microsoft.com/en-us/library/bb761711(VS.85).aspx#drag_list_box_messages
{
  Static DL_BEGINDRAG=0x485, DL_DRAGGING=0x486, DL_DROPPED=0x487, DL_CANCELDRAG=0x488
  Static DL_STOPCURSOR=0x1, DL_COPYCURSOR=0x2, DL_MOVECURSOR=0x3
  Static DraggedItem, LBOnlySelf, SourceArrayNum, AllowedToDrag, hres
;  MsgParentWindow := WinExist()
;
; Use RtlMoveMemory, because lParam is only a pointer to a DRAGLISTINFO structure
; http://msdn.microsoft.com/en-us/library/bb761715(VS.85).aspx
;
  VarSetCapacity(lParam_Temp, 16, 0)
  DllCall("RtlMoveMemory", "UInt", &lParam_Temp, "UInt", lParam, "Int", 16)
  uNotification := NumGet(lParam_Temp, 0, "UInt")
  hWnd := NumGet(lParam_Temp, 4, "UInt")
  ptCursor_X := NumGet(lParam_Temp, 8, "Int")
  ptCursor_Y := NumGet(lParam_Temp, 12, "Int")

  MouseGetPos,,, MyCustomWindowhWnd, MyCustomhWnd,2
  if (MyCustomWindowhWnd+0 <> MsgParentWindow+0)
    MsgParentWindow := MyCustomWindowhWnd+0
  if (uNotification == DL_BEGINDRAG){
    SourceArrayNum := LBDDLib_isValidHandle(hWnd)
    LBOnlySelf := LBDDLib_getLBInfo(3, SourceArrayNum)
    DraggedItem := LBDDLib_itemFromPt(SourceArrayNum, ptCursor_X, ptCursor_Y, 0)
    GFuncLabel := LBDDLib_getFunc(0, 1)
    if (GFuncLabel <> "")
      LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -9)
    FuncLabel := LBDDLib_getFunc(SourceArrayNum, 1)
    res := True
    if (FuncLabel <> ""){
      res := LBDDLib_callUser(FuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, 0)
    }
    if not res
    {
      AllowedToDrag := False
      return False
    }
    else
    {
      AllowedToDrag := True
      LBDDLib_drawInsert(MsgParentWindow, 1)
      LBDDLib_initRects()
      return True
    }
  }
  else if (uNotification == DL_DRAGGING){
    if (AllowedToDrag == False)
      return
    ValidhWnd := LBDDLib_isValidHandle(MyCustomhWnd)
    if (ValidhWnd == 0){
      ValidRect := LBDDLib_isValidRect(ptCursor_X, ptCursor_Y)
      if (ValidRect == 0){
        GFuncLabel := LBDDLib_getFunc(0, 2)
        if (GFuncLabel <> "")
          LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -7)
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
      else
      {
        CurrentType := LBDDLib_getType(ValidRect)
        CurrentArray := ValidRect
      }
    }
    else
    {
      CurrentType := LBDDLib_getType(ValidhWnd)
      CurrentArray := ValidhWnd
    }
    GFuncLabel := LBDDLib_getFunc(0, 2)
    if (LBOnlySelf <> 0)
      if  (CurrentArray <> SourceArrayNum){
        if (GFuncLabel <> "")
          LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -8)
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
    LBOnlySelfTarget := LBDDLib_getLBInfo(3, CurrentArray)
    if (LBOnlySelfTarget == 1)
      if  (CurrentArray <> SourceArrayNum){
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
    FuncLabel := LBDDLib_getFunc(CurrentArray, 2)
    if (CurrentType == 1){
      CurrentItem := LBDDLib_itemFromPt(CurrentArray, ptCursor_X, ptCursor_Y, 1)
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem, -8)
      hres := True
      if (FuncLabel <> ""){
        hres := LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem, 1)
      }
      if not hres
      {
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
      else
      {
        LBDDLib_drawInsert(MsgParentWindow, 0, CurrentArray, CurrentItem)
        return DL_COPYCURSOR
      }
    }
    else
    {
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -8)
      res := True
      if (FuncLabel <> ""){
        res := LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem, -10, 1)
      }
      if not res
      {
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
      else
      {
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_COPYCURSOR
      }
    }
  }
  else if (uNotification == DL_CANCELDRAG){
    LBDDLib_drawInsert(MsgParentWindow, -1)
    GFuncLabel := LBDDLib_getFunc(0)
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -4)
  }
  else if (uNotification == DL_DROPPED){
    if (AllowedToDrag == False)
      return
    ValidhWnd := LBDDLib_isValidHandle(MyCustomhWnd)
    if (ValidhWnd == 0){
      ValidRect := LBDDLib_isValidRect(ptCursor_X, ptCursor_Y)
      if (ValidRect == 0){
        GFuncLabel := LBDDLib_getFunc(0)
          if (GFuncLabel <> "")
            LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -5)
        LBDDLib_drawInsert(MsgParentWindow, -1)
      }
      else
      {
        CurrentType := LBDDLib_getType(ValidRect)
        CurrentArray := ValidRect
      }
    }
    else
    {
      CurrentType := LBDDLib_getType(ValidhWnd)
      CurrentArray := ValidhWnd
    }
    LBDDLib_drawInsert(MsgParentWindow, -1)
    if (LBOnlySelf <> 0)
      if (CurrentArray <> SourceArrayNum)
        return
    LBDDLib_CallBack(1, DraggedItem, hWnd, CurrentArray)
    FuncLabel := LBDDLib_getFunc(CurrentArray)
    GFuncLabel := LBDDLib_getFunc(0)
    LBOnlySelfTarget := LBDDLib_getLBInfo(3, CurrentArray)
    if (LBOnlySelfTarget == 1)
      if (CurrentArray <> SourceArrayNum)
        return
    if (CurrentType == 1){
      CurrentItem := LBDDLib_itemFromPt(CurrentArray, ptCursor_X, ptCursor_Y, 0)
      LBDDLib_CallBack(2, CurrentItem)
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem, -6)
      if (FuncLabel <> "")
        LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem)
      else
        if hres
          LBDDLib_moveListBoxEntry2ListBox(DraggedItem, CurrentItem, hWnd, CurrentArray)
    }
    else if (CurrentType == 2){
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -6)
      if (FuncLabel <> "")
        LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem)
      else
        if hres
          LBDDLib_moveListBoxEntry2EditBox(DraggedItem, hWnd, CurrentArray)
    }
    else if (CurrentType == 3){
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -6)
      if (FuncLabel <> "")
        LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem)
    }
  }
}

LBDDLib_callUser(fName, ArrayNum, hWnd, DraggedItem, CurrentItem=-10, VerifyEvent=-10)
{
  Static UserF
  LBDDLib_UserVar(-1, LBDDLib_getHandle(ArrayNum))
  LBDDLib_UserVar(-2, hWnd)
  LBDDLib_UserVar(-3, DraggedItem)
  LBDDLib_UserVar(-4, CurrentItem)
  if ((VerifyEvent <> 0) && (VerifyEvent <> 1)){
    MyBool := LBDDLib_getMainOptions()
    if MyBool
      LBDDLib_UserVar(-5, VerifyEvent)
    else
      LBDDLib_UserVar(-5, LBDDLib_getVerifyEvent(VerifyEvent))
  }
  else
    LBDDLib_UserVar(-5, VerifyEvent)
  UserF := RegisterCallback(fName)
  res := DllCall(UserF)
  DllCall("GlobalFree", "Uint", UserF)
  return res
}

LBDDLib_moveListBoxEntry2EditBox(ItemToMove, hWnd_source, ArrayNum)
{
  Static LB_GETTEXT=0x189, LB_GETTEXTLEN=0x18A, LB_DELETESTRING=0x182
  hWnd := LBDDLib_getHandle(ArrayNum)
  SendMessage, LB_GETTEXTLEN, ItemToMove, 0,, ahk_id %hWnd_source%
  VarSetCapacity(TempVar, ErrorLevel)
  SendMessage, LB_GETTEXT, ItemToMove, &TempVar,, ahk_id %hWnd_source%
  if (LBDDLibArray_%ArrayNum%_DeleteOrig == 1)
    SendMessage, LB_DELETESTRING, ItemToMove, 0,, ahk_id %hWnd_source%
  if (LBDDLibArray_%ArrayNum%_AddModus == 0){
    ControlGetText, EditBoxText,, ahk_id %hWnd%
    if (EditBoxText <> "")
      EditBoxText .= LBDDLibArray_%ArrayNum%_AddDelimiter
    EditBoxText .= TempVar
    ControlSetText,, %EditBoxText%, ahk_id %hWnd%
  }
  else if (LBDDLibArray_%ArrayNum%_AddModus == 1){
    ControlSetText,, %TempVar%, ahk_id %hWnd%
  }

}

LBDDLib_moveListBoxEntry2ListBox(ItemToMove, NewPosition, hWnd_source, ArrayNum)
{
  Static LB_GETTEXT=0x189, LB_GETTEXTLEN=0x18A
  Static LB_DELETESTRING=0x182, LB_INSERTSTRING=0x181
  Static LB_GETTOPINDEX=0x18E, LB_SETTOPINDEX=0x197, LB_SETCARETINDEX=0x19E
  hWnd_target := LBDDLib_getHandle(ArrayNum)
  SendMessage, LB_GETTOPINDEX, 0, 0,, ahk_id %hWnd_source%
  MyFunc_Var_ListBox_TopIndex := ErrorLevel
  SendMessage, LB_GETTEXTLEN, ItemToMove, 0,, ahk_id %hWnd_source%
  VarSetCapacity(TempVar, ErrorLevel)
  SendMessage, LB_GETTEXT, ItemToMove, &TempVar,, ahk_id %hWnd_source%
  if (LBDDLibArray_%ArrayNum%_DeleteOrig == 1)
    SendMessage, LB_DELETESTRING, ItemToMove, 0,, ahk_id %hWnd_source%
  else if (hWnd_source == hWnd_target)
    SendMessage, LB_DELETESTRING, ItemToMove, 0,, ahk_id %hWnd_source%
  if (hWnd_Source+0 == hWnd_target)
    if (ItemToMove < NewPosition)
      NewPosition --
  SendMessage, LB_INSERTSTRING, NewPosition, &TempVar,, ahk_id %hWnd_target%
  SendMessage, LB_SETTOPINDEX, MyFunc_Var_ListBox_TopIndex, 0,, ahk_id %hWnd_target%
  SendMessage, LB_SETCARETINDEX, NewPosition, 0,, ahk_id %hWnd_target%
  VarSetCapacity(TempVar, 0)
}

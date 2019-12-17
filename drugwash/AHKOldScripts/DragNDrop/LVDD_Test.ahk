#SingleInstance Force
#NoEnv

/*
ListView Drag & Drop
*/

;use LVM_MAPINDEXTOID and LVM_MAPIDTOINDEX to associate an object with a ListView item
;store this unique ID with the object
;what if the item is moved (via drag drop? - or otherwise?)

Gui, Font, s16
Method2 := false

;add a menu
Menu, FileMenu, add, &New, DoNothing
Menu, FileMenu, add
Menu, FileMenu, add, E&xit, CloseProgram

Menu, MenuBar, add, &File, :FileMenu

Gui, Menu, MenuBar

; Gui, -Caption

Gui, Add, Button, , Ok
Gui, Add, Edit

Gui, Add, ListView, Grid Count20 r10 gMyListView vMyListView, Name|Age

GuiControl, -Redraw, MyListView

LV_ModifyCol(1, 100)

;add items
Loop, 20
{
    LV_Add("", "Item" A_Index)
}

GuiControl, +Redraw, MyListView

Gui, Add, ListView, Grid Count10 gMyListView2 vMyListView2, Name|Age
LV_ModifyCol(1, 100)

GuiControl, -Redraw, MyListView2
;add items
Loop, 10
{
    LV_Add("", "Item" A_Index)
}

GuiControl, +Redraw, MyListView2

Gui, Show

return

DoNothing:
return

CloseProgram:
GuiEscape:
GuiClose:
ExitApp

MyListView2:
MyListView:
{
    ;Only part the user touches
    if (A_GuiEvent = "D")
    {
        if (DropLocation := LV_DragDrop())
        {
            LV_ParseDDResults(DropLocation, InsertAfter, Position)
            
            MsgBox, % (InsertAfter ? "After " : "Before ") . Position
        }
    }

    return
}

LV_DragDrop()
{
    ;LVM_FIRST = 0x1000

    MouseGetPos, X, Y, , ThisControl
    ControlGet, ThisControl_HWND, HWND, , %ThisControl%, A
    Used_HWND := ThisControl_HWND

    ControlGetPos, ControlX2, ControlY2, , , , ahk_id %Used_HWND%
    
    ;LVM_GETHEADER = LVM_FIRST + 31 = 0x101F
    SendMessage, 0x101F, 0, 0, , ahk_id %Used_HWND%
    ListViewHeader_HWND := ErrorLevel

    ;LVM_GETCOUNTPERPAGE = LVM_FIRST + 40 = 0x1028
    SendMessage, 0x1028, 0, 0, , ahk_id %Used_HWND%
    NumberOfVisibleItems := ErrorLevel

    LV_InsertMark_create(LV_InsertMark)
    Point_create(Point)
    
    ;Used to detect hovering
    LastX := X
    LastY := Y

    ;Orgin for Control
    OriginX := ControlX2 + 2
    OriginY := ControlY2 + 2

    ;Initialize return values
    InsertAfter := false
    InsertPosition := 0
    
    Loop
    {
        if !GetKeyState("LButton")
            break

        MouseGetPos, X, Y, CurrentWindow, CurrentControl
        
        LocX := X - OriginX
        LocY := Y - OriginY

        if (CurrentControl != "")
            ControlGet, CurrentControl_HWND, HWND, , %CurrentControl%, ahk_id %CurrentWindow%
        else
            CurrentControl_HWND := 0
        
        if (CurrentControl_HWND = ThisControl_HWND
            || CurrentControl_HWND = ListViewHeader_HWND)
        {
            ;LVM_GETTOPINDEX = LVM_FIRST + 39 = 0x1027
            SendMessage, 0x1027, 0, 0, , ahk_id %Used_HWND%

            ;+1 converts from zero-based to one-based index
            TopIndex := ErrorLevel + 1
            BottomIndex := TopIndex + NumberOfVisibleItems - 1

            Point_setPoint(Point, LocX, LocY)

            ;LVM_INSERTMARKHITTEST = LVM_FIRST + 168 = 0x10A8
            SendMessage, 0x10A8, &Point, &LV_InsertMark, , ahk_id %Used_HWND%

            After := LV_InsertMark_getFlags(LV_InsertMark)
            iItem := LV_InsertMark_getItem(LV_InsertMark)

            if (iItem >= TopIndex && iItem <= BottomIndex)
            {
                ;LVM_SETINSERTMARK = LVM_FIRST + 166 = 0x10A6
                SendMessage, 0x10A6, 0, &LV_InsertMark, , ahk_id %Used_HWND%
                
                InsertAfter := After
                InsertPosition := iItem
            }
        }
        else
        {
            ;LVM_SETINSERTMARK = LVM_FIRST + 166 = 0x10A6
            LV_InsertMark_setItem(LV_InsertMark, 0) ;iItem = 0 means remove InsertMark
            SendMessage, 0x10A6, 0, &LV_InsertMark, , ahk_id %Used_HWND%
            
            InsertPosition := 0
        }
        
        if (X = LastX && Y = LastY)
        {
            if (CurrentControl_HWND = ThisControl_HWND
                || CurrentControl_HWND = ListViewHeader_HWND)
            {
                ;checks "Hover" time
                if (Last && (A_TickCount - Last) >= 400)
                {
                    ;scroll on border

                    if (iItem <= TopIndex)
                    {
                        ;LVM_ENSUREVISIBLE = LVM_FIRST + 19
                        ;-1 converts form one-based to zero-based index
                        ;fPartialOK = false
                        SendMessage, 0x1013, (TopIndex - 1) - 1, false, , ahk_id %Used_HWND%
                    }

                    if (iItem >= BottomIndex)
                    {
                        ;LVM_ENSUREVISIBLE = LVM_FIRST + 19
                        ;-1 converts form one-based to zero-based index
                        ;fPartialOK = false
                        SendMessage, 0x1013, (BottomIndex - 1) + 1, false, , ahk_id %Used_HWND%
                    }

                    Last := A_TickCount
                }

                if (!Last)
                    Last := A_TickCount
            }

            continue
        }

;         ToolTip, % "StartDrag: " . TopIndex . " " . BottomIndex
;             . "`n" . (CurrentControl_HWND = ListViewHeader_HWND ? "Header" : "Not Header")
;             . "`n" . (CurrentControl_HWND = ThisControl_HWND ? "ListView" : "Not ListView")

        Last := 0
        LastX := X
        LastY := Y
    }

    ;LVM_SETINSERTMARK = LVM_FIRST + 166 = 0x10A6
    LV_InsertMark_setItem(LV_InsertMark, 0) ;iItem = 0 means remove InsertMark
    SendMessage, 0x10A6, 0, &LV_InsertMark, , ahk_id %Used_HWND%
    
    ToolTip
    
;     MsgBox, % (InsertAfter ? "After" : "Before") . " " . InsertPosition
    
    if (InsertPosition)
        return InsertAfter . " " . InsertPosition
    else
        return 0
}

LV_ParseDDResults(DragDropResults, ByRef InsertAfter, ByRef Position)
{
    StringSplit, DragDropResults, DragDropResults, %A_Space%
    
    InsertAfter := DragDropResults1
    Position := DragDropResults2
}

/*
Structures Used
*/

Point_create(ByRef Point, X = 0, Y = 0)
{
    VarSetCapacity(Point, 8), Point_setPoint(Point, X, Y)
}

Point_getPoint(ByRef Point, ByRef X, ByRef Y)
{
    X := Point_getX(Point)
    Y := Point_getY(Point)
}

Point_setPoint(ByRef Point, X, Y)
{
    Point_setX(Point, X)
    Point_setY(Point, Y)
}

Point_getX(ByRef Point)
{
    return NumGet(Point, 0, "int")
}

Point_setX(ByRef Point, X)
{
    NumPut(X, Point, 0, "int")
}

Point_getY(ByRef Point)
{
    return NumGet(Point, 4, "int")
}

Point_setY(ByRef Point, Y)
{
    NumPut(Y, Point, 4, "int")
}

LV_InsertMark_create(ByRef LV_InsertMark, After = 0, iItem = 0)
{
;     static LVIM_AFTER = 0x1

    ;if After is "true", the Insert mark appears after item
    
    VarSetCapacity(LV_InsertMark, 16, 0), NumPut(16, LV_InsertMark)
        , LV_InsertMark_setFlags(LV_InsertMark, After)
        , LV_InsertMark_setItem(LV_InsertMark, iItem)
}

LV_InsertMark_getFlags(ByRef LV_InsertMark)
{
    return NumGet(LV_InsertMark, 4)
}

LV_InsertMark_setFlags(ByRef LV_InsertMark, After)
{
    NumPut(After, LV_InsertMark, 4)
}

LV_InsertMark_getItem(ByRef LV_InsertMark)
{
    ;+1 converts from zero-based to one-based index
    return NumGet(LV_InsertMark, 8, "int") + 1
}

LV_InsertMark_setItem(ByRef LV_InsertMark, iItem)
{
    ;-1 converts from one-based to zero-based index
    NumPut(iItem - 1, LV_InsertMark, 8, "int")
}
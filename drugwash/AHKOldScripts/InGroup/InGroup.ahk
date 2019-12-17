;adds the active window to the ActiveWindow group
GroupAdd, ActiveWindow, % "ahk_id" WinExist("A")

if hwnd := inGroup("ActiveWindow", "A")
    MsgBox, % "The window with Unique ID (HWND) " hwnd " is in the ActiveWindow group."
else
    MsgBox, % "The specified window is not in the ActiveWindow group."

/*
checks if the specified group contains the specified window
returns the Window's Unique ID (HWND), if the window is in the group
otherwise, returns false (0)

this function's return can be used as a quasi-boolean value.
the statemen inGroup(GroupName, ...) is true if the specified group contains
    the window, and false otherwise.
*/
inGroup(GroupName, WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
{
    WinGet, GroupIDs, List, ahk_group %GroupName%
    WinGet, Window, ID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
   
    Loop, %GroupIDs%
    {
        if (GroupIDs%A_Index% = Window)
        {
            ;found match
            return Window
        }
    }

    return false
}

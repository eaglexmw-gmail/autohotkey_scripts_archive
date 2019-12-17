; MsgBoxGenerator.ahk: AutoHotkey script by r0lZ, September 2011
; Generates the AutoHotkey code to build easily a nice-looking MsgBox.
; Developed vith AutoHotkey_L v1.1.02.01 Unicode X64 under Win7 X64 SP1
;
; Version history:
; v1.0:
; - First release
; v1.1:
; - Bug: The default button numbers that cannot be selected due to the current
;   buttons type selection are now disabled.
; - Added the currently selected icon in the status bar.
; - Test button: When the "Help" button option is selected, clicking the Help
;   button of the messagebox displays now a dummy help message.
; - Added the possibility to input an options number to modify the GUI accordingly.
; - Added the Right-To-Left alignment option.
; - Added the "Default Desktop" (undocumented?) window type option.

VERSION = 1.1

#NoTrayIcon
#NoEnv
#SingleInstance force
#UseHook off
#Persistent
DetectHiddenWindows, on

SplitPath, A_ScriptName, , , , APPTITLE

IncludeBrackets = 1

Menu, OptionsMenu, Add, Always on top, ToggleAlwaysOnTop
Menu, OptionsMenu, add, Show tray tips, ToggleTrayTips
Menu, OptionsMenu, Add, Enable Ctrl-Shift-M hotkey, ToggleSuspend
Menu, OptionsMenu, Check, Enable Ctrl-Shift-M hotkey
Menu, OptionsMenu, Add, Include brackets in code, ToggleBrackets
Menu, OptionsMenu, Check, Include brackets in code

Menu, Tray, NoStandard
Menu, Tray, Add, Open GUI, OpenMainGui
Menu, Tray, Default, Open GUI
Menu, Tray, Add
Menu, Tray, Add, Options, :OptionsMenu
Menu, Tray, Add
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 1
Menu, Tray, Tip, AHK MsgBox generator`nBy r0lZ`, September 2011

if (! A_IsCompiled) {
    tmp = %A_ScriptDir%\%APPTITLE%.ico
    if (FileExist(tmp))
        Menu, Tray, Icon, %tmp%
    else
        Menu, Tray, Icon
    tmp =
} else
    Menu, Tray, Icon

BuildMainGUI()

OnExit, CleanExit


Return


Exit:
    OnExit
CleanExit:
    FileDelete, %A_Temp%\MsgBoxTest.ahk
    ExitApp
return


; **************************** Main GUI ***********************
OpenMainGui:
    Gui, Show
return

BuildMainGUI()
{
    Global VERSION
    Global ButtonsVal, DefaultButtonVal, HelpButton, IconVal, WindowVal, RightJustify, LeftToRight, Title, Text, TimeoutOn, Timeout

    Menu, GuiMenu, add, Exit, Exit
    Menu, GuiMenu, Add, Options, :OptionsMenu
    Menu, GuiMenu, add, Input#, InputNumber
    Gui, Menu, GuiMenu

    Gui, Margin, 4, 4
    Gui, Font, S8


    Gui, Add, Text, X4 Y4 Section, Buttons:
    Gui, Add, ListBox, XS vButtonsVal r7 w200 gGuiChanged AltSubmit, OK|OK / Cancel|Abort / Retry / Ignore|Yes / No / Cancel|Yes / No|Retry / Cancel|Cancel / Try Again / Continue [WinXP+]
    GuiControl, Choose, ButtonsVal, 1

    Gui, Add, Text, XS Section, Default Button:
    Gui, Add, Radio, YS vDefaultButtonVal Checked gGuiChanged, &1
    Gui, Add, Radio, YS gGuiChanged, &2
    Gui, Add, Radio, YS gGuiChanged, &3
   
    Gui, Add, Checkbox, XS Section vHelpButton gGuiChanged, Add '&Help' button`n[ Requires   Gui +OwnDialogs   and`nOnMessage(0x53, "WM_HELP") ]


    Gui, Add, Text, X208 Y4 Section, Icon:
    Gui, Add, ListBox, XS vIconVal r5 w83 gGuiChanged AltSubmit, No icon|Info|Warning|Question|Error
    GuiControl, Choose, IconVal, 2
   
    Gui, Add, Text, XS Section, Window:
    Gui, Add, ListBox, XS vWindowVal r5 w83 gGuiChanged AltSubmit, Normal|Task modal|System modal|Always on top|Default desktop
    GuiControl, Choose, WindowVal, 1


    Gui, Add, Text, X4 Section, Text alignment options:
    Gui, Add, Checkbox, YS vRightJustify gGuiChanged, &Right-justify
    Gui, Add, Checkbox, YS vLeftToRight  gGuiChanged, &Left-to-right


    Gui, Add, Text, XS Section

    Gui, Add, Text, XS Section W30, Title:
    Gui, Add, Edit, YS-4 w253 vTitle gGuiChanged -WantReturn, `%A_ScriptName`%

    Gui, Add, Edit, XS Section w287 vText r4 gGuiChanged +WantReturn, Text

    Gui, Add, Checkbox, XS Section vTimeoutOn gGuiChanged, Ti&meout:
    Gui, Add, Edit, w50 YS-3 Number gGuiChanged
    Gui, Add, UpDown, vTimeout Range1-60 gGuiChanged, 10
    Gui, Add, Text, YS, seconds


    Gui, Add, Text, XS Section, Control-Shift-M inserts the code in the current application.
    Gui, Add, Button, XS w93 gCopyNum Section, Copy &option #
    Gui, Add, Button, YS w93 gCopyCode, Copy &code
    Gui, Add, Button, YS w93 gTest Default, &Test

    Gui, Add, StatusBar

    GoSub, GuiChanged

    SysGet, Mon, MonitorWorkArea
    posx := MonLeft + 20
    posy := MonTop + 20
    Gui, Show, X%posx% Y%posy%, AHK MsgBox generator v%VERSION%
}

GuiChanged:
    Gui, Submit, NoHide
    val := ButtonsVal -1
    if (val == 0) {
        GuiControl, Disable, &2
        GuiControl, Disable, &3
        DefaultButtonVal = 1
        GuiControl, , DefaultButtonVal, 1
    }
    else if (val == 1 || val == 4) {
        GuiControl, Enable, &2
        GuiControl, Disable, &3
        if (DefaultButtonVal > 2) {
            DefaultButtonVal = 2
            GuiControl, , &2, 1
        }
    } else {
        GuiControl, Enable, &2
        GuiControl, Enable, &3
    }
    val += (DefaultButtonVal - 1) * 256
    val += HelpButton ? 16384 : 0
    if (IconVal != 1) {
        val += (6 - IconVal) * 16
        if (iconval == 2)
            iconnum = 5
        else if (iconval == 3)
            iconnum = 2
        else if (iconval == 4)
            iconnum = 3
        else
            iconnum = 4
    } else
        iconnum = 0
    if (WindowVal == 2)
        val += 8192
    else if (WindowVal == 3)
        val += 4096
    else if (WindowVal == 4)
        val += 262144
    if RightJustify
        val += 524288
    if LeftToRight
        val += 1048576
    StringReplace, Title, Title, `, , ```, , 1
    StringReplace, Message, Text, `, , ```, , 1
    StringReplace, Message, Message, `n, ``n, 1
    st = MsgBox, %val%, %Title%, %Message%
    if (TimeoutOn) {
        if (Timeout > 0)
            st = %st%, %Timeout%
        else {
            TimeoutOn = 0
            GuiControl, , TimeoutOn, 0
            soundbeep
        }
    }
    if (iconnum && FileExist(A_WinDir . "\system32\user32.dll")) {
        SB_SetParts(22)
        SB_SetIcon("user32.dll", iconnum)
    } else {
        SB_SetParts(0)
    }
    SB_SetText(st, 2)
    if (ShowTrayTips) {
        GoSub, GenCode
        TrayTip, MsgBox code:, %code%, 10, 1
    }
return

CopyNum:
    GoSub, GuiChanged
    Clipboard = %val%
return

CopyCode:
    GoSub, GuiChanged
    GoSub, GenCode
    clipboard = %code%
return

GenCode:
    code = MsgBox, %val%, %Title%, %Message%
    if (IncludeBrackets)
        s = `n{`n`n}
    else
        s = `n
    if (TimeoutOn)
        code = %code%, %Timeout%
    if (ButtonsVal == 1 && TimeoutOn)
        code = %code%`nIfMsgBox, OK%s%
    if (ButtonsVal == 2)
        code = %code%`nIfMsgBox, OK%s%`nIfMsgBox, Cancel%s%
    if (ButtonsVal == 3)
        code = %code%`nIfMsgBox, Abort%s%`nIfMsgBox, Retry%s%`nIfMsgBox, Ignore%s%
    if (ButtonsVal == 4)
        code = %code%`nIfMsgBox, Yes%s%`nIfMsgBox, No%s%`nIfMsgBox, Cancel%s%
    if (ButtonsVal == 5)
        code = %code%`nIfMsgBox, Yes%s%`nIfMsgBox, No%s%
    if (ButtonsVal == 6)
        code = %code%`nIfMsgBox, Retry%s%`nIfMsgBox, Cancel%s%
    if (ButtonsVal == 7)
        code = %code%`nIfMsgBox, Cancel%s%`nIfMsgBox, Try Again%s%`nIfMsgBox, Continue%s%
    if (TimeoutOn)
        code = %code%`nIfMsgBox, Timeout%s%
    code = %code%`n
return

Test:
    GoSub, GuiChanged
    cmd = MsgBox, %val%, %Title%, %Message%
    if TimeoutOn
        cmd = %cmd%, %Timeout%
    FileDelete, %A_Temp%\MsgBoxTest.ahk
    if (HelpButton) {
        code = Gui, Show, Hide, %Title%`nGui, +OwnDialogs`nOnMessage(0x53, "WM_HELP")`n%cmd%`nexitapp`nWM_HELP()`n{`n MsgBox, 64, Help - %Title%, This is a dummy help message., 3`n}`n
        FileAppend, %code%`n, %A_Temp%\MsgBoxTest.ahk
        code =
    } else {
        FileAppend, %cmd%`n, %A_Temp%\MsgBoxTest.ahk
    }   
    Run, "%A_Temp%\MsgBoxTest.ahk", %A_Temp%, UseErrorLevel
return

GuiClose:
GuiEscape:
    GoSub, GuiChanged
    Gui, Hide
return

ToggleAlwaysOnTop:
    alwaysontop := ! alwaysontop
    Menu, OptionsMenu, ToggleCheck, Always on top
    if (alwaysontop)
        Gui, +AlwaysOnTop
    else
        Gui, -AlwaysOnTop
return

ToggleSuspend:
    Suspend, Toggle
    Menu, OptionsMenu, ToggleCheck, Enable Ctrl-Shift-M hotkey
return

ToggleTrayTips:
    ShowTrayTips := ! ShowTrayTips
    Menu, OptionsMenu, ToggleCheck, Show tray tips
    if (ShowTrayTips)
        GoSub, GuiChanged
    else
        TrayTip
return

ToggleBrackets:
    IncludeBrackets := ! IncludeBrackets
    Menu, OptionsMenu, ToggleCheck, Include brackets in code
    if (ShowTrayTips)
        GoSub, GuiChanged
return

^+m::
    GoSub, GuiChanged
    GoSub, GenCode
    SetKeyDelay, 0
    SendRaw, %code%
return

; **************** GUI 2: Input an option number **************************

InputNumber:
    GoSub, GuiChanged
    num := InputNumber(val)
return

InputNumber(defaultnum)
{
    Global InputNum

    Gui, 1:+Disabled
    Gui, 2:Default
    Gui, +Owner1

    Gui, -MinimizeBox -MaximizeBox

    Gui, Add, Text, Section, MsgBox Options value:

    Gui, Add, Edit, Limit7 Number vInputNum Section w110 -WantReturn, %defaultnum%

    Gui, Add, Button, XS w50 g2GuiOK Section Default, &OK
    Gui, Add, Button, YS w50 g2GuiClose, &Cancel
   
    Gui, 1:+LastFound
    WinGetPos, posx, posy
    posx += 80
    posy += 50
    Gui, Show, X%posx% Y%posy%, Input#
}

2GuiOK:
    Gui, 2:Submit, NoHide
    Gui, 1:Default

    GuiControl, Enable, &2
    GuiControl, Enable, &3
    GuiControl, Choose, ButtonsVal, 3
    val := round((InputNum & 0x300) / 0x100) + 1
    GuiControl, , &%val%, 1

    val := (InputNum & 7) + 1
    if (val > 7) {
        val = 1
        soundbeep
    }
    GuiControl, Choose, ButtonsVal, %val%

    GuiControl, , HelpButton, % round((InputNum & 0x4000) / 0x4000)

    val := round((InputNum & 0x70) / 0x10)
    if (val == 0)
        GuiControl, Choose, IconVal, 1
    else
        GuiControl, Choose, IconVal, % 6 - val

    val := InputNum & 0x63000
    if (val == 0)
        GuiControl, Choose, WindowVal, 1
    else if (val == 0x1000)
        GuiControl, Choose, WindowVal, 3
    else if (val == 0x2000)
        GuiControl, Choose, WindowVal, 2
    else if (val == 0x40000)
        GuiControl, Choose, WindowVal, 4
    else if (val == 0x20000)
        GuiControl, Choose, WindowVal, 5
    else {
        Soundbeep
        GuiControl, Choose, WindowVal, 1
    }

    GuiControl, , RightJustify, % round((InputNum & 0x80000) / 0x80000)
    GuiControl, , LeftToRight,  % round((InputNum & 0x100000) / 0x100000)

    GoSub, 2GuiClose
    GoSub, GuiChanged
return

2GuiEscape:
2GuiClose:
    Gui, 2:Destroy
    Gui, 1:-Disabled
    Gui, 1:Default
return

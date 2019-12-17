ScrollText =
(


AutoHotkey is a free, open-source utility for Windows.

With it, you can:

Automate almost anything by sending keystrokes and mouse
clicks. You can write macros by hand or use the macro recorder.

Create hotkeys for keyboard, joystick, and mouse. Virtually any
key, button, or combination can become a hotkey.

Expand abbreviations as you type them. For example, typing "btw"
can automatically produce "by the way".

Create custom data entry forms, user interfaces, and menu bars.

Remap keys and buttons on your keyboard, joystick, and mouse.

Respond to signals from hand-held remote controls via the WinLIRC
client script.

Run existing AutoIt v2 scripts and enhance them with new capabilities.

Convert any script into an EXE file that can be run on computers
that don't have AutoHotkey installed.



)

Gui, Margin, 0,0
Gui +LastFound
GUI_ID:=WinExist()
Gui, -Caption +AlwaysOnTop +Border
Gui, Color, FFFFFF
Gui, Margin, 40, 40
Gui, Font, s12 Bold, Verdana

Gui, Add, Text, x41 y41 c808080 BackGroundTrans, % ScrollText
Gui, Add, Text, x40 y40 c000000 BackGroundTrans, % ScrollText

Gui,Show, AutoSize Hide, Animated Splash Window - Demo

DllCall("AnimateWindow","UInt",GUI_ID,"Int",20000,"UInt","0x40008")
DllCall("AnimateWindow","UInt",GUI_ID,"Int",20000,"UInt","0x50008")
ExitApp

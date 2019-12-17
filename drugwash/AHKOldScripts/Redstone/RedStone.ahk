#NoEnv
#SingleInstance ignore
#Persistent

AutoTrim, Off
SetBatchLines, -1        ; set to run at maximum speed

Menu, Tray, Icon, SHELL32.dll, 22
Menu, Tray, Tip, RedStone
Menu, Tray, NoStandard
Menu, Tray, Add, E&xit, GuiClose

CR_Initialize("Redstone")

COMMAND("UI Create", "/skin:" . STATE_GET("UI Skin", "tiny"))
COMMAND("Filter Apply", "/name:Categories")
COMMAND("Command CheckErrors")
COMMAND("AHK CompactMemory")
COMMAND("UI Process")

Return

GuiClose:
	COMMAND("AHK Exit")
Return

#include CR_Main.ahk
#include plugins/Lists/CRL_File.ahk
#include plugins/Lists/CRL_Search.ahk
#include plugins/Lists/CRL_Filter.ahk
#include plugins/Lists/CRL_FilterHistory.ahk
#include plugins/Lists/CRL_History.ahk
#include plugins/Lists/CRL_StartMenu.ahk
#include plugins/Lists/CRL_Slash.ahk
#include plugins/Lists/CRL_Process.ahk
#include plugins/Lists/CRL_Window.ahk
#include plugins/Lists/CRL_Scan.ahk
#include plugins/UI-Generic/CR_Menu.ahk
#include plugins/UI-Generic/CR_statusbar.ahk
#include plugins/UI-Generic/CR_Icon.ahk
#include plugins/UI-Generic/CR_Tooltip.ahk
#include plugins/UI-Generic/Toolbar3.ahk
#include plugins/UI-Generic/CR_Animation.ahk
#include plugins/UI-Generic/CR_ContextMenu.ahk
#include plugins/UI-Generic/Anchor.ahk
#include plugins/UI-Generic/CR_Button.ahk
#include plugins/UI-Generic/Hotkey.ahk
#include plugins/UI/CR_Toolbar.ahk
#include plugins/UI/CR_ListView.ahk
#include plugins/UI/CR_Header.ahk
#include plugins/UI/CR_UI.ahk
#include plugins/UI/CR_Lister.ahk
#include plugins/UI/CR_Skin.ahk
#include plugins/UI/CR_Buttons.ahk
#include plugins/UI/CR_Editor2.ahk
#include plugins/UI/CR_Info.ahk
;#include plugins/UI/CR_MiniMode.ahk
#include plugins/UI/CR_Volume.ahk
#include plugins/UI/CR_Help.ahk
#include plugins/gds/CRI_GoogleDesktop.ahk
#include plugins/Windows/CR_Rainmeter.ahk
#include plugins/Input/CR_Hotkeys.ahk
#include plugins/Input/CR_Clipboard.ahk
#include plugins/Input/CR_Speech.ahk
#include plugins/Input/CR_HotCorners.ahk
#include plugins/Input/CR_EventHandler.ahk
#include plugins/Input/CR_AltTab.ahk
;#include plugins/Input/CR_X10.ahk
#include plugins/Miro/CRI_Miro.ahk
#include plugins/Types/CR_Website.ahk
#include plugins/Types/CR_Windows.ahk
#include plugins/Types/CR_File.ahk
#include plugins/Types/CR_Plugin.ahk
#include plugins/ExplorerContextMenu/CRI_File.ahk
#include Test_XML.ahk


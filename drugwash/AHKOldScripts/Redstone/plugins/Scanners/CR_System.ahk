system_Initialize() {
	CommandRegister("System Scan", "System_Scan")
}

system_Scan(A_Command, A_Args) {

	list := list_Create()
	
	driveTypes := "FIXED,NETWORK"
	Loop,Parse,driveTypes, `,
	{
		DriveGet, HDDList, list, %A_LoopField%
		Loop,Parse,HDDList
		{
			list_Add(list, "/listName:Default /category:System /type:folder /name:Drive " . A_LoopField . " /command:" . A_LoopField . ":\")
		}
	}

;	list_Add(list, "/listName:Default /type:system /name:Desktop /command:::{00021400-0000-0000-C000-0000000000046}")
	list_Add(list, "/listName:Default /category:System /type:system /name:My Computer /command:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	list_Add(list, "/listName:Default /category:System /type:folder /name:My Music /command:" . GetCommonPath("MYMUSIC"))
	list_Add(list, "/listName:Default /category:System /type:folder /name:My Pictures /command:" . GetCommonPath("MYPICTURES"))
	list_Add(list, "/listName:Default /category:System /type:folder /name:My Documents /command:" . GetCommonPath("PERSONAL"))
	list_Add(list, "/listName:Default /category:System /type:folder /name:My Videos /command:" . GetCommonPath("MYVIDEO"))
	list_Add(list, "/listName:Default /category:System /type:system /name:My Network Places /command:::{208D2C60-3AEA-1069-A2D7-08002B30309D}")
;	list_Add(list, "/listName:Default /category:System /type:system /name:Control Panel /command:::{21EC2020-3AEA-1069-A2DD-08002B30309D}")
	list_Add(list, "/listName:Default /category:System /type:system /name:Printers and Faxes /command:::{2227A280-3AEA-1069-A2DE-08002B30309D}")
	list_Add(list, "/listName:Default /category:System /type:system /name:Network Connections /command:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}")
	list_Add(list, "/listName:Default /category:System /type:system /name:Recycle Bin /command:::{645FF040-5081-101B-9F08-00AA002F954E}")

	syslist_Merge("Default", list)
}

; http://www.autohotkey.com/forum/topic10325.html - majkinetor
GetCommonPath( csidl )
{
	static init

	if !init
	{
		CSIDL_APPDATA                   =0x001A                 ; Application Data, new for NT4
        CSIDL_FAVORITES                 =0x0006                 ; The file system directory that serves as a common repository for the user's favorite items. A typical path is C:\Documents and Settings\username\Favorites. 
		CSIDL_COMMON_APPDATA            =0x0023                 ; All Users\Application Data
		CSIDL_COMMON_DOCUMENTS          =0x002e                 ; All Users\Documents
		CSIDL_DESKTOP                   =0x0010                 ; C:\Documents and Settings\username\Desktop
		CSIDL_FONTS                     =0x0014                 ; C:\Windows\Fonts
		CSIDL_LOCAL_APPDATA             =0x001C                 ; non roaming, user\Local Settings\Application Data
		CSIDL_MYMUSIC                   =0x000d                 ; "My Music" folder
		CSIDL_MYPICTURES                =0x0027                 ; My Pictures, new for Win2K
		CSIDL_MYVIDEO                   =0x000e
		CSIDL_PERSONAL                  =0x0005                 ; My Documents
		CSIDL_PROGRAM_FILES_COMMON      =0x002b                 ; C:\Program Files\Common
		CSIDL_PROGRAM_FILES             =0x0026                 ; C:\Program Files
		CSIDL_PROGRAMS                  =0x0002                 ; C:\Documents and Settings\username\Start Menu\Programs
		CSIDL_RESOURCES                 =0x0038                 ; %windir%\Resources\, For theme and other windows resources.
		CSIDL_STARTMENU                 =0x000b                 ; C:\Documents and Settings\username\Start Menu
		CSIDL_STARTUP                   =0x0007                 ; C:\Documents and Settings\username\Start Menu\Programs\Startup.
		CSIDL_SYSTEM                    =0x0025                 ; GetSystemDirectory()
		CSIDL_WINDOWS                   =0x0024                 ; GetWindowsDirectory()
	}


	val = % CSIDL_%csidl%
	VarSetCapacity(fpath, 256)
	DllCall( "shell32\SHGetFolderPathA", "uint", 0, "int", val, "uint", 0, "int", 0, "str", fpath)
	return %fpath%
}

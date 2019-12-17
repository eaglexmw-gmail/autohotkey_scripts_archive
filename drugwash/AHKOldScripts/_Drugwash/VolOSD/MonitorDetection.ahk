; detect attached monitors and videocards
/*
MSDN reference:

BOOL EnumDisplayDevices(
  LPCTSTR lpDevice,                // device name (in) pointer
  DWORD iDevNum,                   // display device (in)
  PDISPLAY_DEVICE lpDisplayDevice, // device information (out) struct
  DWORD dwFlags                    // reserved (in)
);

typedef struct _DISPLAY_DEVICE {
  DWORD cb;
  TCHAR DeviceName[32];
  TCHAR DeviceString[128];
  DWORD StateFlags;
  TCHAR DeviceID[128];
  TCHAR DeviceKey[128];
} DISPLAY_DEVICE, *PDISPLAY_DEVICE;
***********************************
DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = &H1
DISPLAY_DEVICE_MULTI_DRIVER = &H2
DISPLAY_DEVICE_PRIMARY_DEVICE = &H4
DISPLAY_DEVICE_MIRRORING_DRIVER = &H8
DISPLAY_DEVICE_VGA_COMPATIBLE = &H10
DISPLAY_DEVICE_REMOVABLE = &H20
DISPLAY_DEVICE_MODESPRUNED = &H8000000
DISPLAY_DEVICE_REMOTE = &H4000000
DISPLAY_DEVICE_DISCONNECT = &H2000000

DISPLAY_DEVICE_ACTIVE = &H1
DISPLAY_DEVICE_ATTACHED = &H2

CCHDEVICENAME = 32
CCHFORMNAME = 32

ENUM_CURRENT_SETTINGS = -1
ENUM_REGISTRY_SETTINGS = -2

User32.dll: MonitorFromWindow
MONITOR_DEFAULTTONULL = 0
MONITOR_DEFAULTTOPRIMARY = 1
MONITOR_DEFAULTTONEAREST = 2

EDD_GET_DEVICE_INTERFACE_NAME = 0x00000001
************************************
detmon()
MsgBox, Active monitors: %MonAct%`nPrimary monitor: %MonPrim%`nMonitor1: %MonNam1%`nMonitor2: %MonNam2%`nMonitor3: %MonNam3%`nMonitor4: %MonNam4%
return
*/

detmon()
{
global MonAct, MonPrim, MonNam1, MonNam2, MonNam3, MonNam4
;struct DISPLAY_DEVICE dd
;struct DISPLAY_DEVICE ddMon
DISPLAY_DEVICE_MIRRORING_DRIVER = 0x00000008	; ask MSDN
DISPLAY_DEVICE_ACTIVE = 0x00000001				; ask MSDN
DISPLAY_DEVICE_PRIMARY_DEVICE = 0x00000004		; ask MSDN

VarSetCapacity(dd, 424, 0)		; allocate space for the dd structure
VarSetCapacity(ddMon, 424 , 0)	; allocate space for the ddMon structure
VarSetCapacity(dd_DeviceName, 32, 0)
VarSetCapacity(dd_DeviceString, 128, 0)
VarSetCapacity(ddMon_DeviceName, 32, 0)
VarSetCapacity(ddMon_DeviceString, 128, 0)

dev = 0					; device index
id = 1					; monitor number, as used by Display Properties > Settings
Loop
	{
	NumPut(424, dd, 0, "UInt")
	dd_DeviceName =
	dd_DeviceString =
	if ! DllCall("EnumDisplayDevices", Int, 0, UInt, dev, Uint, &dd, Int, 0, Int)
		break
	Loop, 32
		dd_DeviceName := dd_DeviceName . chr(NumGet(dd, 3 + A_Index, "UChar"))
	Loop, 128
		dd_DeviceString := dd_DeviceString . chr(NumGet(dd, 35 + A_Index, "UChar"))
	dd_StateFlags := NumGet(dd, 164, "UInt")
	if ! (dd_StateFlags & DISPLAY_DEVICE_MIRRORING_DRIVER)	; ignore virtual mirror displays
		{
		devMon = 0
		Loop
			{
			NumPut(424, ddMon, 0, "UInt")
			ddMon_DeviceName =
			ddMon_DeviceString =
			if ! DllCall("EnumDisplayDevices", Str, dd_DeviceName, UInt, devMon, UInt, &ddMon, Int, 0, Int)
				break
			Loop, 32
				ddMon_DeviceName := ddMon_DeviceName . chr(NumGet(dd, 3 + A_Index, "UChar"))
			Loop, 128
				ddMon_DeviceString := ddMon_DeviceString . chr(NumGet(ddMon, 35 + A_Index, "UChar"))
			ddMon_StateFlags := NumGet(ddMon, 164, "UInt")
			if (ddMon_StateFlags & DISPLAY_DEVICE_ACTIVE)
				break
			devMon++
			}
		if ! ddMon_DeviceString
			{
			NumPut(424, ddMon, 0, "UInt")
			ddMon_DeviceName =
			ddMon_DeviceString =
			DllCall("EnumDisplayDevices", Str, dd_DeviceName, Int, 0, UInt, &ddMon, Int, 0, int)
			Loop, 32
				ddMon_DeviceName := ddMon_DeviceName . chr(NumGet(dd, 3 + A_Index, "UChar"))
			Loop, 128
				ddMon_DeviceString := ddMon_DeviceString . chr(NumGet(ddMon, 35 + A_Index, "UChar"))
			ddMon_StateFlags := NumGet(ddMon, 164, "UInt")
			if ! ddMon_DeviceString
				ddMon_DeviceString = Default Monitor
			}
		MonNam%id% := ddMon_DeviceString . "`n on " . dd_DeviceString
		if (dd_StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)
			MonPrim := id
		id++
		}
	dev++	
	}
MonAct := dev
return MonAct, MonPrim, MonNam1, MonNam2, MonNam3, MonNam4
}

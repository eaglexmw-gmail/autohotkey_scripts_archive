/* 
SysInfo.cpp

Displays information about installed monitors.

This source code may be freely distributed as long as it is not being modified.
You may freely use this source code in your own applications, commercial or not.
copyright 2002 by Realtime Soft - www.realtimesoft.com

THE SOURCE CODE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.

IN NO EVENT SHALL REALTIME SOFT BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES
OF ANY KIND, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR NOT
ADVISED OF THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH
THE USE OR PERFORMANCE OF THIS SOURCE CODE.
*/

#include <windows.h>
#include <tchar.h>

int WINAPI _tWinMain(HINSTANCE hInst, HINSTANCE, LPTSTR, int)
{
	// collect system and monitor information, and display it using a message box

	TCHAR msg[10000] = _T("");

	DISPLAY_DEVICE dd;
	dd.cb = sizeof(dd);
	DWORD dev = 0; // device index
	int id = 1; // monitor number, as used by Display Properties > Settings

	while (EnumDisplayDevices(0, dev, &dd, 0))
	{
		if (!(dd.StateFlags & DISPLAY_DEVICE_MIRRORING_DRIVER))
		{
			// ignore virtual mirror displays

			// get information about the monitor attached to this display adapter. dualhead cards
			// and laptop video cards can have multiple monitors attached

			DISPLAY_DEVICE ddMon;
			ZeroMemory(&ddMon, sizeof(ddMon));
			ddMon.cb = sizeof(ddMon);
			DWORD devMon = 0;

			// please note that this enumeration may not return the correct monitor if multiple monitors
			// are attached. this is because not all display drivers return the ACTIVE flag for the monitor
			// that is actually active
			while (EnumDisplayDevices(dd.DeviceName, devMon, &ddMon, 0))
			{
				if (ddMon.StateFlags & DISPLAY_DEVICE_ACTIVE)
					break;

				devMon++;
			}

			if (!*ddMon.DeviceString)
			{
				EnumDisplayDevices(dd.DeviceName, 0, &ddMon, 0);
				if (!*ddMon.DeviceString)
					lstrcpy(ddMon.DeviceString, _T("Default Monitor"));
			}

			// get information about the display's position and the current display mode
			DEVMODE dm;
			ZeroMemory(&dm, sizeof(dm));
			dm.dmSize = sizeof(dm);
			if (EnumDisplaySettingsEx(dd.DeviceName, ENUM_CURRENT_SETTINGS, &dm, 0) == FALSE)
				EnumDisplaySettingsEx(dd.DeviceName, ENUM_REGISTRY_SETTINGS, &dm, 0);

			// get the monitor handle and workspace
			HMONITOR hm = 0;
			MONITORINFO mi;
			ZeroMemory(&mi, sizeof(mi));
			mi.cbSize = sizeof(mi);
			if (dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
			{
				// display is enabled. only enabled displays have a monitor handle
				POINT pt = { dm.dmPosition.x, dm.dmPosition.y };
				hm = MonitorFromPoint(pt, MONITOR_DEFAULTTONULL);
				if (hm)
					GetMonitorInfo(hm, &mi);
			}

			// format information about this monitor
			TCHAR buf[1000];
			
			// 1. MyMonitor on MyVideoCard
			wsprintf(buf, _T("%d. %s on %s\r\n"), id, ddMon.DeviceString, dd.DeviceString);
			lstrcat(msg, buf);

			// status flags: primary, disabled, removable
			buf[0] = _T('\0');
			if (!(dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP))
				lstrcat(buf, _T("disabled, "));
			else if (dd.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)
				lstrcat(buf, _T("primary, "));
			if (dd.StateFlags & DISPLAY_DEVICE_REMOVABLE)
				lstrcat(buf, _T("removable, "));

			if (*buf)
			{
				buf[lstrlen(buf) - 2] = _T('\0');
				lstrcat(buf, _T("\r\n"));
				lstrcat(msg, buf);
			}

			// width x height @ x,y - bpp - refresh rate
			// note that refresh rate information is not available on Win9x
			wsprintf(buf, _T("%d x %d @ %d,%d - %d-bit - %d Hz\r\n"), dm.dmPelsWidth, dm.dmPelsHeight,
				dm.dmPosition.x, dm.dmPosition.y, dm.dmBitsPerPel, dm.dmDisplayFrequency);
			lstrcat(msg, buf);

			if (hm)
			{
				// workspace and monitor handle

				// workspace: x,y - x,y HMONITOR: handle
				wsprintf(buf, _T("workspace: %d,%d - %d,%d HMONITOR: 0x%X\r\n"), mi.rcWork.left,
					mi.rcWork.top, mi.rcWork.right, mi.rcWork.bottom, hm);
				lstrcat(msg, buf);
			}

			// device name
			wsprintf(buf, _T("Device: %s\r\n\r\n"), *ddMon.DeviceName ? ddMon.DeviceName : dd.DeviceName);
			lstrcat(msg, buf);

			id++;
		}

		dev++;
	}

	MessageBox(0, msg, _T("SysInfo"), MB_OK);

	return 0;
}
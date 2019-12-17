; Device Detector created for VolOSD Pro
; © Drugwash, Oct 2008

Gui, Add, ImageList, spImageData
_hInst = HINSTANCE	; external resource
_hDlg = HWND		; external resource
_pHead = 0			; pointer 0L (device list)
_pOrderHead = 0		; pointer 0L (device order)
; ------------------ InitialDeviceOrder() function --------------------
InitialDeviceOrder()		; returns CHAR
{
_pOrderHead := DLlCall("AllocNewDeviceOrderNode", "Int")
return _pOrderHead ? 1 : 0
}
;-------------------------------------------------------------------------
DEVICE_ORDER := AllocNewDeviceOrderNode()	; returns pointer?
; ------------- AllocNewDeviceOrderNode() function ----------------
AllocNewDeviceOrderNode()	; returns 
{
DEVICE_ORDER* pNew = (DEVICE_ORDER*)LocalAlloc(LPTR, sizeof(DEVICE_ORDER))
if ! pNew
	{
	MsgBox, Error=%ErrorLevel%
	return 0
	}
RtlZeroMemory(pNew->szDevName, sizeof(char)*LINE_LEN)
pNew->pNext = 0L
return pNew
}
;-------------------------------------------------------------------------
; ------------- AddNewDeviceOrderNode() function ----------------
AddNewDeviceOrderNode(const char* szDevName)	; pointer to a string, returns CHAR
{
DEVICE_ORDER* pAdd = AllocNewDeviceOrderNode()
if ! pAdd
	return 0
memcpy(pAdd->szDevName, szDevName, strlen(szDevName))
pAdd->pNext = _pOrderHead->pNext
_pOrderHead->pNext = pAdd
return 1
}
;-------------------------------------------------------------------------
; ------------- FindDeviceOrder() function ----------------
FindDeviceOrder(const char* szName)	; returns SHORT
{
DEVICE_ORDER *pList = _pOrderHead->pNext
wOrder = 0	; short
Loop, 9999	; just get it spinning
	{
	if (!strcmp(pList->szDevName, szName))
		wOrder++
	pList = pList->pNext
	if ! pList
		break
	}
return wOrder
}
;-------------------------------------------------------------------------
; ------------- FreeAllDeviceOrderNode() function ----------------
FreeAllDeviceOrderNode()
{
DEVICE_ORDER *pDel = _pOrderHead->pNext
DEVICE_ORDER *pTmp = 0L
Loop, ???		; while (pDel->pNext)
    {
        pTmp = pDel
        pDel = pDel->pNext
        LocalFree(pTmp)
    }
    LocalFree(_pOrderHead)
    _pOrderHead = 0L
}
;-------------------------------------------------------------------------
;................

;................
; these may be global variables so I let them outside the function for now
DIGCF_PRESENT = 
DIGCF_ALLCLASSES = 
DIGCF_PROFILE = 
VarSetCapacity(SPDRP_CLASS, 256, 0)
VarSetCapacity(MAX_PATH, 260, 0)
;-------------------------------------------------------------------------
;------- function EnumWDMDriver --------------
EnumWDMDriver(nIdTree, nIdBmp)
{
hDevInfo = 0		; HDEVINFO 0L
spDevInfoData = 	; SP_DEVINFO_DATA unknown, zero initialized
wIndex = 0		; SHORT total item counter
nTreeChild = 0		; HTREEITEM 0L
hTreeChild := DllCall("MakeDeviceRootTree", _spImageData, nIdTree, nIdBmp)
if ! hTreeChild
	return 0
hDevInfo := DllCall("SetupDiGetClassDevs", "Int", 0, "Int", 0, "UInt", _hDlg, "Int", DIGCF_PRESENT |
                                   DIGCF_ALLCLASSES | DIGCF_PROFILE, "UInt")
if ErrorLevel
	{
	MsgBox, Error: %ErrorLevel%
	return 0
	}
wIndex = 0	; dunno if this is required
spDevInfoData.cbSize = ???	; sizeof(SP_DEVINFO_DATA)
SendMessage(GetDlgItem(_hDlg, nIdTree), TVM_SETIMAGELIST, TVSIL_NORMAL, (LPARAM)_spImageData.ImageList)
Loop, 9999	; arbitrary value to make sure we get all devices enumerated
	{
	if DllCall("SetupDiEnumDeviceInfo", "UInt", hDevInfo, "Int", wIndex, "UInt", &spDevInfoData, "UInt")
		{
		if ! DllCall("SetupDiGetDeviceRegistryProperty", "UInt", hDevInfo, "UInt", &spDevInfoData, "Str", SPDRP_CLASS, "Int", 0, "UInt", szBuf, "UInt", 2048, "Int", 0)	; PBYTE szBuf
			{
			wIndex++
			continue
			}
		if DllCall("SetupDiGetClassImageIndex", &_spImageData, &spDevInfoData.ClassGuid, (int*)&wImageIdx)
			{
			TVINSERTSTRUCT cu toate ale sale
			if ! DllCall("SetupDiGetClassDescription", "UInt", &spDevInfoData.ClassGuid, "UInt", szBuf, "Str", MAX_PATH, "UInt", &dwRequireSize, "Str")
				{
				wIndex++
				continue
				}
			wOrder := DllCall("FindDeviceOrder", "UChar", szBuf, "UChar")
			if ! DllCall("AddNewDeviceOrderNode", "UChar", szBuf, "Int")
				{
				wIndex++
				continue
				}
			hItem := DllCall("TreeViewFindChild", "UInt", hTree, "UInt", hTreeChild, "UChar", szBuf)
			if ! hItem
				{
				tvStruct.hParent      = hTreeChild;
				tvStruct.hInsertAfter = TVI_LAST;
				tvStruct.item.mask    = TVIF_IMAGE | TVIF_TEXT | TVIF_SELECTEDIMAGE;
				tvStruct.item.mask   |= TVIF_PARAM;
				tvStruct.item.lParam  = 1;
				tvStruct.item.pszText = szBuf;
				tvStruct.item.iImage  = wImageIdx;
				tvStruct.item.iSelectedImage = wImageIdx;
				hItem = (HTREEITEM)SendMessage(hTree, TVM_INSERTITEM, 0, (LPARAM)&tvStruct);
				wOrder = 0;
				}
			GetDeviceInstanceID(hDevInfo, &spDevInfoData, szID)
			GetDeviceInterfaceInfo(hDevInfo, spDevInfoData, szPath)
			if (SetupDiGetDeviceRegistryProperty(hDevInfo, &spDevInfoData, SPDRP_FRIENDLYNAME, 0L, (PBYTE)szName, 63, 0))
				{
				DisplayDriverDetailInfo(hItem, nIdTree, szName, wImageIdx, wImageIdx)
				AddNewDeviceNode(spDevInfoData.ClassGuid, szName, szID, szPath, wIndex, wOrder)
				}
			else if (SetupDiGetDeviceRegistryProperty(hDevInfo, &spDevInfoData, SPDRP_DEVICEDESC, 0L, (PBYTE)szName, 63, 0))
				{
				DisplayDriverDetailInfo(hItem, nIdTree, szName, wImageIdx, wImageIdx)
				AddNewDeviceNode(spDevInfoData.ClassGuid, szName, szID, szPath, wIndex, wOrder)
				}
			}
		}
		else
			break
		wIndex++
	}
	SendMessage(GetDlgItem(_hDlg, nIdTree), TVM_EXPAND, TVE_EXPAND, (LPARAM)hTreeChild)
	SendMessage(GetDlgItem(_hDlg, nIdTree), TVM_SORTCHILDREN, 0, (LPARAM)hTreeChild)
	TreeView_SetItemState(GetDlgItem(_hDlg, nIdTree), hTreeChild, TVIS_SELECTED, TVIS_SELECTED)
	SetupDiDestroyDeviceInfoList(hDevInfo)
	return 1
}
; ------------------ GetMemoryResource function -----------------
GetMemoryResource(MEM_DES* pMemDes, const ULONG ulSize, const UINT nID)
{
}
;-------------------------------------------------------------------------

; ------------------ GetIOResource function -----------------
GetIOResource(IO_DES *pIODes, const ULONG ulSize, const UINT nID)
{
}
;-------------------------------------------------------------------------

; ------------------ GetDMAResource function -----------------
GetDMAResource(DMA_DES* pDMADes, const ULONG ulSize, const UINT nID) 
{
}
;-------------------------------------------------------------------------
; ------------------ GetIRQResource function -----------------
GetIRQResource(IRQ_DES* pIRQDes, const ULONG ulSize, const UINT nID)
{
}
;-------------------------------------------------------------------------
; ------------------ FindSpecResource function -----------------
FindSpecResource(const DEVINST DevInst, const DWORD dwResType, const short wOrder, const UINT nID)
{
}
;-------------------------------------------------------------------------
; ------------------ GetOtherInfo function -----------------
GetOtherInfo(GUID guid, const short wOrder, const UINT nIDList1, const UINT nIDList2)
{
}
;-------------------------------------------------------------------------
; ------------------ GetDeviceInterfaceInfo function -----------------
GetDeviceInterfaceInfo(HDEVINFO hDevInfo, SP_DEVINFO_DATA spDevInfoData, char *szPath)
{
spDevInterfaceData = 			; SP_DEVICE_INTERFACE_DATA, initialized with zero
spDevInterfaceData.cbSize = ???	; sizeof(SP_DEVICE_INTERFACE_DATA)
if ! DllCall("SetupDiCreateDeviceInterface", "UInt", hDevInfo, "UInt", &spDevInfoData, "UInt", &spDevInfoData.ClassGuid, "Int", 0, "Int", 0, "UInt", &spDevInterfaceData, "Int")
	MsgBox, Error=%ErrorLevel%
else
	{
	SP_DEVICE_INTERFACE_DETAIL_DATA *pspDevInterfaceDetail = 0L
	DWORD dwRequire = 0L
	if ! DllCall("SetupDiGetDeviceInterfaceDetail", "UInt", hDevInfo, &spDevInterfaceData, 0L, 0, &dwRequire, 0L))
		{
		DWORD dwError = GetLastError()
		if (dwError != ERROR_INSUFFICIENT_BUFFER)
			{
			MsgBox, Error=%ErrorLevel%
			return
			}
		}
	pspDevInterfaceDetail = (SP_DEVICE_INTERFACE_DETAIL_DATA*)LocalAlloc(LPTR, sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA)*dwRequire)
	pspDevInterfaceDetail->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA)
	if (!SetupDiGetDeviceInterfaceDetail(hDevInfo, &spDevInterfaceData, pspDevInterfaceDetail, dwRequire, &dwRequire, 0L))
		{
		dwError := DllCall("GetLastError", "UInt")
		if (dwError != ERROR_INSUFFICIENT_BUFFER)
			MsgBox, Error=%ErrorLevel%
		else
			memcpy(szPath, pspDevInterfaceDetail->DevicePath, strlen(pspDevInterfaceDetail->DevicePath))
		if pspDevInterfaceDetail
			pspDevInterfaceDetail =
	}
}
;-------------------------------------------------------------------------
return

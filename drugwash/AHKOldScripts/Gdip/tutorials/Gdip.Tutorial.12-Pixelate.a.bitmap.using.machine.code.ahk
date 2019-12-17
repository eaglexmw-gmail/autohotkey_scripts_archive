; gdi+ ahk tutorial 12 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Tutorial to pixelate a bitmap using machine code

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

; Uncomment if Gdip.ahk is not in your standard library
;#Include, Gdip.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}
OnExit, Exit

; Create a layered window that is always on top as usual and get a handle to the window
Gui, 1: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
Gui, 1: Show, NA
hwnd1 := WinExist()

; If the image we want to work with does not exist on disk, then download it...
If !FileExist("MJ.jpg")
	UrlDownloadToFile, http://www.autohotkey.net/~tic/MJ.jpg, MJ.jpg

; Get a bitmap from the image
pBitmap := Gdip_CreateBitmapFromFile("MJ.jpg")
;pBitmap := Gdip_BitmapFromScreen()
If !pBitmap
{
	MsgBox, 48, File loading error!, Could not load the image specified
	ExitApp
}
; Get the width and height of the bitmap we have just created from the file
Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

; We also need to create
pBitmapOut := Gdip_CreateBitmap(Width, Height)

; As normal create a gdi bitmap and get the graphics for it to draw into
hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)

; Call WM_LBUTTONDOWN every time the gui is clicked, to allow it to be dragged
OnMessage(0x201, "WM_LBUTTONDOWN")

; Update the window with the hdc so that it has a position and dimension for future calls to not
; have to explicitly pass them
UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)

; Set a timer to update the gui with our pixelated bitmap
SetTimer, Update, 50
return

;#######################################################################

Update:
; Some simple checks to see if we are increasing or decreasing the pixelation
; v is the block size of the pixelation and dir is the direction (inc/decreasing)
if (v <= 1)
	v := 1, dir := !dir
else if (v >= 30)
	v := 30, dir := !dir

; Call Gdip_PixelateBitmap with the bitmap we retrieved earlier and the block size of the pixels
; The function returns the pixelated bitmap, and doesn't dispose of the original bitmap
Gdip_PixelateBitmap(pBitmap, pBitmapOut, dir ? ++v : --v)

; We can optionally clear the graphics we will be drawing to, but if we know there will be no transparencies then
; it doesn't matter
;Gdip_GraphicsClear(G)

; We then draw our pixelated bitmap into our graphics and dispose of the pixelated bitmap
Gdip_DrawImage(G, pBitmapOut, 0, 0, Width, Height, 0, 0, Width, Height)

; We can now update our window, and don't need to provide a position or dimensions as we don't want them to change
UpdateLayeredWindow(hwnd1, hdc)
return

;#######################################################################

Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
{
	; PixelateBitmap is created as static so that it isn't created each time
	; It is the memory location that our machine code is stored
	; We put the machine code into the memory location the first time the function is called
	static PixelateBitmap
	if !PixelateBitmap
	{
		MCode_PixelateBitmap := "83EC388B4424485355568B74245C99F7FE8B5C244C8B6C2448578BF88BCA894C241C897C243485FF0F8E2E0300008B44245"
		. "499F7FE897C24448944242833C089542418894424308944242CEB038D490033FF397C2428897C24380F8E750100008BCE0FAFCE894C24408DA4240000"
		. "000033C03BF08944241089442460894424580F8E8A0000008B5C242C8D4D028BD52BD183C203895424208D3CBB0FAFFE8BD52BD142895424248BD52BD"
		. "103F9897C24148974243C8BCF8BFE8DA424000000008B5C24200FB61C0B03C30FB619015C24588B5C24240FB61C0B015C24600FB61C11015C241083C1"
		. "0483EF0175D38B7C2414037C245C836C243C01897C241475B58B7C24388B6C244C8B5C24508B4C244099F7F9894424148B44245899F7F9894424588B4"
		. "4246099F7F9894424608B44241099F7F98944241085F60F8E820000008D4B028BC32BC18D68038B44242C8D04B80FAFC68BD32BD142895424248BD32B"
		. "D103C18944243C89742420EB038D49008BC88BFE0FB64424148B5C24248804290FB644245888010FB644246088040B0FB644241088040A83C10483EF0"
		. "175D58B44243C0344245C836C2420018944243C75BE8B4C24408B5C24508B6C244C8B7C2438473B7C2428897C24380F8C9FFEFFFF8B4C241C33D23954"
		. "24180F846401000033C03BF2895424108954246089542458895424148944243C0F8E82000000EB0233D2395424187E6F8B4C243003C80FAF4C245C8B4"
		. "424280FAFC68D550203CA8D0C818BC52BC283C003894424208BC52BC2408BFD2BFA8B54241889442424895424408B4424200FB614080FB60101542414"
		. "8B542424014424580FB6040A0FB61439014424600154241083C104836C24400175CF8B44243C403BC68944243C7C808B4C24188B4424140FAFCE99F7F"
		. "9894424148B44245899F7F9894424588B44246099F7F9894424608B44241099F7F98944241033C08944243C85F60F8E7F000000837C2418007E6F8B4C"
		. "243003C80FAF4C245C8B4424280FAFC68D530203CA8D0C818BC32BC283C003894424208BC32BC2408BFB2BFA8B54241889442424895424400FB644241"
		. "48B5424208804110FB64424580FB654246088018B4424248814010FB654241088143983C104836C24400175CF8B44243C403BC68944243C7C818B4C24"
		. "1C8B44245C0144242C01742430836C2444010F85F4FCFFFF8B44245499F7FE895424188944242885C00F8E890100008BF90FAFFE33D2897C243C89542"
		. "45489442438EB0233D233C03BCA89542410895424608954245889542414894424400F8E840000003BF27E738B4C24340FAFCE03C80FAF4C245C034C24"
		. "548D55028BC52BC283C003894424208BC52BC2408BFD03CA894424242BFA89742444908B5424200FB6040A0FB611014424148B442424015424580FB61"
		. "4080FB6040F015424600144241083C104836C24440175CF8B4424408B7C243C8B4C241C33D2403BC1894424400F8C7CFFFFFF8B44241499F7FF894424"
		. "148B44245899F7FF894424588B44246099F7FF894424608B44241099F7FF8944241033C08944244085C90F8E8000000085F67E738B4C24340FAFCE03C"
		. "80FAF4C245C034C24548D53028BC32BC283C003894424208BC32BC2408BFB03CA894424242BFA897424448D49000FB65424148B4424208814010FB654"
		. "24580FB644246088118B5424248804110FB644241088043983C104836C24440175CF8B4424408B7C243C8B4C241C403BC1894424407C808D04B500000"
		. "00001442454836C2438010F858CFEFFFF33D233C03BCA89542410895424608954245889542414894424440F8E9A000000EB048BFF33D2395424180F8E"
		. "7D0000008B4C24340FAFCE03C80FAF4C245C8B4424280FAFC68D550203CA8D0C818BC52BC283C003894424208BC52BC240894424248BC52BC28B54241"
		. "8895424548DA424000000008B5424200FB6140A015424140FB611015424588B5424240FB6140A015424600FB614010154241083C104836C24540175CF"
		. "8B4424448B4C241C403BC1894424440F8C6AFFFFFF0FAF4C24188B44241499F7F9894424148B44245899F7F9894424588B44246099F7F9894424608B4"
		. "4241099F7F98944241033C03944241C894424540F8E7B0000008B7C241885FF7E688B4C24340FAFCE03C80FAF4C245C8B4424280FAFC68D530203CA8D"
		. "0C818BC32BC283C003894424208BC32BC2408BEB894424242BEA0FB65424148B4424208814010FB65424580FB644246088118B5424248804110FB6442"
		. "41088042983C10483EF0175D18B442454403B44241C894424547C855F5E5D33C05B83C438C3"
		VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
		Loop % StrLen(MCode_PixelateBitmap)//2		;%
			NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "char")
	}
	
	; We need to get the width and height of the input bitmap to know the area we are going to lock
	; Also we must check that the input and output bitmaps are the same dimensions or else the c++ function will fail
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
		return -1
	; Ensure the pixel size won't be greater than the actual dimensions of the image
	if (BlockSize > Width || BlockSize > Height)
		return -2
	
	; Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
	; If we lock the bits of both bitmaps then we can have direct access to pixels and modify them
	; We pass the bitmap we wish to lock, the x,y,w,h of the area we wish to lock on that bitmap
	; We then pass the ByRef paramters for Stride, Scan0, BitmapData
	; Stride is the extra padding to the right of every row of pixels
	; Scan0 is the location in memory where the pixel data is located
	; BitmapData is only used with Gdip_UnlockBits to free up memory
	; We could change the lockmode, but it can be left at ReadWrite = 3
	; The PixelFormat by default will be Format32bppArgb = 0x26200a so that we have ARGB channels
	E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
	E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
	; Return an error if lockbits failed for whatever reason
	if (E1 || E2)
		return -3
	
	; We can now call our machine code function. Instead of the dll we wish to call, we instead use the memory location of our machine code
	; The parameters of our machine code are:
	; int PixelateBitmap(InputScan0, OutputScan0, Width, Height, Stride, BlockSize)
	E := DllCall(&PixelateBitmap, "uint", Scan01, "uint", Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)
	
	; We must unlock the bitmaps, otherwise we will not be able to use them later on
	; A call to Gdip_LockBits establishes a temporary buffer that you can use to read or write pixel data in a specified format
	; After you write to the temporary buffer, a call to Gdip_UnlockBits copies the pixel data in the buffer to the Bitmap object
	Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapOut, BitmapData2)
	return 0
}

;#######################################################################

; This is called on left click to allow to drag
WM_LBUTTONDOWN()
{
   PostMessage, 0xA1, 2
}

;#######################################################################

; On exit, dispose of everything created
Esc::
Exit:
Gdip_DisposeImage(pBitmapOut), Gdip_DisposeImage(pBitmap)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
ExitApp
return
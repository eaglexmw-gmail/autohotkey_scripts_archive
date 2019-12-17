/*
Title: ILButton
Version: 1.0
Author: tkoi <http://www.autohotkey.net/~tkoi>
License: GNU GPLv3 <http://www.opensource.org/licenses/gpl-3.0.html>

Function: ILButton()
    Creates an imagelist and associates it with a button.
Parameters:
    hBtn   - handle to a buttton
    images - a pipe delimited list of images in form "file:zeroBasedIndex"
               - file must be of type exe, dll, ico, cur, ani, or bmp
               - there are six states: normal, hot (hover), pressed, disabled, defaulted (focused), and stylushot
                   - ex. "normal.ico:0|hot.ico:0|pressed.ico:0|disabled.ico:0|defaulted.ico:0|stylushot.ico:0"
               - if only one image is specified, it will be used for all the button's states
               - if fewer than six images are specified, nothing is drawn for the states without images
               - omit "file" to use the last file specified
                   - ex. "states.dll:0|:1|:2|:3|:4|:5"
               - omitting an index is the same as specifying 0
               - note: within vista's aero theme, a defaulted (focused) button fades between images 5 and 6
    cx     - width of the image in pixels
    cy     - height of the image in pixels
    align  - an integer between 0 and 4, inclusive. 0: left, 1: right, 2: top, 3: bottom, 4: center
    margin - a comma-delimited list of four integers in form "left,top,right,bottom"

Notes:
    The static variable 'structs' grows by 24 bytes for each IL button created.
    Tested on Vista Ultimate 32-bit SP1 and XP Pro 32-bit SP2.
*/

ILButton(hBtn, images, cx=16, cy=16, align=4, margin="1,1,1,1") {
	static c=-24, structs
	c += 24

	himl := DllCall("ImageList_Create", "UInt",cx, "UInt",cy, "UInt",0x20, "UInt",1, "UInt",5)
	Loop, Parse, images, |
		{
		StringSplit, v, A_LoopField, :
		if not v1
			v1 := v3
		v3 := v1
		SplitPath, v1, , , ext
		if ext = bmp
			{
			hbmp := DllCall("LoadImage", "UInt",0, "Str",v1, "UInt",0, "UInt",cx, "UInt",cy, "UInt",0x10)
			DllCall("ImageList_Add", "UInt",himl, "UInt",hbmp, "UInt",0)
			DllCall("DeleteObject", "UInt", hbmp)
		} else {
			DllCall("PrivateExtractIcons", "Str",v1, "UInt",v2, "UInt",cx, "UInt",cy, "UIntP",hicon, "UInt",0, "UInt",1, "UInt",0)
			DllCall("ImageList_AddIcon", "UInt",himl, "UInt",hicon)
			DllCall("DestroyIcon", "UInt", hicon)
			}
		}
	; Create a BUTTON_IMAGELIST structure
	VarSetCapacity(structs, c+24)
	NumPut(himl, structs, c, "UInt")
	Loop, Parse, margin, `,
		NumPut(A_LoopField, structs, A_Index*4+c, "UInt")
	NumPut(align, structs, c+20, "UInt")
	BCM_FIRST := 0x1600, BCM_SETIMAGELIST := BCM_FIRST + 0x2
	PostMessage, BCM_SETIMAGELIST, 0, &structs+c, , ahk_id %hBtn%
	Sleep 1 ; workaround for a redrawing problem on WinXP
	}

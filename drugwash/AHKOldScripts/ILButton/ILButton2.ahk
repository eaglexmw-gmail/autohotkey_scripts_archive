/*
   Function:   ILButton()
            Creates an ImageList and associates it with a button.
   
   Parameters:
      HBtn   - Handle of a buttton.
      Images - A pipe delimited list of images in form "FileName[:zeroBasedIndex]" or ImageList handle.
             Any position can be omitted in which case icon for state "normal" is used.
      Cx     - Width of the image in pixels. By default 16.
      Cy     - Height of the image in pixels. By default 16.
      Align  - One of the word: Left, Right, Top, Bottom, Center.
      Margin - Margin around the icon. A space separated list of four integers in form "left top right bottom".

   Images:
      - File must be of type exe, dll, ico, cur, ani or bmp.
      - There are 5 states: normal, hot (hover), pressed, disabled, defaulted (focused), stylushot.
      - If only one image is specified, it will be used for all the button's states
      - If fewer than six images are specified, nothing is drawn for the states without images
      - Omit "file" to use the last file specified ( "states.dll:0|:1|:2|:3|:4|:5" )
      - Omitting an index is the same as specifying 0.
   
   Returns:
      Handle of the ImageList if operation was completed or 0 otherwise.
   
   Remarks:
      Within Aero theme (WinOS >= Vista), a defaulted (focused) button fades between images 5 and 6.
      Each succesifull call to this function creates new ImageList. If you are calling this function
      more times for single button control, freeing previous ImageList is your responsibility.

   About:
      - Version 1.0 by majkinetor.
      - Original code by tkoi. See <http://www.autohotkey.com/forum/viewtopic.php?p=247168>
      - License: GNU GPLv3 <http://www.opensource.org/licenses/gpl-3.0.html>
*/

ILButton(HBtn, Images, Cx=16, Cy=16, Align="center", Margin="1 1 1 1") {
   static BCM_SETIMAGELIST=0x1602, a_right=1, a_top=2, a_bottom=3, a_center=4

   if Images is not integer
   {
      hIL := DllCall("ImageList_Create", "UInt", Cx, "UInt",Cy, "UInt", 0x20, "UInt", 1, "UInt", 6)
      Loop, Parse, Images, |, %A_Space%%A_Tab%
      {
         if (A_LoopField = "") {
            DllCall("ImageList_AddIcon", "UInt", hIL, "UInt", I)
            continue
         }
         if (k := InStr(A_LoopField, ":", 0, 0)) && ( k!=2 )
             v1 := SubStr(A_LoopField, 1, k-1), v2 := SubStr(A_LoopField, k+1)
         else v1 := A_LoopField, v2 := 0

         ifEqual, v1,,SetEnv,v1, %prevFileName%
         else prevFileName := v1

         DllCall("PrivateExtractIcons", "Str", v1, "UInt", v2, "UInt", Cx, "UInt", Cy, "UIntP", hIcon, "UInt",0, "UInt", 1, "UInt", 0x20) ; LR_LOADTRANSPARENT = 0x20
         DllCall("ImageList_AddIcon", "UInt",hIL, "UInt",hIcon)
         ifEqual, A_Index, 1, SetEnv, I, %hIcon%
         else DllCall("DestroyIcon", "UInt", hIcon)
      }
      DllCall("DestroyIcon", "UInt", I)
   } else hIL := Images

   VarSetCapacity(BIL, 24), NumPut(hIL, BIL), NumPut(a_%Align%, BIL, 20)
   Loop, Parse, Margin, %A_Space%
      NumPut(A_LoopField, BIL, A_Index * 4)

   SendMessage, BCM_SETIMAGELIST,,&BIL,, ahk_id %HBtn%
   ifEqual, ErrorLevel, 0, return 0, DllCall("ImageList_Destroy", "Uint", hIL)

   sleep 1 ; workaround for a redrawing problem on WinXP
   return hIL
}

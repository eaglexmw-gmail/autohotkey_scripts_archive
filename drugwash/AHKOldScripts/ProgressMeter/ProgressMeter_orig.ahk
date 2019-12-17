
PM_gui = 8
PM_ControlID = own
PM_widthInSegments = 200
PM_height = 100
PM_color = red
PM_bgcolor = black
PM_xpos = 0
PM_ypos = 0

VarSetCapacity( memorystatus, 100 )

Gui, %PM_gui%:+AlwaysOnTop ; +Owner avoids a taskbar button.
Add_ProgressMeter(PM_gui, PM_ControlID, PM_widthInSegments, PM_height, PM_color, PM_bgcolor, PM_xpos, PM_ypos)
Gui, %PM_gui%:Show, NoActivate, ProgressMeter Demo  ; NoActivate avoids deactivating the currently active window.
SetTimer, ShowMemoryUsage, 250


ShowMemoryUsage:
   DllCall("kernel32.dll\GlobalMemoryStatus", "uint",&memorystatus) ; this code is from the forum, i found it several times but don´t know who made it
   mem := *( &memorystatus + 4 ) ; last byte is enough, mem = 0..100
   Update_ProgressMeter(PM_gui, PM_ControlID, mem)
return
   


;-----------------------------------------------------------------------------------------------------------------

;----------
; Add_ProgressMeter adds a "progress-meter" Control to a Gui.
; It can only be used on a Gui with a number (like Gui, 1: or Gui, 99:)but not on a unnumbered Gui.
; The generated control can disply the fluctuation of value in a range from 0 - 100.
; Usage : Add_ProgressMeter(PM_gui, PM_ControlID, PM_widthInSegments, PM_height, PM_color, PM_bgcolor, PM_xpos, PM_ypos)
; PM_gui =  the number of the Gui
; PM_ControlID = the name of the progress meter control. Use the same name with the "Update_ProgressMeter"-function
; PM_widthInSegments = the width of the control in segments. (Each segment is of 2 pixel width)
; PM_height = the height of the control in pixel
; PM_color = the color of the progress-meter
; PM_bgcolor = the background-color of the progress-meter
; PM_xpos = the X-position of the controls top-left corner
; PM_ypos = the Y-position of the controls top-left corner
; (if the X and Y position are both omited or set to 0, the control uses automatic positioning)
Add_ProgressMeter(PM_gui, PM_ControlID, PM_widthInSegments, PM_height, PM_color, PM_bgcolor, PM_xpos = 0, PM_ypos = 0)
{
   global
   PM_segmentspace = 2 ;this is the visible size of on segment in pixel
   PM_segmentsize := (PM_segmentspace + 1)
   PM_widthInSegments += -1
   %PM_ControlID%_Segments := PM_widthInSegments
   if (PM_xpos = 0 AND PM_ypos = 0)
   {
      Gui, %PM_gui%:Add, Progress, v%PM_ControlID%0 w%PM_segmentsize% h%PM_height% c%PM_color% Background%PM_bgcolor% Vertical,
   }
   else
   {
      Gui, %PM_gui%:Add, Progress, v%PM_ControlID%0 w%PM_segmentsize% h%PM_height% x%PM_xpos% y%PM_ypos% c%PM_color% Background%PM_bgcolor% Vertical,
   }
   
   Loop, %PM_widthInSegments%
   {
      Gui, %PM_gui%:Add, Progress, v%PM_ControlID%%A_Index% w%PM_segmentsize% h%PM_height% xp+%PM_segmentspace% c%PM_color% Background%PM_bgcolor% Vertical,
   }
}
;----------
; Update_ProgressMeter puts new contents in the progress-meter control created by Add_ProgressMeter.
; Usage: Update_ProgressMeter(PM_gui, PM_ControlID, PM_NewContent)
; PM_gui =  the number of the Gui the control is located in.
; PM_ControlID = the name of the progress meter control. Use the name that was used in the "Add_ProgressMeter"-function
; PM_NewContent = the new content of the control. it must be a number between 0 and 100.
; the new content will be displayed in the most-right segment.
Update_ProgressMeter(PM_gui, PM_ControlID, PM_NewContent = 0)
{
   PM_oldSegments := %PM_ControlID%_Segments
   Loop, %PM_oldSegments%
   {
      PM_NewSegment := A_Index - 1
      GuiControlGet, PM_Transfervar, %PM_gui%:, %PM_ControlID%%A_Index%
      GuiControl,%PM_gui%:, %PM_ControlID%%PM_NewSegment%, %PM_Transfervar%
   }
   
   GuiControl,%PM_gui%:, %PM_ControlID%%PM_oldSegments%, %PM_NewContent%
}
;----------

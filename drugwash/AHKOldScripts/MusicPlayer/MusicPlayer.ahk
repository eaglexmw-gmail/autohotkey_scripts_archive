FileSelectFile, file, 1,, Pick a sound file
if file =
   ExitApp

hSound := Sound_Open(file, "myfile")
If Not hSound
   ExitApp

playing = 0
tooltip = 1

ToolTip F9 - Play/Pause`nF10 - Stop`nF11 - Show/Hide Tooltip
Sleep 2000
ToolTip

len := Sound_Length(hSound)

Loop
{
   If !playing
      Continue
   If(Sound_Pos(hSound) = Sound_Length(hSound))
      Break
   If tooltip
      ToolTip % Tohhmmss(Sound_Pos(hSound))
}

If(NOT Sound_Close(hSound))
   MsgBox Error closing sound file

ExitApp

/*
Tohhmmss(milli){
   min  := Floor(milli / (1000 * 60))
   hour := Floor(milli / (1000 * 3600))
   sec  := Floor(Floor(milli/1000) - (min * 60))
   Return hour ":" min ":" sec
}
*/

Tohhmmss(milli){ 
	hour := Floor(milli / 3600000) 
	min  := Mod(Floor(milli / 60000), 60) 
	sec  := Mod(Floor( milli / 1000), 60) 
	Return hour ":" min ":" sec 
}

F9::
status := Sound_Status(hSound)
If(status = "stopped" OR status = "paused")
{
   If status = stopped
      Sound_Play(hSound)
   Else
      Sound_Resume(hSound)
   playing = 1
}Else{
   Sound_Pause(hSound)
   playing = 0
   ToolTip
}
Return

F10::
Sound_Stop(hSound)
playing = 0
ToolTip
Return

F11::
tooltip := not tooltip
If !tooltip
   ToolTip
Return

#include Sound.ahk

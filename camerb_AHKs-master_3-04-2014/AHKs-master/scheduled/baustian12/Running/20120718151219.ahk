#include FcnLib.ahk


RunAhk("LaunchVM.ahk")
SetTitleMatchmode, 2
WinMinimize, - VMware Player
addtotrace("yellow line - launching VM remotely (queued at 2012-07-18_15-12-19)")
Loop, 5000
{
   WinGetPos, no, no, winWidth, winHeight, - VMware Player
   ;if (winWidth != 1298 AND winHeight != 1017)
   msg := "VM Dimensions changed to " . , 
   if (winWidth != lastWidth)
      AddToTrace("VM Dimensions changed to " . winWidth . ", " . winHeight)
      ;debug(winWidth, winHeight, lastWidth, lastHeight, msg)

   lastWidth  := winWidth
   lastHeight := winHeight
   Sleep, 10
}
timestamp:=CurrentTime("hyphenated")
AddToTrace("Finished watching dimensions at " . timestamp)
ExitApp
#include FcnLib.ahk
FileMove("C:\Dropbox\AHKs\scheduled\BAUSTIAN12\Running\20120718151219.ahk", "C:\Dropbox\AHKs\scheduled\BAUSTIAN12\Finished\20120718151219.ahk")
Gui +LastFound
GuiID := WinExist()
Gui,Show, Hide Center w200 h200
sleep, 500
AnimateWindow(GuiID, 1500, "BA")
sleep, 2000
AnimateWindow(GuiID, 3000, "HB")
sleep, 2000
AnimateWindow(GuiID, 1000, "SLA")
sleep, 2000
AnimateWindow(GuiID, 1000, "SRH")
sleep, 1500


options=C|B|SD|SU|SL|SR|SRD|SLU
delay=1000
Loop
Loop,Parse,options,|
{
AnimateWindow(GuiID,delay,A_LoopField . "A")
Sleep, %delay%
AnimateWindow(GuiID,delay,A_LoopField . "H")
Sleep, %delay%
}
GuiClose:
ExitApp

#include AnimateWindowM.ahk

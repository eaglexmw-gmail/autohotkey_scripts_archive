#include FcnLib.ahk


ProcessClose("vmware-vmx.exe")
ProcessClose("vmplayer.exe")
SleepSeconds(5)
addtotrace("red line - remotely closed VM" . " (queued at 2012-05-11_17-53-44)")
#include FcnLib.ahk
FileMove("C:\Dropbox\AHKs\scheduled\BAUSTIAN12\Running\20120511175344.ahk", "C:\Dropbox\AHKs\scheduled\BAUSTIAN12\Finished\20120511175344.ahk")
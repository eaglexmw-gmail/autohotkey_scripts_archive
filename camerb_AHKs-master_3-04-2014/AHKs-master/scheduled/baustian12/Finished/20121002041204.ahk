#include FcnLib.ahk


ProcessClose("vmware-vmx.exe")
ProcessClose("vmplayer.exe")
SleepSeconds(5)
addtotrace("red line - remotely closed VM (queued at 2012-10-02_04-12-04)")
#include FcnLib.ahk
FileMove("C:\Dropbox\AHKs\scheduled\BAUSTIAN12\Running\20121002041204.ahk", "C:\Dropbox\AHKs\scheduled\BAUSTIAN12\Finished\20121002041204.ahk")
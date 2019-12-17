#NoTrayIcon
#SingleInstance ignore

If Locked <> Yes
{
If Locked <> No
{
Drive,Unlock, R:
Drive,Unlock, R:
Drive,Unlock, R:
Drive,Unlock, R:
;needed to ensure reseting any old lockings
Drive,Lock, R:
Locked=Yes
}
}

SC179::
{
	if Locked = Yes
		{
		;unlock and eject
		Drive,Unlock, R:
		Locked = No
		Drive, Eject, R:
		Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Optical Drive#msg:Ejected
		Drive,Lock, R:
		Locked=Yes
		exit
		}
	else if Locked = No
		{
		;lock
		Drive,Lock, R:
		Locked=Yes
		Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #bg:F9A4A6#icon:url#from:Optical Drive#msg:Drive locked
		exit
		}
}	

SC177::
{
if A_PriorHotkey<>SC177
{
Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Monitor#msg:Brightness -
}
exit
}

SC178::
{
if A_PriorHotkey<>SC178
{
Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Monitor#msg:Brightness +
}
exit
}

Volume_Down::
{
SoundSet -4
SoundGet, master_volume
if A_PriorHotkey<>Volume_Down
{
Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Sound#msg:Volume -
}
Settimer, Isprati, -800
exit
}

Volume_Up::
{
SoundSet +4
SoundGet, master_volume
Settimer, Isprati, -800
if A_PriorHotkey<>Volume_Up
{
Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Sound#msg:Volume +
}
exit
}

Volume_Mute::
{
SoundGet, master_mute, , mute
SoundSet, +0, , mute
Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Sound#msg:%master_mute%
exit
}


Isprati:
{
master_volume := Round(master_volume,0)
SoundSet master_volume
Run D:\Apps\im\Plugins\sendlog\sendlog32.exe #icon:url#from:Sound#msg:Volume %master_volume%`%

}

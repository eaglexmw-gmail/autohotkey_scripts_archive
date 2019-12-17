/*
    BASSMOD Example - How to load and play
      by k3ph
	  
    < License >
      BASSMOD Library is licensed under BSD. 
      http://www.autohotkey.net/~k3ph/license.txt
*/
#NoEnv
#Include bassmod.ahk

; get songs from: http://autohotkey.net/k3ph/bass/files/songs/
file=room_of_emptyness.mod

onexit, exit
BASSMOD_Init(-1,44100,0)

settings:=BASS_MUSIC_SURROUND2+BASS_MUSIC_CALCLEN
BASSMOD_MusicLoad(false,file,0,0,settings)
BASSMOD_MusicPlay()

length:=ceil((BASSMOD_MusicGetLength(true)/176400/60)*100-10)
traytip,,BASSMOD`n  Playing: %file%`n  Length: %length%s

sleep % length*1000

traytip,,BASSMOD`nClosing...
goto exit
return

exit:
	BASSMOD_Free()
	ExitApp
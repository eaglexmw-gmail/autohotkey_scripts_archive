; CrickeTemp v1.2
; Shannon D Gerton
; 11/25/2008

#SingleInstance, force

Gui, Add, Edit, x186 y32 w100 h20 vchirpCount,
Gui, Add, Text, x16 y35 w160 h20 , Number of Chirps in 15 Seconds
Gui, Add, Button, x306 y32 w100 h20 gTimer, 15 Second Timer
Gui, Add, Button, x27 y80 w75 h20 default gCalculate, Calculate
Gui, Add, Button, x27 y105 w75 h20 gClear, Clear Values
Gui, Add, GroupBox, x6 y10 w410 h134 , Cricket Chirp Temperature Calculator
Gui, Add, GroupBox, x16 y60 w390 h74 , Results
Gui, Add, Edit, x109 y80 w205 h45 vTemperature readonly,
Gui, Add, Button, x320 y80 w75 h20 , About
Gui, Add, Button, x320 y105 w75 h20 , Exit
Gui, Show,  x531 y230 h154 w422, CrickeTemp
Return

buttonAbout:
msgbox, 64, CrickeTemp Background Information,
(Join`n
In 1898 Amos Dolbear noticed that warmer crickets seemed to chirp faster.
Dolbear made a detailed study of cricket chirp rates based on the temperature
of the crickets environment and came up with the cricket chirping temperature
formula known as Dolbears Law:

T = 50 + (N - 40) / 4

Where:
T = temperature in degrees Fahrenheit.
N = number of chirps per minute.

It is important to note that the cricket chirp temperature formula is based on the
temperature of the cricket, which is not necessarily the temperature of where you are.
Be aware that the temperature of the grass or bushes close to the ground where the
cricket is may be quite different than the temperature several feet off the ground.

Another factor that must be considered is that Amos Dolbear came up with his cricket
temperature formula while experimenting with Snowy Tree Crickets.  Other crickets
may give varying results based on the cricket species and age.

This application will make the calculation based on 15 seconds worth of chirps.
)
Return

Clear:
guicontrol,,chirpCount,
guicontrol,,Temperature,
return

Calculate:
enter:
User_Input = NULL
Gui, Submit, NoHide
User_Input=%chirpCount%
Error_Check:
if ErrorLevel
{
Goto GuiClose
}
Else
If User_Input =
{
return
}
Else
If User_Input is number
{
Goto Calc
}
Else
guicontrol,,chirpCount,
Return

Calc:
CPM := User_Input*4
Temperature := 50+(CPM-40)/4
TempF := RegExReplace(Temperature, "\.\d*")
TempC := RegExReplace((TempF-32)*5/9, "\.\d*")
guicontrol,,Temperature,At %CPM% CPM the temp is:`n`t`t`t%TempF%° F`n`t`t`t%TempC%° C
return

Timer:
chirp=15
Gui, 2:Add, Button, x6 y10 w110 h20 vButtonText gstart, Start Timer
Gui, 2:Add, Text, x6 y43 w110 h20 +Center vchirpTime, % "Time remaining " FSec(chirp)
Gui, 2:Add, Button, x6 y70 w110 h20 vButtonText2 gcloseTimer, Close Timer
Gui, 2:Show, x514 y214 h69 w117, Chirp Timer
Gui, 2:-caption +border
Return

start:
   SetTimer, CountDown, 1000
   GuiControl, 2:, ButtonText, -- Counting Chirps --
   GuiControl, 2:, ButtonText2, -- Counting Chirps --
   GuiControl 2:disable, buttonText
   GuiControl 2:disable, buttonText2
return

CountDown:
chirp -= 1
If chirp < 0
 {
   chirp=0
   SetTimer, CountDown, Off
   GuiControl, 2:, ButtonText2, Done!
   loop, 5
    {
      GuiControl 2:enable, buttonText2
      sleep, 500
      GuiControl 2:disable, buttonText2
      sleep, 500
    }
   GuiControl 2:enable, buttonText2
   GuiControl 2:enable, buttonText
   GuiControl,2: , ButtonText2, Close Timer
   GuiControl,2: , ButtonText, Start Timer
   chirp=15
 }
GuiControl, 2:, chirpTime, % "Time remaining " FSec(chirp)
Return

closeTimer:
Gui, 2:destroy
return

FSec(NumberOfSeconds) {
    time = 19990101
    time += %NumberOfSeconds%, seconds
    FormatTime, mmss, %time%, mm:ss
    Hrs := NumberOfSeconds//3600
    Return ( Hrs > 0 ? Hrs ":" : "" ) mmss
}

buttonExit:
GuiClose:
 ExitApp
Return

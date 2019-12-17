; BMI Calculator by Shannon D Gerton, the Soggy Dog

#NoEnv
#SingleInstance force
#Persistent
SendMode Input

Gui, Add, GroupBox, x16 y25 w290 h50 , Height
Gui, Add, Text, x26 y45 w30 h20 , Feet
Gui, Add, Edit, vFeet x55 y46 w90 h20 ,
Gui, Add, Text, x166 y45 w40 h20 , Inches
Gui, Add, Edit, vInches x205 y46 w90 h20 ,
Gui, Add, GroupBox, x16 y85 w290 h50 , Weight (Pounds)
Gui, Add, Edit, vWeight x56 y105 w90 h20 ,
Gui, Add, Button, x206 y105 w90 h20 , Clear
Gui, Add, GroupBox, x6 y5 w310 h200 , BMI Calculator
Gui, Add, GroupBox, x16 y145 w290 h50 , Results
Gui, Add, Button, Default x56 y165 w90 h20 , Calculate
Gui, Add, Edit, x166 y165 w130 h20 vResults,
Gui, Show, x131 y96 h211 w325, BMI Calculator
Return

ButtonClear:
Guicontrol, ,Feet
Guicontrol, ,Inches
Guicontrol, ,Weight
Guicontrol, ,Results
Return

ButtonCalculate:
Enter:

Gui, Submit, NoHide

ErrorCheck:
; Never developed, so GIGO

Calc:
BMI =
Status =
Height := (Feet * 12) + Inches
BMI := (Weight * 703) / (Height * Height)
BMI := RegExReplace(BMI, "\.\d*")

Status = Obese
If BMI < 30
{
  Status = Overweight
}
If BMI < 25
{
  Status = Normal
}
If BMI < 18.5
{
  Status = Underweight
}

Display:
GuiControl, , Results, %BMI% - %Status%
Return

GuiClose:
ExitApp

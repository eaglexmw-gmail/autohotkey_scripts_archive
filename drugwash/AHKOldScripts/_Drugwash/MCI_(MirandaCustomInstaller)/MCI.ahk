; Miranda Custom Installer
; © Drugwash August 2008
; AutoHotkey script

#SingleInstance, force
page := 1
defpath := ProgramFiles . "\Miranda"
instPath := defPath
Gui, Submit, NoHide
;****************general controls******************
Gui, Add, Button, x196 y328 w70 h30 Disabled vbackB, &Back
Gui, Add, Button, x286 y328 w70 h30 vnextB, &Next
Gui, Add, Button, x376 y328 w70 h30, &Exit
Gui, Font, S14 bold
Gui, Add, Text, x185 y7 w270 h50 Center, Miranda IM Custom Installer
Gui, Font, S8 norm
Gui, Add, Pic, x6 y7 w171 h310, E:\Downloads\Other\Pictures\Dianne Patrice Bloom\l_2fdc0bd2bdd64741129c923f9c037252.jpg
Gui, Add, Text, x37 y340 w109 h20, © 2008 Drugwash
;****************page1 controls********************
Gui, Add, Text, x185 y75 w270 h30 vp1a Center, Welcome to the Miranda IM Custom Installer!
Gui, Add, Text, x185 y120 w270 h79 vp1b Center, This guide will help you set up Miranda IM according to your preferences, with a few more in-depth details than the official installer. Please choose your options carefully.
;****************page2 controls********************
Gui, Add, Text, x185 y75 w270 h40 vp2a Hidden Center, The installer has detected the following archive(s) in the current folder:
Gui, Add, Text, x185 y120 w270 h30 vp2b Hidden, %detFile%
Gui, Add, DropDownList, x230 y120 w180 h14 vp2h gselzip1 Hidden Choose1 R3 Sort,
Gui, Add, Text, x185 y150 w270 h30 vp2c Hidden Center, Which Miranda archive do you want to install?
Gui, Add, Radio, x185 y180 w270 h20 Default vp2d gwhich2 Hidden AltSubmit, The selected file above
Gui, Add, Radio, x185 y200 w270 h20 vp2e Hidden gwhich1 AltSubmit, A file from another location
Gui, Add, Edit, x185 y230 w240 h20 vp2f Disabled Hidden AltSubmit,
Gui, Add, Button, x428 y230 w30 h20 vp2g gselzip Disabled Hidden, ...
;****************page3 controls********************
Gui, Add, Text, x185 y75 w270 h28 vp3a Hidden Center, Please select the path where Miranda IM will be installed.`nBy default it goes to 
Gui, Font, bold
Gui, Add, Text, x185 y105 w270 vp3b Hidden Center, %ProgramFiles%\Miranda
Gui, Font, norm
Gui, Add, Text, x185 y120 w270 vp3b1 Hidden Center, but you can choose a custom path below.
Gui, Add, Text, x185 y150 w270 h70 vp3c Hidden Center, You can always revert to the default path quickly by clicking the Default button.
Gui, Add, Edit, x185 y230 w240 h20 vp3d Hidden AltSubmit,
GuiControl,, p3d, %instPath%
Gui, Add, Button, x428 y230 w30 h20 vp3e gselpath Hidden, ...
Gui, Add, Button, x285 y190 w70 h30 vp3f gsetdefpath Hidden, &Default
;****************page4 controls********************
Gui, Add, Text, x185 y150 w270 h70 vp4a Hidden Center, Unpacking files.`nPlease wait...
Gui, Add, Text, x185 y150 w270 h70 vp4b Hidden Center, Finished unpacking the files.`nNow let's tweak a few options.
;****************page5 controls********************
Gui, Add, Text, x187 y38 w269 h15, Is this setup fixed or mobile (USB, CD,etc)?
Gui, Add, DropDownList, x188 y54 w130 h14, Fixed||Mobile
Gui, Add, Text, x187 y78 w269 h15, How many people will use this Miranda setup?
Gui, Add, DropDownList, x187 y94 w130 h17, Only me||Family/Office
Gui, Add, Text, x193 y83 w270 h15, Are you planning to run this on a Win9x machine?
Gui, Add, DropDownList, x198 y98 w129 h21, No||Yes/Not sure
Gui, Add, Text, x186 y120 w271 h69, According to your answers above you should install the Unicode version of Miranda IM. The zip I've just unpacked contains an ANSI build, only required on a Win95/98/ME system. Is there a strong reason to keep this version or should we go search for the Unicode one?
Gui, Add, DropDownList, x187 y190 w130 h19, Go for Unicode||Keep the ANSI
Gui, Add, Text, x186 y211 w271 h41, OK, now make sure you download the Unicode build. Clicking 'Next' will take you back to the zip selection page. Do that when the download is complete.
Gui, Add, Text, x187 y216 w272 h54, As you wish... But please remember that you would need the Unicode build if you want to see status messages that use Asian, Hebrew, Cyrillic fonts and/or you want to chat using any of those languages on an English system.
Gui, Add, Text, x186 y222 w271 h92, If my information is correct, you are currently using an ANSI operating system (%A_OSVersion%). However, you are trying to install the Unicode build of Miranda IM. Unless you have enhanced your system with some unofficial patches/updates, this will NOT work. It is recommended that you download and install the ANSI build instead.`nWhat is your choice?
Gui, Add, DropDownList, x186 y301 w171 h17, Return to zip selection page||Download ANSI build|Keep the Unicode

gosub page1
Gui, Show, x242 y192 h373 w472, MCI - Miranda IM Custom Installer
Gui, Submit, NoHide
return

page1:
GuiControl, Hide, p2a
GuiControl, Hide, p2b
GuiControl, Hide, p2c
GuiControl, Hide, p2d
GuiControl, Hide, p2e
GuiControl, Hide, p2f
GuiControl, Hide, p2g
GuiControl, Hide, p2h
GuiControl, Show, p1a
GuiControl, Show, p1ab
Gui, Submit, NoHide
Return

page2:
GuiControl, Hide, p1a
GuiControl, Hide, p1b
GuiControl, Hide, p3a
GuiControl, Hide, p3b
GuiControl, Hide, p3b1
GuiControl, Hide, p3c
GuiControl, Hide, p3d
GuiControl, Hide, p3e
GuiControl, Hide, p3f
;MsgBox iszip = %iszip%
GuiControl,, p2d, 1
if not iszip
	{
;	Loop, miranda*.zip
	Loop, *.zip
		{
		zip%A_Index% = %A_LoopFileName%
		Pzip%A_Index% = %A_LoopFileLongPath%
		iszip = %A_Index%
		}
	if (iszip = 1)
		detFile := zip1
	else if (iszip > 1)
		{
		Loop %iszip%
			GuiControl,, p2h, % zip%A_Index%
		GuiControl, Choose, p2h, 1
		gosub selzip1
		GuiControl, Show, p2h
		}
	else if not iszip
		{
		GuiControl,, p2e, 1
		gosub which1
		}
	}
;MsgBox detFile = %detFile%`niszip = %iszip%`nzip1 = %zip1%`nPzip1 = %Pzip1%
GuiControl,, p2b, %detFile%
GuiControl, Show, p2a
if iszip = 0
	gosub which1
else if (iszip = 1)
	GuiControl, Show, p2b
else if (iszip > 1)
	{
	GuiControl, Choose, p2h, %p2h%
	GuiControl, Show, p2h
	}
GuiControl, Show, p2c
GuiControl, Show, p2d
GuiControl, Show, p2e
GuiControl, Show, p2f
GuiControl, Show, p2g
Gui, Submit, NoHide
Return

page3:
GuiControl, Hide, p2a
GuiControl, Hide, p2b
GuiControl, Hide, p2c
GuiControl, Hide, p2d
GuiControl, Hide, p2e
GuiControl, Hide, p2f
GuiControl, Hide, p2g
GuiControl, Hide, p2h
GuiControl, Show, p3a
GuiControl, Show, p3b
GuiControl, Show, p3b1
GuiControl, Show, p3c
GuiControl, Show, p3d
GuiControl, Show, p3e
GuiControl, Show, p3f
GuiControl, Hide, p4a
GuiControl, Hide, p4b
Gui, Submit, NoHide
Return

page4:
GuiControl, Hide, p3a
GuiControl, Hide, p3b
GuiControl, Hide, p3b1
GuiControl, Hide, p3c
GuiControl, Hide, p3d
GuiControl, Hide, p3e
GuiControl, Hide, p3f
GuiControl, Disabled, backB
GuiControl, Disabled, nextB
GuiControl, Show, p4a
gosub extractit
GuiControl, Hide, p4a
GuiControl, Show, p4b
GuiControl, Enabled, backB
GuiControl, Enabled, nextB
return

which1:
	{
	GuiControl, Enable, p2f
	GuiControl, Enable, p2g
	}
return

which2:
	{
	GuiControl, Disable, p2f
	GuiControl, Disable, p2g
	}
return

selzip:
Gui +OwnDialogs
FileSelectFile, zipPath, 3, .\, Select the Miranda IM zip, Miranda IM archives (*.zip)
	if zipPath =
	{
		MsgBox, 12336, Error, You haven't selected a zip archive.,
		return
	}
	else
;		MsgBox, You selected the file :`n%zipPath%
GuiControl,, p2f, %zipPath%
Gui, Submit, NoHide
return

selzip1:
Gui, Submit, NoHide
Loop %iszip%
	if zip%A_Index% =  %p2h%
		{
		zipPath := Pzip%A_Index%
		break
		}
GuiControl,, p2f, %zipPath%
return

selpath:
Gui +OwnDialogs
FileSelectFolder, instPath, , 3, Select the destination path
	if instPath =
	{
		MsgBox, 12336, Error, You haven't selected a path. Assuming the default.,
		return
	}
	else
instPath := instPath . "\Miranda"
;		MsgBox, You selected the path :`n%instPath%
GuiControl,, p3b, %instPath%
GuiControl,, p3d, %instPath%
Gui, Submit, NoHide
return

setdefpath:
instPath := defPath
GuiControl,, p3b, %instPath%
GuiControl,, p3d, %instPath%
Gui, Submit, NoHide
return

extractit:
; overw should be blank or -ao
; apparently it always overwrites
FileCreateDir, %instPath%
if ErrorLevel
	{
	MsgBox, 12336, Error, Couldn't create the Miranda folder.`nPlease check path, rights, folder permissions and attributes.
	return
	}
commline := "7z.exe x " . zipPath . " -o" . instPath . " * -r -y " . overw
;MsgBox commline = %commline%
RunWait, %commline%,, Hide UseErrorLevel
if ErrorLevel
	MsgBox, 12336, Error, There has been an error %ErrorLevel% extracting the files in the zip.,
return

ButtonBack:
if page > 1
	{
	page -= 1
		if page =1
			GuiControl, Disable, backB
	gosub page%page%
	}
return

ButtonNext:
	GuiControl, Enable, backB
page +=1
gosub page%page%
return

ButtonExit:
GuiClose:
ExitApp

; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CNeeMediaPlayerDlg
LastTemplate=CStatic
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "NeeMediaPlayer.h"

ClassCount=5
Class1=CNeeMediaPlayerApp
Class2=CNeeMediaPlayerDlg
Class3=CAboutDlg

ResourceCount=5
Resource1=IDD_NEEMEDIAPLAYER_DIALOG
Resource2=IDR_MAINFRAME
Resource3=IDD_ABOUTBOX
Class4=CPlayerList
Resource4=IDD_DIALOG1
Class5=CSeekPosCtrl
Resource5=IDR_MENU1

[CLS:CNeeMediaPlayerApp]
Type=0
HeaderFile=NeeMediaPlayer.h
ImplementationFile=NeeMediaPlayer.cpp
Filter=N
BaseClass=CWinApp
VirtualFilter=AC

[CLS:CNeeMediaPlayerDlg]
Type=0
HeaderFile=NeeMediaPlayerDlg.h
ImplementationFile=NeeMediaPlayerDlg.cpp
Filter=W
BaseClass=CDialog
VirtualFilter=dWC
LastObject=ID_GO_NEEMEDIA

[CLS:CAboutDlg]
Type=0
HeaderFile=NeeMediaPlayerDlg.h
ImplementationFile=NeeMediaPlayerDlg.cpp
Filter=D

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=5
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889
Control5=IDC_STATIC,static,1342308352

[DLG:IDD_NEEMEDIAPLAYER_DIALOG]
Type=1
Class=CNeeMediaPlayerDlg
ControlCount=4
Control1=IDC_OCX1,{6BF52A52-394A-11D3-B153-00C04F79FAA6},1342242816
Control2=IDCANCEL,button,1073807360
Control3=IDC_STATIC_SEEKBAR,static,1342308608
Control4=IDC_STATIC_SEEKBAR2,static,1342308608

[DLG:IDD_DIALOG1]
Type=1
Class=CPlayerList
ControlCount=3
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_LIST1,listbox,1352728835

[CLS:CPlayerList]
Type=0
HeaderFile=PlayerList.h
ImplementationFile=PlayerList.cpp
BaseClass=CDialog
Filter=D
VirtualFilter=dWC
LastObject=CPlayerList

[MNU:IDR_MENU1]
Type=1
Class=?
Command1=ID_COLOR_THEME
Command2=ID_RANDOMSTYLE
Command3=ID_GO_NEEMEDIA
CommandCount=3

[CLS:CSeekPosCtrl]
Type=0
HeaderFile=SeekPosCtrl.h
ImplementationFile=SeekPosCtrl.cpp
BaseClass=CStatic
Filter=W
VirtualFilter=WC


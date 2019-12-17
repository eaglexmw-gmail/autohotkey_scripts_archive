; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CMainFrame
LastTemplate=CToolBarCtrl
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "ToolBar.h"
LastPage=0

ClassCount=6
Class1=CToolBarApp
Class2=CToolBarDoc
Class3=CToolBarView
Class4=CMainFrame

ResourceCount=2
Resource1=IDR_MAINFRAME
Class5=CAboutDlg
Class6=CMyTool
Resource2=IDD_ABOUTBOX

[CLS:CToolBarApp]
Type=0
HeaderFile=ToolBar.h
ImplementationFile=ToolBar.cpp
Filter=N

[CLS:CToolBarDoc]
Type=0
HeaderFile=ToolBarDoc.h
ImplementationFile=ToolBarDoc.cpp
Filter=N

[CLS:CToolBarView]
Type=0
HeaderFile=ToolBarView.h
ImplementationFile=ToolBarView.cpp
Filter=C


[CLS:CMainFrame]
Type=0
HeaderFile=MainFrm.h
ImplementationFile=MainFrm.cpp
Filter=T
BaseClass=CFrameWnd
VirtualFilter=fWC
LastObject=ID_TOOL_ZOOM




[CLS:CAboutDlg]
Type=0
HeaderFile=ToolBar.cpp
ImplementationFile=ToolBar.cpp
Filter=D

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=4
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889

[MNU:IDR_MAINFRAME]
Type=1
Class=CMainFrame
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_FILE_SAVE_AS
Command5=ID_FILE_PRINT
Command6=ID_FILE_PRINT_PREVIEW
Command7=ID_FILE_PRINT_SETUP
Command8=ID_EDIT_UNDO
Command9=ID_EDIT_CUT
Command10=ID_EDIT_COPY
Command11=ID_EDIT_PASTE
Command12=ID_FILE_MRU_FILE1
Command13=ID_APP_EXIT
Command14=ID_EDIT_UNDO
Command15=ID_EDIT_CUT
Command16=ID_EDIT_COPY
Command17=ID_EDIT_PASTE
Command18=ID_VIEW_TOOLBAR
Command19=ID_VIEW_STATUS_BAR
Command20=ID_APP_ABOUT
CommandCount=20

[ACL:IDR_MAINFRAME]
Type=1
Class=CMainFrame
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_FILE_PRINT
Command5=ID_EDIT_UNDO
Command6=ID_EDIT_CUT
Command7=ID_EDIT_COPY
Command8=ID_EDIT_PASTE
Command9=ID_EDIT_UNDO
Command10=ID_EDIT_CUT
Command11=ID_EDIT_COPY
Command12=ID_EDIT_PASTE
Command13=ID_NEXT_PANE
Command14=ID_PREV_PANE
CommandCount=14

[TB:IDR_MAINFRAME]
Type=1
Class=CMainFrame
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_TOOL_ZOOM
Command5=ID_EDIT_CUT
Command6=ID_EDIT_COPY
Command7=ID_EDIT_PASTE
Command8=ID_FILE_PRINT
Command9=ID_APP_ABOUT
CommandCount=9

[CLS:CMyTool]
Type=0
HeaderFile=MyTool.h
ImplementationFile=MyTool.cpp
BaseClass=CToolBarCtrl
Filter=W


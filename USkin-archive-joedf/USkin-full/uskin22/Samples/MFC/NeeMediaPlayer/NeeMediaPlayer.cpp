// NeeMediaPlayer.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "NeeMediaPlayer.h"
#include "NeeMediaPlayerDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CNeeMediaPlayerApp

BEGIN_MESSAGE_MAP(CNeeMediaPlayerApp, CWinApp)
	//{{AFX_MSG_MAP(CNeeMediaPlayerApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CNeeMediaPlayerApp construction

CNeeMediaPlayerApp::CNeeMediaPlayerApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CNeeMediaPlayerApp object

CNeeMediaPlayerApp theApp;
CNeeMediaPlayerDlg * g_pMainPlayer;

/////////////////////////////////////////////////////////////////////////////
// CNeeMediaPlayerApp initialization

BOOL CNeeMediaPlayerApp::InitInstance()
{
	AfxEnableControlContainer();

	// Standard initialization
	// If you are not using these features and wish to reduce the size
	//  of your final executable, you should remove from the following
	//  the specific initialization routines you do not need.

#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif


	USkinInit(NULL,NULL,_T("winamp.u3"));
	
	m_pMainWnd = new CNeeMediaPlayerDlg;
	m_pMainWnd->ShowWindow(SW_SHOW);
	g_pMainPlayer=(CNeeMediaPlayerDlg*)m_pMainWnd;
	
	return TRUE;
}

int CNeeMediaPlayerApp::ExitInstance() 
{
	// TODO: Add your specialized code here and/or call the base class
	g_pMainPlayer->DestroyWindow();
	delete g_pMainPlayer;
	USkinExit();
	return CWinApp::ExitInstance();
}

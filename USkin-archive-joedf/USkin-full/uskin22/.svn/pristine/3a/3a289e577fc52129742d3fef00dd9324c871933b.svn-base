// NeeMediaPlayerDlg.cpp : implementation file
//

#include "stdafx.h"
#include "NeeMediaPlayer.h"
#include "NeeMediaPlayerDlg.h"

#include "wmpcontrols.h"
#include "WMPSettings.h"
#include "wmpmedia.h"
#include "wmpmediacollection.h"
#include "wmpplaylistcollection.h"
#include "wmpnetwork.h"
#include "wmpplaylist.h"
#include "wmpcdromcollection.h"
#include "wmpclosedcaption.h"
#include "WMPError.h"
#include "wmpdvd.h"
#include "WMPPlayerApplication.h"
#include "resource.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
		

	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CNeeMediaPlayerDlg dialog

CNeeMediaPlayerDlg::CNeeMediaPlayerDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CNeeMediaPlayerDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CNeeMediaPlayerDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	Create( CNeeMediaPlayerDlg::IDD, pParent );
	m_pPlayerList=NULL;
}

void CNeeMediaPlayerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CNeeMediaPlayerDlg)
	DDX_Control(pDX, IDC_STATIC_SEEKBAR2, m_Volume);
	DDX_Control(pDX, IDC_STATIC_SEEKBAR, m_SeekBar);
	DDX_Control(pDX, IDC_OCX1, m_PlayerCore);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CNeeMediaPlayerDlg, CDialog)
	//{{AFX_MSG_MAP(CNeeMediaPlayerDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_CLOSE()
	ON_COMMAND(	BTN_SOUND_MUTE_ON,OnSoundMuteOn)
		ON_COMMAND(BTN_SOUND_MUTE_OFF,OnSoundMuteOff)
		ON_COMMAND( BTN_WINAMP_FLAG,OnWinampFlag)
		ON_COMMAND( BTN_PREV,OnPrev)
		ON_COMMAND( BTN_PLAY,OnPlay)
		ON_COMMAND( BTN_PAUSE,OnPause)
		ON_COMMAND( BTN_STOP,OnStop)
		ON_COMMAND( BTN_NEXT,OnNext)
		ON_COMMAND( BTN_OPEN,OnOpen)
		ON_COMMAND( BTN_ML,OnML)
		ON_COMMAND( BTN_PL,OnPL)
		ON_COMMAND( BTN_REPEAT,OnRepeat)
		ON_COMMAND( BTN_SHUFF,OnShuff)
		ON_COMMAND( BTN_MENU,OnMenu)
		ON_COMMAND( BTN_EXPAND,OnExpand)
		ON_COMMAND( BTN_COL,OnCol)
	ON_WM_ERASEBKGND()
	ON_COMMAND(ID_RANDOMSTYLE, OnRandomstyle)
	ON_COMMAND(ID_COLOR_THEME, OnColorTheme)
	ON_WM_DESTROY()
		ON_COMMAND( IDC_STATIC_SEEKBAR,OnSeekBar)
		ON_COMMAND( IDC_STATIC_SEEKBAR2,OnVolume)
	ON_WM_TIMER()
	ON_BN_CLICKED(IDCANCEL, OnCancel)
	ON_COMMAND(ID_GO_NEEMEDIA, OnGoNeemedia)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CNeeMediaPlayerDlg message handlers

BOOL CNeeMediaPlayerDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	srand( (unsigned)time( NULL ) );

	// TODO: Add extra initialization here
	USkinSetWindowSkin(m_hWnd,_T("MainWnd"));
	RECT rc;
	USkinGetWindowSkinObjectRect(m_hWnd,_T("SeekBar"),&rc);
	m_SeekBar.MoveWindow(&rc);
	m_PlayerCore.ShowWindow(SW_HIDE);
	USkinGetWindowSkinObjectRect(m_hWnd,_T("Volume"),&rc);
	m_Volume.MoveWindow(&rc);
	m_Volume.m_nThumbWidth = 10;
	m_Volume.m_nValue =100;
	m_Volume.m_nCommandID=IDC_STATIC_SEEKBAR2;
	m_SeekBar.m_nCommandID=IDC_STATIC_SEEKBAR;
	SetWindowText("NEEMEDIA PLAYER");
	SetTimer(0x100,100,NULL);
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CNeeMediaPlayerDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CNeeMediaPlayerDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CNeeMediaPlayerDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CNeeMediaPlayerDlg::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	DestroyWindow();
	CDialog::OnClose();
}

void CNeeMediaPlayerDlg::OnCancel() 
{
	// TODO: Add your control notification handler code here
	CDialog::OnCancel();
	PostQuitMessage(1);
}

void CNeeMediaPlayerDlg::OnSeekBar()
{
	m_PlayerCore.GetControls().SetCurrentPosition((double)m_SeekBar.m_nValue);
}

void CNeeMediaPlayerDlg::OnVolume()
{
	m_PlayerCore.GetSettings().SetVolume(m_Volume.m_nValue);
}

void CNeeMediaPlayerDlg::OnSoundMuteOn()
{
	m_PlayerCore.GetSettings().SetVolume(0);
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnSoundMuteOff",TRUE);
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnSoundMuteOn",FALSE);
}
void CNeeMediaPlayerDlg::OnSoundMuteOff()
{
	m_PlayerCore.GetSettings().SetVolume(100);
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnSoundMuteOff",FALSE);
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnSoundMuteOn",TRUE);
}

void CNeeMediaPlayerDlg::OnWinampFlag()
{
	ShellExecute(m_hWnd,"open","http://www.winamp.com",NULL,NULL,SW_SHOW);
}

void CNeeMediaPlayerDlg::OnPrev()
{
}
void CNeeMediaPlayerDlg::OnPlay()
{
	
	m_PlayerCore.GetControls().play();
}
void CNeeMediaPlayerDlg::OnPause()
{
	m_PlayerCore.GetControls().pause();
}
void CNeeMediaPlayerDlg::OnStop()
{
	m_PlayerCore.GetControls().stop();
}
void CNeeMediaPlayerDlg::OnNext()
{
}
void CNeeMediaPlayerDlg::OnOpen()
{
	CString str=" mp3 file(*.mp3)|*.mp3||";
	CFileDialog dlg(TRUE,0,0,0,str,this);
	if(dlg.DoModal()==TRUE)
	{
		m_strFileName=dlg.GetFileTitle();
		CString str=_T("Starting Play ");
		str+=m_strFileName;
		USkinSetWindowSkinObjectText(m_hWnd,_T("Infomation"),str);
		m_strFileName=dlg.GetPathName();
		m_PlayerCore.SetUrl(m_strFileName);
	}
}
void CNeeMediaPlayerDlg::OnML()
{
}
void CNeeMediaPlayerDlg::OnPL()
{
	if(m_pPlayerList==NULL)
		m_pPlayerList=new CPlayerList;
	m_pPlayerList->ShowWindow(SW_SHOW);
}
void CNeeMediaPlayerDlg::OnRepeat()
{
}
void CNeeMediaPlayerDlg::OnShuff()
{
}
void CNeeMediaPlayerDlg::OnMenu()
{
	CMenu menu;
	menu.LoadMenu(IDR_MENU1);
	CPoint pt;
	GetCursorPos(&pt);
	menu.GetSubMenu(0)->TrackPopupMenu(0,pt.x,pt.y,this);
}
void CNeeMediaPlayerDlg::OnExpand()
{
	CRect rc;
	GetWindowRect(&rc);
	rc.bottom = rc.top+255;
	
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnExpand",FALSE);

	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnColBg",TRUE);
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnCol",TRUE);
	MoveWindow(&rc,TRUE);

}
void CNeeMediaPlayerDlg::OnCol()
{
	CRect rc;
	GetWindowRect(&rc);
	rc.bottom = rc.top+147;
	
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnExpand",TRUE);

	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnColBg",FALSE);
	USkinSetWindowSkinObjectVisible(m_hWnd,"BtnCol",FALSE);
	MoveWindow(&rc,TRUE);
}

BOOL CNeeMediaPlayerDlg::OnEraseBkgnd(CDC* pDC) 
{
	// TODO: Add your message handler code here and/or call default
	
	return FALSE;//CDialog::OnEraseBkgnd(pDC);
}

void CNeeMediaPlayerDlg::OnRandomstyle() 
{
	// TODO: Add your command handler code here
	int n=rand();
	float h=n%360;
	USkinApplyColorTheme(h,1.0);//(rand()%255)/255);
}

void CNeeMediaPlayerDlg::OnColorTheme() 
{
	// TODO: Add your command handler code here
	USkinApplyColorThemeByRGB(RGB(0,0,255));
}

void CNeeMediaPlayerDlg::OnDestroy() 
{
	CDialog::OnDestroy();
	
	// TODO: Add your message handler code here
	if(m_pPlayerList)
	{
		m_pPlayerList->DestroyWindow();
		delete m_pPlayerList;
		m_pPlayerList=NULL;
	}
}

BEGIN_EVENTSINK_MAP(CNeeMediaPlayerDlg, CDialog)
    //{{AFX_EVENTSINK_MAP(CNeeMediaPlayerDlg)
	ON_EVENT(CNeeMediaPlayerDlg, IDC_OCX1, 5202 /* PositionChange */, OnPositionChangeOcx1, VTS_R8 VTS_R8)
	//}}AFX_EVENTSINK_MAP
END_EVENTSINK_MAP()

void CNeeMediaPlayerDlg::OnPositionChangeOcx1(double oldPosition, double newPosition) 
{
	// TODO: Add your control notification handler code here
	m_SeekBar.m_nValue = (int)(newPosition*100);
	m_SeekBar.Invalidate();
}

void CNeeMediaPlayerDlg::OnTimer(UINT nIDEvent) 
{
	// TODO: Add your message handler code here and/or call default
	
	m_SeekBar.m_nValue = (int)(m_PlayerCore.GetControls().GetCurrentPosition());
	m_SeekBar.Invalidate();
	CString strText;
	
	strText=m_PlayerCore.GetCurrentMedia().GetDurationString();
	
	USkinSetWindowSkinObjectText(m_hWnd,_T("Led"),strText);
	CDialog::OnTimer(nIDEvent);
}

void CNeeMediaPlayerDlg::OnGoNeemedia() 
{
	// TODO: Add your command handler code here
	ShellExecute(NULL,"open","http://www.neemedia.com",NULL,NULL,SW_SHOW);
}

// PlayerList.cpp : implementation file
//

#include "stdafx.h"
#include "NeeMediaPlayer.h"
#include "PlayerList.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPlayerList dialog


CPlayerList::CPlayerList(CWnd* pParent /*=NULL*/)
	: CDialog(CPlayerList::IDD, pParent)
{
	//{{AFX_DATA_INIT(CPlayerList)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	Create( CPlayerList::IDD , pParent );
}


void CPlayerList::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPlayerList)
	DDX_Control(pDX, IDC_LIST1, m_FileList);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CPlayerList, CDialog)
	//{{AFX_MSG_MAP(CPlayerList)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPlayerList message handlers

BOOL CPlayerList::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	// TODO: Add extra initialization here
	USkinSetWindowSkin(m_hWnd ,_T("PlayerList") );
	SetWindowText("PLAYERLIST EDITOR");
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CPlayerList::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	ShowWindow( SW_HIDE );
}
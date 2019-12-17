// NeeMediaPlayerDlg.h : header file
//
//{{AFX_INCLUDES()
#include "wmpplayer4.h"
//}}AFX_INCLUDES

#if !defined(AFX_NEEMEDIAPLAYERDLG_H__E2E1B592_351F_4D3E_827B_7F346EA18D1C__INCLUDED_)
#define AFX_NEEMEDIAPLAYERDLG_H__E2E1B592_351F_4D3E_827B_7F346EA18D1C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CNeeMediaPlayerDlg dialog
#define BTN_SOUND_MUTE_ON 5001
#define BTN_SOUND_MUTE_OFF 5002
#define BTN_WINAMP_FLAG	5003

#define BTN_PREV	5005
#define BTN_PLAY	5006
#define BTN_PAUSE	5007
#define BTN_STOP	5008
#define BTN_NEXT	5009
#define BTN_OPEN	5010	
#define BTN_PL		5011
#define BTN_ML		5012
#define BTN_REPEAT	5013
#define BTN_SHUFF	5014
#define BTN_MENU	5015
#define BTN_EXPAND	5016
#define BTN_COL		5017

#include "PlayerList.h"
#include "SeekPosCtrl.h"
class CNeeMediaPlayerDlg : public CDialog
{
// Construction
public:
	CString m_strFileName;
	CNeeMediaPlayerDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CNeeMediaPlayerDlg)
	enum { IDD = IDD_NEEMEDIAPLAYER_DIALOG };
	CSeekPosCtrl	m_Volume;
	CSeekPosCtrl	m_SeekBar;
	CWMPPlayer4	m_PlayerCore;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CNeeMediaPlayerDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CNeeMediaPlayerDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnClose();
	afx_msg void OnCancel();
	afx_msg void OnSoundMuteOn();
	afx_msg void OnSoundMuteOff();
	afx_msg void OnWinampFlag();
	afx_msg void OnPrev();
	afx_msg void OnPlay();
	afx_msg void OnPause();
	afx_msg void OnStop();
	afx_msg void OnNext();
	afx_msg void OnOpen();
	afx_msg void OnML();
	afx_msg void OnPL();
	afx_msg void OnRepeat();
	afx_msg void OnShuff();
	afx_msg void OnMenu();
	afx_msg void OnExpand();
	afx_msg void OnCol();
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnRandomstyle();
	afx_msg void OnColorTheme();
	afx_msg void OnDestroy();
	afx_msg void OnSeekBar();
	afx_msg void OnVolume();
	afx_msg void OnPositionChangeOcx1(double oldPosition, double newPosition);
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnGoNeemedia();
	DECLARE_EVENTSINK_MAP()
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
protected:
	CPlayerList * m_pPlayerList;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_NEEMEDIAPLAYERDLG_H__E2E1B592_351F_4D3E_827B_7F346EA18D1C__INCLUDED_)

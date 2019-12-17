#if !defined(AFX_SEEKPOSCTRL_H__5CDF8341_9900_4541_B996_2836D576352E__INCLUDED_)
#define AFX_SEEKPOSCTRL_H__5CDF8341_9900_4541_B996_2836D576352E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// SeekPosCtrl.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CSeekPosCtrl window

class CSeekPosCtrl : public CStatic
{
// Construction
public:
	CSeekPosCtrl();

// Attributes
public:
	int m_nMin;
	int m_nMax;
	int m_nValue;
	int m_nDragValue;
	CRect m_rcValue;
	CRect m_rcDragValue;
	BOOL m_bMouseDown;
	BOOL m_bInThumb;
	BOOL m_bDrag;
	BOOL m_bHilightedThumb;
	int  m_nThumbWidth;
	UINT m_nCommandID;
// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CSeekPosCtrl)
	//}}AFX_VIRTUAL

// Implementation
public:
	void SetValue(int nValue);
	virtual ~CSeekPosCtrl();

	// Generated message map functions
protected:
	//{{AFX_MSG(CSeekPosCtrl)
	afx_msg void OnPaint();
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnClicked();
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SEEKPOSCTRL_H__5CDF8341_9900_4541_B996_2836D576352E__INCLUDED_)

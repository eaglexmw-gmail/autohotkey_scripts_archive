// SeekPosCtrl.cpp : implementation file
//

#include "stdafx.h"
#include "NeeMediaPlayer.h"
#include "SeekPosCtrl.h"
#include "MemoryDC.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CSeekPosCtrl

CSeekPosCtrl::CSeekPosCtrl()
{
	m_nMin=0;
	m_nMax=100;
	m_nDragValue=0;
	m_nValue=0;
	m_nThumbWidth=30;
	m_bMouseDown=FALSE;
	m_bInThumb=FALSE;
	m_bDrag=FALSE;
	m_bHilightedThumb=FALSE;
	m_nCommandID=0;
}

CSeekPosCtrl::~CSeekPosCtrl()
{
}


BEGIN_MESSAGE_MAP(CSeekPosCtrl, CStatic)
	//{{AFX_MSG_MAP(CSeekPosCtrl)
	ON_WM_PAINT()
	ON_WM_ERASEBKGND()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_CONTROL_REFLECT(BN_CLICKED, OnClicked)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CSeekPosCtrl message handlers

void CSeekPosCtrl::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
	CRect rc;
	GetClientRect( rc );

	CMemDC mdc( &dc , rc );
	
	// TODO: Add your message handler code here
	HUSKIN hSkin = USkinOpenSkinData( _T("WmpSeekBar") );
	//Render Background First
	USkinDrawSkinImageSection( hSkin ,NULL, _T("Background") , mdc.GetSafeHdc() , rc );
	if( hSkin )
	{
		int nPos=((rc.right-rc.left-m_nThumbWidth)*m_nValue/(m_nMax-m_nMin));
		CRect rcDraw;
		rcDraw.left = nPos;
		rcDraw.right = nPos+m_nThumbWidth;
		rcDraw.bottom = rc.bottom;
		rcDraw.top = rc.top;
		if(m_bMouseDown && m_bInThumb)
			USkinDrawSkinImageSection( hSkin ,_T("ThumbPaintOption"), _T("DragThumb") , mdc.GetSafeHdc() , rcDraw );
		else if(m_bDrag==TRUE)
		{
			//Draw Current 
			USkinDrawSkinImageSection( hSkin ,_T("ThumbPaintOption"), _T("NormalThumb") , mdc.GetSafeHdc() , rcDraw );
			int nPos=((rc.right-rc.left-m_nThumbWidth)*m_nDragValue/(m_nMax-m_nMin));
			CRect rcDraw;
			rcDraw.left = nPos;
			rcDraw.right = nPos+m_nThumbWidth;
			rcDraw.bottom = rc.bottom;
			rcDraw.top = rc.top;
			//Draw Drag
			USkinDrawSkinImageSection( hSkin ,_T("DragThumbPaintOption"), _T("NormalThumb") , mdc.GetSafeHdc() , rcDraw );
		}
		else if(m_bHilightedThumb==TRUE)
			USkinDrawSkinImageSection( hSkin ,_T("ThumbPaintOption"), _T("HilightThumb") , mdc.GetSafeHdc() , rcDraw );
		else
			USkinDrawSkinImageSection( hSkin ,_T("ThumbPaintOption"), _T("NormalThumb") , mdc.GetSafeHdc() , rcDraw );
		
		/////////////////////////////
		dc.BitBlt( rc.left , rc.top , rc.right-rc.left , rc.bottom-rc.top , &mdc , rc.left , rc.top , SRCCOPY );
		USkinCloseSkinData( hSkin );
	}	
}

BOOL CSeekPosCtrl::OnEraseBkgnd(CDC* pDC) 
{
	// TODO: Add your message handler code here and/or call default
	return TRUE;//CStatic::OnEraseBkgnd(pDC);
}

void CSeekPosCtrl::OnLButtonDown(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default
	m_bMouseDown=TRUE;
	CRect rc;
	GetClientRect(&rc);
	int nPos=((rc.right-rc.left-m_nThumbWidth)*m_nValue/(m_nMax-m_nMin));
	CRect rcDraw;
	
	rcDraw.left = nPos;
	rcDraw.right = nPos+m_nThumbWidth;
	rcDraw.bottom = rc.bottom;
	rcDraw.top = rc.top;
	m_bInThumb=FALSE;
	m_bDrag=FALSE;
	if(rcDraw.PtInRect(point)==TRUE)
	{
		m_bInThumb=TRUE;
		m_bDrag=TRUE;
		m_nDragValue=m_nValue;
	}else
	{
		//Not in Thumb,in chanel
		m_bDrag=TRUE;
		if(point.x>rc.right) point.x=rc.right;
		if(point.x<rc.left) point.x = rc.left;
		float fClickPos=(float)((float)(rc.right-rc.left-m_nThumbWidth)/(float)(m_nMax-m_nMin));
		int nValue=0;
		if(fClickPos!=0.0f){
			nValue=(point.x-rc.left-m_nThumbWidth)/fClickPos;
		}
		m_nDragValue=nValue;
	}
	Invalidate();
	CStatic::OnLButtonDown(nFlags, point);
}

void CSeekPosCtrl::OnLButtonUp(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default
	m_bMouseDown=FALSE;
	m_bInThumb=FALSE;
	m_bDrag=FALSE;
	CRect rc;
	GetClientRect(&rc);
	if(point.x>rc.right) point.x=rc.right;
	if(point.x<rc.left) point.x = rc.left;
	float fClickPos=(float)((float)(rc.right-rc.left-m_nThumbWidth)/(float)(m_nMax-m_nMin));
	m_nValue=0;
	if(fClickPos!=0.0f){
		m_nValue=(point.x-rc.left-m_nThumbWidth)/fClickPos;
	}
	
	GetParent()->SendMessage(WM_COMMAND,m_nCommandID);
	Invalidate();
	CStatic::OnLButtonUp(nFlags, point);
}

void CSeekPosCtrl::OnMouseMove(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default
	CRect rc;
	GetClientRect(&rc);
	if(point.x>rc.right) point.x=rc.right;
	if(point.x<rc.left) point.x = rc.left;
	float fClickPos=(float)((float)(rc.right-rc.left-m_nThumbWidth)/(float)(m_nMax-m_nMin));
	int nValue=0;
	if(fClickPos!=0.0f){
		nValue=(point.x-rc.left-m_nThumbWidth)/fClickPos;
	}
	if(m_bDrag==TRUE){
		m_nDragValue=nValue;
	}
	if(m_bInThumb==TRUE)
	{
		m_nValue=nValue;
	}
	m_bHilightedThumb=FALSE;
	
	int nPos=((rc.right-rc.left-m_nThumbWidth)*m_nValue/(m_nMax-m_nMin));
	CRect rcDraw;
	rcDraw.left = nPos;
	rcDraw.right = nPos+m_nThumbWidth;
	rcDraw.bottom = rc.bottom;
	rcDraw.top = rc.top;
	if(rcDraw.PtInRect(point)==TRUE)
		m_bHilightedThumb=TRUE;
	Invalidate();
	CStatic::OnMouseMove(nFlags, point);
}

void CSeekPosCtrl::OnClicked() 
{
	// TODO: Add your control notification handler code here
	
}

void CSeekPosCtrl::SetValue(int nValue)
{
	if( nValue >= m_nMax ) nValue = m_nMax;
	if( nValue <= m_nMin ) nValue = m_nMin;
	m_nValue = nValue;
	Invalidate();
}

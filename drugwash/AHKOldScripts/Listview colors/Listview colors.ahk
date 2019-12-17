; http://www.autohotkey.com/forum/viewtopic.php?t=9266

/* struct NMHDR {
    HWND            hwndFrom;       uint4       0
    UINT            idFrom;         uint4       4
    UINT            code;           uint4       8
}                                               12
*/

/* struct NMCUSTOMDRAW {
    NMHDR           hdr;            12          0
    DWORD           dwDrawStage;    uint4       12
    HDC             hdc;            uint4       16
    RECT            rc;             16          20
    DWORD_PTR       dwItemSpec;     uint4       36
    UINT            uItemState;     uint4       40
    LPARAM          lItemlParam;    int4        44
}                                               48
*/

/* struct NMLVCUSTOMDRAW {
    NMCUSTOMDRAW    nmcd;           48          0
    COLORREF        clrText;        uint4       48
    COLORREF        clrTextBk;      uint4       52

    #if (_WIN32_IE >= 0x0400)
        int         iSubItem;       int4        56
    #endif

    #if (_WIN32_IE >= 0x560)
        DWORD       dwItemType;     uint4       60
        COLORREF    clrFace;        uint4       64
        int         iIconEffect;    int4        68
        int         iIconPhase;     int4        72
        int         iPartId;        int4        76
        int         iStateId:       int4        80
        RECT        rcText;         16          84
        UINT        uAlign;         uint4       100
    #endif
}                                               104
*/

Gui, +LastFound
Gui, Add, ListView, x5 y5 w200 h200 vLV_Sample, index|day 
LV_Add( "", 1, "Monday" )
LV_Add( "", 2, "Tuesday" )
LV_Add( "", 3, "Wednesday" )
LV_Add( "", 4, "Thursday" )
LV_Add( "", 5, "Friday" )
LV_Add( "", 6, "Saturday" )
LV_Add( "", 7, "Sunday" )
LV_ModifyCol( 1, "AutoHdr" )
LV_ModifyCol( 2, "AutoHdr" )
Gui, Show, x50 y50 w210 h210
;nothing special up to this point


LV_ColorInitiate() ; (Gui_Number, Control) - defaults to: (1, SysListView321)


Msgbox, Example 1: Highlighting alternating lines in the listview.
Loop, % LV_GetCount()
  {
  If ( Mod( A_Index, 2 ) )
    LV_ColorChange(A_Index, "0xFFFFFF", "0xFF0000")
  }


Msgbox, Example 2: Highlighting specific lines in the listview.
LV_ColorChange() ; clear all highlighting
LV_ColorChange(6, "0xFFFFFF", "0xFF0000")
LV_ColorChange(7, "0xFFFFFF", "0xFF0000")


Msgbox, Example 3: Flashing specific lines in the listview.
LV_ColorChange() ; clear all highlighting
Loop, 3 {
    LV_ColorChange(6) ; default color (highlight off)
    LV_ColorChange(7)
    Sleep, 500
    LV_ColorChange(6, "0xFFFFFF", "0xFF0000")
    LV_ColorChange(7, "0xFFFFFF", "0xFF0000")
    Sleep, 500
  }
Return

GuiClose:
GuiEscape:
  Exitapp



LV_ColorInitiate(Gui_Number=1, Control="") ; initiate listview color change procedure
{
  global hw_LV_ColorChange
  If Control =
    Control =SysListView321
  Gui, %Gui_Number%:+Lastfound
  Gui_ID := WinExist()
  ControlGet, hw_LV_ColorChange, HWND,, %Control%, ahk_id %Gui_ID%
  OnMessage( 0x4E, "WM_NOTIFY" )
}

LV_ColorChange(Index="", TextColor="", BackColor="") ; change specific line's color or reset all lines
{
  global
  If Index =
    Loop, % LV_GetCount()
      LV_ColorChange(A_Index)
  Else
    {
    Line_Color_%Index%_Text := TextColor
    Line_Color_%Index%_Back := BackColor
    WinSet, Redraw,, ahk_id %hw_LV_ColorChange%
    }
}



WM_NOTIFY( p_w, p_l, p_m )
{
  local  draw_stage, Current_Line, Index
  if ( DecodeInteger( "uint4", p_l, 0 ) = hw_LV_ColorChange ) {
      if ( DecodeInteger( "int4", p_l, 8 ) = -12 ) {                            ; NM_CUSTOMDRAW
          draw_stage := DecodeInteger( "uint4", p_l, 12 )
          if ( draw_stage = 1 )                                                 ; CDDS_PREPAINT
              return, 0x20                                                      ; CDRF_NOTIFYITEMDRAW
          else if ( draw_stage = 0x10000|1 ){                                   ; CDDS_ITEM
              Current_Line := DecodeInteger( "uint4", p_l, 36 )+1
              LV_GetText(Index, Current_Line)
              If (Line_Color_%Index%_Text != ""){
                  EncodeInteger( Line_Color_%Index%_Text, 4, p_l, 48 )   ; foreground
                  EncodeInteger( Line_Color_%Index%_Back, 4, p_l, 52 )   ; background
                }
            }
        }
    }
}

DecodeInteger( p_type, p_address, p_offset, p_hex=true )
{
  old_FormatInteger := A_FormatInteger
  ifEqual, p_hex, 1, SetFormat, Integer, hex
  else, SetFormat, Integer, dec
  StringRight, size, p_type, 1
  loop, %size%
      value += *( ( p_address+p_offset )+( A_Index-1 ) ) << ( 8*( A_Index-1 ) )
  if ( size <= 4 and InStr( p_type, "u" ) != 1 and *( p_address+p_offset+( size-1 ) ) & 0x80 )
      value := -( ( ~value+1 ) & ( ( 2**( 8*size ) )-1 ) )
  SetFormat, Integer, %old_FormatInteger%
  return, value
}

EncodeInteger( p_value, p_size, p_address, p_offset )
{
  loop, %p_size%
    DllCall( "RtlFillMemory", "uint", p_address+p_offset+A_Index-1, "uint", 1, "uchar", p_value >> ( 8*( A_Index-1 ) ) )
}

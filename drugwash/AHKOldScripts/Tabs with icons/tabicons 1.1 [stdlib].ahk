/**
 * @synopsis    The stdLib compliant function list of tabfunctions allows easily to modify tabs
 *              and add or change icons in a given tabControl
 *              Originally this functions based upon posts from chris, lexikos and serenity and
 *              may be found here: http://www.autohotkey.com/forum/viewtopic.php?t=6060
 *
 * @name        tab.ahk
 * @version     1.0
 *
 * @author      derRaphael - based on the works of serenity, chris, Lexikos and Drugwash
 *
 * @licence     released under the EUPL 1.1 or later
 *              see http://ec.europa.eu/idabc/en/document/7774 for a translated version in your
 *              language
 *
 * @see         http://www.autohotkey.com/forum/viewtopic.php?p=323173#323173
 */

/**
 * Attaches a previously defined imagelist to a tabcontrol
 *
 * @author derRaphael
 * @version 1.0
 *
 * @param ImageListId
 *            The ID of the previously created imagelist
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the sendMessage call
*/
Tab_AttachImageList( ImageListId, TabControl = "SysTabControl321" )
{
   Return % Tab_Send( Msg := 0x1303, wParam := 0, lParam := ImageListId, TabControl ) ; TCM_SETIMAGELIST
}

/**
 * Attaches a tab with a custom icon to a tabcontrol
 *
 * @author derRaphael
 * @version 1.0
 *
 * @param TabText
 *            The text to display at the tab
 * @param IconNumber
 *            The ID of a chosen icon - usually the index 'd start
 *            with zero but ahk usually uses a "1" based index
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the sendMessage call
 */
Tab_AppendWithIcon( TabText, IconNumber, TabControl = "SysTabControl321" )
{ ; TCM_INSERTITEM
   VarSetCapacity(TCITEM, 28, 0)
   NumPut(3, TCITEM, 0, "UInt")
   NumPut(&TabText, TCITEM, 12, "UInt")
   NumPut(IconNumber - 1, TCITEM, 20, "UInt")
   Return % Tab_Send( Msg := 0x1307, wParam := 999, lParam := &TCITEM, TabControl )
}

/**
 * returns the index of the current selected tab
 *
 * @author chris, Drugwash, derRaphael
 * @version 1.0
 *
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_GetActiveIdx( TabControl = "SysTabControl321" )
{
   ControlGet, ActiveTab, Tab,,, % "ahk_id " Tab_GetHwnd( TabControl )
   Return, % ActiveTab
}

/**
 * Modifies the icon and the name of the givenb TabIndex in the selected TabControl
 *
 * @author chris, Drugwash, derRaphael
 * @version 1.0
 *
 * @param TabName
 *            The text to display at the tab
 * @param IconIdx
 *            The ID of a chosen icon - usually the index 'd start
 *            with zero but ahk usually uses a "1" based index
 * @param TabIdx
 *            The index of the chosen tab
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_Modify( TabName, IconIdx, TabIdx, TabControl = "SysTabControl321" )
{ ; TCM_SETITEM
   VarSetCapacity(TCITEM, 28, 0)
   NumPut(3, TCITEM, 0, "UInt")
   NumPut(&TabName, TCITEM, 12, "UInt")
   NumPut(IconIdx - 1, TCITEM, 20, "UInt")
   return % Tab_Send( Msg := 0x1306, wParam := TabIdx, lParam := &TCITEM, TabControl )
}

/**
 * Removes a tab by a given index
 *
 * @author chris, Drugwash, derRaphael
 * @version 1.0
 *
 * @param TabIdx
 *            The index of the chosen tab
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_Delete( TabIdx = 0, TabControl = "SysTabControl321")
{ ; TCM_DELETEITEM
   return % Tab_Send( Msg := 0x1308, wParam := TabIdx, lParam := 0, TabControl )
}

/**
 * Counts the total of all tabs in the given control
 *
 * @author chris, Drugwash, derRaphael
 * @version 1.0
 *
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_Count( TabControl = "SysTabControl321" )
{ ; TCM_GETITEMCOUNT
   return % Tab_Send( Msg := 0x1304, wParam := 0, lParam := 0, TabControl )
}

/**
 * Returns the index of the currently focused tab
 *
 * @author chris, Drugwash, derRaphael
 * @version 1.0
 *
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_GetFocus( TabControl = "SysTabControl321" )
{ ; TCM_GETCURFOCUS
   return % Tab_Send( Msg := 0x132f, wParam := 0, lParam := 0, TabControl ) + 1
}

/**
 * Returns the text of the given tabIndex
 *
 * @author chris, Drugwash, derRaphael
 * @version 1.0
 *
 * @param TabIdx
 *            The index of the chosen tab
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_GetName( TabIdx, TabControl = "SysTabControl321")                     
{ ; TCM_GETITEM
   szBuf=254
   VarSetCapacity(TCITEM, 28, 0)
   VarSetCapacity(Buffer, szBuf, 0)
   NumPut(1, TCITEM, 0, "UInt")
   NumPut(&Buffer, TCITEM, 12, "UInt")
   NumPut(szBuf, TCITEM, 16, "Int")
   Tab_Send( Msg := 0x1305, wParam := TabIdx, lParam := &TCITEM, TabControl )
   Loop, %szBuf%
   {
      getchr := NumGet(Buffer, A_Index - 1, "UChar")
      if !getchr
         break
      newbuf := newbuf . Chr(getchr)
   }
   return newbuf
}

/**
 * An alias for SendMessage to the tabControl
 *
 * @author derRaphael
 * @version 1.0
 *
 * @param msg
 *           The message for the call
 * @param wParam
 *           The wParam
 * @param lParam
 *           The lParam
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return ErrorLevel of the SendMessage call
 */
Tab_Send( ByRef msg, ByRef wParam, ByRef lParam, TabControl = "SysTabControl321" )
{
   SendMessage, %msg%, %wParam%, %lParam%,, % "ahk_id " Tab_GetHwnd( TabControl )
   Return ErrorLevel
}

/**
 * returns the windows handle (hWnd) of the given tabControl
 *
 * @author derRaphael
 * @version 1.1
 *
 * @param TabControl
 *            Either the associated variablename, its classname with the index or
 *            the TabControl's windowHandle
 *            May be blank - in this case the 1st found control will be used as default
 * @return the handle to the given control
 */
Tab_GetHwnd( TabControl = "SysTabControl321" )
{
   If ( TabControl != "" )
   {
      WinGetClass, TestClass, ahk_id %TabControl%
      If ( RegExMatch( TestClass, "^SysTabControl32" ) )
      {
         return % TabControl
      }
   }
   if ( TabControl = "" )
   {
      TabControl := "SysTabControl321"
   }
   GuiControlGet, TabHwnd, Hwnd, %TabControl%
   Return % TabHwnd
}

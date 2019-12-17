using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;

namespace WindowsApplication1
{
	/// <summary>
	/// FrmDocument 的摘要说明。
	/// </summary>
	public class FrmDocument : System.Windows.Forms.Form
	{
		private System.Windows.Forms.TextBox textBox1;
		/// <summary>
		/// 必需的设计器变量。
		/// </summary>
		private System.ComponentModel.Container components = null;

		public FrmDocument()
		{
			//
			// Windows 窗体设计器支持所必需的
			//
			InitializeComponent();

			//
			// TODO: 在 InitializeComponent 调用后添加任何构造函数代码
			//
		}

		/// <summary>
		/// 清理所有正在使用的资源。
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if(components != null)
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows 窗体设计器生成的代码
		/// <summary>
		/// 设计器支持所需的方法 - 不要使用代码编辑器修改
		/// 此方法的内容。
		/// </summary>
		private void InitializeComponent()
		{
			this.textBox1 = new System.Windows.Forms.TextBox();
			this.SuspendLayout();
			// 
			// textBox1
			// 
			this.textBox1.Location = new System.Drawing.Point(16, 16);
			this.textBox1.Multiline = true;
			this.textBox1.Name = "textBox1";
			this.textBox1.ScrollBars = System.Windows.Forms.ScrollBars.Both;
			this.textBox1.Size = new System.Drawing.Size(248, 224);
			this.textBox1.TabIndex = 0;
			this.textBox1.Text = "hWnd \r\nHandle to the window. \r\nhWndInsertAfter \r\nHandle to the window to precede " +
				"the positioned window in the z-order. This parameter must be a window handle or " +
				"one of the following values: Value Description \r\nHWND_BOTTOM Places the window a" +
				"t the bottom of the z-order. If the hWnd parameter identifies a topmost window, " +
				"the window loses its topmost status and is placed at the bottom of all other win" +
				"dows. \r\nHWND_NOTOPMOST Places the window above all non-topmost windows (that is," +
				" behind all topmost windows). This flag has no effect if the window is already a" +
				" non-topmost window. This value is not supported in Windows CE versions 1.0 and " +
				"1.01.  \r\nHWND_TOP Places the window at the top of the z-order. \r\nHWND_TOPMOST Pl" +
				"aces the window above all non-topmost windows. The window maintains its topmost " +
				"position even when it is deactivated. This value is not supported in Windows CE " +
				"versions 1.0 and 1.01. \r\n\r\nFor more information about how this parameter is used" +
				", see the following Remarks section. \r\n\r\nX \r\nSpecifies the new position of the l" +
				"eft side of the window, in client coordinates. \r\nY \r\nSpecifies the new position " +
				"of the top of the window, in client coordinates. \r\ncx \r\nSpecifies the new width " +
				"of the window, in pixels. \r\ncy \r\nSpecifies the new height of the window, in pixe" +
				"ls. \r\nuFlags \r\nSpecifies the window sizing and positioning flags. This parameter" +
				" can be a combination of the following values: Value Description \r\nSWP_DRAWFRAME" +
				" Draws a frame (defined in the window’s class description) around the window. Th" +
				"is value is not supported in Windows CE versions 1.0 and 1.01. \r\nSWP_FRAMECHANGE" +
				"D Sends a WM_NCCALCSIZE message to the window, even if the window’s size is not " +
				"being changed. If this flag is not specified, WM_NCCALCSIZE is sent only when th" +
				"e window’s size is being changed. \r\nSWP_HIDEWINDOW Hides the window. \r\nSWP_NOACT" +
				"IVATE Does not activate the window. If this flag is not set, the window is activ" +
				"ated and moved to the top of either the topmost or non-topmost group (depending " +
				"on the setting of the hWndInsertAfter parameter). \r\nSWP_NOCOPYBITS Discards the " +
				"entire contents of the client area. If this flag is not specified, the valid con" +
				"tents of the client area are saved and copied back into the client area after th" +
				"e window is sized or repositioned. This value is not supported in Windows CE ver" +
				"sions 2.10 and later. \r\nSWP_NOMOVE Retains the current position (ignores the X a" +
				"nd Y parameters). \r\nSWP_NOOWNERZORDER Does not change the owner window’s positio" +
				"n in the z-order. \r\nSWP_NOREPOSITION Same as the SWP_NOOWNERZORDER flag. \r\nSWP_N" +
				"OSIZE Retains the current size (ignores the cx and cy parameters). \r\nSWP_NOZORDE" +
				"R Retains the current z-order (ignores the hWndInsertAfter parameter). \r\nSWP_SHO" +
				"WWINDOW Displays the window. \r\n\r\nReturn Values\r\n\r\nNonzero indicates success. Zer" +
				"o indicates failure. To get extended error information, call GetLastError.\r\n\r\nRe" +
				"marks\r\n\r\nIf the specified window is a visible top-level window and the SWP_NOACT" +
				"IVATE flag is not specified, this function activates the window. If the window i" +
				"s the currently active and the SWP_HIDEWINDOW flag is specified, the activation " +
				"is passed on to another visible top-level window.\r\n\r\nA window can be made a topm" +
				"ost window either by setting the hWndInsertAfter parameter to HWND_TOPMOST and e" +
				"nsuring that the SWP_NOZORDER flag is not set, or by setting a window’s position" +
				" in the z-order so that it is above any existing topmost windows. When a non-top" +
				"most window is made topmost, its owned windows are also made topmost. Its owners" +
				", however, are not changed. \r\n\r\nIf neither the SWP_NOACTIVATE nor SWP_NOZORDER f" +
				"lag is specified (that is, when the application requests that a window be simult" +
				"aneously activated and its position in the z-order changed), the value specified" +
				" in hWndInsertAfter is used only in the following circumstances: \r\n";
			// 
			// FrmDocument
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(6, 14);
			this.ClientSize = new System.Drawing.Size(292, 266);
			this.Controls.Add(this.textBox1);
			this.Name = "FrmDocument";
			this.Text = "FrmDocument";
			this.ResumeLayout(false);

		}
		#endregion
	}
}

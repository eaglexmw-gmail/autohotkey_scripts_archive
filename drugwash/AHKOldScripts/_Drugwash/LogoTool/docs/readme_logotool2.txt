LogoTool2
-----------
created by Drugwash March 9-22, 2008

ABOUT:
---------
This is a simple application created in AutoHotkey 1.0.47.05, that will patch a 640x480 px 256color bitmap intended for use with PassingBy's WBL.COM (based on Tihiy's WLL.COM), adding in the animation coordinates necessary for this version to function properly.
The AutoHotkey script is provided together with the compiled version. The icon has been created from scratch by Drugwash and is also provided within the package. All files can be used and distributed freely, according to the AutoHotkey license.

USAGE:
---------
The usage is extremely simple and there are also tooltips for all relevant controls (for edit boxes please point to the spinners).
The logo creator has to input the values corresponding to the progressbar and animation shaft and then press 'Patch' - the program will ask for the source bitmap, will patch it with the input values and will ask to save it under the generic name of SPLASH.SYS, in the current folder.

Please note that there currently are some limits for the possible values. The limits are enforced by WBL.COM's internal architecture.

For the time being, LogoTool2 can be used with the released WBL.COM code, to test the concept. For feedback please use the following MSFN board thread: http://www.msfn.org/board/Fixes-and-enhancements-WLLCOM-t113341.html

Enjoy! :-)

CHANGELOG:
----------------

v2.0.0.0
- Initial public release (based on LogoTool v1.0.1.0)

v2.0.0.1
- Fixed a bad, bad, bad calculation bug that would've trashed the bitmap (oops!)

v2.0.0.2
- Removed debug info (was in a hurry, sorry...)

v2.0.1.0
- Added automatic watermarking

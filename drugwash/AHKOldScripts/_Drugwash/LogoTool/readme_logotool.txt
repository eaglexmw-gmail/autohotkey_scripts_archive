LogoTool
-----------
created by Drugwash March 9-11, 2008

ABOUT:
---------
This is a simple application created in AutoHotkey 1.0.47.05, that will patch a 640x480 px 256color bitmap intended for use with Tihiy's WLL.COM, adding in the animation coordinates necessary for the new version of WLL.COM (yet unreleased at the time of writing this) to function properly.
The AutoHotkey script is provided together with the compiled version. The icon has been created from scratch by Drugwash and is also provided within the package. All files can be used and distributed freely, according to the AutoHotkey license.

USAGE:
---------
The usage is extremely simple and there are also tooltips for all relevant controls (for edit boxes please point to the spinners).
The logo creator has to input the values corresponding to the progressbar and animation shaft and then press 'Patch' - the program will ask for the source bitmap, will patch it with the input values and will ask to save it under the generic name of LOGO.SYS, in the current folder.

Please note that there currently are some limits for the possible values. The limits are enforced by WLL.COM's internal architecture.

For the time being, LogoTool can be used with the released SVGACOM code, to test the concept. For feedback please use the following MSFN board thread: http://www.msfn.org/board/Fixes-and-enhancements-WLLCOM-t113341.html

Enjoy! :-)

CHANGELOG:
----------------

v1.0.0.1
- Initial public release

v1.0.1.0
- Fixed edit boxes not autoupdating
- Added button to load bitmap

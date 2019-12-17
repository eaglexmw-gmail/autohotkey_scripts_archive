-= SmartGUI XP Creator by Rajat =-
Modified by Drugwash for Win9x support

Last official version by Rajat is v4.0

To compile succesfully a working copy of the script, you must first add the bitmap resources to AutoHotkeySC.bin:
- skin.bmp as 100
- grid.bmp as 101
- splash.bmp as 102
You may also replace icons in icon group 159 and 228 with icon.ico. The above can be found in the \res subfolder.

Known issues:
- When editing complex scripts, the result - when saved - may lack portions of code;
please use a file comparison utility to detect and fix the problem, if present. BACKUP old script first!

CHANGELOG: (incomplete, to be updated)

v4.3 (not released)
===
* (fixed) Custom options were multiplied and vowels got crippled
* (fixed) Groupboxes looked ugly in GUI Helper
* (fixed) Missing FileInstall directives when running with source demand parameter

v4.3a (not released)
===
+ (added) first attempt at adding Menu control; still buggy
* changed Save dialog to buttons instead of radio group, for usability

v4.3b (not released)
===
+ added 6 extra icons to the icon library: 3 for the Menu TreeView and 3 more for Toolbar
* minor changes

v4.3c (not released)
===
* (fixed) minor syntax fixes to Manual.htm (Creater -> Creator)
* changed tooltip subroutine to variables array, to shorten code
* Menu integration is almost complete, still few minor bugs left

v4.3d beta3 (not released)
===
* fixed mouse function regression (finally!!!)
* added Label to Menu creation (to be finished)
+ connected Menu GUI with main script's ini write
* minor code cleanup
* fixed missing variable initializations for math operations

v4.3e (not released)
===
* there should be no hotkeys or labels on intermediary menu levels (nodes)!!!
+ added Menu code creation to final script
+ added automated labeling to prevent script errors (testlabel:)
* menu items order is correct now

v4.3f (not released)
===
+ finally a Menu is created in GUI1; editing will follow

v4.3g (not released)
===
+ Menu can now be loaded from external script or clipboard; no editing yet
+ Added easiest way to edit menu, considering it doesn''t respond to RightClick: open Menu edit dialog when right-clicking the grid/main window
* fixed bug allowing first level menu items without child (OK button gets disabled)

v4.3h (not released)
===
* Modified Delete/Undelete routines to allow Menu manipulation
* Modified startup Splash to not interfere with casual messageboxes in certain situations
+ Added progressbar to startup and source saving routines, for fun
* Modified the mini-help to a more stylish dialog that also handles the missing of main HTML help
* minor code reorganization to avoid unnecessary variables initialization when only asking for source
* some adjustments to Custom Options vs Toolbar tooltips; not perfect though
* fixed longstanding issue in Custom Options with multiple additions to ComboBox

v4.3i (not released)
===
+ Added 'Show grid' to the options ini as a permanent setting
* Finally fixed (hopefully) 9x mouse function errors

v4.3j (not released)
===
* fixed (finally!) a bunch of bugs in TreeView drag'n'drop and Menu creation/edit
+ deny saving Menu when at least one root item has no child
+ deny saving and warning when at least one active item has no label assigned

v4.3k (not released)
===
+ Added cursor/drag image changes to notify drop limitations; needs small fix under XP and 98SE
* fixed old bug: "1GuiClose:" label not working
* fixed menu code save and menu display
* fixed old bug: Font GUI count in saved script was never set
* fixed missing labels that contain hotkeys
* fixed wrong window height when Menu present

v4.3L (not released)
===
* minor cosmetic changes to startup Duplicate/Win9x/First Time message boxes
+ added AltSubmit to Custom Options list (a few numeric styles were already added in an earlier version)
* minor text change in MiniHelp (revamped in an earlier version)
* fixed Options switches not working (how did I miss that for so long ?!)
* changed ShiftMove switch to SM and now uses 0/1 (False/True) values for consistency with the other menu options 
* fixed background picture path in Save dialog (broken since v4.3a)
* changed the Help showing routine on F1 press to show Help Manual when Main window focused or MiniHelp when Working window focused
+ added delay for showing Manual/MiniHelp on first run only after program loading finished and splash is gone
* fixed lockup issue in GUI Stealer routine - Input command doesn't work in Win9x, worked around it
* changed the KeyWait9x() function to accept any key, not only mouse buttons; needed for GUI Stealer (see above)
* fixed indentation bug in Menu editor, now we can loop through small icons -> large icons

v4.3m (not released)
===
* tooltip is now positioned over the missing label item (if script works as planned, you'll never see it)
* fixed 'menu item not added to GUI1 when label doesn't exist' issue - now all items are redirected to testlabel (for testing purposes only)
+ added 'Debug' as a menu item as I got tired of changing the variable and reloading the script
* fixed tooltips kicking one-another or staying on screen forever
* attempted fix at 'About' window not showing under Win95 ('AnimateWindow' API missing, most likely)
+ added GDI+ dependability for TV image manipulation; uses part of tic's GdiP library: startup and shutdown (might break W95 compatibility - not checked)
* first attempt at listening to correct notification messages - failed, so far

v4.3o (not released)
===
* (don't ask about 4.3n - ugh!)
* finally fixed cursor changes between TreeView states
* improved the drag'n'drop routine (but still remains buggy)
* fixed the 'About' window not showing under Win95
* changed toolbar icons & tooltips code to something more compact and independent

v4.3p (not released)
===
+ added resize capabilities to the Menu Editor window; unfortunately, XP and 7 wouldn't respond to WM_NCLBUTTONDOWN -> HTxxxx for a non-resizable window, so for now resizing works properly only in Win9x
* fixed 'menu can be saved without a name assigned' (+ added notification)

v4.3q (not released)
===
* fixed resize issues between captionless windows
+ added Menu processing from loaded scripts (woo-hoo!) - now Menu manipulation is complete but not perfect; that is: still got bugs
+ added ability to specify a g-Label in Custom Options dialog (just type gmylabel, where 'mylabel' is a label of your choice, preferrably already created in the script if it's an edited one)
+ added ability to specify a control variable in Custom Options dialog (just type vmyvariable, where 'myvariable' is a variable name of your choice, that has not been declared elsewhere)
* fixed (probably very old) issues with invalid/inherited coordinates ("H=idden" written in the ini is one of them; if 'h' were to be processed, error may occur)

v4.3r (not released)
===
* put Gdip functions back into main script - too much modularity hurts
* resized Menu Editor window to fit initial workspace height
* drag image type now depends on OS version, since they behave differently
* fixed coords omitted from final script if zero (vs. nonexistant)
* fixed redundant spaces in final script when coords missing

v4.3s (not released)
===
* replaced arbitrary wait time in L-click & Dbl-Click with DllCall("GetDoubleClickTime") which gets system setting for double-click
* fixed Menu processing when loading from existing script; saving is still buggy though, so editing complex scripts is highly unrecommended for now
* minor changes and fixes in Custom Option routine
+ added 'minimize to tray' by Right-click on titlebar
+ added "Show/Hide window" in tray menu
* changed control label dialog according to control type (requested)
* minor changes to helper GUIs
* fixed redundant space char added after tab when hotkey present, in Menu building routine

v4.3t
===
* minor code cleanup
* fixed 'item label lost during drag'n'drop'

v4.3u
===
* fixed missing value for the 'y' coordinate in saved script due to 'menuH' not initialized (I still can't understand why a variable isn't initalized to zero when involved in a math operation, if it wasn't declared/initialized previously)
* fixed debug action (scripts.txt creation and display) running in normal mode

v4.3v
===
* hack-fixed multi-select tooltip issue under Windows 7 (thank you, Microsoft, for screwing things up more and more with every new version of Windows)

v4.3w (not released)
===
* fixed Static label editor width & height considering non-display characters & and %

v4.3x (not released)
===
* fixed longstanding bug with duplicated font settings in 'Gui, Font' commands
* fixed bug in 'Custom option' with +/- option not properly processed
* fixed vulnerability in 'Save as' routine when chosen file extension's length not equals three
+ added ability to specify GUI name (only when saving to clipboard or as new GUI)
* enlarged GUI Helper and Group Move windows to accomodate long control names
* changed temporary repository to TempDir (%Temp%\SGUI) for better containment of related files
* fixed a few minor issues in FontEx
* fixed group selection not working when grid was disabled (hack to create window color-bitmap on-the-fly)
+ added skin changing capabilty
+ added grid changing capability

v4.3y (renamed to 4.3.25.x)
===
* fixed regression with GUI count not applied to saved script
* fixed GUI name asked when testing script (Menu -> File -> Test script)
* changed first parameter options in FontEx to literal (A=apply "Gui, Font" command, R=Return font parameters string)
* changed 'Duplicate control' behavior to include custom options for most accurate duplication (not fully tested)
+ added ask rows or height before adding ComboBox or DropDownList
+ added  ask vertical position before adding UpDown, Progress or Slider
+ added GUI options dialog to ask GUI properties (gets saved only for newly created scripts)
* fixed duplicated control shows 'ERROR' when custom option dialog invoked
* fixed  GUI name gets lost when resaved after modification
+ added (admittedly, with huge delay) fasto's fix for keeping control's initial position when 'move control' is performed
* changed the Save dialog appearance and, partly, its functionality
* minor changes to GUI Options dialog appearance and functionality
+ added classic toolbar using own Toolbar and Rebar functions (both incomplete but working to the extent required by this app)
- Removed GUI4 (font selector dialog) since font selection now works directly through toolbar
* minor code cleanup
* fixed control name inconsistencies (RichEdit20A/RichEdit20W)
+ added StatusBar control creation (work in progress)
* slightly changed delete/restore control function for Menu, StatusBar and Tab
+ added color option for Main Menu
* fixed mouse and control position display in GUI Helper (old issue)
* fixed control and window coordinates inconsistencies between workspace and saved script (old issue)
* fixed Show Window to hide only when main window titlebar is right-clicked
* improved options recognition in editing external script by adding 'Gui, Color' and 'Gui, Margin' (work in progress)
* fixed deleted controls' restoration
+ added tray balloon tip (tested in Win98SE and XP-SP3)
* changed tray icon behavior: left-click shows main menu, double-click shows/hides main window, right-click shows tray menu
* replaced multi-select tooltip with drawn rectangle, to overcome Vista/7 tooltip growth limitation (known issue: workspace flickers)
+ added menu options to disable/enable toolbar balloons and tray balloon
* minor changes to Mini-Help window
* changed adding Picture with original size (resizing is possible afterwards)
* fixed wrong coordinates displayed and/or applied to moving control
* changed update check routine and added new version download
* fixed wrong coordinates saved when adding/removing Menu
* fixed 'MenuCol' not initialized (menu color picker box in Menu Editor always black on startup)

v4.3.25.17
===
* changed Tab type to Tab2 (only on output, since it has major redrawing problems in workspace)
* fixed a few issues with Tab switching, leading to errors on Preview and output
* fixed deleted controls reappear & restored controls dissapear in Tab control (thanks Klark92 for reporting)
+ added ability to add controls free or bound to a previously added Tab control (toolbar button state switch)
* fixed minor issue with ComboBox/DropDownList rows option on Add
* fixed minor issue with AltSubmit option when adding Picture/icon
* other minor fixes

v4.3.26.1
===
+ added option to specify snap-to-grid steps, separately for horizontal and vertical positioning/resizing (upon Guest request)
+ added a few new skins for a total of 8
* changed grid creation system, to get rid of the huge GIF(s)
* fixed version check routine
* fixed toolbar submenus not skinned
* minor code cleanup

v4.3.26.2 (not released)
===
* fixed multi-select rectangle kicking in erroneously
* fixed controls still being added to the Tab after this has been deleted
* changed toolbar tooltips to reflect Tab creation status and scope of newly added controls (in-Tab or independant)
* improved (hopefully!) tray balloon and toolbar tooltips behavior
* multi-selection menus Style and Thick have been rightfully switched to Radio-type menus
* replaced all literal iterations of the Settings and Controls ini files with corresponding variables
* replaced all literal iterations of the SGUI Manual path with corresponding variable

v4.3.26.3
===
* improved (barely) grid behavior, fixing bug from previous version where assigning a GUI color would kill the grid
* fixed longstanding bug where canceling a Label change on a Picture would remove the Picture control
* improved SnapToGrid dialog with Separate, Proportional and Square options
* fixed a few minor glitches in the grid/skin selector window

v4.3.26.4 (not released)
===
* fixed 'Gui, Color' applied in external script parser was killing the grid
+ added main menu skinning (no submenus) *no effect under Win7
+ added multi-select color preview in dropdown menu
* changed skin colors and style to single-bitmap

v4.3.26.5
===
* fixed a few memory leaks (still leaks 1 bitmap, gotta catch the bastard)

v4.3.26.6 (not released)
===
* fixed tray balloon not changing skin
+ added link to Mod homepage to the 'About' window
* fixed Exit always asking to save, even when workspace is empty
* fixed hidden GUIs not restored when main window was restored after hide
* fixed 'mini-help' window not changing skin
* removed gripper from rebar, since it wasn't movable anyway

v4.3.27.0 (not released)
===
* split the MenuEditor subroutines from the main script, in an attempt to modularize it
* split the Win9x subroutines from the main script and made the 'w9xstuff' module optional
+ added a 'Default' button in the 'GUI Options' styles list
 * improved control relabeling
* fixed StatusBar background color not changing if first color change upon adding was dismissed
+ added option to change font in StatusBar
+ added option to add ProgressBar in StatusBar (unfinished, won't be saved)
* changed font operations recording for the resulting script, allowing individual controls to change/retain their own font settings

v4.3.27.1 (not released)
===
+ added per-control font settings (unfinished)
+ added debug logging to track resource leaks
+ label change preview now follows control's font face, size & color, besides control size
* fixed (once and for all, hopefully) mouse position reports in GUI Helper and directly related bug in multi-select when Menu was present
	(incorrectly calculated vertical position of controls made it hard/impossible to select them through multi-select rectangle)
* changed settings file path to %appdata%\%appname% to comply to multi-user environments under NT-based OS versions
* code cleanup and reorganization, added meaningful section comments
* replaced grid size info bitmap (pxbar.bmp) with Static controls
* embedded any possible 'mailto:' error into a more decent message
* added more skin variants and changed skin chooser window to fit lower display resolutions
* increased individual grid size to 60x60px, added dark grid versions and switched to single-bitmap style (like the skin)
* moved all save-to-INI operations pertaining to settings, to the exit routine, to avoid unnecessary disk access during usage

v4.3.27.2 (not released)
===
* changed icon and splash for a more modern and colorful look
* split the ScriptParser subroutines to external module, as it needs a lot of work for fixes and improvements
* enabled saving per-control font settings (very briefly tested, may still be bugs)
* changed ownership of the workspace, still not sure this is the right way to go - it has upsides and downsides
* minor changes and fixes to the script parser

v4.3.27.3
===
- reverted to original workspace ownership, as the above solution was creating much more problems than it solved :(
- finally got rid of the dreaded Grid which kept creating problems
*fixed (hopefully) the old issue of ListView hiding beyond the Tab contol
* changed (temporarily?) the multi-select system, to get rid of the flickering effect; looks like a regression, but it'll stay until - if ever - a better solution is found
* fixed a few label-changing issues related to ListView, Tab and other multi-line/multi-items capable controls
+ added snap-to-grid override through Shift keypress (forgot to mention it in official readme)
* fixed multi-select routine to allow selection while inside GroupBox or Tab (forgot to mention it in official readme)

v4.3.27.4
===
* fixed (or rather, improved) unwanted behavior when positioning/resizing GroupBox or Tab would inadvertently display the multi-select tooltip and rectangle
* fixed (hopefully, needs more testing) annoying, longstanding bug when group move window would jump out of place after resizing a control (FixCoord() hijacked X & Y)
* fixed DropDownList & ComboBox not being caught in multi-selection due to their hidden height (read from the ini)
* fixed trying to edit a ComboBox label by R-clicking its Edit would return ERROR (created Edit2Combo() redirector function, used also with font change and custom options)

v4.3.27.5
===
* fixed uncaught server error upon update check (error 500)
* fixed release check version bug leading to "File not found" error (thanks Klark92 for the heads up)

v4.3.28.0
===
+ added menu option to disable display of splash screen at startup (Klark92, you're a PITA, did you know that?)

v4.3.29.0
===
* fixed wrong coordinates displayed in GUI Helper (thanks Learning One for reporting)
* merged ask-for-GUI-properties dialogs into a single dialog, optional through menu item 'Ask GUI Properties'
* increased multi-select detection time, attempting to avoid unwanted selection rectangle display (yeah, Klark92 "The Debugger" again! :) )
* improved multi-select routine to move the rectangle together with the selected group
+ added toolbar submenu with separate selections for single line and multiline edit control
* changed arrow buttons in multi-select window back to normal style, since Flat style only works in Win9x
* fixed issue in Save routine where script was being saved as 'Generated.ahk' in %temp% instead of updating last saved file
* fixed bug introduced in previous version where splash image was not loaded for the 'About' window (argh, Klark92!! )
* changed files' organization into subfolders for a cleaner look; there's now a 'lib' folder for function libraries and a 'mod' folder for extension modules

v4.3.29.1
===
* fixed small hovering issue in grid selector; also, now selector can be dragged around by one of the size labels at the bottom
* fixed newly added Edit submenu in toolbar not 'catching' new color when changing skins
+ added toolbar menu option for UpDown control : 'Vertical free' which avoids the UpDown control to be snapped to previously added control
* slightly modified the balloon function to accept only control handle
* modified the manifest file in an attempt to fix an issue present in Win7 (x64) with multi-select tooltip

v4.3.29.3
===
* fixed version check parsing (reset variables before each check)

v4.3.29.4
===
* attempt to fix disabled/read-only control when editing a label
+ added a small function to compact the code (DrawFocus() used in label 3Move and drawMS() )
* changed some personal data (e-mail, homepage)

v4.3.29.5
===
* attempt to fix and improve picture placement when using variables as path (needs testing)
+ added a placeholder icon for variable path-named pictures
 * improved attempt to fix disabled/read-only control when editing a label (needs testing)
! bug: changing label breaks variable percents (may be an older regression)

v4.3.29.6
===
+ added toolbar submenu for Picture control, for ease of use
! bug: new submenu won't change skin with the rest of the elements

v4.3.29.7
===
* fixed picture not resizable when no-label or variable-label
* fixed longstanding bug of double-G in gLabel
* fixed custom options list not showing last added option(s) in dropdown
* fixed weird and annoying bug where picture won't show (W=0 H=0) on duplicating if it has the 0x200 style on its own or combined.
* fixed (?) changing label breaks variable percents
* fixed Picture submenu not changing skin
* fixed recent bug with Edit toolbar menu induced by newly added Picture menu
* fixed Edit controls inherit placeholder path
* fixed Placeholder image won't show up in preview

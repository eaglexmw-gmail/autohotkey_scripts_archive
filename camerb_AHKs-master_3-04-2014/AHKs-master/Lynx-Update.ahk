;#singleinstance force
#include FcnLib.ahk
#include Lynx-FcnLib.ahk
#include Lynx-UpdateParts.ahk
;#singleinstance force
Lynx_MaintenanceType := "upgrade"

;Beginning of the actual upgrade procedure
notify("Starting Update of the LynxGuide server")
SleepSeconds(5)
SendStartMaintenanceEmail()

lynx_message("Check to make sure you have a green messenger icon. If not, Inform level 2 support.")
PreMaintenanceTasks()
TestScriptAbilities()
TestLynxSystem()
RunTaskManagerMinimized()

;TODO move this into a function (figure out what #includes need to be moved)
   LynxOldVersion := GetLynxVersion()
   LynxDestinationVersion := GetLatestLynxVersion()
   PerlUpgradeNeeded:=IsPerlUpgradeNeeded()
   ApacheUpgradeNeeded:=IsApacheUpgradeNeeded()
;ShowPreliminaryUpdateSummary()

CreateSmsKey()

DownloadAllLynxFilesForUpgrade()

;TODO get client information and insert it into the database (if empty)
; log the info as well
CheckDatabaseFileSize()
GetServerSpecs()
GetClientInfo()
BackupLynxDatabase("BeforeUpdate")

notify("Start of Downtime", "Turning the LynxGuide Server off, in order to perform the upgrade")
TurnOffIisIfApplicable()
StopAllLynxServices()
SleepSeconds(9)
EnsureAllServicesAreStopped()

UpgradePerlIfNeeded()
DeleteOldPerlLibDir()
CopyInetpubFolder()
UpgradeApacheIfNeeded()
BannerDotPlx()

;TODO ManualCheckDb()
;TODO append to extensive log file
lynx_message("Run 'perl checkdb.plx' from C:\inetpub\wwwroot\cgi")

CheckDb()
CleanupServerSupervision()

RestartService("apache2.2")
SleepSeconds(5)
InstallAll()

notify("End of Downtime", "The LynxGuide Server should be back up, now we will begin the tests and configuration phase")
SleepSeconds(9)

;another checkdb just to ensure that the system is awesome
CleanupServerSupervision()
;CheckDb()

;ensure services are set to restart automatically after failures
SetServiceToRetryAfterFailures("MSSQLSERVER")
SetServiceToRetryAfterFailures("SQLEXPRESS")
SetServiceToRetryAfterFailures("APACHE2.2")
;RenameLynxguideAlarmChannels()

;admin login (web interface)
;TODO pull password out of DB and open lynx interface automatically
;TODO ensure all locations are described correctly
lynx_message("(Admin Panel > Change system settings > File system locations and logging):`n`nChange logging to extensive, log age to yearly, message age to never, and log size to 500MB. Save your changes.")
CheckIfSubscriptionNeedsToBeTurnedOff()
lynx_message("Under back up system, set file system backups quarterly and database backups weekly")
InstallSmsKey()

;security login (web interface)
;TODO pull password out of DB and open lynx interface automatically
lynx_message("Ensure lynx2@mitsi.com is added in the contact list, with the comment 'Lynx Technical Support - Automated Supervision'")
lynx_message("Send Test SMS message, popup (to server), and email (to lynx2).")
LynxNewVersion := GetLynxVersion()
EnsureAllServicesAreRunning()
TestLynxSystem()
SendLogsHome()
lynx_message("Disable 000 Supervision on Alarm Groups POPUP and LYNXKEYPRO, if they do not have any destinations set up.")
lynx_message("Ensure the LynxGuide supervision channels 000 Normal, 000 Alarm, 001, 002, 006, 007, 008, 009 are enabled, with the company name in the subject line of each alarm message.")
lynx_message("Ensure lynx2 is a contact for the LynxGuide channels 000 Normal, 000 Alarm, 001, 002, 009")
lynx_message("For all hardware alarm groups, ensure lynx2 is a contact on 000 Normal, 000 Alarm and 990")
lynx_message("Change desktop background, if the background is not current.")

;testing
;lynx_message("Note in sugar: Tested SMS and Email to lynx2@mitsi.com, failed/passed by [initials] mm-dd-yyyy")
;lynx_message("Note server version, last updated in sugar")
;lynx_message("Make case in sugar for 'Server upgraded to 7.##.##.#', note specific items/concerns addressed with customer in description")

BackupLynxDatabase("AfterUpdate")
PostMaintenanceTasks()
ShowUpgradeSummary()
lynx_message("Log off of the server")
SleepMinutes(60*12)
Shutdown, 4
ExitApp


;TODO do all windows updates (if their server is acting funny)
;  this is a bad idea cause it will require a reboot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; functions

;ghetto hotkey
;Appskey & r::
;SetTitleMatchMode, 2
;WinActivate, Notepad
;WinWaitActive, Notepad
;Sleep, 200
;Send, {ALT}fs
;Sleep, 200
;reload
;return


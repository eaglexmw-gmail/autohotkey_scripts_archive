; This closes the confirmation on Miranda Forum log off (vBulletin shitty script) and gets rid of other confirmations
; (c) Drugwash July2008

#Persistent
SetTimer, CloseMFC, 250
return

CloseMFC:
ControlSend, , {Enter}, Shortcut, The new shortcut will be placed on the desktop.
ControlSend, , {Enter}, Miranda Crash Dumper, Miranda crashed.
ControlSend, , {Tab}, Hard Disk is Full, You have run out of disk space
ControlSend, , {Enter}, Hard Disk is Full, You have run out of disk space
ControlSend, , {Enter}, Damage Cleanup Engine (DCE), No Virus Found
ControlSend, , {Enter}, Security Alert, You are about to be redirected to a connection that is not secure.
ControlSend, , {Enter}, Microsoft Internet Explorer, Are you sure you want to log out?
ControlSend, , {Enter}, Microsoft Internet Explorer, Are you sure you want to empty this folder?
ControlSend, , {Enter}, Microsoft Internet Explorer, Are you sure you want to permanently delete the selected message(s)?
ControlSend, , {Enter}, Microsoft Internet Explorer, Are you sure you want to permanently delete the content of the Spam folder?
ControlSend, , {Enter}, SlimBrowser, ªterg DEFINITIV istoric,cookies,cache. Eºti sigur?
ControlSend, , {Enter}, SlimBrowser, Sigur vrei sã ºtergi toate fiºierele de Internet din cache?
return

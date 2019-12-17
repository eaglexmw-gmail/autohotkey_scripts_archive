; This tries to reconnect the damn Dial-up Broadband shit
; (c) Drugwash July2008

#Persistent
SetTimer, Reconn, 5000
return

Reconn:
ControlSend, , {Enter}, Connect To, Connection to G...
ControlSend, , {Enter}, Reestablish Connection, Connection to
return

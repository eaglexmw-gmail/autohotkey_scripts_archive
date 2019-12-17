; 
; by Sean   http://www.autohotkey.com/forum/posting.php?mode=quote&p=140143

#Persistent
OnExit, CleanUp

CoInitialize()
pspeaker := ActiveXObject("SAPI.SpVoice")
plistener:= ActiveXObject("SAPI.SpSharedRecognizer")
pcontext := Invoke(plistener, "CreateRecoContext")
pgrammar := Invoke(pcontext, "CreateGrammar")
Invoke(pgrammar, "DictationSetState", 0)
prules := Invoke(pgrammar, "Rules")
prulec := Invoke(prules, "Add", "wordsRule", 0x1|0x20)
Invoke(prulec, "Clear")
pstate := Invoke(prulec, "InitialState")

; Add here the words to be recognized! Looks like it understands the null pointer.
Invoke(pstate, "AddWordTransition", "+" . 0, "One")
Invoke(pstate, "AddWordTransition", "+" . 0, "Two")
Invoke(pstate, "AddWordTransition", "+" . 0, "Three")

Invoke(prules, "Commit")
Invoke(pgrammar, "CmdSetRuleState", "wordsRule", 1)
Invoke(prules, "Commit")
ConnectObject(pcontext, "On")

If (pspeaker && plistener && pcontext && pgrammar && prules && prulec && pstate)
   Invoke(pspeaker, "Speak", "Starting Succeeded")
Else   Invoke(pspeaker, "Speak", "Starting Failed")
Return

CleanUp:
Release(pstate)
Release(prulec)
Release(prules)
Release(pgrammar)
Release(pcontext)
Release(plistener)
Release(pspeaker)
CoUninitialize()
ExitApp


OnRecognition(prms, this)
{
   Global   pspeaker
   presult := DispGetParam(prms, 3, 9)
   pphrase := Invoke(presult, "PhraseInfo")
   Invoke(pspeaker, "Speak", "You said " . Invoke(pphrase, "GetText"))
   Release(pphrase)
}

#Include CoHelper.ahk

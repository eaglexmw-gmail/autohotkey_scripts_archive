;  by Sean  http://www.autohotkey.com/forum/viewtopic.php?t=26841

#Persistent
OnExit, CleanUp

COM_Init()
plistener:= COM_CreateObject("SAPI.SpSharedRecognizer")
COM_Invoke(plistener, "AudioInput", paudioin ? "+" . paudioin : "+0")
pcontext := COM_Invoke(plistener, "CreateRecoContext")
pgrammar := COM_Invoke(pcontext , "CreateGrammar")
COM_Invoke(pgrammar, "DictationSetState", 0)
prules := COM_Invoke(pgrammar, "Rules")
prulec := COM_Invoke(prules, "Add", "wordsRule", 0x1|0x20)
COM_Invoke(prulec, "Clear")
pstate := COM_Invoke(prulec, "InitialState")

; Add here the words to be recognized!
COM_Invoke(pstate, "AddWordTransition", "+" . 0, "One")
COM_Invoke(pstate, "AddWordTransition", "+" . 0, "Two")
COM_Invoke(pstate, "AddWordTransition", "+" . 0, "Three")
;;

COM_Invoke(prules, "Commit")
COM_Invoke(pgrammar, "CmdSetRuleState", "wordsRule", 1)
COM_Invoke(prules, "Commit")
pevent := COM_ConnectObject(pcontext, "On")
Return

CleanUp:
COM_Release(pevent)
COM_Release(pstate)
COM_Release(prulec)
COM_Release(prules)
COM_Release(pgrammar)
COM_Release(pcontext)
COM_Release(plistener)
COM_Term()
ExitApp

OnRecognition(prms, this)
{
   presult := COM_DispGetParam(prms, 3, 9)
   pphrase := COM_Invoke(presult, "PhraseInfo")
   sText   := COM_Invoke(pphrase, "GetText")
   COM_Release(pphrase)
;   Add custom operations from here!
}

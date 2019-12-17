; based on...
; Sean : http://www.autohotkey.com/forum/viewtopic.php?t=26841&highlight=sapi

speech_Initialize() {

	NotifyRegister("AHK Closing", "speech_OnExit")
	NotifyRegister("System Initialized", "speech_OnInitialized")
	NotifyRegister("UI Create", "speech_OnUiCreate")
	NotifyRegister("Lister SetFilter", "speech_OnSetFilter")

	CommandRegister("Speech Off", "speech_OnPause", "/name:Speech Off")
	CommandRegister("Speech On", "speech_OnResume", "/name:Speech On")
	CommandRegister("Speak Text", "speak_OnText")
	CommandRegister("Speech Toggle", "speech_OnToggle")
	CommandRegister("Speech Computer", "speech_OnComputer", "/name:Computer")

	COM_Init()
}

speak_OnText(A_Command, A_Args) {

	global pcontext

	text := getValue(A_Args, "text")
	
	if (text <> "") {
		COM_Invoke(pcontext, "State", 0)
		TTS(text)
		COM_Invoke(pcontext, "State", 1)
	}
}

speech_OnUiCreate(A_Command, A_Args) {
	global CTRLSpeech

	COMMAND("UI AddControl", "/name:CTRLSpeech"
		. " /type:button"
		. " /x:475 /y:62 /w:16 /h:16"
		. " /anchor:x"
		. " /text:."
		. " /style:-theme +0x8000"
		. " /options:vCTRLSpeech"
		. " /tooltip:Voice Recognition"
		. " /callback:Speech Toggle")
}

speech_OnToggle(A_Command, A_Args) {
	global pcontext
	state := COM_Invoke(pcontext, "State")
	if (state = 0) {
		COMMAND("Speech On")
	} else {
		COMMAND("Speech Off")
	}
}

speech_OnPause(A_Command, A_Args) {
	global pcontext
	COM_Invoke(pcontext, "State", 0)
	GuiControl, , CTRLSpeech, %A_Space%
}

speech_OnResume(A_Command, A_Args) {
	global pcontext
	COM_Invoke(pcontext, "State", 1)
	GuiControl, , CTRLSpeech, -
	COMMAND("Speak Text", "/text:Speech enabled")
}

speech_OnInitialized(A_Command, A_Args) {

	global pevent, pstate, prulec, prules, pgrammar, pcontext, plistener

	plistener:= COM_CreateObject("SAPI.SpSharedRecognizer")
	pcontext := COM_Invoke(plistener, "CreateRecoContext")
	pgrammar := COM_Invoke(pcontext , "CreateGrammar")
	COM_Invoke(pgrammar, "DictationSetState", 0)
	prules := COM_Invoke(pgrammar, "Rules")
	prulec := COM_Invoke(prules, "Add", "wordsRule", 0x1|0x20)
	COM_Invoke(prulec, "Clear")
	pstate := COM_Invoke(prulec, "InitialState")

	COM_Invoke(pstate, "AddWordTransition", "+" . 0, "computer")

	COM_Invoke(prules, "Commit")
	COM_Invoke(pgrammar, "CmdSetRuleState", "wordsRule", 1)
	COM_Invoke(prules, "Commit")
	pevent := COM_ConnectObject(pcontext, "On")
	COM_Invoke(pcontext, "State", 0)
}

speech_OnComputer(A_Command, A_Args) {
	COMMAND("Speak Text", "/text:Yes")

	filter := STATE_GET("Lister CurrentFilter")
	speech_RegisterCommands(filter)
}

speech_RegisterCommands(filter="") {

	global pcontext, prules, prulec, pstate, pgrammar

	COM_Invoke(pcontext, "State", 0)
	COM_Invoke(prulec, "Clear")
	pstate := COM_Invoke(prulec, "InitialState")

	COM_Invoke(pstate, "AddWordTransition", "+" . 0, "computer")
	
	if (filter = "") {
		list := list_Create()
	} else {
		list := FilterList(filter)
		listName := getValue(filter, "list")
	}
	
	if (listName <> "filters") {
		filters := syslist_Get("Categories")
		list_Merge(list, filters)
	}

	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		name := getValue(entry, "name")
		COM_Invoke(pstate, "AddWordTransition", "+" . 0, name)
	}

	COM_Invoke(prules, "Commit")
	COM_Invoke(pgrammar, "CmdSetRuleState", "wordsRule", 1)
	COM_Invoke(prules, "Commit")
	COM_Invoke(pcontext, "State", 1)
}

speech_OnSetFilter(A_Command, A_Args) {

	global gblComputer

	if (gblComputer = 1) {
		speech_RegisterCommands(A_Args)
	}
}

speech_OnExit(A_Command, A_Args) {
	COM_Release(pevent)
	COM_Release(pstate)
	COM_Release(prulec)
	COM_Release(prules)
	COM_Release(pgrammar)
	COM_Release(pcontext)
	COM_Release(plistener)
	COM_Term()
}

OnRecognition(prms, this)
{
	global gblComputer, pcontext

	presult := COM_DispGetParam(prms, 3, 9)
	pphrase := COM_Invoke(presult, "PhraseInfo")
	sText   := COM_Invoke(pphrase, "GetText")
	COM_Release(pphrase)

	SetTimer, timer_SpeechOff, 5000

	if (sText = "computer") {
		gblComputer = 1
		GuiControl, , CTRLSpeech, !
		COMMAND("UI Show")
		COMMAND("Speech Computer")

	} else if (gblComputer = 1) {
		filter := STATE_GET("Lister CurrentFilter")
		list := getValue(filter, "list")

		entry := syslist_Get(list, "/single:Yes /filter:name=" . sText)
		if (entry = "") {
			entry := syslist_Get("Categories", "/single:Yes /filter:name=" . sText)
		}
		COMMAND("Command Run", entry)
		COMMAND("Speak Text", "/text:" . sText)
	}
	Return
	
	timer_SpeechOff:
		gblComputer = 0
		speech_RegisterCommands()
		SetTimer, timer_SpeechOff, off
		GuiControl, , CTRLSpeech, -
	Return
}

#include plugins/input/COM.ahk
#include plugins/input/TTS.ahk
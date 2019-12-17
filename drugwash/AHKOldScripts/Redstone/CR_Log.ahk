log_Initialize(AppName) {
	global
	
	gblLogFile := A_ScriptDir . "\" . AppName . ".log"
	
	FileDelete, %gblLogFile%

	log_level_PASS := STATE_GET("Logging Pass")
	log_level_FAIL := STATE_GET("Logging Fail")
	log_level_DEBUG := STATE_GET("Logging Debug")
	log_level_PERF := STATE_GET("Logging Perf")
	log_level_LIST := STATE_GET("Logging List")
	log_level_STATE := STATE_GET("Logging State")
	log_level_PLUGIN := STATE_GET("Logging Plugin")
	log_level_EXTENDED := 0
}

log(text, status=2, level=1) {
	text := SubStr(text, 1, 100)
	logA(text, status, level)
}

getLogExtended() {
global
	return log_level_EXTENDED
}

setLogExtended(mode) {
global
	log_level_EXTENDED := mode
}

logExt(text) {
global
	if (log_level_EXTENDED > 0) {
		logA(text)
	}
}

logA(text, type=2, level=0) {
	local pf

;	gblLogFile := A_ScriptDir . "\Redstone.log"
;log_level_EXTENDED := 1

	if (type = 0) {
		pf := "FAIL "
		level := log_level_FAIL
	} else if (type = 1) {
		pf := "PASS "
		level := log_level_PASS
	} else if (type = 2) {
		pf := "DEBUG"
		level := log_level_DEBUG
	} else if (type = 3) {
		pf := "LIST "
		level := log_level_LIST
	} else if (type = 4) {
		pf := "PERF "
		level := log_level_PERF
	} else if (type = 5) {
		pf := "STATE"
		level := log_level_STATE
	} else if (type = 6) {
		pf := "PLUGIN"
		level := log_level_PLUGIN
	} else {
		pf := "CUSTM"
		level := 1
	}
	
	if (level > 0) OR (log_level_EXTENDED = 1 AND type = 2){
		FileAppend,**** %pf% %text%`n,%gblLogFile%
	}
}

file_Initialize() {

	CommandRegister("Files SetFolder", "file_SetFolder")
	CommandRegister("Files Properties", "file_Properties")
	CommandRegister("Files Run", "file_Run")

	NotifyRegister("UI BuildMenu", "file_BuildMenu")
}

file_Properties(A_Command, A_Args) {

	fileMeta := getNestedNode(A_Args, "Entry")
	file := getValue(fileMeta, "command")

	Run, properties %file%,, UseErrorLevel
}

file_SetFolder(A_Command, A_Args) {

	directory := getValue(A_Args, "command")
	type := getValue(A_Args, "type")

	if (type = "file") {
		SplitPath, directory, , directory
	}

	filter := syslist_Get("Filters", "/single:Yes /filter:name=Files")
	addValues(filter, "/directory:" . directory)
	COMMAND("Lister SetFilter", filter)
}

file_Run(A_Command, A_Args) {

	command := getValue(A_Args, "command")
	args := getValue(A_Args, "parameters")
	type := getValue(A_Args, "type")
	
	dir := A_ScriptDir

	if (type = "file") {
		
		filter := STATE_GET("Lister CurrentFilter")
		listName := getValue(filter, "list", "Default")
		SplitPath, command, , dir
	}

	if (args <> "")
		command := command . " " . args

	error := False

	Run, %command%, %dir%, UseErrorLevel
	if ErrorLevel = ERROR
		error := True

	if (error = True) {
		syslist_Add("Errors", "/type:error /error:Failed to execute: " . command)
	} else {
		COMMAND("UI Hide")
		if (listName = "Files") {
		
			SplitPath, dir, FName, , , FNameNoExt
			StringRight,isColon,dir,1
			if (isColon = ":")
				dir := dir . "\"
			if (FName = "") {
				FName := dir
			}
			COMMAND("Command HistoryAdd", "/name:" . FName . " /type:folder /command:" . dir)
		}
		COMMAND("Command HistoryAdd", A_Args)
	}
}

file_BuildMenu(A_Command, A_Args) {

	entry := getNestedNode(A_Args, "Entry")
	type := getPrimitiveType(entry)

	if (type = "file" OR type = "folder") {
	 	
	 	; Set the command
	 	command := commandCreate("Files Properties")
	 	addNamedArgument(command, "Entry", entry)
		
		menuAdd(A_Args, "/item:Properties", command)

		;<MenuEntry>
		;  <menu>uiMenu</menu>
		;  <item>Properties</item>
		;  <command>
		;    <command>Files Properties</command>
		;    <type>command</type>
		;    <Args>
		;      <file>
		;        <type>file</type>
		;        <name>term</name>
		;        <command>C:\cygwin\home\joe\quickcommands\Cygwin\term.sh</command>
		;        <executed>2008/07/13 16:22:14</executed>
		;        <listName>History</listName>
		;      </file>
		;    </Args>
		;  </command>
		;</MenuEntry>
	}
}


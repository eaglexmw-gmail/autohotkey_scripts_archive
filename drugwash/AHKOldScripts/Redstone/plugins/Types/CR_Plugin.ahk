pluginType_Initialize() {
	NotifyRegister("UI BuildMenu", "pluginType_OnBuildMenu")
}

pluginType_OnBuildMenu(A_Command, A_Args) {

	pluginMeta := getNestedNode(A_Args, "Entry")
	type := getValue(pluginMeta, "type")

	if (type = "plugin") {
		enabled := getValue(pluginMeta, "enabled")
		name := getValue(pluginMeta, "name")

		if (enabled = "Yes") {
			replaceValue(pluginMeta, "enabled", "No")
			command := commandCreate("List Add", "/listName:Plugins")
			addNamedArgument(command, "Entry", pluginMeta)
			menuAdd(A_Args, "/item:Disable", command)
		} else {
			replaceValue(pluginMeta, "enabled", "Yes")
			command := commandCreate("List Add", "/listName:Plugins")
			addNamedArgument(command, "Entry", pluginMeta)
			menuAdd(A_Args, "/item:Enable", command)
		}
	}
}

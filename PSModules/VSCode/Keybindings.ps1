function Update-VscodeUserKeybindingsJson {
	Copy-Item $PSScriptRoot\keybindings.json $VSCODE_USER_KEYBINDINGS_JSON
}

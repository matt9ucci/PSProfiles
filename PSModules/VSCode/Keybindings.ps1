#Requires -Modules Core

function Backup-VscodeUserKeybindingsJson {
	Backup-Item $VSCODE_USER_KEYBINDINGS_JSON
}

function Update-VscodeUserKeybindingsJson {
	Copy-Item $PSScriptRoot\keybindings.json $VSCODE_USER_KEYBINDINGS_JSON
}

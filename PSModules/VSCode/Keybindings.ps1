#Requires -Modules Core

function Backup-VSCodeUserKeybindingsJson {
	Backup-Item $VSCODE_USER_KEYBINDINGS_JSON
}

function Install-VSCodeUserKeybindingsJson {
	Copy-Item $PSScriptRoot\keybindings.json $VSCODE_USER_KEYBINDINGS_JSON
}

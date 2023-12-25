function Edit-PsrlHistory {
	code -r (Get-PSReadLineOption).HistorySavePath
}

function Remove-PsrlDuplicateHistory {
	Get-Content (Get-PSReadLineOption).HistorySavePath
	| Sort-Object
	| Get-Unique
	| Set-Content -Path (Get-PSReadLineOption).HistorySavePath
}

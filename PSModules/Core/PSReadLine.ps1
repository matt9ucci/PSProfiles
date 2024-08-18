function Edit-PsrlHistory {
	code -r (Get-PSReadLineOption).HistorySavePath $PROFILEDIR\ConsoleHost_history.txt
}

function Remove-PsrlDuplicateHistory {
	Get-Content (Get-PSReadLineOption).HistorySavePath
	| Sort-Object -Unique
	| Set-Content -Path (Get-PSReadLineOption).HistorySavePath
}

function Add-PsrlHistoryCommon {
	Get-Content $PSScriptRoot\..\..\ConsoleHost_history.txt
	| ? { $_ -notmatch '^\s*#+' }
	| Add-Content -Path (Get-PSReadLineOption).HistorySavePath
}


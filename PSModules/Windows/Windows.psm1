function New-Shortcut {
	param (
		[Parameter(Position = 0, Mandatory)]
		[string]
		$Path,

		[Parameter(Position = 1, Mandatory)]
		[string]
		$TargetPath
	)

	$wshShell = New-Object -ComObject WScript.Shell
	$shortcut = $wshShell.CreateShortcut($Path)
	$shortcut.TargetPath = $TargetPath
	$shortcut.Save()
}

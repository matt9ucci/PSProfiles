function Copy-Icon {
	$param = @{
		Path = Join-Path $PSHOME assets
		Destination = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\ProfileIcons"
		Filter = '*.ico'
		Recurse = $true
	}
	Copy-Item @param
}

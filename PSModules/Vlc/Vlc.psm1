function Get-Vlcrc {
	$vlcrc = Get-Content (Join-Path $env:APPDATA vlc vlcrc)
	$vlcrc | sls '(?=^[^#\[])'
}

function Open-Vlcrc {
	code (Join-Path $env:APPDATA vlc vlcrc)
}

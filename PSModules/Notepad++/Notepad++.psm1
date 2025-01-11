$NPP_HOME = "$USERAPPS/Notepad++"
$NPP_EXE = Join-Path $NPP_HOME notepad++.exe

function npp {
	[string[]]$path = $args

	$command = @($NPP_EXE)

	if ((Test-Path $path -PathType Container) -contains $true) {
		$command += '-openFoldersAsWorkspace'
	}

	# Resolve-Path is needed for "."
	$command += (Resolve-Path $path).Path -join ' '

	Write-Debug ('Invoking: {0}' -f ($command -join ' '))
	Invoke-Expression -Command ($command -join ' ')
}

function Update-NppConfigXml {
	Copy-Item $PSScriptRoot\config.xml (Join-Path $NPP_HOME config.xml)
}

function Update-NppShortcutsXml {
	Copy-Item $PSScriptRoot\shortcuts.xml (Join-Path $NPP_HOME shortcuts.xml)
}

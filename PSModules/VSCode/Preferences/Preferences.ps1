function Use-VscodePreference {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	$extensionsDir = Join-Path $USERAPPS VsCode preferences $Name extensions
	if (Test-Path $extensionsDir) {
		$env:VSCODE_EXTENSIONS = Join-Path $USERAPPS VsCode preferences $Name extensions
	}
}

function Initialize-VscodePreference {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	$preferenceRoot = Join-Path $USERAPPS VsCode preferences $Name
	$extensionsDir = Join-Path $preferenceRoot extensions
	New-Item $extensionsDir -ItemType Directory -Force | Out-Null

	$psd1 = Import-PowerShellDataFile (Join-Path $PSScriptRoot "$Name.psd1")
	$psd1.Extensions | % {
		code --extensions-dir $extensionsDir --install-extension $_
	}
}

function Reset-VscodePreference {
	$env:VSCODE_EXTENSIONS = $null
}

Register-ArgumentCompleter -ParameterName Name -CommandName Use-VscodePreference, Initialize-VscodePreference -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)

	([string[]](Get-ChildItem $PSScriptRoot -Filter *.psd1).BaseName) -like "$wordToComplete*"
}

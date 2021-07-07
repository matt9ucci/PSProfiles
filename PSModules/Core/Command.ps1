function syntax {
	param ([string[]]$Name)
	(Get-Command -Name $Name -Syntax) -replace ' (?=\[-\w+( <.+>)?\] \[)', "`n`t" -replace ' \[<CommonParameters>\]'
}

Register-ArgumentCompleter -CommandName syntax -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

	Get-Command -Name $wordToComplete* | % Name
}

function Get-CommandDefinition([string[]]$Name) { (gcm $Name).Definition }
sal gcmdefinition Get-CommandDefinition

function Show-CommandLocation {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	$cmd = Get-Command $Name
	if ($cmd.Path) {
		Split-Path $cmd.Path | Invoke-Item
	} else {
		throw "Unsupported command type: $($cmd.GetType())"
	}
}

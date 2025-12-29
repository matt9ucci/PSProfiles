$commandInfo = Get-Content $PSScriptRoot\CompleterV2.json | ConvertFrom-Json

$commandNames = @('multipass')
if ($names = (Get-Alias -Definition multipass -ErrorAction Ignore).Name) {
	$commandNames += $names
}

Register-ArgumentCompleter -Native -CommandName $commandNames -ScriptBlock {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	$results = $commandInfo.Commands | ? Name -Like "$wordToComplete*" | % {
		New-Object System.Management.Automation.CompletionResult @(
			$_.Name
			$_.Name
			$_.Type
			$_.Description
		)
	}

	$results
}

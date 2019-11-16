function gcms { param ([string[]]$Name) Get-Command -Name $Name -Syntax }
Register-ArgumentCompleter -CommandName gcms -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

	Get-Command -Name $wordToComplete* | % Name
}

function Get-CommandDefinition([string[]]$Name) { (gcm $Name).Definition }

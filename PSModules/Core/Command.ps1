function syntax {
	param (
		[ArgumentCompleter({
			param ($commandName, $parameterName, $wordToComplete)
			Get-Command -Name $wordToComplete* | % Name
		})]
		[string[]]$Name
	)
	(Get-Command -Name $Name -Syntax) -replace ' (?=\[-\w+( <.+>)?\] \[)', "`n`t" -replace ' \[<CommonParameters>\]'
}

function Get-CommandDefinition([string[]]$Name) { (gcm $Name).Definition }
sal gcmdefinition Get-CommandDefinition

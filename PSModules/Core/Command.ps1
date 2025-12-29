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

function Get-CommandParameterSet([string[]]$Name) { (gcm $Name).ParameterSets }

function Show-CommandLocation {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	Get-Command $Name | % Source | Split-Path | Invoke-Item
}

function Get-CommandParameter {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name,

		[switch]
		$Full
	)

	$result = (Get-Command -Name $Name).Parameters.GetEnumerator() | select -ExpandProperty Value
	if (!$Full) {
		$result = $result | select -ExcludeProperty Attributes, ParameterSets
		$result = $result | ? Name -NotIn @(
			# Exclude common parameters https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters
			'Debug'
			'ErrorAction'
			'ErrorVariable'
			'InformationAction'
			'InformationVariable'
			'OutBuffer'
			'OutVariable'
			'PipelineVariable'
			'Verbose'
			'WarningAction'
			'WarningVariable'
		)
	}

	$result
}
sal gcmparam Get-CommandParameter

function Get-CommandParameterAttributes {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name,

		[ValidateSet(
			'Mandatory',
			'ValueFromPipeline',
			'ValueFromPipelineByPropertyName',
			'ValueFromRemainingArguments'
		)]
		[string[]]
		$Filter
	)

	$result = Get-CommandParameter -Name $Name -Full | select Name -ExpandProperty Attributes

	if ('Mandatory' -in $Filter) {
		$result = $result | ? Mandatory
	}
	if ('ValueFromPipeline' -in $Filter) {
		$result = $result | ? ValueFromPipeline
	}
	if ('ValueFromPipelineByPropertyName' -in $Filter) {
		$result = $result | ? ValueFromPipelineByPropertyName
	}
	if ('ValueFromRemainingArguments' -in $Filter) {
		$result = $result | ? ValueFromRemainingArguments
	}

	$result
}

function Out-ProxyCommandString {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	$metadata = New-Object System.Management.Automation.CommandMetadata (Get-Command $Name)
	[System.Management.Automation.ProxyCommand]::Create($metadata)
}

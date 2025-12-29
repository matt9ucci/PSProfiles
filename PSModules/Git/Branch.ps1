function New-Branch {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	igit branch $Name
}

function Remove-Branch {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name,

		[switch]
		$Force
	)

	[string[]]$options = @(
		'--delete'
	)

	if ($Force) {
		$options += '--force'
	}

	igit branch $options $Name
}

function Get-BranchName {
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param (
		[Parameter(ParameterSetName = 'Default', Position = 0)]
		[string]
		$Pattern = '*',

		[Parameter(ParameterSetName = 'Default')]
		[switch]
		$Remote,

		[Parameter(ParameterSetName = 'Current')]
		[switch]
		$Current
	)

	if ($Current) {
		[string[]]$options = @(
			'--show-current'
		)
	} else {
		[string[]]$options = @(
			'--list'
			$Pattern
			'--format'
			'"%(refname:short)"'
		)

		if ($Remote) {
			$options += '--remotes'
		}
	}

	igit branch $options
}

function Switch-Branch {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	igit switch $Name
}

if ($cmdName = gcm -Noun Branch) {
	Register-ArgumentCompleter -CommandName $cmdName -ParameterName Name -ScriptBlock {
		param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
		Get-BranchName -Pattern $WordToComplete* 6>$null
	}
}

$ENV_DIR = '.venv'

function New-PyVenv {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Path = $ENV_DIR
	)

	$params = @(
		'-m'
		'venv'
		$Path
	)
	python @params
}

function Enable-PyVenv {
	[Alias('Activate')]
	[CmdletBinding()]
	param ()

	if (!(Test-Path $ENV_DIR -PathType Container)) {
		throw "Directory not found: $ENV_DIR"
	}

	if (Test-PyVenv) {
		Write-Debug 'Venv is already enabled'
	} else {
		& (Join-Path $ENV_DIR Scripts Activate.ps1)
	}
}

function Disable-PyVenv {
	if (Test-PyVenv) {
		deactivate
	}
}

function Restore-PyVenv {
	Enable-PyVenv
	pip install -r requirements.txt
}

function Save-PyVenv {
	Enable-PyVenv
	pip freeze > requirements.txt
}

function Test-PyVenv {
	[bool]$env:VIRTUAL_ENV
}

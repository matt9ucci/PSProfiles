$ENV_DIR = '.venv'

function New-VirtualEnvironment {
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

function Enable-VirtualEnvironment {
	[CmdletBinding()]
	param ()

	if (!(Test-Path $ENV_DIR -PathType Container)) {
		throw "Directory not found: $ENV_DIR"
	}

	& (Join-Path $ENV_DIR Scripts Activate.ps1)
}

function Disable-VirtualEnvironment {
	if (Test-VirtualEnvironment) {
		deactivate
	}
}

function Restore-VirtualEnvironment {
	if (!(Test-VirtualEnvironment)) {
		Enable-VirtualEnvironment
	}
	pip install -r requirements.txt
}

function Test-VirtualEnvironment {
	[bool]$env:VIRTUAL_ENV
}

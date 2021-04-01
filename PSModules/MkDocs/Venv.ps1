function New-VirtualEnvironment {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Path = '.venv'
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

	if (!(Test-Path .venv -PathType Container)) {
		throw 'Directory not found: .venv'
	}

	.\.venv\Scripts\Activate.ps1
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

'python', 'pip' | % {
	Get-Command $_ -ErrorAction SilentlyContinue -ErrorVariable e
	if ($e) {
		Write-Warning "Command not found: $_"
		Remove-Variable e
	}
}

function New-Project {
	[CmdletBinding()]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Path
	)

	if (!$PSBoundParameters.ContainsKey('Path')) {
		$Path = '.'
	} elseif (Test-Path $Path) {
		if ((Get-ChildItem $Path).Count) {
			throw "The `$Path ($Path) is not empty."
		}
	} else {
		New-Item $Path -ItemType Directory
	}

	Push-Location $Path

	python -m venv .venv
	.\.venv\Scripts\Activate.ps1
	pip install mkdocs mkdocs-material
	python -m pip freeze > requirements.txt

	mkdocs new .
	Set-Content mkdocs.yml @(
		"site_name: $(Split-Path $Path -Leaf)"
		'theme:'
		'  name: material'
		'  features:'
		'    - navigation.instant'
		'use_directory_urls: false'
	)

	Set-Content .gitignore @(
		'.venv/'
		'site/'
	)

	deactivate
	Pop-Location
}

function Start-Server {
	if (!(Test-VirtualEnvironment)) {
		Enable-VirtualEnvironment
	}
	mkdocs serve
}

function Enable-VirtualEnvironment {
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

function Test-VirtualEnvironment {
	[bool]$env:VIRTUAL_ENV
}

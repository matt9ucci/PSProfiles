'python', 'pip' | % {
	Get-Command $_ -ErrorAction SilentlyContinue -ErrorVariable e
	if ($e) {
		Write-Warning "Command not found: $_"
		Remove-Variable e
	}
}

Import-Module Python

function New-MaterialProject {
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

	New-PythonVirtualEnvironment
	Enable-PythonVirtualEnvironment
	pip install mkdocs mkdocs-material
	Save-PythonVirtualEnvironment

	mkdocs new .
	Set-Content mkdocs.yml @(
		"site_name: $(Split-Path $Path -Leaf)"
		'use_directory_urls: false'
		'theme:'
		'  name: material'
		'  features:'
		'    - navigation.instant'
		'markdown_extensions:'
		'  - toc:'
		'      permalink: true'
	)

	Set-Content .gitignore @(
		'.venv/'
		'site/'
	)

	Disable-PythonVirtualEnvironment
	Pop-Location
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

	New-PythonVirtualEnvironment
	Enable-PythonVirtualEnvironment

	pip install mkdocs
	Save-PythonVirtualEnvironment

	mkdocs new .
	Set-Content mkdocs.yml @(
		"site_name: $(Split-Path $Path -Leaf)"
		'use_directory_urls: false'
		'markdown_extensions:'
		'  - toc:'
		'      permalink: true'
	)

	Set-Content .gitignore @(
		'.venv/'
		'site/'
	)

	Disable-PythonVirtualEnvironment

	Pop-Location
}

function Start-Server {
	if (!(Test-VirtualEnvironment)) {
		Enable-VirtualEnvironment
	}
	mkdocs serve
}

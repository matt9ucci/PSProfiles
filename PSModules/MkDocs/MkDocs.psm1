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
	Add-Content mkdocs.yml @(
		'theme:'
		'  name: material'
	)

	Set-Content .gitignore @(
		'.venv/'
		'site/'
	)

	mkdocs build
	Start-Process site\index.html

	deactivate
	Pop-Location
}

$GitCloneIntoRootPath = "$HOME\Repository"

if (!(Test-Path $GitCloneIntoRootPath)) {
	New-Item -Path $GitCloneIntoRootPath -ItemType Directory
}

function Invoke-GitClone {
	param (
		[Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[uri]
		$Uri,

		[uint]
		$Depth,

		[switch]
		$DisableAutoCrLf
	)

	$path = ConvertTo-GitCloneIntoRepositoryPath -Uri $Uri
	Write-Debug "git clone into $path"

	$params = @(
		if ($Depth) { '--depth', $Depth }
		if ($DisableAutoCrLf) { '--config', 'core.autocrlf=false' }
	)
	git clone @params $Uri $path
}

function ConvertTo-GitCloneIntoRepositoryPath {
	param (
		[Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[uri]
		$Uri
	)

	$host = $Uri.Host
	switch ($host) {
		{
			$_ -in @(
				'github.com'
				'bitbucket.org'
			)
		} {
			Join-Path $GitCloneIntoRootPath $host ($Uri.AbsolutePath -replace '(.*)\.git$', '$1')
		}
		default {
			throw [System.Management.Automation.PSNotSupportedException]::new()
		}
	}
}

$params = @{
	Function = @(
		'Invoke-GitClone'
	)
	Variable = @(
		'GitCloneIntoRootPath'
	)
}
Export-ModuleMember @params

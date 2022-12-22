<#
.EXAMPLE
	Initialize-GitRepository
.EXAMPLE
	Initialize-GitRepository -RemoteUri https://github.com/user/repo.git
#>
function Initialize-GitRepository {
	param (
		[Parameter(Position = 0)]
		[uri]
		$RemoteUri,

		[string]
		$Path = (Split-Path $RemoteUri -LeafBase),

		[string]
		$RemoteName = 'origin',

		[string]
		$BranchName = 'main',

		[switch]
		$NoInitialEmptyCommit
	)

	New-Item $Path -ItemType Directory -Force

	Push-Location $Path

	git init --initial-branch $BranchName

	if ($NoInitialEmptyCommit) {
		Write-Warning 'Skip creating an initial empty commit'
	} else {
		New-GitEmptyCommit
	}

	if ($RemoteUri.IsAbsoluteUri) {
		git remote add $RemoteName $RemoteUri
		git remote --verbose
	}

	Pop-Location
}

function New-GitEmptyCommit {
	git commit --allow-empty -m 'Initial empty commit'
}

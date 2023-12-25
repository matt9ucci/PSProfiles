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

function Copy-GitRepository {
	param (
		[Parameter(Position = 0, Mandatory)]
		[uri]
		$Uri,

		[Parameter(Position = 1)]
		[string]
		$Path,

		[uint]
		$Depth,

		[string]
		$BranchName,

		[switch]
		$GitRepos
	)

	$params = @()

	if ($Depth -ge 1) {
		$params += '--depth'
		$params += $Depth
	}

	if ($BranchName) {
		$params += '--branch'
		$params += $BranchName
	}

	$params += $Uri

	if ($Path) {
		$params += $Path
	} elseif ($GitRepos) {
		$remoteHost = $Uri.Host
		$owner = Split-Path (Split-Path $Uri -Parent) -Leaf
		$repo = Split-Path $Uri -LeafBase
		$params += Join-Path $HOME 'GitRepos' @($remoteHost, $owner, $repo)
	}

	igit clone @params
}

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

function Get-GitRepository {
	param (
		[ArgumentCompleter({
			param ($0, $1, [string]$WordToComplete, $3, [hashtable]$FakeBoundParameters)
			$owner = $FakeBoundParameters.Owner ?? '*'
			$repos = Get-GitRepository -Owner $owner
			if ($repos) { $repos.Name -like "$WordToComplete*" }
		})]
		[string]
		$Name = '*',

		[ArgumentCompleter({
			param ($0, $1, [string]$WordToComplete, $3, [hashtable]$FakeBoundParameters)
			$name = $FakeBoundParameters.Name ?? '*'
			$repos = Get-GitRepository -Name $name
			if ($repos) { [string[]]$repos.Parent.Name -like "$WordToComplete*" }
		})]
		[string]
		$Owner = '*',

		[switch]
		$FullPath,

		[switch]
		$Id
	)

	$repos = Get-ChildItem -Path $GitCloneIntoRootPath\*\$Owner\$Name
	if ($Id) {
		foreach ($r in $repos) {
			Join-Path $r.Parent.Parent.Name $r.Parent.Name $r.Name
		}
	} elseif ($FullPath) {
		$repos.FullPath
	} else {
		$repos
	}
}

function Invoke-GitRepository {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[ArgumentCompleter({
			param ($0, $1, [string]$WordToComplete, $3, [hashtable]$FakeBoundParameters)
			$owner = $FakeBoundParameters.Owner ?? '*'
			$repos = Get-GitRepository -Owner $owner
			if ($repos) { $repos.Name -like "$WordToComplete*" }
		})]
		[string]
		$Name = '*',

		[ArgumentCompleter({
			param ($0, $1, [string]$WordToComplete, $3, [hashtable]$FakeBoundParameters)
			$name = $FakeBoundParameters.Name ?? '*'
			$repos = Get-GitRepository -Name $name
			if ($repos) { [string[]]$repos.Parent.Name -like "$WordToComplete*" }
		})]
		[string]
		$Owner = '*',

		[scriptblock]
		$ScriptBlock = { Invoke-Item -Path $Repo.FullPath },

		[switch]
		$Force
	)

	$repos = Get-GitRepository -Name $Name -Owner $Owner

	if (
		$Force -or
		$repos.Count -lt 2 -or
		$PSCmdlet.ShouldContinue("$($repos.Count) repositories", "Invoke {$ScriptBlock}")
	) {
		foreach ($repo in $repos) {
			$ScriptBlock.InvokeWithContext($null, @([psvariable]::new('Repo', $repo)))
		}
	}
}

$params = @{
	Function = @(
		'Get-GitRepository'
		'Invoke-GitClone'
		'Invoke-GitRepository'
	)
	Variable = @(
		'GitCloneIntoRootPath'
	)
}
Export-ModuleMember @params

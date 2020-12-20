Set-Variable GIT_CONFIG_GLOBAL "$HOME\.gitconfig" -Option ReadOnly, AllScope -Scope Global -Force

. $PSScriptRoot\Repository.ps1

function g-clone-gopath ($Repository) { git clone $Repository (Join-Path $env:GOPATH src ($Repository -replace 'https://(.*)\.git','$1')) }
function g-clone-gopath-depth-1 ($Repository) { git clone --depth 1 $Repository (Join-Path $env:GOPATH src ($Repository -replace 'https://(.*)\.git','$1')) }

function Get-GitConfig {
	param ([switch]$Global)

	$config = @{}
	$section = ''
	$name = ''
	$configPath = if ($Global) { $GIT_CONFIG_GLOBAL } else { '.git\config' }

	Get-Content $configPath | ForEach-Object {
		$line = $_.Trim()
		switch -Regex ($line) {
			'\[(\w*)\s*"?(\w*)"?\]' {
				$section = $Matches[1]
				$name = $Matches[2]

				if (!$config[$section]) {
					$config[$section] = @{}
				}

				if ($name) {
					$config[$section][$name] = @{}
				}
			}
			'(\S+)\s*=\s*(\S+)' {
				$key = $Matches[1]
				$value = switch ($Matches[2]) {
					'true' { $true }
					'false' { $false }
					Default { $_ }
				}

				if ($name) {
					$config[$section][$name][$key] = $value
				} else {
					$config[$section][$key] = $value
				}
			}
			Default { $_ }
		}
	}
	$config
}

function Get-RemoteRepositoryInfo {
	$remote = (Get-GitConfig).remote
	foreach ($key in $remote.Keys) {
		$result = [ordered]@{
			Name = $key
		}

		$r = $remote[$key]
		foreach ($k in $r.Keys) {
			$k = (Get-Culture).TextInfo.ToTitleCase($k)
			$result[$k] = $r[$k]
		}

		[pscustomobject]$result
	}
}

function Rename-Branch {
	param (
		[string]
		$OldName = (git branch --show-current),

		[Parameter(Mandatory)]
		[string]
		$NewName
	)

	git branch -m $OldName $NewName
}

function Switch-Branch {
	param (
		[Parameter(Mandatory)]
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			@(, (git branch --format='%(refname:short)')) -like "$WordToComplete*"
		})]
		[string]
		$Name
	)

	git switch $Name
}

function Update-Fork {
	param (
		[string]$Name = 'master'
	)

	if ((Get-RemoteRepositoryInfo).Name -notcontains 'upstream') {
		Write-Warning "'upstream' is required. Invoke 'git remote add upstream <URL>'"
		return
	}

	git co $Name
	git fetch upstream $Name
	git merge upstream/$Name
	git push
}

$commandNames = (Get-Command -Module Git -Name *-Branch).Name
Register-ArgumentCompleter -ParameterName Name -CommandName $commandNames -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	(Get-Branch) -like "$wordToComplete*"
}

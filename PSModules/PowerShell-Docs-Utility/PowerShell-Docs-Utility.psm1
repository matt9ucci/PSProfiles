$PSDOCSHOME = "$HOME\github.com\PowerShell-Docs"

function Get-Md {
	Param(
		[string]$Name = '*',
		[string]$Folder = 'reference',
		[string]$Version = '6'
	)

	$path = $PSDOCSHOME
	if ($Folder) {
		$path = Join-Path $path $Folder
	}
	if ($Version) {
		$path = Join-Path $path $Version
	}

	Get-ChildItem -Path $path -Filter "$Name.md" -Recurse -File
}

function Copy-Md {
	Param(
		[Parameter(Mandatory = $true)]
		[string]$Name,
		[string]$FromVersion = '6',
		[string[]]$ToVersion = @('3.0', '4.0', '5.0', '5.1')
	)
	$from = Get-Doc -Name $Name -Version $FromVersion
	foreach ($tv in $ToVersion) {
		$to = Get-Doc -Name $Name -Version $tv
		Copy-Item -Path $from.FullName -Destination $to.FullName -Verbose
	}
}

function Update-Repository([string]$Branch = 'staging') {
	Set-RepositoryLocation
	{
		git remote -v
		git remote add upstream https://github.com/PowerShell/PowerShell-Docs
		git remote -v
	}
	git checkout $Branch
	git fetch upstream staging
	git merge upstream/staging
	git push
}

function Set-RepositoryLocation {
	Set-Location $PSDOCSHOME
}

function New-Patch {
	Param(
		[string]$Name
	)
	Set-RepositoryLocation
	git checkout staging
	git checkout -b "patch-$Name"
	git branch
}

function Remove-Patch {
	Param(
		[Parameter(ValueFromPipeline = $true)][string]$PatchName,
		[switch]$All
	)
	Begin {
		Set-RepositoryLocation
		git checkout staging
	}
	Process {
		if ($All) {
			(git branch | Select-String patch-*).Line.Trim() | % {
				git branch -d $_
			}
		} else {
			git branch -d "patch-$PatchName"
		}
	}
	End {
		git branch
	}
}

function Reset-Repository {
	Update-Repository
	Remove-Patch -All
}

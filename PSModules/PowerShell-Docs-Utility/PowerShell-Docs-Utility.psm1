using module ../GitOld/Git.psm1

$PSDOCSHOME = "$HOME\github.com\PowerShell-Docs"

function Get-Md {
	param (
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
	param (
		[Parameter(Mandatory)]
		[string]$Name,
		[string]$FromVersion = '6',
		[string[]]$ToVersion = @('3.0', '4.0', '5.0', '5.1')
	)
	$from = Get-Md -Name $Name -Version $FromVersion
	foreach ($tv in $ToVersion) {
		$to = Get-Md -Name $Name -Version $tv
		Copy-Item -Path $from.FullName -Destination $to.FullName -Verbose
	}
}

function Update-Repository([string]$Branch = 'staging') {
	Set-RepositoryLocation
	Update-Fork $Branch
}

function Set-RepositoryLocation {
	Set-Location $PSDOCSHOME
}

function New-Patch {
	param (
		[string]$Name
	)
	Set-RepositoryLocation
	git checkout staging
	git checkout -b "patch-$Name"
	git branch
}

function Remove-Patch {
	param (
		[Parameter(ValueFromPipeline)]
		[string]$PatchName,
		[switch]$All
	)
	Begin {
		Set-RepositoryLocation
		git checkout staging
	}
	Process {
		if ($All) {
			$patches = git branch | Select-String patch-*
			if ($patches) {
				$patches.Line.Trim() | % { git branch -d $_ }
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

function Update-ExampleNumber {
	param (
		[Parameter(Mandatory)]
		[string]$Name,
		[string[]]$Version = @('3.0', '4.0', '5.0', '5.1', '6')
	)

	$Version | % {
		$egNumber = 1
		$target = $(Get-Md -Name $Name -Version $_)
		$content = Get-Content $target.FullName -Verbose | % {
			if ($_ -match '### Example \d{1,2}(.*)') {
				$_ -replace '### Example \d{1,2}(.*)', "### Example $egNumber`$1"
				$egNumber++
			} else {
				$_
			}
		}
		Set-Content -Path $target.FullName -Value $content
	}
}

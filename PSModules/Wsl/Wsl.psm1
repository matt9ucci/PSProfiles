function Unregister-Distro {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	if ($PSCmdlet.ShouldProcess($DistroName, 'wsl --unregister')) {
		wsl --unregister $DistroName
	}
}

function Install-Distro {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName,

		[switch]
		$Clean
	)

	[string[]]$allDistroNames = wsl --list --all --quiet
	if ($allDistroNames -contains $DistroName) {
		if ($Clean) {
			Unregister-Distro -DistroName $DistroName
		} else {
			throw "The distro '$DistroName' already exists."
		}
	}

	wsl --install $DistroName
}

function Add-Sudoers {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName,

		[Parameter(Mandatory)]
		[string]
		$UserName
	)

	$sudoersFileContent = "$UserName ALL=(ALL) NOPASSWD: ALL"
	$sudoersFilePath = "/etc/sudoers.d/$UserName"

	wsl --distribution $DistroName --user root echo $sudoersFileContent `> $sudoersFilePath
}

function Install-DockerOnUbuntu {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	wsl --distribution $DistroName --user root --cd $PSScriptRoot\Ubuntu --exec ./install-docker.sh
}

function Add-DockerGroupUser {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName,

		[Parameter(Mandatory)]
		[string]
		$UserName
	)

	wsl --distribution $DistroName --user $UserName --cd $PSScriptRoot\Ubuntu --exec ./add-me-to-docker-group.sh
}

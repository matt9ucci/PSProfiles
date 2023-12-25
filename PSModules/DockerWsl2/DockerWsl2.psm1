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
		$DistroName
	)

	[string[]]$allDistroNames = wsl --list --all --quiet
	if ($allDistroNames -contains $DistroName) {
		Unregister-Distro -DistroName $DistroName -Confirm
	}

	wsl --install $DistroName
}

function New-Sudoers {
	param (
		[Parameter(Mandatory)]
		[string]
		$UserName
	)

	$sudoersFileContent = "$UserName ALL=(ALL) NOPASSWD: ALL"
	$sudoersFilePath = "/etc/sudoers.d/$UserName"

	wsl --user root echo $sudoersFileContent `> $sudoersFilePath
}

function Install-DockerOnUbuntu {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	wsl --distribution $DistroName sudo apt-get update
	wsl --distribution $DistroName sudo apt-get install ca-certificates curl gnupg
	wsl --distribution $DistroName sudo install -m 0755 -d /etc/apt/keyrings
	wsl --distribution $DistroName curl -fsSL https://download.docker.com/linux/ubuntu/gpg `| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	wsl --distribution $DistroName sudo chmod a+r /etc/apt/keyrings/docker.gpg

	wsl --distribution $DistroName echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable' `| sudo tee /etc/apt/sources.list.d/docker.list `> /dev/null
	wsl --distribution $DistroName sudo apt-get update

	$dockerPackages = @(
		'docker-ce'
		'docker-ce-cli'
		'containerd.io'
		'docker-buildx-plugin'
		'docker-compose-plugin'
	) -join ' '
	Invoke-Expression -Command "wsl --distribution $DistroName sudo apt-get install -y $dockerPackages"
}


function Add-UserToDockerGroup {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName,

		[Parameter(Mandatory)]
		[string]
		$UserName
	)

	wsl --distribution $DistroName sudo groupadd docker
	wsl --distribution $DistroName sudo usermod -aG docker $UserName
}

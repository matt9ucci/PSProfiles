$wslPath = 'wsl'
$wsl = Get-Command -Name $wslPath -ErrorAction Stop

function Register-WslDistro {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	& $wsl --install $Name
}

function Unregister-WslDistro {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	if ($PSCmdlet.ShouldProcess($Name, 'wsl --unregister')) {
		& $wsl --unregister $Name
	}
}

Register-ArgumentCompleter -ParameterName Name -ScriptBlock {
	$params = @{
		InitializationScript = { $env:WSL_UTF8 = 1 }
		ScriptBlock = {
			foreach ($line in $(& $using:wsl --list --online).Where({ $_ -match '^NAME\s+.+$' }, 'SkipUntil') | Select-Object -Skip 1) {
				$name, $friendlyName = $line -split '\s{4,}'
				[System.Management.Automation.CompletionResult]::new($name, $name, 'Text', $friendlyName)
			}
		}
	}
	Start-Job @params | Receive-Job -Wait -AutoRemoveJob
} -CommandName @(
	'Register-WslDistro'
)


function New-Sudoers {
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

	& $wsl --distribution $DistroName --user root echo $sudoersFileContent `> $sudoersFilePath
}

function Install-DockerOnUbuntu {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	& $wsl --distribution $DistroName --cd $PSScriptRoot ./install_docker.sh
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

	& $wsl --distribution $DistroName sudo groupadd docker
	& $wsl --distribution $DistroName sudo usermod -aG docker $UserName
}

function Enable-DockerRemoteAccess {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	# See https://docs.docker.com/config/daemon/remote-access/
	$systemdUnitFileContent = "# Created with Enable-DockerRemoteAccess
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375`n"
	$systemdUnitDirPath = "/etc/systemd/system/docker.service.d"
	$systemdUnitFilePath = "$systemdUnitDirPath/override.conf"

	& $wsl --distribution $DistroName --user root mkdir -p $systemdUnitDirPath
	& $wsl --distribution $DistroName --user root echo $systemdUnitFileContent `> $systemdUnitFilePath
	& $wsl --distribution $DistroName --user root systemctl daemon-reload
	& $wsl --distribution $DistroName --user root systemctl restart docker.service
}

function Start-WslDistroInBackground {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	& $wsl --distribution $DistroName --exec dbus-launch true
}

function Stop-WslDistro {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	& $wsl --distribution $DistroName --shutdown
}

function Install-Nodejs {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName
	)

	& $wsl --distribution $DistroName --cd $PSScriptRoot ./install_nodejs.sh
}

function Build-DevcontainerImage {
	param (
		[Parameter(Mandatory)]
		[string]
		$DistroName,

		[Parameter(Mandatory)]
		[string]
		$Workspace,

		[Parameter(Mandatory)]
		[string]
		$ImageName
	)

	& $wsl --distribution $DistroName --cd $Workspace --exec bash -i -c "devcontainer build --no-cache --workspace-folder . --image-name $ImageName"
}

function Export-Container {
	param (
		[Parameter(Mandatory)]
		[string]
		$ImageName,

		[Parameter(Mandatory)]
		[string]
		$TarPath
	)

	$containerName = "converting$(Get-Random)"

	docker run --name $containerName $ImageName
	docker export --output $TarPath $containerName
	docker container rm $containerName
}

function Import-WslDistro {
	param (
		[Parameter(Mandatory)]
		[string]
		$TarPath,

		[Parameter(Mandatory)]
		[string]
		$DistroDirectory,

		[string]
		$DockerDistroName = (Get-Item -Path $TarPath).BaseName,

		[Parameter(Mandatory)]
		[string]
		$UserName
	)

	& $wsl --import $DockerDistroName (Join-Path $DistroDirectory $DockerDistroName) $TarPath
	& $wsl --distribution $DockerDistroName echo "[user]`ndefault=$UserName" `>`> /etc/wsl.conf
}

Register-ArgumentCompleter -ParameterName Name -ScriptBlock {
	$params = @{
		InitializationScript = { $env:WSL_UTF8 = 1 }
		ScriptBlock = { & $using:wsl --list --all --quiet }
	}
	Start-Job @params | Receive-Job -Wait -AutoRemoveJob
} -CommandName @(
	'Unregister-WslDistro'
)

Register-ArgumentCompleter -ParameterName DistroName -ScriptBlock {
	$params = @{
		InitializationScript = { $env:WSL_UTF8 = 1 }
		ScriptBlock = { & $using:wsl --list --all --quiet }
	}
	Start-Job @params | Receive-Job -Wait -AutoRemoveJob
} -CommandName @(
	'New-Sudoers'
	'Install-DockerOnUbuntu'
	'Add-UserToDockerGroup'
	'Enable-DockerRemoteAccess'
	'Start-WslDistroInBackground'
	'Stop-WslDistro'
	'Install-Nodejs'
	'Build-DevcontainerImage'
)

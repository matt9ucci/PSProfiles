param (
	[string]
	$Name = (Get-Item $PSCommandPath).BaseName,

	[string]
	$BaseDistroName = 'Ubuntu'
)

ipmo Wsl

($baseDistroTar = Export-WslDistro -Name $BaseDistroName)

# Clean import
Unregister-WslDistro -Name $Name
Import-WslDistro -Name $Name -TarPath $baseDistroTar

wsl --distribution $Name --user $env:WSL_USER --cd $PSScriptRoot ./sh/install_docker_ubuntu.sh
wsl --distribution $Name --user $env:WSL_USER sudo groupadd docker
wsl --distribution $Name --user $env:WSL_USER sudo usermod -aG docker $env:WSL_USER

# Enable Docker remote access
# See https://docs.docker.com/config/daemon/remote-access/
$systemdUnitFileContent = "# Created with $(Get-Item $PSCommandPath)
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375`n"
$systemdUnitDirPath = "/etc/systemd/system/docker.service.d"
$systemdUnitFilePath = "$systemdUnitDirPath/override.conf"
$params = @(
	'mkdir', '-p', $systemdUnitDirPath
	'&&'
	'echo', $systemdUnitFileContent, '>', $systemdUnitFilePath
	'&&'
	'systemctl', 'daemon-reload'
	'&&'
	'systemctl', 'restart', 'docker.service'
)
wsl --distribution $Name --user root @params

# Setup devcontainer tools
wsl --distribution $Name --user $env:WSL_USER --cd $PSScriptRoot ./sh/install_devcontainer_tools_ubuntu.sh

# Setup default user
Set-WslDistroDefaultUser -Name $Name -UserName $env:WSL_USER

# Shutdown to restart
Stop-WslDistro -Name $Name

# Run the distro in background
wsl --distribution $Name --exec dbus-launch true

# Recreate Docker context
docker context rm --force $Name
docker context create $Name --description 'Docker on WSL Ubuntu' --docker 'host=tcp://127.0.0.1:2375'
docker context use $Name

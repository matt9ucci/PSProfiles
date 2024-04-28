ipmo DockerWsl2

$BaseDistroName = 'Ubuntu'
$DockerDistroName = 'DockerOn' + $BaseDistroName
$UserName = 'wsl-user'

Set-Clipboard -Value $UserName

# Clean installation
Unregister-WslDistro -Name $BaseDistroName
Register-WslDistro -Name $BaseDistroName

# Allow `sudo` without password
New-Sudoers -DistroName $BaseDistroName -UserName $UserName

# Setup Docker and user
Install-DockerOnUbuntu -DistroName $BaseDistroName
Add-UserToDockerGroup -DistroName $BaseDistroName -UserName $UserName
Enable-DockerRemoteAccess -DistroName $BaseDistroName

# Create a dir for distro tar files
$distroDirectoryPath = "D:\WslDistro\"
New-Item -Path $distroDirectoryPath -ItemType Directory -Force

# Export tar
$exportedTar = Join-Path $distroDirectoryPath "$DockerDistroName.tar"
wsl --export $BaseDistroName $exportedTar

# Import tar
Unregister-WslDistro -Name $DockerDistroName
wsl --import $DockerDistroName (Join-Path $distroDirectoryPath $DockerDistroName) $exportedTar

# Setup default user
wsl --distribution $DockerDistroName echo "[user]`ndefault=$UserName" `>`> /etc/wsl.conf

# Set the distro as default
wsl --set-default $DockerDistroName

# Shutdown to restart
Stop-WslDistro -DistroName $DockerDistroName

# Run the distro in background
Start-WslDistroInBackground -DistroName $DockerDistroName

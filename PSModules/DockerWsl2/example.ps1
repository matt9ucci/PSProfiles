ipmo DockerWsl2

$BaseDistroName = 'Ubuntu'
$DockerDistroName = 'DockerOn' + $BaseDistroName
$UserName = 'matt'

Install-Distro -DistroName $BaseDistroName

New-Sudoers -UserName $UserName

Install-DockerOnUbuntu -DistroName $BaseDistroName

Add-UserToDockerGroup -DistroName $BaseDistroName -UserName $UserName

$distroDirectoryPath = "D:\Wsl2Distro\"
New-Item -Path $distroDirectoryPath -ItemType Directory -Force

$exportedTar = Join-Path $distroDirectoryPath $BaseDistroName-Docker.tar
wsl --export $BaseDistroName $exportedTar

wsl --import $DockerDistroName (Join-Path $distroDirectoryPath $DockerDistroName) $exportedTar

wsl --distribution $DockerDistroName echo "[user]`ndefault=$UserName" `>`> /etc/wsl.conf

ipmo Wsl

$BaseDistroName = 'Ubuntu'
$DockerDistroName = 'DockerOn' + $BaseDistroName
$UserName = 'wsl-user'

Install-Distro -DistroName $BaseDistroName -Clean

Add-Sudoers -DistroName $BaseDistroName -UserName $UserName

Install-DockerOnUbuntu -DistroName $BaseDistroName

Add-DockerGroupUser -DistroName $BaseDistroName -UserName $UserName

$distroDirectoryPath = "$USERAPPS\Wsl2Distro\"
New-Item -Path $distroDirectoryPath -ItemType Directory -Force

$exportedTar = Join-Path $distroDirectoryPath $BaseDistroName-Docker.tar
wsl --export $BaseDistroName $exportedTar

wsl --import $DockerDistroName (Join-Path $distroDirectoryPath $DockerDistroName) $exportedTar

wsl --distribution $DockerDistroName --user root echo "[user]`ndefault=$UserName" `>`> /etc/wsl.conf

wsl --distribution $DockerDistroName --user root --cd $PSScriptRoot\..\Ubuntu --exec ./add-docker.service.sh
docker context create WSL2Ubuntu --description 'Docker on WSL2 Ubuntu' --docker 'host=tcp://127.0.0.1:2375'
docker context use WSL2Ubuntu

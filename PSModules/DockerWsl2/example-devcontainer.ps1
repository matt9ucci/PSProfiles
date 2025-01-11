ipmo DockerWsl2

$DockerDistroName = 'DockerOnUbuntu'

# Contains `.devcontainer` dir
# $Workspace = "$HOME\github.com\matt9ucci\constructs"
$Workspace = "C:\Users\masa\Repository\github.com\matt9ucci\remote.containers.repositoryConfiguration\Repos\github.com\matt9ucci\constructs"

# The image name is same as the distro name
$ImageName = 'jsii-superchain'
$UserName = 'superchain'

$DistroDirectory = "D:\WslDistro"
$TarPath = Join-Path $DistroDirectory "$ImageName.tar"

# Clean
Unregister-WslDistro -Name $ImageName

Build-DevcontainerImage -DistroName $DockerDistroName -Workspace $Workspace -ImageName $ImageName

Export-Container -ImageName $ImageName -TarPath $TarPath

Import-WslDistro -TarPath $TarPath -DistroDirectory $DistroDirectory -UserName $UserName

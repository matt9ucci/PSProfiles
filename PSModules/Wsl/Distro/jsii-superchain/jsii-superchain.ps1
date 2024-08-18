param (
	[string]
	$Name = (Get-Item $PSCommandPath).BaseName
)

ipmo Wsl

# Build devcontainer image
# devcontainer build --workspace-folder $PSScriptRoot --image-name $Name
devcontainer build --workspace-folder $PSScriptRoot --image-name $Name --no-cache

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
$TarPath = Join-Path $env:WSL_DISTRO_DIRECTORY "$Name.tar"
Export-Container -ImageName $Name -TarPath $TarPath

# Clean import
Unregister-WslDistro -Name $Name
Import-WslDistro -Name $Name -TarPath $TarPath

# Setup default user
Set-WslDistroDefaultUser -Name $Name -UserName 'superchain'

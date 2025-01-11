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

# Add default user to docker group
wsl --distribution $Name --user 'superchain' sudo groupadd docker
wsl --distribution $Name --user 'superchain' sudo usermod -aG docker 'superchain'

# Start docker daemon automatically
$params = @(
	'--distribution', $Name
	'--user', 'root'
	'echo', "[boot]`ncommand = service docker start", '>>', '/etc/wsl.conf'
)
wsl @params

<#
# Initialize localstack container
docker run -d --restart unless-stopped -p 127.0.0.1:4566:4566 -p 127.0.0.1:4510-4559:4510-4559 localstack/localstack
localstack status services
sudo npm install -g aws-cdk-local aws-cdk
cdklocal bootstrap aws://000000000000/us-east-1

# Initialize and deploy sample cdk app
mkdir sample-app && cd sample-app && npx cdk init sample-app --language typescript
cdklocal deploy --require-approval never
#>

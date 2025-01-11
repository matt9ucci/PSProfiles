param (
	[Parameter(Mandatory)]
	[string]
	$Version
)

$param = @{
	Uri = "https://github.com/docker/app/releases/download/$Version/docker-app-windows.tar.gz"
	OutFile = "docker-app.tar.gz"
	Verbose = $true
}
Invoke-WebRequest @param

tar -xvf docker-app.tar.gz docker-app-plugin-windows.exe

New-Item -Path $HOME/.docker/cli-plugins -ItemType Directory -Force
Move-Item docker-app-plugin-windows.exe $HOME/.docker/cli-plugins/docker-app.exe

Write-Host @"
Check your config.json ($HOME\.docker\config.json):

{
	"experimental": "enabled"
}
"@ -ForegroundColor Yellow

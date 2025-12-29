<#
.LINK
	https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?tabs=visual-studio-code
#>
param (
	[string]
	$Name = 'HelloDotnetWebApi'
)

dotnet dev-certs https --trust
dotnet new webapi --output $Name
dotnet build HelloDotnetWebApi

Write-Host 'After the api started, run the below command on another terminal:' -ForegroundColor Green
Write-Host 'saps https://localhost:5001/WeatherForecast' -ForegroundColor Green
dotnet (Resolve-Path "$Name/bin/Debug/*/$Name.dll").Path

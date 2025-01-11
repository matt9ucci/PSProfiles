<#
.LINK
	https://docs.microsoft.com/en-us/aspnet/core/blazor/tutorials
#>
param (
	[string]
	$Name = 'HelloBlazorWasm',

	[switch]
	$Pwa
)

try {
	$sdkVersion = [version](dotnet --version)
} catch {
	# preview or others
}

if ([version]$sdkVersion -lt [version]'3.1.300') {
	throw [System.Management.Automation.PSNotSupportedException]::new("Not supported SDK: $sdkVersion . See https://devblogs.microsoft.com/aspnet/blazor-webassembly-3-2-0-now-available/")
}

$params = @(
	'--output', $Name
	if ($Pwa) { '--pwa' }
)

dotnet new blazorwasm @params

dotnet run --project $Name

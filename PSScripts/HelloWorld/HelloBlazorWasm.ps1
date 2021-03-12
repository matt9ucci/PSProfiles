<#
.LINK
	https://docs.microsoft.com/en-us/aspnet/core/blazor/get-started
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
	throw "Not supported SDK: $sdkVersion . See https://devblogs.microsoft.com/aspnet/blazor-webassembly-3-2-0-now-available/"
}

# For information about these options, run `dotnet new blazorwasm --help`
if ($Pwa) {
	dotnet new blazorwasm --output $Name --pwa
} else {
	dotnet new blazorwasm --output $Name
}

dotnet run --project $Name

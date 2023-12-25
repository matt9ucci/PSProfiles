<#
.LINK
	https://learn.microsoft.com/en-us/dotnet/core/get-started
#>
param (
	[string]
	$Name = 'HelloDotnetConsole'
)

dotnet new console --output $Name
dotnet run --project $Name

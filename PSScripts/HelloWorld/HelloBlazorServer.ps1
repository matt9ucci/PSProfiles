<#
.LINK
	Blazor Server https://docs.microsoft.com/en-us/aspnet/core/blazor/hosting-models#blazor-server
	Use ASP.NET Core SignalR with Blazor https://docs.microsoft.com/en-us/aspnet/core/tutorials/signalr-blazor?pivots=server&tabs=visual-studio-code
#>
param (
	[string]
	$Name = 'HelloBlazorServer'
)

# For information about these options, run `dotnet new blazorserver --help`
dotnet new blazorserver --output $Name --no-https

dotnet run --project $Name

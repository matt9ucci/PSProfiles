param (
	[Parameter(Mandatory)]
	[string]
	$Name
)

New-LicenseFile mit -Commit
New-ReadmeFile

New-VscodeWorkspaceSettingsJson
Set-Content -Path .vscode\extensions.json -Value @"
{
	"recommendations": [
		"ms-dotnettools.csharp",
		"ms-vscode.powershell",
	],
}
"@

dotnet new sln

dotnet new classlib --name $Name
dotnet sln add $Name
New-Item -Path (Join-Path $Name src) -ItemType Directory

dotnet new xunit -o "$Name.Test"
dotnet sln add "$Name.Test"
dotnet add "$Name.Test" reference $Name
New-Item -Path (Join-Path "$Name.Test" Pester) -ItemType Directory
New-Item -Path (Join-Path "$Name.Test" Data) -ItemType Directory
New-Item -Path (Join-Path "$Name.Test" Data.Web) -ItemType Directory

dotnet new globaljson --roll-forward latestFeature
dotnet new editorconfig

Set-Content -Path .gitignore -Value @"
bin/
obj/

Data.Web/
"@

Set-Content -Path PSScriptAnalyzerSettings.psd1 -Value @"
@{
	ExcludeRules = @(
		'PSUseShouldProcessForStateChangingFunctions'
	)

	Rules = @{
		'PSAvoidUsingCmdletAliases' = @{
			'allowlist' = @(
				'?' # Where-Object
				'%' # ForEach-Object
			)
		}
	}
}
"@

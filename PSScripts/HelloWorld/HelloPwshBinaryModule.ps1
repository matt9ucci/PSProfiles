<#
.LINK
	https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-binary-module
#>
param (
	[string]
	$Path = 'HelloPwshBinaryModule'
)

$name = Split-Path $Path -Leaf

dotnet new classlib --output $Path

pushd $Path

dotnet new globaljson
dotnet new gitignore

mkdir .vscode
Set-Content .vscode/settings.json @"
{
	"editor.detectIndentation": false,
	"editor.tabSize": 4
}
"@

Set-Content HelloCmdlet.cs @"
using System;
using System.Management.Automation;

namespace $name
{
	[Cmdlet(VerbsCommunications.Write, "Hello")]
	public class HelloCmdlet : Cmdlet
	{
		protected override void ProcessRecord()
		{
			Console.WriteLine("Hello, PowerShell Binary Module!");
		}
	}
}
"@

dotnet add package PowerShellStandard.Library
dotnet build

$params = @{
	Path = "$name.psd1"
	RootModule = (gci .\bin\Debug\*\* HelloPwshBinaryModule.dll).FullName | Resolve-Path -Relative
}
New-ModuleManifest @params

ipmo (Join-Path . $params.Path)
Write-Hello

popd

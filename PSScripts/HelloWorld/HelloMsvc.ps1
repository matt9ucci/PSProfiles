<#
.LINK
	Microsoft C++ Build Tools https://visualstudio.microsoft.com/visual-cpp-build-tools/
	Use the Microsoft C++ toolset from the command line https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=vs-2019
#>
param (
	[string]
	$Path = 'HelloMSVC'
)

New-Item $Path -ItemType Directory

Push-Location $Path

Add-Content -Path hello.c -Value @'
#include <stdio.h>

int main()
{
	printf("Hello, MSVC! (Microsoft C++ Build Tools)\n");
	return 0;
}
'@

$commandFile = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
cmd /c """$commandFile"" & cl hello.c"
.\hello.exe

Pop-Location

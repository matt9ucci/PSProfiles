<#
.LINK
	Using GCC with MinGW https://code.visualstudio.com/docs/cpp/config-mingw
#>
param (
	[string]
	$Path = 'HelloMinGW'
)

New-Item $Path -ItemType Directory

Push-Location $Path

Add-Content -Path hello.c -Value @'
#include <stdio.h>

int main()
{
	printf("Hello, MinGW!\n");
	return 0;
}
'@

gcc hello.c -o hello.exe
.\hello.exe

Pop-Location

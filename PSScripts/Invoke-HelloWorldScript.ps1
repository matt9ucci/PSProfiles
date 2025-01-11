param (
	[ArgumentCompleter({
		param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
		Join-Path $PSScriptRoot HelloWorld | gci | ? BaseName -like "$WordToComplete*" | % BaseName | sort
	})]
	[Parameter(Mandatory)]
	[string]
	$Name,

	[string[]]
	$Parameters
)

if ($Parameters) {
	& (gci -Path (Join-Path $PSScriptRoot HelloWorld) -Filter "$Name.*") @Parameters
} else {
	& (gci -Path (Join-Path $PSScriptRoot HelloWorld) -Filter "$Name.*")
}

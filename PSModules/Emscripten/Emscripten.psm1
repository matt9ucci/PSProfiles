function Install-Emsdk {
	[CmdletBinding()]
	param (
		[string]
		$Version = 'latest',

		[string]
		$Path = (Join-Path (Get-Location) emsdk),

		[switch]
		$Force
	)

	if ($Force -or $PSCmdlet.ShouldContinue("Version: $Version", "Install Emscripten SDK under $Path")) {
		git clone --depth 1 https://github.com/emscripten-core/emsdk.git $Path
		$emsdk = Join-Path $Path emsdk.ps1
		& $emsdk install $Version
		& $emsdk activate $Version
	}
}

<#
.LINK
	https://scoop.sh/
#>

if (!(Get-Command scoop -ErrorAction Ignore)) {
	Write-Error 'Scoop command not found. Invoke the following command to install it: { iwr get.scoop.sh | iex }'
}

pwsh -nop -c @'
@(
	'7zip'
	'cmake'
	'gcc'
	'git'
	'llvm'
	'vlc'
	'wasmtime'
) | % { scoop install $_ }

if ((scoop bucket list) -notcontains 'extra') {
	scoop bucket add extras
}

@(
	'sysinternals'
	'wabt'
) | % { scoop install $_ }
'@

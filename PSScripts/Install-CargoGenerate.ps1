param (
	[string]
	$Version
)

if (!$Version) {
	$Version = (Invoke-RestMethod 'https://api.github.com/repos/ashleygwilliams/cargo-generate/releases/latest').tag_name
}

if ($IsWindows) {
	$uri = "https://github.com/ashleygwilliams/cargo-generate/releases/download/${Version}/cargo-generate-${Version}-x86_64-pc-windows-msvc.tar.gz"
	$binName = 'cargo-generate.exe'
} elseif ($IsLinux) {
	$uri = "https://github.com/ashleygwilliams/cargo-generate/releases/download/${Version}/cargo-generate-${Version}-x86_64-unknown-linux-musl.tar.gz"
	$binName = 'cargo-generate'
} else {
	throw 'Not Windows or Linux'
}

$params = @{
	Uri = $uri
	OutFile = Split-Path $uri -Leaf
	Verbose = $true
}
Invoke-WebRequest @params

tar -x -f $params.OutFile --strip=1 "*/$binName"

Move-Item $binName $HOME/.cargo/bin

Remove-Item $params.OutFile

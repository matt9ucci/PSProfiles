param (
	[string]
	$Version
)

if (!$Version) {
	$Version = (Invoke-RestMethod 'https://api.github.com/repos/WebAssembly/binaryen/releases/latest').tag_name
}

if ($IsWindows) {
	$uri = "https://github.com/WebAssembly/binaryen/releases/download/${Version}/binaryen-${Version}-x86_64-windows.tar.gz"
	$binName = 'cargo-generate.exe'
} else {
	throw 'Not Windows'
}

$params = @{
	Uri = $uri
	OutFile = Split-Path $uri -Leaf
	Verbose = $true
}
Invoke-WebRequest @params

tar -x -f $params.OutFile

Move-Item "binaryen-$Version" $USERAPPS\Binaryen
New-Item -Path $USERAPPS\bin\Binaryen -Value $USERAPPS\Binaryen\bin -ItemType Junction

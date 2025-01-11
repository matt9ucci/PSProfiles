param (
	[version]
	$Version,

	[string]
	$Path = (Join-Path $HOME Apps Wabt)
)

if (!$Version) {
	$Version = (Invoke-RestMethod 'https://api.github.com/repos/WebAssembly/wabt/releases/latest').tag_name
}

$os = if ($IsLinux) {
	'ubuntu'
} elseif ($IsMacOS) {
	'macos'
} else {
	'windows'
}

$uri = 'https://github.com/WebAssembly/wabt/releases/download/{0}/wabt-{0}-{1}.tar.gz' -f $Version, $os

$params = @{
	Uri = $uri
	OutFile = Split-Path $uri -Leaf
	Verbose = $true
}
Invoke-WebRequest @params

$expectedHash = ((Invoke-RestMethod ($uri + '.sha256')) -split ' ')[0]
$hash = Get-FileHash $params.OutFile -Algorithm SHA256
if ($expectedHash -ine $hash.Hash) {
	throw ('Invalid hash [{0}]: expected hash [{1}]' -f $hash.Hash, $expectedHash)
}

tar -x -f $params.OutFile
Move-Item "wabt-$Version" $USERAPPS\Wabt
New-Item -Path $USERAPPS\bin\Wabt -Value $USERAPPS\Wabt\bin -ItemType Junction

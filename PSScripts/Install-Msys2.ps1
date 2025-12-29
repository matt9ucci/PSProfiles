Get-Command 7z, tar -ea Stop

[uri]$uri = 'https://github.com/msys2/msys2-installer/releases/download/2023-07-18/msys2-base-x86_64-20230718.tar.xz'

$params = @{
	Uri     = $uri
	OutFile = $uri.Segments[-1]
	Verbose = $true
}

try {
	Invoke-WebRequest @params
} catch {
	$statusCode = $_.Exception.Response.StatusCode
	Write-Error ("{0} {1} {2} : {3}" -f @($statusCode.value__, $statusCode, $uri, $_.Exception.Message))
	return
}

$sha256 = (Get-FileHash $params.OutFile SHA256).Hash
$sha256expected = ((Invoke-RestMethod "$uri.sha256") -split '\s{2}')[0]
if ($sha256 -ine $sha256expected) {
	throw "$sha256 is not expected: $sha256expected"
}

7z x $params.OutFile
tar -x -f (Get-Item $params.OutFile).BaseName

$dirName = ($uri | Select-String '\d{8}').Matches[0].Value.Substring(2)
New-Item $USERAPPS\MSYS2 -ItemType Directory -Force
Move-Item msys64 $USERAPPS\MSYS2\$dirName

New-Junction -Path $USERAPPS\MSYS2 -Name current -Value $USERAPPS\MSYS2\$dirName

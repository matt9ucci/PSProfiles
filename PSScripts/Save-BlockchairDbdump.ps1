param (
	$Blokchain = 'bitcoin',
	$Date = (Get-Date).AddDays(-1)
)

$yyyyMMdd = $Date.ToString('yyyyMMdd')
$uri = "https://gz.blockchair.com/${Blokchain}/transactions/blockchair_${Blokchain}_transactions_${yyyyMMdd}.tsv.gz"

$TempPath = Join-Path $PROFILEDIR Temp
if (!(Test-Path $TempPath)) {
	New-Directory $TempPath
}

Invoke-WebRequest $uri -OutFile (Join-Path $TempPath (Split-Path $uri -Leaf)) -Verbose

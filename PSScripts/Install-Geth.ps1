ipmo $HOME\github.com\GethUtility\GethUtility -Force
$blob = Get-GethDownloadList | ? Name -Match 'geth-alltools-windows-amd64-1.8.21-\w*?.zip$'
$uri = 'https://gethstore.blob.core.windows.net/builds/{0}' -f $blob.Name
$outFile = "$DOWNLOADS\$($blob.Name)"
Invoke-WebRequest $uri -OutFile $outFile -Verbose

$old = "$USERAPPS\Geth"
Rename-Item -Path $old -NewName "$old-$(Get-Date -Format yyyyMMddHHmmss)" -ErrorAction SilentlyContinue

$root = (Expand-Archive -Path $outFile -DestinationPath $USERAPPS -PassThru | ? PSIsContainer)[0]

$new = "$USERAPPS\Geth"
Rename-Item -Path $root.FullName -NewName $new

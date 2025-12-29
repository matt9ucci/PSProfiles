function Install-GoIpfs {
	param (
		[Alias('Tag')]
		$Version
	)

	if ($Version) {
		$uri = 'https://api.github.com/repos/ipfs/go-ipfs/releases/tags/{0}' -f $Version
	} else {
		$uri = 'https://api.github.com/repos/ipfs/go-ipfs/releases/latest'
	}

	$assets = (Invoke-RestMethod $uri -Verbose).assets
	if (!(Get-Variable IsWindows -ErrorAction Ignore) -or $IsWindows) {
		$assets = $assets | ? name -Like "*_windows-*"
	}

	Write-Host 'Select a number for download'
	for ($i = 0; $i -lt $assets.Count; $i++) {
		Write-Host ('{0}) {1}' -f $i, $assets[$i].name)
	}
	$n = Read-Host 'Download'
	$browserDownloadUrl = $assets[$n].browser_download_url

	$outFile = New-TemporaryFile
	Invoke-WebRequest $browserDownloadUrl -OutFile $outFile -Verbose
	Rename-Item $USERAPPS\GoIpfs $USERAPPS\GoIpfs-$(Get-Date -Format yyMMddHHmmss) -Verbose
	Expand-Archive $outFile $USERAPPS\GoIpfs -Verbose
	Remove-Item $outFile
}

if (!(Get-Command -Name ipfs -ErrorAction Ignore)) {
	Write-Warning 'ipfs binary must be in $env:Path'
	return
}

[string[]]$cmds = ipfs commands
[string[]]$flgs = ipfs commands --flags | ForEach-Object {
	if ($_ -notin $cmds) {
		$_ -split ' / '
	}
}

[scriptblock]$completer = {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	# replace 'ipfs.exe' and aliases with 'ipfs'
	$astString = "$commandAst" -replace '^\S+', 'ipfs'
	$astStringElements = $astString -split ' '

	$candidates = if ($wordToComplete.StartsWith('-')) { $flgs } else { $cmds }
	$candidates | Where-Object { $_ -match "$astString.+" } | ForEach-Object {
		$words = $_ -split ' '
		for ($i = 0; $i -lt $words.Count; $i++) {
			if (($words[$i] -ne $astStringElements[$i]) -and ($words[$i] -like "$wordToComplete*")) {
				New-Object System.Management.Automation.CompletionResult $words[$i]
				break
			}
		}
	} | Sort-Object CompletionText -Unique
}

'ipfs', (Get-Alias -Definition 'ipfs' -ErrorAction Ignore).Name | ForEach-Object {
	if ($_) { Register-ArgumentCompleter -Native -CommandName $_ -ScriptBlock $completer }
}

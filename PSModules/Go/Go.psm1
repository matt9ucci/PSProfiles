if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
	$PSDefaultParameterValues['Invoke-RestMethod:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-RestMethod:ProxyCredential'] = $proxyCredential
}

$env:GOROOTROOT = if ($IsWindows) { 'C:\Go' } else { '/usr/local/go' }
$env:GOROOT = if ($env:GOROOT) {
	$env:GOROOT
} else {
	(Get-ChildItem $env:GOROOTROOT | Sort-Object @{ Expression = { $_.Name -as [version] } } -Bottom 1).FullName
}

$goenv = & "$env:GOROOT\bin\go" env -json | ConvertFrom-Json -AsHashtable
$env:GOPATH = $goenv.GOPATH

$env:Path = @(
	"$env:GOPATH\bin"
	"$env:GOROOT\bin"
	$env:Path
) -join [System.IO.Path]::PathSeparator

Register-ArgumentCompleter -CommandName go -Native -ScriptBlock {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	if ("$commandAst" -eq 'go' -or "$commandAst".StartsWith('go help') -or ("$commandAst" -notmatch 'go \w*\s' -and $wordToComplete -ne '')) {
		function COMPGEN($txt, $tip) {
			New-Object System.Management.Automation.CompletionResult $txt, $txt, 'Command', $tip
		}
		$comps = @(
			COMPGEN 'bug'      'start a bug report'
			COMPGEN 'build'    'compile packages and dependencies'
			COMPGEN 'clean'    'remove object files and cached files'
			COMPGEN 'doc'      'show documentation for package or symbol'
			COMPGEN 'env'      'print Go environment information'
			COMPGEN 'fix'      'update packages to use new APIs'
			COMPGEN 'fmt'      'gofmt (reformat) package sources'
			COMPGEN 'generate' 'generate Go files by processing source'
			COMPGEN 'get'      'download and install packages and dependencies'
			COMPGEN 'help'     'show help'
			COMPGEN 'install'  'compile and install packages and dependencies'
			COMPGEN 'list'     'list packages or modules'
			COMPGEN 'mod'      'module maintenance'
			COMPGEN 'run'      'compile and run Go program'
			COMPGEN 'test'     'test packages'
			COMPGEN 'tool'     'run specified go tool'
			COMPGEN 'version'  'print Go version'
			COMPGEN 'vet'      'report likely mistakes in packages'
		)
		if ("$commandAst".StartsWith('go help')) {
			$comps += @(
				COMPGEN 'buildmode'   'build modes'
				COMPGEN 'c'           'calling between Go and C'
				COMPGEN 'cache'       'build and test caching'
				COMPGEN 'environment' 'environment variables'
				COMPGEN 'filetype'    'file types'
				COMPGEN 'go.mod'      'the go.mod file'
				COMPGEN 'gopath'      'GOPATH environment variable'
				COMPGEN 'gopath-get'  'legacy GOPATH go get'
				COMPGEN 'goproxy'     'module proxy protocol'
				COMPGEN 'importpath'  'import path syntax'
				COMPGEN 'modules'     'modules, module versions, and more'
				COMPGEN 'module-get'  'module-aware go get'
				COMPGEN 'packages'    'package lists and patterns'
				COMPGEN 'testflag'    'testing flags'
				COMPGEN 'testfunc'    'testing functions'
			)
		}

		$comps | ? CompletionText -Like "$wordToComplete*"
	}
}

<#
.LINK
	Workspaces https://golang.org/doc/code.html#Workspaces
#>
function New-Gopath {
	$gopath = go env GOPATH
	New-Item @(
		"$gopath"
		"$gopath\src"
		"$gopath\bin"
	) -ItemType Directory -Force
}

function Backup-Gopath {
	param (
		[string]$Suffix = (Get-Date -Format 'yyMMddHHmmss')
	)
	$gopath = go env GOPATH
	Rename-Item $gopath $gopath-$Suffix
}

function Save-GoBinary {
	param (
		[Parameter(Mandatory)]
		[version]
		$Version,

		[ValidateSet('darwin', 'linux', 'windows')]
		[string]
		$Os = 'windows',
		
		[ValidateSet('amd64', '386')]
		[string]
		$Architecture = 'amd64'
	)

	$extension = switch ($Os) {
		darwin { 'pkg' }
		linux { 'tar.gz' }
		windows { 'zip' }
	}

	$uri = "https://dl.google.com/go/go$Version.$Os-$Architecture.$extension"
	$outFile = Join-Path $DOWNLOADS (Split-Path $uri -Leaf)
	Invoke-WebRequest $uri -OutFile $outFile -Verbose
	Get-FileHash $outFile -Algorithm SHA256
}

function Uninstall-Go {
	[CmdletBinding(SupportsShouldProcess)]
	param()

	if (!$env:GOROOTROOT) {
		Write-Error '$env:GOROOTROOT is required.'
		return
	}

	$versions = Get-ChildItem $env:GOROOTROOT

	Write-Host 'Select a number for uninstall'
	for ($i = 0; $i -lt $versions.Count; $i++) {
		Write-Host ('{0}) {1}' -f $i, $versions[$i].Name)
	}
	$n = Read-Host 'Uninstall'

	if ($PSCmdlet.ShouldProcess($versions[$n])) {
		Remove-Item $versions[$n] -Recurse -Force -Confirm:$false
	}
}

sv USERAPPS (Join-Path $HOME Apps) -Option ReadOnly, AllScope
sv DESKTOP ([Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)) -Option ReadOnly, AllScope
sv DOWNLOADS (Join-Path $HOME Downloads) -Option ReadOnly, AllScope
sv PROFILEDIR (Split-Path $PROFILE) -Option ReadOnly, AllScope
Add-Member -InputObject $PROFILEDIR -Name Private -Value "$HOME\.psprofiles" -MemberType NoteProperty
sv SCRIPTS (Join-Path $HOME Scripts) -Option ReadOnly, AllScope

sal gh help
sal gcb Get-Clipboard
sal scb Set-Clipboard
sal FromJson ConvertFrom-Json
sal ToJson ConvertTo-Json

sal c code
sal d docker
sal dc docker-compose
sal dm docker-machine
sal g git

sal .n dotnet
function .nh { dotnet help @Args }
function .nr { dotnet run @Args }

function gho { Get-Help @Args -Online }
function la { gci @Args -Force }
function ll { gci @Args | ? Name -NotLike .* }
function more { $input | Out-Host -Paging }
function sl.. { sl .. }
function sl... { sl ../.. }
function sl.... { sl ../../.. }

function c. { code . }
function codes { code $SCRIPTS }
if (!$IsLinux -and !$IsMacOS -and !(gcm Set-Clipboard -ErrorAction Ignore)) {
	function Set-Clipboard { param ([Parameter(Mandatory, ValueFromPipeline)][string]$Value) $Value | clip.exe }
}
function cssh {
	param (
		[string]
		$Name = 'default',

		[Parameter(HelpMessage = 'e.g. /home/me or home/me')]
		[string]
		$Path = 'home'
	)

	code --folder-uri "vscode-remote://ssh-remote+$Name/$Path"
}

function nop { pwsh -nop -c ($Args -join ' ') }

function Update-Profile { pushd $PROFILEDIR; git pull --rebase; popd }

Set-PSReadlineOption -BellStyle None

if ($IsLinux) {
	Set-PSReadlineKeyHandler -Chord Tab -Function TabCompleteNext
}

$env:PSModulePath = @(
	(Join-Path $PROFILEDIR PSModules)
	$env:PSModulePath
) -join [System.IO.Path]::PathSeparator

$env:Path = @(
	$SCRIPTS
	"$PSScriptRoot\PSScripts"
	$env:Path
) -join [System.IO.Path]::PathSeparator

ipmo Core
ipmo DockerCompletion

function Use-Sed { Add-PathEnvValue "$HOME\scoop\apps\git\current\usr\bin" }

. $PSScriptRoot\Completers.ps1

if ([System.Net.ServicePointManager]::SecurityProtocol -ne [System.Net.SecurityProtocolType]::SystemDefault) {
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
}

$PSDefaultParameterValues['Import-Module:Force'] = $true

if ($PSVersionTable.PSVersion.Major -le 5) {
	function prompt {
		$Host.UI.RawUI.WindowTitle = "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))"
		return "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)> "
	}
} else {
	function prompt {
		"`e[34;1m`e[47m `e[0m`e[44;1m $($ExecutionContext.SessionState.Path.CurrentLocation) `e[0m`n$('$' * ($NestedPromptLevel + 1)) "
	}
}

if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	if ($PSVersionTable.PSVersion.Major -le 6) {
		$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
		$PSDefaultParameterValues['Invoke-RestMethod:Proxy'] = $proxy
	}
	$PSDefaultParameterValues['Install-Module:Proxy'] = $proxy
	$PSDefaultParameterValues['Register-PackageSource:Proxy'] = $proxy
	$PSDefaultParameterValues['Register-PSRepository:Proxy'] = $proxy
	$PSDefaultParameterValues['Save-Module:Proxy'] = $proxy
	$PSDefaultParameterValues['Save-Package:Proxy'] = $proxy
	$PSDefaultParameterValues['Install-AWSToolsModule:Proxy'] = $proxy
	$PSDefaultParameterValues['Update-AWSToolsModule:Proxy'] = $proxy

	[System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy $proxy

	if ($proxyCredential) {
		if ($PSVersionTable.PSVersion.Major -le 6) {
			$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
			$PSDefaultParameterValues['Invoke-RestMethod:ProxyCredential'] = $proxyCredential
		}
		$PSDefaultParameterValues['Install-Module:ProxyCredential'] = $proxyCredential
		$PSDefaultParameterValues['Register-PackageSource:ProxyCredential'] = $proxyCredential
		$PSDefaultParameterValues['Register-PSRepository:ProxyCredential'] = $proxyCredential
		$PSDefaultParameterValues['Save-Module:ProxyCredential'] = $proxyCredential
		$PSDefaultParameterValues['Save-Package:ProxyCredential'] = $proxyCredential
		$PSDefaultParameterValues['Install-AWSToolsModule:ProxyCredential'] = $proxyCredential
		$PSDefaultParameterValues['Update-AWSToolsModule:ProxyCredential'] = $proxyCredential

		[System.Net.WebRequest]::DefaultWebProxy.Credentials = $proxyCredential

		$httpProxyEnv = @(
			$proxyCredential.GetNetworkCredential().UserName
			$proxyCredential.GetNetworkCredential().Password
			$proxy.Authority
		)
		$env:http_proxy = 'http://{0}:{1}@{2}' -f $httpProxyEnv
		$env:https_proxy = 'https://{0}:{1}@{2}' -f $httpProxyEnv
	} else {
		$env:http_proxy = 'http://{0}' -f $proxy.Authority
		$env:https_proxy = 'https://{0}' -f $proxy.Authority
	}

	Remove-Variable pwshProxy, proxy, proxyCredential, httpProxyEnv -ErrorAction Ignore
}

if (Test-Path "$($PROFILEDIR.Private)\profile.ps1") {
	function codep { code $PROFILEDIR $PROFILE.CurrentUserAllHosts "$($PROFILEDIR.Private)\profile.ps1" }
	. $HOME\.psprofiles\profile.ps1
} else {
	function codep { code $PROFILEDIR $PROFILE.CurrentUserAllHosts }
}

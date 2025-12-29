sv USERAPPS (Join-Path $HOME Apps) -Option ReadOnly, AllScope
sv USERCOMMANDS (Join-Path $HOME Commands) -Option ReadOnly, AllScope
sv DESKTOP ([Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)) -Option ReadOnly, AllScope
sv DOWNLOADS (Join-Path $HOME Downloads) -Option ReadOnly, AllScope
sv PROFILEDIR (Split-Path $PROFILE) -Option ReadOnly, AllScope
Add-Member -InputObject $PROFILEDIR -Name Private -Value "$HOME\.psprofiles" -MemberType NoteProperty
sv SCRIPTS (Join-Path $HOME Scripts) -Option ReadOnly, AllScope

sal gcb Get-Clipboard
sal scb Set-Clipboard
sal FromJson ConvertFrom-Json
sal ToJson ConvertTo-Json
sal FromZip Expand-Archive
sal ToZip Compress-Archive

sal c code
sal d docker
sal dc docker-compose
sal g git
sal s syntax

sal .n dotnet
function .nb { dotnet build @Args }
function .nr { dotnet run @Args }
function .nt { dotnet test @Args }

function helpo { Get-Help @Args -Online }
function l { gci @Args | Format-Wide Name -AutoSize }
function la { gci @Args -Force | Format-Wide Name -AutoSize }
function ll { gci @Args | ? Name -NotLike .* }
function lla { gci @Args -Force }
function more { $input | Out-Host -Paging }
function .. { sl .. }
function ... { sl ../.. }
function .... { sl ../../.. }

function c. { code . }
function codes { code $SCRIPTS }

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

function cwsl {
	param (
		[string]
		$Name = 'default',

		[Parameter(HelpMessage = 'e.g. /home/me')]
		[string]
		$Path
	)

	code --remote "wsl+$Name" $Path
}
Register-ArgumentCompleter -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)

	$tmp, $env:WSL_UTF8 = $env:WSL_UTF8, 1

	wsl --list --quiet | ? { $_ -like "$wordToComplete*" }

	$env:WSL_UTF8 = $tmp
} -CommandName @(
	'cwsl'
)

function nop { pwsh -nop -c ($Args -join ' ') }

function Update-Profile { pushd $PROFILEDIR; git pull --rebase; popd }

Set-PSReadlineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PSReadLineKeyHandler -Key Ctrl+R -Function ForwardSearchHistory

if ($IsLinux) {
	Set-PSReadlineKeyHandler -Chord Tab -Function TabCompleteNext
	Set-PSReadlineKeyHandler -Chord Shift+Tab -Function TabCompletePrevious
}

$env:PSModulePath = @(
	(Join-Path $PROFILEDIR PSModules)
	$env:PSModulePath
) -join [System.IO.Path]::PathSeparator

ipmo Core

$env:Path = @(
	$SCRIPTS
	"$PSScriptRoot\PSScripts"
	if ($IsWindows) {
		$USERCOMMANDS
		(Get-ChildItem $USERCOMMANDS -Directory)
	}
	$env:Path
) -join [System.IO.Path]::PathSeparator

$env:DOTNET_CLI_UI_LANGUAGE = 'en'
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Use-Sed { Add-PathEnv "$HOME\scoop\apps\git\current\usr\bin" }

function google {
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param (
		[Parameter(Position=0, ValueFromRemainingArguments)]
		$Query,

		[ValidateSet('en', 'ja', 'ko')]
		$Lang,

		[switch]
		$Edge
	)

	$uri = 'https://www.google.com/search?q={0}&lr=lang_{1}' -f ($Query -join '+'), $Lang
	if ($Edge) {
		$uri = 'microsoft-edge:' + $uri
	}

	Start-Process -FilePath $uri
}

. $PSScriptRoot\Completers.ps1

if ([System.Net.ServicePointManager]::SecurityProtocol -ne [System.Net.SecurityProtocolType]::SystemDefault) {
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
}

$PSDefaultParameterValues['Import-Module:Force'] = $true
$PSDefaultParameterValues['Trace-Command:PSHost'] = $true

function prompt {
	return "`u{1F4BB} PS-$($PSVersionTable.PSVersion.ToString()) $(Get-Date -Format 'yy-MM-ddTHH:mm:ssK') $([System.Environment]::UserName)@$($env:WSL_DISTRO_NAME ?? [System.Environment]::MachineName) $($PSStyle.FileInfo.Directory)$($ExecutionContext.SessionState.Path.CurrentLocation)$($PSStyle.Reset)`n$('$' * ($NestedPromptLevel + 1)) "
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

		Remove-Variable proxyCredential, httpProxyEnv
	} else {
		$env:http_proxy = 'http://{0}' -f $proxy.Authority
		$env:https_proxy = 'https://{0}' -f $proxy.Authority
	}

	Remove-Variable pwshProxy, proxy
}

if (Test-Path $PROFILEDIR.Private) {
	function codep {
		$params = @(
			$PROFILEDIR
			$PROFILE.CurrentUserAllHosts
			(Get-ChildItem $PROFILEDIR.Private -File)
		)
		code @params
	}
	. "$($PROFILEDIR.Private)\profile.ps1"
} else {
	function codep { code $PROFILEDIR $PROFILE.CurrentUserAllHosts }
}

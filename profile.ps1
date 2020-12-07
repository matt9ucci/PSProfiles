sv APPS (Join-Path $HOME Apps) -Option ReadOnly, AllScope
sv DESKTOP ([Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)) -Option ReadOnly, AllScope
sv DOWNLOADS (Join-Path $HOME Downloads) -Option ReadOnly, AllScope
sv PROFILEDIR (Split-Path $PROFILE) -Option ReadOnly, AllScope
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

function gho { Get-Help @Args -Online }
function ll { gci @Args | ? Name -NotLike .* }
function sl.. { sl .. }
function sl~ { sl ~ }
function Get-FileHash { $fh = Microsoft.PowerShell.Utility\Get-FileHash @Args; Set-Clipboard $fh.hash; $fh }
function c. { code . }
function codep { code $PROFILEDIR $PROFILE.CurrentUserAllHosts }
function codes { code $SCRIPTS }

$env:PSModulePath = -join ((Join-Path $PROFILEDIR PSModules), [System.IO.Path]::PathSeparator, $env:PSModulePath)

$env:Path = @(
	$SCRIPTS
	"$HOME\Apps\Git\cmd"
	"$HOME\Apps\VSCode\bin"
	$env:Path
) -join ";"

ipmo DockerCompletion -ea SilentlyContinue
ipmo DockerComposeCompletion -ea SilentlyContinue
ipmo DockerMachineCompletion -ea SilentlyContinue

if ([System.Net.ServicePointManager]::SecurityProtocol -ne [System.Net.SecurityProtocolType]::SystemDefault) {
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
}

$PSDefaultParameterValues['Import-Module:Force'] = $true

function prompt {
	$Host.UI.RawUI.WindowTitle = "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))"
	return "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)> "
}

if (Test-Path $HOME\.psprofiles\profile.ps1) {
	function codep { code $PROFILEDIR $PROFILE.CurrentUserAllHosts $HOME\.psprofiles\profile.ps1 }
	. $HOME\.psprofiles\profile.ps1
}

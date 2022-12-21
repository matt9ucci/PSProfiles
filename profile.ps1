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
sal s syntax

sal .n dotnet
function .nr { dotnet run @Args }

function gho { Get-Help @Args -Online }
function ll { gci @Args | ? Name -NotLike .* }
function sl.. { sl .. }
function Get-FileHash { $fh = Microsoft.PowerShell.Utility\Get-FileHash @Args; Set-Clipboard $fh.hash; $fh }
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

function Update-Profile { pushd $PROFILEDIR; git pull --rebase; popd }

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

if ($PSVersionTable.PSVersion.Major -le 5) {
function prompt {
	$Host.UI.RawUI.WindowTitle = "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))"
	return "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)> "
	}
} else {
	function prompt {
		"`e[34;1m`e[47m `e[0m`e[48;5;20m $($ExecutionContext.SessionState.Path.CurrentLocation) `e[0m`n$('$' * ($NestedPromptLevel + 1)) "
	}
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

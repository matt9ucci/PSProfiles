# . $PSScriptRoot\Completer.ps1
. $PSScriptRoot\CompleterV2.ps1

# TODO primary -> default name

function New-MultipassOfMyOwn {
	param (
		[string]
		$Name = 'primary',

		[UInt16]
		$Cpu = 2,

		[UInt64]
		$Disk = 16GB,

		[string]
		$UserDataPath = "$PSScriptRoot/user-data.yaml"
	)

	$param = @(
		'--name', $Name
		'--cpus', $Cpu
		'--disk', $Disk
		'-vvv'
	)

	if ($UserDataPath) {
		if (Test-Path $UserDataPath -PathType Leaf) {
			$param += '--cloud-init', $UserDataPath
		} else {
			throw "Invalid user-data path: $UserDataPath"
		}
	}

	multipass launch @param
	multipass exec $Name -- pwsh -nop -c 'git clone https://github.com/matt9ucci/PSProfiles.git (Split-Path $PROFILE)'
	multipass exec $Name -- pwsh -nop -c 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted'
	multipass exec $Name -- pwsh -nop -c 'Install-Module DockerCompletion -Scope CurrentUser'
}

function Remove-MultipassInstance {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[string]
		$Name = 'primary',

		[switch]
		$Force
	)

	if ($Force -or $PSCmdlet.ShouldContinue($Name, 'Delete and purge the instance:')) {
		if ($PSCmdlet.ShouldProcess($Name)) {
			multipass delete --purge -vvv $Name
		}
	}
}

function Install-MultipassDocker {
	param (
		[string]
		$Name = 'primary'
	)

	Get-Content $PSScriptRoot\install_docker.sh | multipass transfer - ${Name}:/home/ubuntu/install_docker.sh
	multipass exec $Name -- chmod +x /home/ubuntu/install_docker.sh
	multipass exec $Name -- /home/ubuntu/install_docker.sh
}

function Install-MultipassPowerShell {
	param (
		[string]
		$Name = 'primary'
	)

	Get-Content $PSScriptRoot\install_pwsh.sh | multipass transfer - ${Name}:/home/ubuntu/install_pwsh.sh
	multipass exec $Name -- chmod +x /home/ubuntu/install_pwsh.sh
	multipass exec $Name -- /home/ubuntu/install_pwsh.sh
}

function Get-MultipassInstanceInfo {
	param (
		[string]
		$Name = 'primary'
	)

	(multipass info --format json $Name | Out-String | FromJson).info.$Name
}

<#
.SYNOPSIS
	Start VSCode Remote SSH connecting to Multipass instance
.NOTES
	Prerequisite: Write $HOME/.ssh/config properly, for example:
		Host *.mshome.net
			IdentityFile C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\ssh-keys\id_rsa
			User ubuntu
#>
function Start-MultipassVscode {
	param (
		[Parameter(HelpMessage = 'Instance name')]
		[string]
		$Name = 'primary',

		[Parameter(HelpMessage = 'e.g. /home/me or home/me')]
		[string]
		$Path = '/home/ubuntu'
	)

	$hostName = "$Name.mshome.net"
	code --folder-uri "vscode-remote://ssh-remote+$hostName/$Path"
}

function Add-MultipassSshConfig {
	$sshConfigPath = Join-Path $HOME .ssh config

	Add-Content $sshConfigPath @'
Host *.mshome.net
	IdentityFile C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\ssh-keys\id_rsa
	User ubuntu
	StrictHostKeyChecking no
'@
	code $sshConfigPath
}
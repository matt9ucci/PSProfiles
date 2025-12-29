<#
.EXAMPLE
	$param = @{
		Name         = "dev"
		HostName     = "myremotehost.com"
		User         = "me"
		IdentityFile = "%d/myid.pem"
		Force        = $true
	}
	New-SshConfig @param
#>
function New-SshConfig {
	param (
		[Parameter(Mandatory)]
		[string]
		$HostName,

		[string]
		$Name = 'default',

		[string]
		$User,

		[string]
		$IdentityFile,

		[string]
		$Path = "$HOME/.ssh/config_$Name",

		[switch]
		$Force
	)

	New-Item $Path -Force:$Force
	Add-Content $Path -Value "Host = $Name`n`tHostName = $HostName"
	if ($User) {
		Add-Content $Path -Value "`tUser = $User"
	}
	if ($IdentityFile) {
		Add-Content $Path -Value "`tIdentityFile = $IdentityFile"
	}
}

function Build-SshCommand {
	param (
		[string]
		$HostName,

		[string]
		$User,

		[string]
		$IdentityFile,

		[string]
		$ProxyCommand
	)

	$c = New-Object System.Collections.ArrayList
	$c.Add('ssh') | Out-Null
	if ($User) {
		$c.Add("-l $User") | Out-Null
	}
	if ($IdentityFile) {
		if (!(Test-Path $IdentityFile)) {
			Write-Warning "IdentityFile not found: $IdentityFile"
		}
		$c.Add("-i $IdentityFile") | Out-Null
	}
	if ($ProxyCommand) {
		$c.Add("-o ProxyCommand='$ProxyCommand'") | Out-Null
	}
	if ($HostName) {
		$c.Add($HostName) | Out-Null
	}
	$c -join ' '
}

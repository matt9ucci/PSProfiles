param (
	[string]$ProxyHost,
	[UInt16]$ProxyPort
)

Import-Module AWS.Tools.EC2 -ErrorAction Continue

if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml

	$awsProxy = @{
		Credential = $pwshProxy.ProxyCredential
		Hostname   = $pwshProxy.Proxy.Host
		Port       = $pwshProxy.Proxy.Port
	}
	Set-AWSProxy @awsProxy
}

function Get-EC2PublicDnsName {
	param (
		[Parameter(Mandatory)]
		[string]
		$InstanceId
	)

	Get-EC2Instance $InstanceId -Select Reservations.Instances.PublicDnsName
}

function Show-AwsToolVersion {
	aws --version
	& "$env:ProgramFiles\Amazon\SessionManagerPlugin\bin\session-manager-plugin.exe" --version
	sam --version
}

. $PSScriptRoot\Bastion.ps1

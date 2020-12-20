param (
	$SshIdentityFile = "$HOME\AwsBastion.pem"
)

$BastionInstanceId = $null
$BastionPublicDnsName = $null
$BASTION_SG_NAME = '*BastionSg'

function Start-Bastion   { Start-EC2Instance   -InstanceId (Get-BastionInstanceId) }
function Stop-Bastion    { Stop-EC2Instance    -InstanceId (Get-BastionInstanceId) }
function Restart-Bastion { Restart-EC2Instance -InstanceId (Get-BastionInstanceId) }

function Get-BastionStatus {
	Get-EC2InstanceStatus -InstanceId (Get-BastionInstanceId) -IncludeAllInstance $true | ConvertTo-Json
}

<#
.PARAMETER Force
	Overwrites cached value and returns new one.
#>
function Get-BastionInstanceId([switch]$Force) {
	if ($Force -or !$script:BastionInstanceId) {
		$filter = @{ Name = 'instance.group-name'; Value = $BASTION_SG_NAME }
		[Amazon.EC2.Model.Reservation]$reservation = Get-EC2Instance -Filter $filter
		$script:BastionInstanceId = $reservation.Instances[0].InstanceId
	}
	$script:BastionInstanceId
}

<#
.PARAMETER Force
	Overwrites cached value and returns new one.
#>
function Get-BastionPublicDnsName([switch]$Force) {
	if ($Force -or !$script:BastionPublicDnsName) {
		$filter = @{ Name = 'instance.group-name'; Value = $BASTION_SG_NAME }
		[Amazon.EC2.Model.Reservation]$reservation = Get-EC2Instance -Filter $filter
		$script:BastionPublicDnsName = $reservation.Instances[0].PublicDnsName
	}
	$script:BastionPublicDnsName
}

function New-SshEnv {
	$credential = (Import-Clixml $HOME\.psprofiles\HttpProxyCredential.xml).GetNetworkCredential()
	$env:HTTP_PROXY_USER = $credential.UserName
	$env:HTTP_PROXY_PASSWORD = $credential.Password
}

function Remove-SshEnv {
	$env:HTTP_PROXY_USER = $null
	$env:HTTP_PROXY_PASSWORD = $null
}

function Enter-Bastion {
	param (
		[string]
		$User = 'ec2-user',

		[uint16]
		$SshPort = 22
	)

	New-SshEnv
	ssh "${User}@$(Get-BastionPublicDnsName)" -o ProxyCommand="connect -H ${ProxyHost}:${ProxyPort} %h %p" -p $SshPort -i $SshIdentityFile
	Remove-SshEnv
}

function Enter-EC2 {
	param (
		[Parameter(Mandatory)]
		[string]
		$EC2,

		[string]
		$User = 'ec2-user'
	)

	New-SshEnv
	Stop-Process -Name ssh-agent
	function setenv($Name, $Value) {
		'$env:{0} = ''{1}''' -f $Name, $Value | Invoke-Expression
	}
	ssh-agent -c | Invoke-Expression
	ssh-add $SshIdentityFile

	# TODO parameterize 'bastion', etc.
	ssh $User@$EC2 -o ProxyCommand="$('ssh bastion -o Hostname={0} -W %h:%p' -f (Get-BastionPublicDnsName))"

	Remove-SshEnv
}

function Save-EC2Item($EC2, $Path) {
	New-SshEnv
	
	Stop-Process -Name ssh-agent
	function setenv($Name, $Value) {
		'$env:{0} = ''{1}''' -f $Name, $Value | Invoke-Expression
	}
	ssh-agent -c | Invoke-Expression
	ssh-add $SshIdentityFile

	# TODO parameterize 'bastion', 'docker', etc.
	scp -o ProxyCommand="$('ssh bastion -o Hostname={0} -W %h:%p' -f (Get-BastionPublicDnsName))" -F $HOME\.ssh\config docker@${EC2}:$Path .

	Remove-SshEnv
}

if ($IsWindows) {
	Set-Variable AWS_CREDENTIAL_LOCATION $env:LOCALAPPDATA\AWSToolkit\RegisteredAccounts.json -Option ReadOnly, AllScope -Scope Global -Force
	Set-Variable AWS_SHARED_CREDENTIAL_LOCATION "$HOME\.aws\credentials" -Option ReadOnly, AllScope -Scope Global -Force
}

function Register-ArgumentCompleterByModuleName {
	param (
		[Parameter(Mandatory)]
		[string]
		$ModuleName,

		[Parameter(Mandatory)]
		[string]
		$ParameterName,

		[Parameter(Mandatory)]
		[scriptblock]
		$ScriptBlock
	)

	if ($cms = Get-Command -Module $ModuleName -ParameterName $ParameterName) {
		Register-ArgumentCompleter -CommandName $cms.Name -ParameterName $ParameterName -ScriptBlock $ScriptBlock
	}
}

. $PSScriptRoot\Cfn.ps1
. $PSScriptRoot\Cloud9.ps1
. $PSScriptRoot\Ec2.ps1
. $PSScriptRoot\Ec2ib.ps1
. $PSScriptRoot\Iam.ps1
. $PSScriptRoot\Vpc.ps1

<#
.LINK
	Using AWS Credentials https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html
#>
function Set-AwsCredentialFromCsv {
	param (
		[string]
		$Path = 'accessKeys.csv',

		[string]
		$ProfileName = 'default'
	)

	$csv = Get-Content $Path | ConvertFrom-Csv

	$param = @{
		AccessKey = $csv.'Access key ID'
		SecretKey = $csv.'Secret access key'
		StoreAs   = $ProfileName
	}
	Set-AWSCredential @param
}

function Set-AwsSharedCredentialsFileFromNetSDKCredentialsFile {
	param (
		$ProfileName = 'default'
	)

	$param = @{
		StoreAs         = $ProfileName
		Credential      = Get-AWSCredential -ProfileName $ProfileName
		ProfileLocation = Join-Path $HOME .aws credentials
	}
	Set-AWSCredential @param
}

function Get-AwsProfile {
	param (
		[string]
		$Name,

		[ValidateSet('NetSDKCredentialsFile', 'SharedCredentialsFile')]
		[string[]]
		$StoreType,

		[switch]
		$Credential
	)

	$profiles = Get-AWSCredential -ListProfileDetail

	if ($Name) {
		$profiles = $profiles | ? ProfileName -Like $Name
	}

	if ($StoreType) {
		$profiles = $profiles | ? StoreTypeName -In $StoreType
	}

	if ($Credential) {
		foreach ($p in $profiles) {
			$credential = ($p | Get-AWSCredential).GetCredentials()[0]
			foreach ($prop in $credential.psobject.properties) {
				$p | Add-Member $prop.Name $prop.Value
			}
		}
	}

	$profiles
}

function Get-AwsToolsModuleName {
	param (
		[string]
		$Name = '*',

		[switch]
		$Full
	)

	$moduleName = if ($Full) {
		(Get-AWSService).ModuleName
	} else {
		(Get-AWSService).ModuleName -replace '^AWS\.Tools\.'
	}

	$moduleName -like $Name | sort
}

function Get-AwsIamGroupInlinePolicy {
	param (
		[string]
		$GroupName
	)

	Get-IAMGroupPolicyList -GroupName $GroupName | % {
		Get-IAMGroupPolicy -GroupName $GroupName -PolicyName $_
	}
}

function Save-AwsMfaCredential {
	param (
		[Parameter(Mandatory)]
		[string]
		$ProfileName,

		[Parameter(Mandatory)]
		[string]
		$MfaDeviceSerialNumber,

		[string]
		$TokenCode,

		[string]
		$Region
	)

	$params = @{
		ProfileName  = $ProfileName
		SerialNumber = $MfaDeviceSerialNumber
		TokenCode    = if ($TokenCode) { $TokenCode } else { Read-Host -Prompt 'TokenCode' }
	}
	if ($Region) { $params['Region'] = $Region }

	$sessionToken = Get-STSSessionToken @params

	$params = @{
		AccessKey    = $sessionToken.AccessKeyId
		SecretKey    = $sessionToken.SecretAccessKey
		SessionToken = $sessionToken.SessionToken
	}

	# Save the MFA profile in AWS SDK store (Windows) or shared credential file
	Set-AWSCredential -StoreAs ${ProfileName}_MFA @params
	# Set the MFA profile for the current session
	Set-AWSCredential -ProfileName ${ProfileName}_MFA -Scope Global
}

Set-Alias Add-AWSCredentialProfile Set-AWSCredential

# Set aliases for tab completion
Get-Command -Module AWSToolsUtility -Verb Get | % {
	sal $_.Noun $_.Name
}

Register-ArgumentCompleter -ParameterName Name -CommandName Install-AWSToolsModule -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)

	(Get-AwsToolsModuleName) -like "$wordToComplete*"
}

Register-ArgumentCompleter -ParameterName Path -CommandName Get-SSMParametersByPath -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)

	@(
		'/aws/service/ami-amazon-linux-latest'
		'/aws/service/ami-windows-latest'
	) -like "*$wordToComplete*"
}

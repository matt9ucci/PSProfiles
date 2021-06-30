if ($IsWindows) {
	Set-Variable AWS_CREDENTIAL_LOCATION $env:LOCALAPPDATA\AWSToolkit\RegisteredAccounts.json -Option ReadOnly, AllScope -Scope Global -Force
	Set-Variable AWS_SHARED_CREDENTIAL_LOCATION "$HOME\.aws\credentials" -Option ReadOnly, AllScope -Scope Global -Force
}

. $PSScriptRoot\Ec2.ps1
. $PSScriptRoot\Cloud9.ps1

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
		StoreAs = $ProfileName
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

function New-CFNStackFromTemplateFile {
	param (
		[Parameter(Mandatory)]
		[string]
		$StackName,

		[Parameter(Mandatory)]
		[string]
		$Path,

		[Parameter(ValueFromRemainingArguments)]
		$Remaining
	)

	$param = @{}
	for ($i = 0; $i -lt $Remaining.Count; $i += 2) {
		$param[$Remaining[$i]] = $Remaining[$i + 1]
	}

	New-CFNStack -StackName $StackName -TemplateBody (Get-Content $Path -Raw) @param
}

Set-Alias Add-AWSCredentialProfile Set-AWSCredential

filter FromBase64ToUtf8 {
	[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))
}

filter FromUrlEncodedString {
	[System.Web.HttpUtility]::UrlDecode($_)
}

sal CfnStack Get-CFNStack

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

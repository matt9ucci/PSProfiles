param (
	[ValidateSet('aws', 'sam', 'session-manager-plugin')]
	[string[]]
	$Tool = @('aws', 'sam', 'session-manager-plugin')
)

if ('aws' -in $Tool) {
	# AWS CLI version 2 on Windows
	# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
	$param = @{
		Uri = 'https://awscli.amazonaws.com/AWSCLIV2.msi'
		Verbose = $true
	}
	Invoke-WebRequest @param -OutFile (Split-Path $param.Uri -Leaf)
}

if ('sam' -in $Tool) {
	# AWS SAM CLI 64-bit
	# https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-windows.html
	$param = @{
		Uri = 'https://github.com/awslabs/aws-sam-cli/releases/latest/download/AWS_SAM_CLI_64_PY3.msi'
		Verbose = $true
	}
	Invoke-WebRequest @param -OutFile (Split-Path $param.Uri -Leaf)
}

if ('session-manager-plugin' -in $Tool) {
	# Session Manager Plugin for the AWS CLI
	# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-windows
	$param = @{
		Uri = 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe'
		Verbose = $true
	}
	Invoke-WebRequest @param -OutFile (Split-Path $param.Uri -Leaf)
}

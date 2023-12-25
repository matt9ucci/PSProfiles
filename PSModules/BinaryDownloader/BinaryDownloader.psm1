class BinaryInfo {
	[uri]$Uri
	[string]$FileName

	BinaryInfo([uri]$Uri) {
		$this.Uri = $Uri
		$this.FileName = Split-Path $Uri -Leaf
	}

	BinaryInfo([uri]$Uri, [string]$FileName) {
		$this.Uri = $Uri
		$this.FileName = $FileName
	}

	[hashtable]ToParam4Iwr() {
		$h = @{
			Uri = $this.Uri
			OutFile = $this.FileName
		}
		return $h
	}
}

$info = @{
	# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
	'AWS CLI version 2 on Windows' = [BinaryInfo]::new(
		'https://awscli.amazonaws.com/AWSCLIV2.msi'
	)
	# https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-windows.html
	'AWS SAM CLI 64-bit' = [BinaryInfo]::new(
		'https://github.com/awslabs/aws-sam-cli/releases/latest/download/AWS_SAM_CLI_64_PY3.msi'
	)
	# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-windows
	'Session Manager Plugin for the AWS CLI' = [BinaryInfo]::new(
		'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe'
	)
}

function Save-Binary {
	param (
		[string]
		$Name
	)

	$param = $info[$Name].ToParam4Iwr()
	Invoke-WebRequest @param -Verbose
}

Register-ArgumentCompleter -ParameterName Name -CommandName Save-Binary -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	$info.Keys -like "*$wordToComplete*" | % { "'{0}'" -f $_ } | sort
}

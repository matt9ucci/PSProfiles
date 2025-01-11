if (Get-Command aws_completer -ErrorAction Ignore) {
	Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
		param ($commandName, [string]$wordToComplete, $cursorPosition)

		$env:COMP_LINE = $wordToComplete + $(if ($wordToComplete.Length -lt $cursorPosition) { ' ' })

		$env:COMP_POINT = $cursorPosition

		aws_completer | % {
			[System.Management.Automation.CompletionResult]::new($_, $_, 'Text', $_)
		}

		Remove-Item Env:\COMP_LINE, Env:\COMP_POINT
	}
}

function Set-AwsMfaEnv {
	param (
		[Parameter(Mandatory)]
		[string]
		$ProfileName,

		[Parameter(Mandatory)]
		[string]
		$MfaDeviceSerialNumber,

		[Parameter(Mandatory)]
		[string]
		$TokenCode,

		[string]
		$Region
	)

	$params = @(
		'--profile', $ProfileName,
		'--serial-number', $MfaDeviceSerialNumber,
		'--token-code', $TokenCode
	)
	if ($Region) { $params += '--region', $Region }

	$sessionTokenJson = aws sts get-session-token --output json @params
	Write-Debug ($sessionTokenJson | Out-String)

	$cred = ($sessionTokenJson | ConvertFrom-Json).Credentials

	$env:AWS_ACCESS_KEY_ID = $cred.AccessKeyId
	$env:AWS_SECRET_ACCESS_KEY = $cred.SecretAccessKey
	$env:AWS_SESSION_TOKEN = $cred.SessionToken
}

function Install-CdkToolkit {
	npm install -g aws-cdk
}

function Initialize-CdkProject {
	param (
		[ValidateSet('csharp', 'fsharp', 'go', 'java', 'javascript', 'python', 'typescript')]
		[string]
		$Language = 'typescript',

		[switch]
		$Full
	)

	$params = @(
		'--language', $Language
		if (!$Full) { '--generate-only' }
	)
	cdk init @params
}

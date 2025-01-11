function New-CfnStackFromTemplateFile {
	param (
		[Parameter(Mandatory)]
		[string]
		$StackName,

		[Parameter(Mandatory)]
		[string]
		$Path,

		[ValidateSet('CAPABILITY_IAM', 'CAPABILITY_NAMED_IAM', 'CAPABILITY_AUTO_EXPAND')]
		[string[]]
		$Capability,

		[Amazon.CloudFormation.OnFailure]
		$OnFailure,

		[Parameter(ValueFromRemainingArguments)]
		$Remaining
	)

	$param = @{}

	if ($Capability) { $param['Capability'] = $Capability }
	if ($OnFailure) { $param['OnFailure'] = $OnFailure }

	for ($i = 0; $i -lt $Remaining.Count; $i += 2) {
		$param[$Remaining[$i]] = $Remaining[$i + 1]
	}

	New-CFNStack -StackName $StackName -TemplateBody (Get-Content $Path -Raw) @param
}

sal CfnStack Get-CFNStack

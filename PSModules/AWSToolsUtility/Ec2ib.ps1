function Get-Ec2ibManagedComponent {
	param (
		[ValidateSet(
			'Linux',
			'Windows'
		)]
		[string[]]
		$Platform,

		[ArgumentCompletions(
			"'Amazon Linux 2'",
			"'Microsoft Windows Server 2019'",
			"'Ubuntu 20'"
		)]
		[string[]]
		$SupportedOsVersion
	)

	$filters = @()
	if ($Platform.Count) {
		$filters += @{ Name = 'platform'; Values = $Platform }
	}
	if ($SupportedOsVersion.Count) {
		$filters += @{ Name = 'supportedOsVersion'; Values = $SupportedOsVersion } 
	}

	Get-EC2IBComponentList -Owner Amazon -Filter $filters
}

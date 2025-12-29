function Get-LogPretty {
	param (
		[ValidateSet(
			'email',
			'full',
			'fuller',
			'mboxrd',
			'medium',
			'oneline',
			'raw',
			'reference',
			'short'
		)]
		[string]
		$Format = 'medium'
	)

	igit log --pretty=$Format
}
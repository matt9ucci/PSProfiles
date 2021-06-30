function Open-C9Environment {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			(Get-C9EnvironmentList | Get-C9EnvironmentData | ? Name -like "$WordToComplete*").Name
		})]
		[string]
		$Name
	)

	$id = (Get-C9EnvironmentList | Get-C9EnvironmentData | ? Name -EQ $Name).Id
	Start-Process https://console.aws.amazon.com/cloud9/ide/$id
}

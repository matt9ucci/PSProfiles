function Open-C9Environment {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			(Get-C9EnvironmentList | Get-C9EnvironmentData | ? Name -like "$WordToComplete*").Name
		})]
		[string]
		$Name,

		[Amazon.PowerShell.Common.AWSRegion]
		$Region = (Get-DefaultAWSRegion)
	)

	$id = (Get-C9EnvironmentList | Get-C9EnvironmentData | ? Name -EQ $Name).Id
	Start-Process https://$Region.console.aws.amazon.com/cloud9/ide/$id
}

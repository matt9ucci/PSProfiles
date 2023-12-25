function Get-Ec2InstanceDescription {
	Get-EC2Instance -Select Reservations.Instances
}

function Get-Ec2InstanceState {
	Get-EC2Instance -Select Reservations.Instances | select @(
		@{ n = 'InstanceName'; e = { ($_.Tags | ? Key -EQ Name).Value } }
		'InstanceId'
		@{ n = 'StateName'; e = { $_.State.Name } }
		'StateReason'
		'StateTransitionReason'
	) | Sort-Object InstanceName
}

function Save-Ec2ConsoleScreenshot {
	param (
		[Parameter(Mandatory)]
		[string]
		$InstanceId,

		[string]
		$Path = '{0}-{1}.jpg' -f ('Ec2Console', (Get-Date -Format yyyyMMdd-HHmmss))
	)

	$imageData = Get-EC2ConsoleScreenshot -InstanceId $InstanceId -Select ImageData
	[byte[]]$buffer = [System.Convert]::FromBase64String($imageData)
	$stream = [System.IO.MemoryStream]::new($buffer)
	$image = [System.Drawing.Image]::FromStream($stream)
	$image.Save($Path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
}

sal Ec2 Get-Ec2InstanceDescription
sal Ec2State Get-Ec2InstanceState

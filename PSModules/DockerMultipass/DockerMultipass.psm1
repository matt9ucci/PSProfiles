function New-Instance {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = 'DockerMultipass',

		[ValidateRange(1, [UInt16]::MaxValue)]
		[UInt16]
		$Cpu = 2,

		[ValidateRange(512MB, [UInt64]::MaxValue)]
		[UInt64]
		$Disk = 16GB,

		[ValidateRange(128MB, [UInt64]::MaxValue)]
		[UInt64]
		$Memory = 2GB
	)

	$param = @(
		'--cloud-init', "$PSScriptRoot/DockerMultipass.yaml"
		'--name', $Name
		'--cpus', $Cpu
		'--disk', $Disk
		'--mem', $Memory
		'-vvv'
	)

	multipass launch @param
}

function Start-Instance {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = 'DockerMultipass'
	)

	multipass start $Name
}

function Get-InstanceInfo {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = 'DockerMultipass'
	)

	multipass info --format csv $Name | ConvertFrom-Csv
}

function New-Context {
	param (
		[string]
		$Name = 'DockerMultipass'
	)

	$params = @(
		'context'
		'create'
		"DM_$Name"
		'--docker'
		"host=ssh://ubuntu@$Name.mshome.net"
		'--description'
		'DockerMultipass'
	)
	docker @params
}

function Get-SubnetName {
	Get-EC2Subnet | select @(
		@{ n = 'SubnetName'; e = { ($_.Tags | ? Key -EQ Name).Value } }
		'SubnetId'
		'AvailabilityZone'
		'VpcId'
	) | Sort-Object SubnetName
}

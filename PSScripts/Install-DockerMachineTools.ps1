param (
	[string]$Machine = 'default'
)

$tczNames = @(
	'make'
)

docker-machine ssh $Machine tce-load -wi ($tczNames -join ' ')

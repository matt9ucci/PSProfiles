Import-Module Multipass

$params = @{
	Name         = 'dev-c'
	Disk         = 32GB
	UserDataPath = "$PSScriptRoot/dev-c.yaml"
}
New-MultipassOfMyOwn @params

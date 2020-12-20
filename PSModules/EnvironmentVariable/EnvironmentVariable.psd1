@{

RootModule           = 'EnvironmentVariable'
ModuleVersion        = '0.0.0.200314'
CompatiblePSEditions = 'Core'
Author               = 'Matt Gucci'
Copyright            = '(c) Matt Gucci. All rights reserved.'
PowerShellVersion    = '6.0'

FunctionsToExport = @(
	'Add-PathEnvironmentVariableValue'
	'Get-EnvironmentVariable'
	'Get-PathEnvironmentVariable'
	'Remove-HttpProxyEnv'
	'Remove-PathEnvironmentVariable'
	'Set-EnvironmentVariable'
	'Set-HttpProxyEnv'
	'Set-PathEnv'
)
CmdletsToExport = @(

)
VariablesToExport = @(

)
AliasesToExport = @(
	'Add-PathEnvValue'
	'Get-Env'
	'Get-PathEnv'
	'Set-Env'
	'Remove-PathEnv'
)

}
@{

RootModule = 'PowerShell-Docs-Utility'
ModuleVersion = '0.181107'
GUID = 'b57a21af-ea0c-45f7-937c-d528f89f1f06'
Author = 'Matt Gucci'
CompanyName = 'Unknown'
Copyright = '(c) 2018 Matt Gucci. All rights reserved.'
NestedModules = @('..\Git\Git.psm1')
FunctionsToExport = @(
	'Copy-Md'
	'Get-Md'
	'New-Patch'
	'Remove-Patch'
	'Reset-Repository'
	'Set-RepositoryLocation'
	'Update-ExampleNumber'
	'Update-Repository'
)
DefaultCommandPrefix = 'PSDoc'

}


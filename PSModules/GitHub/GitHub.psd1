@{

RootModule        = 'GitHub'
ModuleVersion     = '0.180901'
GUID              = 'b0c3a22b-7067-48d4-9883-b48feb194cca'
Author            = 'Masatoshi Higuchi'
CompanyName       = 'N/A'
Copyright         = '(c) 2018 Masatoshi Higuchi. All rights reserved.'
Description       = 'GitHub module for PowerShell.'
PowerShellVersion = '5.0'

FunctionsToExport = @(
	'Get-Release'
	'Get-Starred', 'Save-Starred'
)
CmdletsToExport   = @()
VariablesToExport = @()
AliasesToExport   = @()

PrivateData = @{ PSData = @{
	Tags         = 'github'
	LicenseUri   = 'https://github.com/matt9ucci/PSProfiles/blob/master/LICENSE'
	ProjectUri   = 'https://github.com/matt9ucci/PSProfiles'
	ReleaseNotes = 'beta'
} }

DefaultCommandPrefix = 'GitHub'

}

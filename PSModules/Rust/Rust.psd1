@{

RootModule           = 'Rust.psm1'
ModuleVersion        = '0.0.1'
CompatiblePSEditions = 'Core'
GUID                 = '17708c81-100b-4189-9246-a87d9fad7bd0'
Author               = 'Matt Gucci'
CompanyName          = 'Unknown'
Copyright            = '(c) Matt Gucci. All rights reserved.'

FunctionsToExport    = '*'
CmdletsToExport      = '*'
VariablesToExport    = '*'
AliasesToExport      = '*'

PrivateData          = @{
	PSData = @{
		LicenseUri   = 'https://github.com/matt9ucci/Rust/blob/master/LICENSE'
		ProjectUri   = 'https://github.com/matt9ucci/Rust'
		ReleaseNotes = 'Initial release'
	}
}

DefaultCommandPrefix = 'Rust'

}

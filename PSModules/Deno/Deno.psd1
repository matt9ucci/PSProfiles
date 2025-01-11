@{

RootModule           = 'Deno.psm1'
ModuleVersion        = '0.0.1'
CompatiblePSEditions = 'Core'
GUID                 = 'de26e25d-ae34-4bfb-9bb7-2fb8458f9908'
Author               = 'Matt Gucci'
CompanyName          = 'Unknown'
Copyright            = '(c) 2021 Matt Gucci. All rights reserved.'

FunctionsToExport    = '*'
CmdletsToExport      = '*'
VariablesToExport    = '*'
AliasesToExport      = '*'

PrivateData          = @{
	PSData = @{
		LicenseUri   = 'https://github.com/matt9ucci/PSProfiles/blob/master/LICENSE'
		ProjectUri   = 'https://github.com/matt9ucci/PSProfiles'
		ReleaseNotes = 'Initial release'

	}
}

DefaultCommandPrefix = 'Deno'

}

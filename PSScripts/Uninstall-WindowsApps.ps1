#Requires -Modules Appx
#Requires -RunAsAdministrator

@(
	'king.com.CandyCrush*'
	'king.com.FarmHeroesSaga'
	'Microsoft.BingNews'
	'Microsoft.BingWeather'
	'Microsoft.MicrosoftOfficeHub'
	'Microsoft.MicrosoftSolitaireCollection'
	'Microsoft.OneConnect'
	'Microsoft.People'
	'Microsoft.SkypeApp'
	'microsoft.windowscommunicationsapps'
	'Microsoft.WindowsFeedbackHub'
	'Microsoft.WindowsMaps'
	'Microsoft.Xbox.TCUI'
	'Microsoft.XboxApp'
	'Microsoft.XboxGameOverlay'
	'Microsoft.XboxGamingOverlay'
	'Microsoft.XboxIdentityProvider'
	'Microsoft.XboxSpeechToTextOverlay'
	'Microsoft.YourPhone'
	'Microsoft.ZuneMusic'
	'Microsoft.ZuneVideo'
	'MicrosoftTeams'
	'SpotifyAB.SpotifyMusic'
) | % { Get-AppxPackage $_ | Remove-AppxPackage }

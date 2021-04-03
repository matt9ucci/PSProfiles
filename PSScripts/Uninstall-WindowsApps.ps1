#Requires -Modules Appx
#Requires -RunAsAdministrator

@(
    'Microsoft.BingWeather'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.People'
    'Microsoft.SkypeApp'
    'microsoft.windowscommunicationsapps'
    'Microsoft.XboxApp'
	'Microsoft.YourPhone'
	'Microsoft.ZuneVideo'
    'king.com.CandyCrush*'
    'king.com.FarmHeroesSaga'
    'SpotifyAB.SpotifyMusic'
) | % { Get-AppxPackage $_ | Remove-AppxPackage }

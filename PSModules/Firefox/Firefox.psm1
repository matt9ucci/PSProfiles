Set-Variable FIREFOX_HOME "$env:ProgramFiles\Mozilla Firefox" -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_PROFILES "$env:APPDATA\Mozilla\Firefox\Profiles" -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_EXE (Join-Path $FIREFOX_HOME firefox.exe) -Scope Global -Option ReadOnly, AllScope

function Get-FirefoxProfile($Name = '*') {
	if ($IsLinux) {
		Get-ChildItem -Directory $HOME/.mozilla/firefox -Filter *.$Name
	} else {
		Get-ChildItem -Directory $FIREFOX_PROFILES -Filter *.$Name
	}
}

function Open-FirefoxProfile {
	param (
		[string]
		$Name = '*'
	)

	Get-FirefoxProfile $Name | Invoke-Item
}

function New-FirefoxProfile([string[]]$Name) {
	$Name | % { Start-Process -FilePath $FIREFOX_EXE -ArgumentList "-CreateProfile $_" -Wait }
}

function Get-FirefoxUserJs([string]$Name) {
	Join-Path (Get-FirefoxProfile $Name).FullName user.js
}

function Copy-FirefoxUserJs([string]$Name) {
	$js = Join-Path $PSScriptRoot user.js
	Copy-Item $js (Get-FirefoxUserJs $Name)
}

function Remove-FirefoxUserJs([string]$Name) {
	Remove-Item (Get-FirefoxUserJs $Name)
}

function Start-Firefox([string]$Name) {
	if ($Name) {
		Start-Process -FilePath $FIREFOX_EXE -ArgumentList "-P $Name", '--no-remote'
	} else {
		Start-Process -FilePath $FIREFOX_EXE
	}
}

function Open-FirefoxConfig([string]$Name) {
	$options = @('-new-tab', 'about:config')
	if ($Name) {
		$options += "-P $Name"
	}
	Start-Process -FilePath $FIREFOX_EXE -ArgumentList $options
}

function Get-FirefoxLogin($Name = '*') {
	Get-Content (Join-Path (Get-FirefoxProfile $Name) logins.json)| ConvertFrom-Json | ForEach-Object logins
}

function Install-Firefox([Parameter(Mandatory)][string]$Exe) {
	$ini = Join-Path $PSScriptRoot firefox.ini
	Start-Process -FilePath $Exe -ArgumentList "/INI=$ini"
}

function Uninstall-Firefox {
	Start-Process -FilePath "$FIREFOX_HOME\uninstall\helper.exe" -ArgumentList '/S' -Wait
	Remove-Item -Confirm -Recurse $env:APPDATA\Mozilla\Firefox
	Remove-Item -Confirm -Recurse $env:LOCALAPPDATA\Mozilla\Firefox
}

Register-ArgumentCompleter -CommandName (gcm *-FirefoxUserJs, *-FirefoxProfile, *-FirefoxLogin, *-FirefoxConfig) -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
	$result = Get-FirefoxProfile | Select-Object -Property @{ e = { $_.Name.Split('.')[1] }; n = 'Name' } | % Name
	$result -like "$wordToComplete*"
}

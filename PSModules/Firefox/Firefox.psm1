Set-Variable FIREFOX_HOME "$env:ProgramFiles\Mozilla Firefox" -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_PROFILES "$env:APPDATA\Mozilla\Firefox\Profiles" -Scope Global -Option ReadOnly, AllScope

function Get-FirefoxProfile($Name = '*') {
	if ($IsLinux) {
		Get-ChildItem -Directory $HOME/.mozilla/firefox -Filter *.$Name
	} else {
		Get-ChildItem -Directory $FIREFOX_PROFILES -Filter *.$Name
	}
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

function Copy-FirefoxUserCss([string]$Name) {
	$chrome = Join-Path $PSScriptRoot chrome
	Copy-Item $chrome (Get-FirefoxProfile $Name).FullName -Recurse -Force
}

function Remove-FirefoxUserCss([string]$Name) {
	Remove-Item (Join-Path (Get-FirefoxProfile $Name) chrome) -Recurse -Force
}

function Uninstall-Firefox {
	Start-Process -FilePath "$FIREFOX_HOME\uninstall\helper.exe" -ArgumentList '/S' -Wait
	Remove-Item -Confirm -Recurse $env:APPDATA\Mozilla\Firefox
	Remove-Item -Confirm -Recurse $env:LOCALAPPDATA\Mozilla\Firefox
}

Set-Variable FIREFOX_HOME "$env:ProgramFiles\Mozilla Firefox" -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_PROFILES "$env:APPDATA\Mozilla\Firefox\Profiles" -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_EXE (Join-Path $FIREFOX_HOME firefox.exe) -Scope Global -Option ReadOnly, AllScope

function Get-FirefoxProfile {
	param (
		[string]
		$Name = '*'
	)

	if ($IsLinux) {
		Get-ChildItem -Directory $HOME/.mozilla/firefox -Filter *.$Name
	} else {
		Get-ChildItem -Directory $FIREFOX_PROFILES -Filter *.$Name
	}
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

function Copy-FirefoxUserCss([string]$Name) {
	$chrome = Join-Path $PSScriptRoot chrome
	Copy-Item $chrome (Get-FirefoxProfile $Name).FullName -Recurse -Force
}

function Remove-FirefoxUserCss([string]$Name) {
	Remove-Item (Join-Path (Get-FirefoxProfile $Name) chrome) -Recurse -Force
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
	Get-Content (Join-Path (Get-FirefoxProfile $Name) logins.json) | ConvertFrom-Json | ForEach-Object logins
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

function Test-UBlacklistUri {
	Get-Content (Join-Path $PSScriptRoot uBlacklist.txt) | % {
		if ($_ -match '^\*[^*]+\*$') {
			$uri = [uri]('https' + $_.Trim('*'))
			Write-Host "HEAD $uri ... " -ForegroundColor Green -NoNewline
			$res = try { Invoke-WebRequest $uri } catch { $_.Exception.Response }
			if ($res.StatusCode -ne 200) {
				Write-Host "NG $($res.StatusCode.value__) $($res.ReasonPhrase)" -ForegroundColor Red
			} else {
				Write-Host "OK $($res.StatusCode)" -ForegroundColor Green
			}
		} elseif ($_) {
			Write-Warning "Skip $_"
		}
	}
}

Register-ArgumentCompleter -CommandName (gcm *-FirefoxUserJs, *-FirefoxProfile, *-FirefoxLogin, *-FirefoxConfig) -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
	$result = Get-FirefoxProfile | Select-Object -Property @{ e = { $_.Name.Split('.')[1] }; n = 'Name' } | % Name
	$result -like "$wordToComplete*"
}

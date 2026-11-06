Set-Variable FIREFOX_HOME "$env:ProgramFiles\Mozilla Firefox" -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_PROFILES $(
	if ($IsLinux) {
		"$HOME/.mozilla/firefox"
	} else {
		"$env:APPDATA\Mozilla\Firefox\Profiles"
	}
) -Scope Global -Option ReadOnly, AllScope
Set-Variable FIREFOX_EXE (Join-Path $FIREFOX_HOME firefox.exe) -Scope Global -Option ReadOnly, AllScope

function Get-FirefoxProfile {
	param (
		[string]
		$Name = '*'
	)

	Get-ChildItem -Directory -Path $FIREFOX_PROFILES | ? {
		($Name -eq '*') -or ($_.Name -like "*.$Name") -or ($_.Name -eq $Name)
	}
}

function New-FirefoxProfile([string[]]$Name) {
	$Name | % { Start-Process -FilePath $FIREFOX_EXE -ArgumentList "-CreateProfile $_" -Wait }
}

function Copy-FirefoxUserJs {
	param (
		[string]
		$Name = '*'
	)

	$js = Join-Path $PSScriptRoot user.js
	Get-FirefoxProfile -Name $Name | % {
		Copy-Item -Path $js -Destination (Join-Path $_.FullName user.js) -Force -Verbose
	}
}

function Remove-FirefoxUserJs {
	param (
		[string]
		$Name = '*'
	)

	Get-FirefoxProfile -Name $Name | % {
		Remove-Item -Path (Join-Path $_.FullName user.js) -Verbose
	}
}

function Copy-FirefoxUserCss {
	param (
		[string]
		$Name = '*'
	)

	$chrome = Join-Path $PSScriptRoot chrome
	Get-FirefoxProfile -Name $Name | % {
		Copy-Item -Path $chrome -Destination $_.FullName -Recurse -Force -Verbose
	}
}

function Remove-FirefoxUserCss {
	param (
		[string]
		$Name = '*'
	)

	Get-FirefoxProfile -Name $Name | % {
		Remove-Item -Path (Join-Path $_.FullName chrome) -Recurse -Force -Verbose
	}
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

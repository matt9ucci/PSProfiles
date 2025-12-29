$env:npm_config_progress = 'false'

if ($env:http_proxy) {
	$env:npm_config_proxy = $env:http_proxy
}
if ($env:https_proxy) {
	${env:npm_config_https-proxy} = $env:https_proxy
}
if ($env:no_proxy) {
	$env:npm_config_noproxy = $env:no_proxy
}

function Get-NpmConfig {
	npm config list --json | ConvertFrom-Json
}

function Invoke-NpmDoctor {
	npm doctor
}

function Find-NpmPackage {
	param (
		[string]
		$String
	)

	npm search --json $String | ConvertFrom-Json
}

Register-ArgumentCompleter -Native -CommandName npm -ScriptBlock {
	param ($WordToComplete, $CommandAst, $CursorPosition)

	$npmCommand = $CommandAst.CommandElements[1].Value

	switch ($npmCommand) {
		run {
			$scriptsHashtable = (ConvertFrom-Json -InputObject (Get-Content -Path ./package.json -Raw) -AsHashtable).scripts
			foreach ($scriptName in $scriptsHashtable.Keys -like "$WordToComplete*") {
				[System.Management.Automation.CompletionResult]::new(
					$scriptName,
					$scriptName,
					[System.Management.Automation.CompletionResultType]::Text,
					$scriptsHashtable[$scriptName]
				)
			}
		}
	}
}

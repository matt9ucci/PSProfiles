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

function Get-Config {
	npm config list --json | ConvertFrom-Json
}

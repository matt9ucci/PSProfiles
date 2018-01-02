function Set-HttpProxyEnv {
	Param(
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process,
		[Parameter(Mandatory = $true)]
		[string]$Server,
		[Parameter(Mandatory = $true)]
		[string]$Port,
		[switch]$AuthenticationRequired
	)

	$proxy = "${Server}:${Port}"
	if ($AuthenticationRequired) {
		$credential = (Get-Credential -UserName $env:USERNAME -Message 'What is your proxy user?').GetNetworkCredential()
		$user = $credential.UserName
		$password = $credential.Password
		$proxy = "$($credential.UserName):$($credential.Password)@${proxy}"
	}

	Set-Env "HTTP_PROXY" "http://$proxy" $Target
	Set-Env "HTTPS_PROXY" "https://$proxy" $Target
	Set-Env "http_proxy" "http://$proxy" $Target
	Set-Env "https_proxy" "https://$proxy" $Target
}

function Remove-HttpProxyEnv {
	Param(
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	Set-Env "HTTP_PROXY" $null $Target
	Set-Env "HTTPS_PROXY" $null $Target
	Set-Env "http_proxy" $null $Target
	Set-Env "https_proxy" $null $Target
}

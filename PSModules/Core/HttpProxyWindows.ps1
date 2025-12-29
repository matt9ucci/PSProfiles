function Enable-HttpProxy([switch]$PassThru) {
	$registryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
	Set-ItemProperty $registryKey ProxyEnable 1 -PassThru:$PassThru
}

function Disable-HttpProxy([switch]$PassThru) {
	$registryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
	Set-ItemProperty $registryKey ProxyEnable 0 -PassThru:$PassThru
}

function Switch-HttpProxy([switch]$PassThru) {
	$registryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
	$proxyEnable = Get-ItemProperty $registryKey ProxyEnable
	if ($proxyEnable.ProxyEnable -eq 1) {
		Disable-HttpProxy -PassThru:$PassThru
	} else {
		Enable-HttpProxy -PassThru:$PassThru
	}
}

function Update-HttpProxyServer {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name,

		[Parameter(Mandatory)]
		[UInt16]
		$Port
	)

	$registryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
	$proxyServer = "${Name}:${Port}"
	Set-ItemProperty $registryKey ProxyServer $proxyServer
}

function Clear-HttpProxyServer {
	$registryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
	Clear-ItemProperty $registryKey ProxyServer
}

function Update-HttpProxyOverride {
	param (
		[Parameter(Mandatory)]
		[string[]]
		$Override = @(
			$env:COMPUTERNAME
			'<local>' # Bypass proxy server for local addresses
		)
	)

	$registryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
	Set-ItemProperty $registryKey ProxyOverride ($Override -join ';')
}

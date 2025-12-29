using namespace System.Net.Sockets

. $PSScriptRoot\Model.ps1

function Invoke-FcApi {
	param (
		[Parameter(Mandatory)]
		[string]
		$ApiMethod,

		[Parameter(Mandatory)]
		[string]
		$ApiPath,
		
		[Parameter(Mandatory)]
		[string]
		$Body,

		[string]$SocketPath = '/tmp/firecracker.socket',
		[string]$ApiHost = 'localhost',
		[string]$UserAgent = "powershell/$($PSVersionTable.PSVersion)"
	)

	[System.Net.EndPoint]$endPoint = New-Object UnixDomainSocketEndPoint $SocketPath

	[Socket]$socket = New-Object Socket @(
		$endPoint.AddressFamily
		[SocketType]::Stream
		[ProtocolType]::Unspecified
	)

	$socket.Connect($endPoint)

	$json = $Body

	[string]$req = @"
$ApiMethod $ApiPath HTTP/1.1
Host: $ApiHost
User-Agent: $UserAgent
Accept: application/json
Content-Type: application/json
Content-Length: $($json.Length)

$json
"@

	$req

	[byte[]]$msg = [System.Text.Encoding]::UTF8.GetBytes($req)

	$socket.Send($msg) > $null

	[byte[]]$bytes = New-Object byte[] 1024

	$count = $socket.Receive($bytes)

	[System.Text.Encoding]::UTF8.GetString($bytes, 0, $count)
}


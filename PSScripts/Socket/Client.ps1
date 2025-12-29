using namespace System.Net.Sockets

function Get-IPv6LinkLocalAddress {
	[System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).AddressList | Where-Object IsIPv6LinkLocal
}

function Start-Client {
	param (
		[ipaddress]$IPAddress = '127.0.0.1',
		[uint16]$Port = 11000,
		[int]$Backlog = 10
	)

	try {
		[IPEndPoint]$endPoint = New-Object System.Net.IPEndPoint $IPAddress, $Port

		[Socket]$client = New-Object Socket @(
			$IPAddress.AddressFamily
			[SocketType]::Stream
			[ProtocolType]::Tcp
		)

		$client.Connect($endPoint)

		Write-Host ("Communicating with {0}" -f $client.RemoteEndPoint)

		[byte[]]$msg = [System.Text.Encoding]::UTF8.GetBytes("POST / HTTP/1.1")

		$client.Send($msg) > $null

		$bytes = New-Object byte[] 1024
		[int]$count = $client.Receive($bytes)
		Write-Host ("Echo received: {0}" -f [System.Text.Encoding]::UTF8.GetString($bytes, 0, $count))
	} catch {
		Write-Host $_.ToString()
	} finally {
		if ($client) { Close-Socket $client }
	}
}

function Close-Socket([Socket]$Socket) {
	$Socket.Shutdown([SocketShutdown]::Both)
	$Socket.Close()
	$Socket.Dispose()
}

Start-Client

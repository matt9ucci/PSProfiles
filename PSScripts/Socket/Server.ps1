using namespace System.Net.Sockets

function Get-IPv6LinkLocalAddress {
	[System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).AddressList | Where-Object IsIPv6LinkLocal
}

function Start-Listening {
	param (
		[ipaddress]$IPAddress = '127.0.0.1',
		[uint16]$Port = 11000,
		[int]$Backlog = 10
	)

	[IPEndPoint]$endPoint = New-Object System.Net.IPEndPoint $IPAddress, $Port
	
	Write-Host $endPoint -ForegroundColor Green
	Write-Host $IPAddress.AddressFamily -ForegroundColor Green
	
	[Socket]$listeningSocket = New-Object Socket @(
		$IPAddress.AddressFamily
		[SocketType]::Stream
		[ProtocolType]::Tcp
	)
		
	try {
		$listeningSocket.Bind($endPoint)
		$listeningSocket.Listen($Backlog)

		while ($true) {
			Write-Host "Listening for incoming connections"
			[Socket]$acceptedSocket = $listeningSocket.Accept()

			[byte[]]$bytes = New-Object byte[] 1024
			[int]$count = $acceptedSocket.Receive($bytes)
			[string]$data = [System.Text.Encoding]::UTF8.GetString($bytes, 0, $count)

			Write-Host ("Received: '{0}'" -f $data)

			[byte[]]$msg = [System.Text.Encoding]::UTF8.GetBytes($data)

			$acceptedSocket.Send($msg)
			Close-Socket $acceptedSocket
		}
	} catch {
		Write-Host $_.ToString()
	} finally {
		if ($acceptedSocket) { Close-Socket $acceptedSocket }
		if ($listeningSocket) { Close-Socket $listeningSocket }
	}
}

function Close-Socket([Socket]$Socket) {
	$Socket.Shutdown([SocketShutdown]::Both)
	$Socket.Close()
	$Socket.Dispose()
}

Start-Listening

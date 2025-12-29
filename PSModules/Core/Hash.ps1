function Test-FileHash {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path,

		[Parameter(Mandatory, HelpMessage = 'Expected hash')]
		[string]
		$Hash,

		[System.Security.Cryptography.HashAlgorithmName]
		$Algorithm = 'SHA256'
	)

	$fileHashInfo = Get-FileHash $Path -Algorithm $Algorithm
	if ($fileHashInfo.Hash.ToUpper() -eq $Hash.ToUpper()) {
		Write-Host ('Valid hash [{0}]' -f $fileHashInfo.Hash.ToUpper())
	} else {
		throw 'Invalid hash [{0}]: expected [{1}]' -f $fileHashInfo.Hash.ToUpper(), $Hash.ToUpper()
	}
}

function ConvertTo-Hash {
	param (
		[Parameter(Mandatory)]
		[System.Security.Cryptography.HashAlgorithmName]
		$Algorithm,

		[Parameter(Mandatory)]
		[string]
		$Text,

		[System.Text.Encoding]
		$Encoding = [System.Text.Encoding]::Default
	)

	$hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
	[byte[]]$target = $Encoding.GetBytes($Text)
	[byte[]]$bytes = $hashAlgorithm.ComputeHash($target)
	[System.BitConverter]::ToString($bytes) -replace '-', ''
}

function ConvertTo-Sha256 ([Parameter(Mandatory)][string]$Text) {
	ConvertTo-Hash SHA256 $Text
}

function ConvertTo-Sha1 ([Parameter(Mandatory)][string]$Text) {
	ConvertTo-Hash SHA1 $Text
}

function ConvertTo-Md5 ([Parameter(Mandatory)][string]$Text) {
	ConvertTo-Hash MD5 $Text
}

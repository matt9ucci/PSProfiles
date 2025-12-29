param (
	[Parameter(Mandatory)]
	[string]$Text,
	[uint32]$MinNonce = 1,
	[uint32]$MaxNonce = 1000,
	[uint16]$Byte = 3
)

$zeros = '0' * $Byte

$MinNonce..$MaxNonce | % {
	$target = '{0}Nonce{1}' -f $Text, $_
	$hash = ConvertTo-Sha256 $target
	if ($hash.StartsWith($zeros)) {
		'{0} => {1}' -f $target, $hash
	}
}

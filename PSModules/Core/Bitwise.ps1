<#
.SYNOPSIS
	ROTate Left.
.DESCRIPTION
	The rotate left (circular left shift) operation.
#>
function ROTL {
	param (
		[Parameter(HelpMessage = 'Number of bits to be rotated left.')]
		[ValidateRange(0, 63)]
		[byte]$n,

		[Parameter(HelpMessage = 'A 64-bit word')]
		[UInt64]$x
	)

	($x -shl $n) -bor ($x -shr 64 - $n)
}

<#
.SYNOPSIS
	ROTate Right.
.DESCRIPTION
	The rotate right (circular right shift) operation.
#>
function ROTR {
	param (
		[Parameter(HelpMessage = 'Number of bits to be rotated right.')]
		[ValidateRange(0, 63)]
		[byte]$n,

		[Parameter(HelpMessage = 'A 64-bit word')]
		[UInt64]$x
	)

	($x -shr $n) -bor ($x -shl 64 - $n)
}

$gs = (Get-Command gswin64c).Path

function ConvertTo-Pdf {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path,
		
		[string]
		$OutFile = (Get-Item $Path).BaseName + '.pdf'
	)

	& $gs -sDEVICE=pdfwrite -o $OutFile $Path
}

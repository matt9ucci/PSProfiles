function New-Directory {
	[Alias('nd')]
	param (
		[string[]]
		$Path
	)
	New-Item $Path -ItemType Directory -Force
}

function Remove-Directory {
	[CmdletBinding(SupportsShouldProcess)]
	[Alias('rd')]
	param ([string[]]$Path)

	Remove-Item $Path -Recurse -Force
}


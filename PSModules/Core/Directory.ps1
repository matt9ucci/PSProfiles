function New-Directory {
	[CmdletBinding(SupportsShouldProcess)]
	[Alias('nd')]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Path
	)

	process {
		New-Item $Path -ItemType Directory -Force
	}
}

function Remove-Directory {
	[CmdletBinding(SupportsShouldProcess)]
	[Alias('rd')]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]$Path
	)

	process {
		Remove-Item $Path -Recurse -Force
	}
}


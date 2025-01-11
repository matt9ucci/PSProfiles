Set-Alias nd md
Set-Alias New-Directory nd

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


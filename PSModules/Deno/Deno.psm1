function Install-Binary {
	param (
		[semver]
		$Version
	)

	scoop install deno"$(if ($Version) { "@$Version" })"
}

function Use-Binary {
	[Alias('Use-')]
	param (
		[semver]
		$Version
	)

	scoop reset deno"$(if ($Version) { "@$Version" })"
}

deno completions powershell | Out-String | iex

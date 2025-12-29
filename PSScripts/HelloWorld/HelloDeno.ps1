if (!(Get-Command deno -ErrorAction Ignore)) {
	Write-Error 'Deno command not found. See: https://deno.land/manual/getting_started/installation'
	return
}

$uri = 'https://deno.land/std/examples/welcome.ts'
deno --log-level debug run $uri
Write-Host 'See also: https://deno.land/std/examples/' -ForegroundColor Green

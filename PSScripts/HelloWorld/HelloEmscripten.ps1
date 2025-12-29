param (
	[string]
	$Path = 'HelloEmscripten',

	[switch]
	$Html
)

New-Item $Path -ItemType Directory

Push-Location $Path

Add-Content -Path HelloEmscripten.c -Value @"
#include <stdio.h>
int main() {
	printf("Hello, Emscripten!\n");
	return 0;
}
"@

if ($Html) {
	emcc HelloEmscripten.c -o HelloEmscripten.html
	Start-Process http://localhost:8000/HelloEmscripten.html
	python -m http.server 8000
} else {
	emcc HelloEmscripten.c
	node a.out.js
}

Pop-Location

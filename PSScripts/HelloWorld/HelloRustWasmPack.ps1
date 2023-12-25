<#
.LINK
	https://rustwasm.github.io/docs/book/game-of-life/hello-world.html
#>
param (
	[string]
	$Name = 'hello_rust_wasm_pack'
)

Get-Command -Name cargo, cargo-generate, wasm-pack, npm -ErrorAction Stop | Out-Null

cargo generate --name $Name --force --git https://github.com/rustwasm/wasm-pack-template

Push-Location $Name

wasm-pack build
npm init wasm-app www
sl www

$packageName = $Name -replace '-', '_'

$packageJson = Get-Content -Path package.json | ConvertFrom-Json -AsHashtable
$packageJson['dependencies'] = @{ "$packageName" = 'file:..\pkg' }
Set-Content -Path package.json -Value ($packageJson | ConvertTo-Json)

Set-Content -Path index.js -Value @"
import * as wasm from "$packageName";

wasm.greet();
"@

npm install
npm run start

Pop-Location

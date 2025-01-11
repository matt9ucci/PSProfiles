param (
	[string]
	$Version = 'wat-1.0.39'
)

git clone --depth 1 -b $Version https://github.com/bytecodealliance/wasm-tools.git

Push-Location wasm-tools

cargo build --release
New-Item $USERAPPS\wasm-tools -ItemType Directory -Force | Out-Null
Get-ChildItem .\target\release\ | Write-Host -ForegroundColor Green

Move-Item -Path @(
	'.\target\release\wasm-dump.exe'
	'.\target\release\wasm-objdump-rs.exe'
	'.\target\release\wasm-smith.exe'
	'.\target\release\wasm-validate-rs.exe'
	'.\target\release\wasm2wat-rs.exe'
	'.\target\release\wat2wasm-rs.exe'
) -Destination $USERAPPS\wasm-tools
New-Item -Path $HOME\Commands\wasm-tools -Value $USERAPPS\wasm-tools -ItemType Junction

Pop-Location

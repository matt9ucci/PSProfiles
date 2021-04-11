param (
	[string]
	$Version = '0.17.1'
)

git clone --depth 1 -b $Version https://github.com/wasmerio/wasmer.git

Push-Location wasmer

cargo build --release
New-Item $USERAPPS\Wasmer -ItemType Directory -Force | Out-Null
Get-ChildItem .\target\release\

Move-Item .\target\release\wasmer.exe $USERAPPS\Wasmer
New-Item -Path $USERAPPS\bin\Wasmer -Value $USERAPPS\Wasmer -ItemType Junction

Pop-Location

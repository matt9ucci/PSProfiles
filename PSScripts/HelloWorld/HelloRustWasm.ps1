param (
	[string]
	$Name = 'hello_rust_wasm'
)

if ('wasm32-wasi' -notin (rustup target list --installed)) {
	throw 'wasm32-wasi target may not be installed'
}

New-Item $Name -ItemType Directory

Push-Location $Name

Add-Content -Path main.rs -Value @'
fn main() {
	println!("Hello, Rust Wasm World!");
}
'@

rustc main.rs --target wasm32-wasi

wasmtime main.wasm

Pop-Location

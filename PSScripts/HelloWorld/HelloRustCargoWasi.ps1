param (
	[string]
	$Name = 'hello_rust_cargo_wasi'
)

if ('wasm32-wasi' -notin (rustup target list --installed)) {
	throw 'wasm32-wasi target may not be installed'
}

# Same as `cargo wasi run`

cargo new $Name --verbose
cargo build --target wasm32-wasi --manifest-path (Join-Path $Name Cargo.toml) --verbose
wasmtime "$Name\target\wasm32-wasi\debug\hello_rust_cargo_wasi.wasm"

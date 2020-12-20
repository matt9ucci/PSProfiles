<#
.LINK
	https://doc.rust-lang.org/book/ch01-03-hello-cargo.html
#>
param (
	[string]
	$Name = 'hello_rust_cargo'
)

cargo new $Name --verbose
cargo run --manifest-path (Join-Path $Name Cargo.toml) --verbose

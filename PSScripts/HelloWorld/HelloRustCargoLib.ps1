<#
.LINK
	https://doc.rust-lang.org/book/ch01-03-hello-cargo.html
#>
param (
	[string]
	$Name = 'hello_rust_cargo_lib'
)

cargo new --lib $Name --verbose
cargo test --manifest-path (Join-Path $Name Cargo.toml) --verbose

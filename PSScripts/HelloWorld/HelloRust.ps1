<#
.LINK
	https://doc.rust-lang.org/book/ch01-02-hello-world.html
#>
param (
	[string]
	$Path = 'hello_rust'
)

ni $Path -ItemType Directory -Force

pushd $Path

Set-Content main.rs @"
fn main() {
	println!("Hello, world!");
}
"@

rustc main.rs
./main

popd

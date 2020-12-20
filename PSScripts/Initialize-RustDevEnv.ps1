# Install Rust
Get-Command curl, sh -ErrorAction Stop | Out-Null
curl https://sh.rustup.rs -sSf | sh -s -- --default-host x86_64-pc-windows-msvc -y

# Add components
$env:Path += ';' + [System.Environment]::GetEnvironmentVariable('PATH', 'User')
rustup component add rls rust-analysis rust-src

# Install Rust for VS Code https://marketplace.visualstudio.com/items?itemName=rust-lang.rust
Get-Command code -ErrorAction Stop | Out-Null
code --install-extension rust-lang.rust

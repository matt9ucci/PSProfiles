Import-Module Multipass

$params = @{
	Name         = 'dev-rust'
	Disk         = 32GB
	UserDataPath = "$PSScriptRoot/dev-rust.yaml"
}
New-MultipassOfMyOwn @params

Write-Host @'
# Run these commands for bash completions
mkdir -p ~/.local/share/bash-completion/completions
rustup completions bash > ~/.local/share/bash-completion/completions/rustup
rustup completions bash cargo > ~/.local/share/bash-completion/completions/cargo
pwsh -c 'rustup completions powershell >> $PROFILE'
'@ -ForegroundColor Green


param (
	[string]
	$Name = (Get-Item $PSCommandPath).BaseName,

	[string]
	$UserName = $env:WSL_USER ?? 'wsl-user'
)

ipmo Wsl

# Paste this user name
Set-Clipboard -Value $UserName

# Clean installation
Unregister-WslDistro -Name $Name
Register-WslDistro -Name $Name

# Allow `sudo` without password
$params = @(
	'echo', "$UserName ALL=(ALL) NOPASSWD: ALL"
	'>'
	"/etc/sudoers.d/$UserName"
)
wsl --distribution $Name --user root @params

# Update packages & Install PowerShell
$params = @(
	'sudo', 'apt-get', 'update'
	'&&'
	'sudo', 'apt-get', 'upgrade', '--yes'
	'&&'
	'sudo', 'snap', 'install', 'powershell', '--classic'
)
wsl --distribution $Name @params

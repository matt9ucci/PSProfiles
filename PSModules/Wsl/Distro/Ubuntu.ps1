ipmo Wsl

$Name = (Get-Item $PSCommandPath).BaseName
$UserName = $env:WSL_USER

# Paste this user name
Set-Clipboard -Value $UserName

# Clean installation
Unregister-WslDistro -Name $Name
Register-WslDistro -Name $Name

# Allow `sudo` without password
$params = @(
	'--distribution', $Name
	'--user', 'root'
	'echo', "$UserName ALL=(ALL) NOPASSWD: ALL", '>', "/etc/sudoers.d/$UserName"
)
wsl @params

# Update
$params = @(
	'--distribution', $Name
	'sudo', 'apt-get', 'update'
	'&&'
	'sudo', 'apt-get', 'upgrade', '--yes'
)
wsl @params

<#
See https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
#>

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error 'Elevation is required : Open a PowerShell console as Administrator'
	return
}

$dism = Get-Command -Name Dism.exe -CommandType Application -ErrorAction Stop

& $dism /Online /Enable-Feature /FeatureName:Microsoft-Hyper-V /All

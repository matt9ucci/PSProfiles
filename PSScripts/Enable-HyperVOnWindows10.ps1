#Requires -RunAsAdministrator

<#
See https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
#>

$dism = Get-Command -Name Dism.exe -CommandType Application -ErrorAction Stop

& $dism /Online /Enable-Feature /FeatureName:Microsoft-Hyper-V /All

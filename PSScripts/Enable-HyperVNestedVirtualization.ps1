param (
	[string]$VMName
)

<#
See https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization
#>

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error 'Elevation is required : Open a PowerShell console as Administrator'
	return
}

$sVMP = Get-Command -Name Set-VMProcessor -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop
$gVMP = Get-Command -Name Get-VMProcessor -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop

& $sVMP -VMName $VMName -ExposeVirtualizationExtensions $true
& $gVMP -VMName $VMName | Format-List VMName, ExposeVirtualizationExtensions

# See https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/live/hyperv-tools/Nested/Enable-NestedVm.ps1
<#
$sVMNA = Get-Command -Name Set-VMNetworkAdapter -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop
$gVMNA = Get-Command -Name Get-VMNetworkAdapter -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop

& $sVMNA -VMName $VMName -MacAddressSpoofing On
& $gVMNA -VMName $VMName | Format-List VMName, MacAddressSpoofing

$sVMMem = Get-Command -Name Set-VMMemory -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop
$gVMMem = Get-Command -Name Get-VMMemory -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop

& $sVMMem -VMName $vmName -DynamicMemoryEnabled $false
& $gVMMem -VMName $VMName
#>

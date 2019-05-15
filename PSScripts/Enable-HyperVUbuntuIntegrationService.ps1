param (
	[string]$VMName
)

<#
For Ubuntu 18.04
See https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
#>

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error 'Elevation is required : Open a PowerShell console as Administrator'
	return
}

# Get 'Guest Service Interface' ID from VM
$vm = Get-VM $VMName
$guestServiceInterfaceId = "Microsoft:$($vm.Id)\6C09BB55-D683-4DA0-8931-C9BF705F6480"
$guestServiceInterface = Get-VMIntegrationService $vm | ? Id -EQ $guestServiceInterfaceId

$eVMIS = Get-Command -Name Enable-VMIntegrationService -Module Hyper-V -CommandType Cmdlet -ErrorAction Stop

& $eVMIS $guestServiceInterface

Write-Host 'Run the following shell in the VM:'
Write-Host @"
sudo apt-get update
sudo apt-get install linux-azure

lsmod | grep hv_utils
ps -ef | grep hv
compgen -c hv_
"@

param (
	[string]$SocketPath = '/tmp/firecracker.socket'
)

Import-Module $PSScriptRoot\Firecracker.psm1
. $PSScriptRoot\Model.ps1

# $PSDefaultParameterValues = @{
# 	'Invoke-FcApi:SocketPath' = "/srv/jailer/firecracker/551e7604-e35c-42b3-b825-41685344123/api.socket"
# }

$apiMethod = 'PUT'
$apiPath = '/boot-source'

$bootSource = New-Object BootSource
$bootSource.kernel_image_path = './hello-vmlinux.bin'
$bootSource.boot_args = 'console=ttyS0 reboot=k panic=1 pci=off'
$body = $bootSource.ToJson()

Invoke-FcApi $apiMethod $apiPath $body $SocketPath

$apiMethod = 'PUT'
$apiPath = '/drives/rootfs'

$drive = New-Object Drive
$drive.drive_id = "rootfs"
$drive.path_on_host = "./hello-rootfs.ext4"
$drive.is_root_device = $true
$drive.is_read_only = $false
$body = $drive.ToJson()

Invoke-FcApi $apiMethod $apiPath $body $SocketPath

$apiMethod = 'PUT'
$apiPath = '/actions'

$instanceActionInfo = New-Object InstanceActionInfo
$instanceActionInfo.action_type = "InstanceStart"
$body = $instanceActionInfo.ToJson()

Invoke-FcApi $apiMethod $apiPath $body $SocketPath

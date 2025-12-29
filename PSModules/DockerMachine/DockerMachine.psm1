if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
	$PSDefaultParameterValues['Invoke-RestMethod:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-RestMethod:ProxyCredential'] = $proxyCredential
}

function New-DockerMachine {
	param (
		[string]$Name = 'default',
		[ValidateSet(
			'amazonec2',
			'azure',
			'digitalocean',
			'exoscale',
			'generic',
			'google',
			'hyperv',
			'none',
			'openstack',
			'rackspace',
			'softlayer',
			'virtualbox',
			'vmwarefusion',
			'vmwarevcloudair',
			'vmwarevsphere'
		)]
		[string]$Driver = 'virtualbox',
		[string]$Version,
		[uint16]$Cpu,
		[uint64]$Memory,
		[string]$HypervVirtualSwitch,
		[switch]$BehindProxy
	)

	$options = @()
	if ($BehindProxy) {
		Get-Item -Path 'Env:HTTP_PROXY', 'Env:HTTPS_PROXY', 'Env:NO_PROXY' -ErrorAction Ignore| ForEach-Object {
			$options += '--engine-env {0}={1}' -f $_.Key, $_.Value
		}
	}
	if ($Version) {
		$url = "https://github.com/boot2docker/boot2docker/releases/download/$Version/boot2docker.iso"
		switch ($Driver) {
			hyperv { $options += "--hyperv-boot2docker-url $url" }
			virtualbox { $options += "--virtualbox-boot2docker-url $url" }
		}
	}
	if ($Cpu) {
		switch ($Driver) {
			hyperv { $options += "--hyperv-cpu-count $Cpu" }
			virtualbox { $options += "--virtualbox-cpu-count $Cpu" }
		}
	}
	if ($Memory) {
		switch ($Driver) {
			hyperv { $options += "--hyperv-memory $($Memory/1MB)" }
			virtualbox { $options += "--virtualbox-memory $($Memory/1MB)" }
		}
	}
	if ($Driver -eq 'hyperv' -and $HypervVirtualSwitch) {
		$options += "--hyperv-virtual-switch '$HypervVirtualSwitch'"
	}
	$options = $options -join ' '

	"docker-machine create --driver $Driver $options $Name"
	Invoke-Expression -Command "docker-machine create --driver $Driver $options $Name"
}

function Connect-DockerMachine([string]$Name = 'default') {
	docker-machine env --shell powershell --no-proxy $Name | Invoke-Expression
}

Register-ArgumentCompleter -CommandName Connect-DockerMachine -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, [string]$wordToComplete)

	if ($wordToComplete) {
		docker-machine ls --quiet --filter name=$wordToComplete
	} else {
		docker-machine ls --quiet
	}
}

function New-SwarmMachine {
	param (
		[int]$ManagerSize = 1,
		[Alias('ClusterSize')]
		[int]$WorkerSize = 2
	)

	1..$ManagerSize | ForEach-Object {
		New-DockerMachine "manager$i"
	}

	1..$WorkerSize | ForEach-Object {
		New-DockerMachine "worker$i"
	}
}

function Get-DockerMachineVersion {
	[CmdletBinding(DefaultParameterSetName = 'Latest')]
	param (
		[Parameter(ParameterSetName = 'All')]
		[switch]
		$All,

		[Parameter(ParameterSetName = 'Latest')]
		[switch]
		$Latest
	)
	if ($Latest) {
		(Invoke-RestMethod "https://api.github.com/repos/docker/machine/releases/latest" -Method Get).tag_name
	} elseif ($All) {
		(Invoke-RestMethod "https://api.github.com/repos/docker/machine/releases" -Method Get -FollowRelLink).tag_name
	} else {
		(Invoke-RestMethod "https://api.github.com/repos/docker/machine/releases" -Method Get).tag_name
	}
}

function Install-DockerMachine {
	[CmdletBinding()]
	param (
		[string]$Version,
		[string]$Os = 'Windows',
		[string]$Architecture = 'x86_64',
		[string]$Extension = '.exe',
		[switch]$Force
	)

	if (Get-Command docker-machine -ErrorAction Ignore) {
		Write-Warning "$(docker-machine version) already exists"
		if (!$Force) {
			return
		}
	}

	if (!$Version) { $Version = Get-DockerMachineVersion -Latest }
	$machineUrl = "https://github.com/docker/machine/releases/download/${Version}/docker-machine-${Os}-${Architecture}${Extension}"
	$outFile = Join-Path $SCRIPTS docker-machine$Extension

	Invoke-WebRequest $machineUrl -OutFile $outFile -Verbose

	$sumUrl = "https://github.com/docker/machine/releases/download/${Version}/sha256sum.txt"
	(Invoke-WebRequest $sumUrl -Verbose).RawContent

	Get-FileHash $outFile -Algorithm SHA256
}

sal dm docker-machine
sal ccdm Connect-DockerMachine

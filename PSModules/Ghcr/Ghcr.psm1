param (
	$GhcrConfig = @{
		UserName   = 'matt9ucci'
		ClixmlPath = Join-Path (Split-Path $PROFILE) GhcrIo.xml
	}
)

function Export-GhcrIoClixml {
	param (
		[pscredential]
		$Credential = (Get-Credential -UserName $GhcrConfig.UserName),

		[string]
		$Path = $GhcrConfig.ClixmlPath
	)

	$ghcrIo = [pscustomobject]@{
		GhcrIoCredential = $Credential
	}

	Export-Clixml -Path $Path -InputObject $ghcrIo
}

function Import-GhcrIoClixml {
	Import-Clixml $GhcrConfig.ClixmlPath
}

function Enter-GhcrIo {
	param (
		[pscredential]
		$Credential
	)

	if (!$PSBoundParameters.ContainsKey('Credential')) {
		$Credential = if (Test-Path $GhcrConfig.ClixmlPath) {
			(Import-GhcrIoClixml).GhcrIoCredential
		} else {
			Get-Credential -UserName $GhcrConfig.UserName
		}
	}

	$Credential.GetNetworkCredential().Password | docker login ghcr.io --username $Credential.GetNetworkCredential().UserName --password-stdin
}

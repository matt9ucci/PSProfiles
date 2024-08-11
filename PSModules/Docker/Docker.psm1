function Get-DockerCliPlugin {
	param (
		[ArgumentCompletions('buildx', 'compose', 'scan')]
		[string]
		$Name
	)

	$format = if ($Name) {
		@(
			'{{range .ClientInfo.Plugins}}'
			"{{if eq .Name \`"$Name\`"}}"
			'{{json .}}'
			'{{end}}'
			'{{end}}'
		)
	} else {
		'{{json .ClientInfo.Plugins}}'
	}

	docker system info --format (-join $format) | ConvertFrom-Json
}

function Invoke-DockerEphemeralContainer {
	param (
		[ArgumentCompleter({
			param ($CommandName, $ParameterName, $WordToComplete)
			(docker image ls --format '{{.Repository}}:{{.Tag}}') -like '*:latest' -notlike '*:<none>' -replace ':latest$' |
			Sort-Object |
			Get-Unique |
			? { $_ -like "$WordToComplete*" }
		})]
		[string]
		$Image,

		[string]
		$Command
	)

	docker run --rm -it $Image $Command
}

function Install-DockerCli {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete, [System.Management.Automation.Language.CommandAst]$CommandAst, [hashtable]$FakeBoundParameters)

			[string[]]$versions = (iwr https://download.docker.com/win/static/stable/x86_64).Content |
				sls '<a .*>docker-(.*).zip</a>' -AllMatches |
				% Matches |
				% { $_.Groups[1].Value }
			$versions -like "$WordToComplete*"
		})]
		[Parameter(Mandatory)]
		$Version
	)

	$params = @{
		Uri     = 'https://download.docker.com/win/static/stable/x86_64/docker-{0}.zip' -f $Version
		OutFile = 'docker.zip'
		Verbose = $true
	}
	Invoke-WebRequest @params

	Expand-Archive -Path $params.OutFile -DestinationPath $USERCOMMANDS -Force
	Remove-Item -Path $params.OutFile
}

sal idephemeral Invoke-DockerEphemeralContainer

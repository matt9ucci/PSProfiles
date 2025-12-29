function Expand-NodeJSBinary {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path,

		[string]
		$DestinationPath = '.',

		[string]
		$Version
	)

	if (!$Version) {
		$Version = ((Split-Path $Path -Leaf) -split '-')[1]
	}

	$expanded = Expand-Archive -Path $Path -DestinationPath $DestinationPath -PassThru
	$expandedRoot = ($expanded | ? PSIsContainer)[0]
	Rename-Item -Path $expandedRoot.FullName -NewName $Version -Verbose
}

function Save-NodeJsBinary {
	param (
		[string]
		$Version,
		[string]
		$Path
	)

	if ($Version) {
		if (!(Get-NodeJsDistributionVersion -Force) -contains $Version) {
			throw "Invalid `$Version [$Version]"
		}
	} else {
		$Version = Get-NodeJsDistributionVersion -Latest -Lts -Force
	}

	$uri = 'https://nodejs.org/dist/{0}/node-{0}-win-x64.zip' -f $Version

	if ($Path) {
		if (Test-Path $Path -PathType Container) {
			# $Path = directory
			$outFile = Join-Path $Path (Split-Path $uri -Leaf)
		} elseif (Test-Path (Split-Path $Path) -PathType Container) {
			# $Path = directory + file name
			$outFile = $Path
		} else {
			throw "Invalid `$Path [$Path]: use existing directory"
		}
	} else {
		$outDirectory = Join-Path $HOME Downloads
		if (Test-Path $outDirectory -PathType Container) {
			$outFile = Join-Path $outDirectory (Split-Path $uri -Leaf)
		} else {
			throw "Default save directory is not found [$outDirectory]"
		}
	}

	Invoke-WebRequest $uri -OutFile $outFile
	Get-Item $outFile
}

Register-ArgumentCompleter -ParameterName Version -CommandName (Get-Command -Noun NodeJsBinary) -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	(& $DistributionIndex).version -like "$wordToComplete*"
}

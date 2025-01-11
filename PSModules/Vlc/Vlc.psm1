function Get-Vlcrc {
	$vlcrc = Get-Content (Join-Path $env:APPDATA vlc vlcrc)
	$vlcrc | sls '(?=^[^#\[])'
}

function Open-Vlcrc {
	code (Join-Path $env:APPDATA vlc vlcrc)
}

function Start-Vlc {
	param (
		[Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Path,

		[uint]
		$StartTime,

		[uint]
		$StopTime,

		[switch]
		$Repeat,

		[switch]
		$Fullscreen,

		[switch]
		$ShowVideoTitle,

		[ValidateSet('auto', 'blend', 'bob', 'discard', 'ivtc', 'linear', 'mean', 'phosphor', 'x', 'yadif', 'yadif2x')]
		[string]
		$DeinterlaceMode,

		[switch]
		$Random
	)

	$params = @(
		$Path
		if ($ShowVideoTitle) { '--video-title-show' } else { '--no-video-title-show' }
		if ($Random) { '--random' } else { '--no-random' }
	)

	if ($StartTime) {
		$params += '--start-time', $StartTime
	}
	if ($StopTime) {
		$params += '--stop-time', $StopTime
	}
	if ($Repeat) {
		$params += '--repeat'
	}
	if ($Fullscreen) {
		$params += '--fullscreen'
	}
	if ($DeinterlaceMode) {
		$params += '--deinterlace-mode', $DeinterlaceMode
	}

	vlc @params
}

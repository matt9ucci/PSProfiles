function ConvertFrom-ComObject {
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[System.__ComObject]$InputObject,
		[int]$Depth = 2
	)

	$hash = @{}
	foreach ($name in $InputObject.psobject.properties.Name) {
		$value = $InputObject."$name"

		if ($Depth -le 0) {
			$hash[$name] = $value
		} elseif ($value -is [System.__ComObject]) {
			$hash[$name] = ConvertFrom-ComObject -InputObject $value -Depth ($Depth - 1)
		} elseif ($value -is [array] -and $value[0] -is [System.__ComObject]) {
			$list = New-Object System.Collections.ArrayList
			foreach ($v in $value) {
				if ($v -is [System.__ComObject]) {
					$list.Add($(ConvertFrom-ComObject -InputObject $v -Depth ($Depth - 1))) > $null
				} else {
					$list.Add($v) > $null
				}
			}
			$hash[$name] = $list
		} else {
			$hash[$name] = $value
		}
	}
	[PSCustomObject]$hash
}

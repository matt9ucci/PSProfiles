function Get-MutableProperty {
	param (
		[Parameter(ValueFromPipeline)]
		$Object
	)

	Get-Member -InputObject $Object -MemberType Property |
		Where-Object Definition -Like '*{set}*'
}

function ConvertTo-Param {
	param (
		[Parameter(ValueFromPipeline)]
		[Microsoft.PowerShell.Commands.MemberDefinition[]]
		$Property
	)

	Begin {
		$result = New-Object System.Collections.ArrayList
	}

	Process {
		foreach ($p in $Property) {
			
			$definition = $p.Definition -split ' '
			$type = switch -Wildcard -CaseSensitive ($definition[0]) {
				string { '[string]' }
				int { '[int]' }
				uint { '[uint32]' }
				'I*' { '' }
				'SAFEARRAY(I*' { '' }
				'SAFEARRAY*' { $_ -replace 'SAFEARRAY\((.*)\)', '[$1[]]' }
				Default { "[$_]" }
			}
			$result.Add($('{0}${1}' -f $type, $p.Name)) > $null
		}
	}

	End {
		'param ('
		$result -join ",`n"
		')'
	}
}

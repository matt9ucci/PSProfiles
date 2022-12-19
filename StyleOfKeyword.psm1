using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Collections.ObjectModel
using namespace System.Management.Automation.Language

<#
.SYNOPSIS
	StyleOfKeyword
.DESCRIPTION
	All keywords should be:
		* lowercase
	`param` should be:
		* followed by one space
#>
function Measure-StyleOfKeyword {
	[CmdletBinding()]
	[OutputType([DiagnosticRecord[]])]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[Token[]]
		$InputToken
	)

	begin {
		$results = @()
	}

	process {
		for ($i = 0; $i -lt $InputToken.Count; $i++) {
			$token = $InputToken[$i]
			$nextToken = $InputToken[$i + 1]

			# Rules for all keywords
			if ($token.TokenFlags -band [TokenFlags]::Keyword) {
				if ($token.Text -cmatch '[A-Z]') {
					$suggestedCorrections = [Collection[CorrectionExtent]]::new()
					$suggestedCorrections.Add([CorrectionExtent]::new($token.Extent, $token.Text.ToLower(), $MyInvocation.MyCommand.Definition)) | Out-Null

					$results += [DiagnosticRecord]@{
						Message              = "Keyword ""$($token.Text)"" should be lowercase"
						Extent               = $token.Extent
						RuleName             = $PSCmdlet.MyInvocation.InvocationName -replace 'Measure-'
						Severity             = [DiagnosticSeverity]::Warning
						SuggestedCorrections = $suggestedCorrections
					}
				}
			}

			# Rules for `param` keyword
			switch ($token.Kind) {
				Param {
					if (($null -ne $nextToken) -and ($nextToken.Extent.StartOffset - $token.Extent.EndOffset) -ne 1) {
						$results += [DiagnosticRecord]@{
							Message  = "Keyword ""$($token.Text)"" should be followed by one space"
							Extent   = $token.Extent
							RuleName = $PSCmdlet.MyInvocation.InvocationName -replace 'Measure-'
							Severity = [DiagnosticSeverity]::Warning
						}
					}
				}
			}
		}
	}

	end {
		$results
	}
}

Export-ModuleMember -Function 'Measure-StyleOfKeyword'

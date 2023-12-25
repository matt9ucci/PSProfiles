$help = pwsh -Help
$completionResults = foreach ($line in $help) {
	switch -regex ($line) {
		^- {
			if ($sb.Length -gt 0) {
				$s = $sb.ToString()
				$toolTip = $s.Substring(0, $s.IndexOf('.') + 1)
				foreach ($p in $parameters) {
					"[CompletionResult]::new('{0}', '{0}', 'ParameterName', '{1}')" -f $p, $toolTip
				}
				$sb.Clear() | Out-Null
			}
			$parameters = $line -split '[\|,]' | % Trim
		}
		^\s+.+ {
			if ($sb.Length -le 0) {
				$sb = New-Object System.Text.StringBuilder
			} else {
				$sb.Append(' ') | Out-Null
			}
			$sb.Append($line.Trim()) | Out-Null
		}
	}
}

# Add last line
$completionResults += if ($sb.Length -gt 0) {
	$s = $sb.ToString()
	$toolTip = $s.Substring(0, $s.IndexOf('.') + 1)
	foreach ($p in $parameters) {
		"[CompletionResult]::new('{0}', '{0}', 'ParameterName', '{1}')" -f $p, $toolTip
	}
	$sb.Clear() | Out-Null
}

@"
using namespace System.Management.Automation

Register-ArgumentCompleter -CommandName pwsh -ScriptBlock {
	param ([string]`$wordToComplete)
	if (`$wordToComplete.StartsWith('-')) {
		@(
			$($completionResults -join "`n`t`t`t")
		) | ? CompletionText -Like `$wordToComplete*
	}
}
"@ > PwshCompleter.ps1

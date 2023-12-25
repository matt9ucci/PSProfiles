if (Get-Command aws_completer -ErrorAction Ignore) {
	Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
		param ($commandName, [string]$wordToComplete, $cursorPosition)

		$env:COMP_LINE = $wordToComplete + $(if ($wordToComplete.Length -lt $cursorPosition) { ' ' })

		$env:COMP_POINT = $cursorPosition

		aws_completer | % {
			[System.Management.Automation.CompletionResult]::new($_, $_, 'Text', $_)
		}

		Remove-Item Env:\COMP_LINE, Env:\COMP_POINT
	}
}

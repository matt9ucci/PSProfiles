Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
	param ($wordToComplete, $commandAst, $cursorPosition)

	$env:COMP_LINE = $commandAst.Extent.Text.PadRight($cursorPosition, ' ')
	$env:COMP_POINT = $cursorPosition

	aws_completer

	$env:COMP_LINE = $env:COMP_POINT = $null
}

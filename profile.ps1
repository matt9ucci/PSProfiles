sal gh help
function ll([string[]]$Path = '.') { gci $Path -Exclude .* }
function sl.. { sl .. }
function sl~ { sl ~ }

function prompt {
	$Host.UI.RawUI.WindowTitle = "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))"
	return 'PS> '
}

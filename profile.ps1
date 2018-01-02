sv PROFILEDIR (Split-Path $PROFILE) -Option ReadOnly, AllScope
sv SCRIPTS (Join-Path $HOME Scripts) -Option ReadOnly, AllScope

sal gh help
function ll([string[]]$Path = '.') { gci $Path -Exclude .* }
function sl.. { sl .. }
function sl~ { sl ~ }

function prompt {
	$Host.UI.RawUI.WindowTitle = "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))"
	return 'PS> '
}

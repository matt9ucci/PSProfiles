sv DESKTOP (Join-Path $HOME Desktop) -Option ReadOnly, AllScope
sv DOWNLOADS (Join-Path $HOME Downloads) -Option ReadOnly, AllScope
sv PROFILEDIR (Split-Path $PROFILE) -Option ReadOnly, AllScope
sv SCRIPTS (Join-Path $HOME Scripts) -Option ReadOnly, AllScope

sal gh help

sal d docker
sal dc docker-compose
sal dm docker-machine
sal g git

function ll([string[]]$Path = '.') { gci $Path -Exclude .* }
function sl.. { sl .. }
function sl~ { sl ~ }

function prompt {
	$Host.UI.RawUI.WindowTitle = "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))"
	return 'PS> '
}

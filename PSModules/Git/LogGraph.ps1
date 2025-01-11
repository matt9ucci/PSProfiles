function Get-LogGraph {
	param (
		[switch]
		$Reflog
	)

	if ($Reflog) {
		igit log --graph --reflog
	} else {
		igit log --graph
	}
}
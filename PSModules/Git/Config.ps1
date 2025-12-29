function Get-ConfigLocation {
	$system = [pscustomobject]@{ PSTypeName = 'Git.Config.PathInfo'; Scope = 'System'; Path = '' }
	$global = [pscustomobject]@{ PSTypeName = 'Git.Config.PathInfo'; Scope = 'Global'; Path = '' }
	$local = [pscustomobject]@{ PSTypeName = 'Git.Config.PathInfo'; Scope = 'Local'; Path = '' }
	$command = [pscustomobject]@{ PSTypeName = 'Git.Config.PathInfo'; Scope = 'Command'; Path = '' }
	$target = $null

	# system`0path`0 ... `0global`0path`0 ... `0local`0path`0 ...
	(git config --list --show-origin --show-scope --null --path) -split "`0" | % {
		if ($target -and !$target.Path) {
			$path = $_ -replace 'file:'
			if ($target.Scope -eq 'Local') {
				$path = Join-Path (git rev-parse --show-toplevel) $path
			}
			$target.Path = Resolve-Path $path
			$target = $null
		}
		switch ($_) {
			system { $target = $system }
			global { $target = $global }
			local { $target = $local }
			command { $target = $command }
		}
	}
	$system
	$global
	$local
	$command
}
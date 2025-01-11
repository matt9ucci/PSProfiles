Register-ArgumentCompleter -CommandName code, c -Native -ScriptBlock {
	param ([string]$wordToComplete)

	Get-ChildItem $HOME\Repository\*\*\* -ErrorAction Ignore
	| ? FullName -Like "*$wordToComplete*"
	| % FullName
	| Sort-Object

	@(
		"$HOME\gitlocal"
		"$HOME\github.com"
		"$HOME\bitbucket.org"
		"$HOME\CodeCommit"
	) | ? { Test-Path $_ } | % {
		Get-ChildItem $_ | ? Name -Like "$wordToComplete*" | % FullName
	}

	if ($env:GOPATH) {
		(Get-ChildItem $env:GOPATH\src\github.com\*\*) | ? Name -Like "$wordToComplete*" | % FullName
	}

	(Get-ChildItem -Name) -like "$wordToComplete*" | Resolve-Path -Relative
}

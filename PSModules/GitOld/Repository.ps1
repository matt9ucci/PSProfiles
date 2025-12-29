[scriptblock]$Repositories = & {
	$cache = $null
	{
		param ([switch]$Force)

		if (!$cache -or $Force) {
			$user = 'matt9ucci'

			$uri = 'https://api.github.com/users/{0}/starred' -f $user
			$script:cache += Invoke-RestMethod $uri -FollowRelLink

			$uri = 'https://api.github.com/users/{0}/repos' -f $user
			$script:cache += Invoke-RestMethod $uri -FollowRelLink
		}
		$cache
	}.GetNewClosure()
}

<#
.PARAMETER Uri
	The repository to clone from.
.PARAMETER Path
	The directory to clone into.
.PARAMETER Depth
	The history of repository will be truncated to the number.
#>
function Copy-Repository {
	param (
		[uri]
		$Uri,
		[string]
		$Path,
		[uint]
		$Depth
	)

	$command = [System.Collections.ArrayList]@(
		'git'
		'clone'
	)

	if ($Depth) {
		$command.Add('--depth') | Out-Null
		$command.Add($Depth) | Out-Null
	}

	$command.Add($Uri) | Out-Null
	$command.Add($Path) | Out-Null

	Invoke-Expression -Command ($command -join ' ')
}

Register-ArgumentCompleter -ParameterName Uri -CommandName 'Copy-Repository' -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	(& $Repositories).clone_url -like "*$wordToComplete*"
}

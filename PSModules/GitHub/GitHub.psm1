$DefaultUserName = 'matt9ucci'
$DefaultStarredJsonPath = "$PSScriptRoot\..\..\Temp\$DefaultUserName-starred.json"
$StarredJsonCache = Get-Content $DefaultStarredJsonPath -ErrorAction Ignore | ConvertFrom-Json -ErrorAction Ignore

if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
	$PSDefaultParameterValues['Invoke-RestMethod:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-RestMethod:ProxyCredential'] = $proxyCredential
}

function Save-Starred {
	param (
		$UserName = $DefaultUserName,
		$Path = $DefaultStarredJsonPath
	)

	$res = Get-Starred
	if (!(Test-Path (Split-Path $Path))) {
		New-Item (Split-Path $Path) -ItemType Directory
	}
	$res | ConvertTo-Json | Out-File $Path
}

function Get-Starred {
	param (
		[ValidateSet('archived', 'archive_url', 'assignees_url', 'blobs_url', 'branches_url', 'clone_url', 'collaborators_url', 'comments_url', 'commits_url', 'compare_url', 'contents_url', 'contributors_url', 'created_at', 'default_branch', 'deployments_url', 'description', 'downloads_url', 'events_url', 'fork', 'forks', 'forks_count', 'forks_url', 'full_name', 'git_commits_url', 'git_refs_url', 'git_tags_url', 'git_url', 'has_downloads', 'has_issues', 'has_pages', 'has_projects', 'has_wiki', 'homepage', 'hooks_url', 'html_url', 'id', 'issues_url', 'issue_comment_url', 'issue_events_url', 'keys_url', 'labels_url', 'language', 'languages_url', 'license', 'merges_url', 'milestones_url', 'mirror_url', 'name', 'node_id', 'notifications_url', 'open_issues', 'open_issues_count', 'owner', 'private', 'pulls_url', 'pushed_at', 'releases_url', 'size', 'ssh_url', 'stargazers_count', 'stargazers_url', 'statuses_url', 'subscribers_url', 'subscription_url', 'svn_url', 'tags_url', 'teams_url', 'trees_url', 'updated_at', 'url', 'watchers', 'watchers_count')]
		[string[]]
		$Property,

		[string]
		$UserName = $DefaultUserName,

		[switch]
		$NoCache
	)

	if ($NoCache -or !$StarredJsonCache) {
		$uri = 'https://api.github.com/users/{0}/starred' -f $UserName
		$script:StarredJsonCache = Invoke-RestMethod $uri -FollowRelLink -Verbose # TODO error handling
	}

	if ($Property) { $StarredJsonCache | % { $_ | Select-Object $Property } | Sort-Object }
	else { $StarredJsonCache }
}

function Get-Release {
	param (
		[Parameter(Mandatory)]
		[string]$Owner,
		[Parameter(Mandatory)]
		[string]$Repository,
		[string]$Tag
	)

	if ($Tag) {
		$uri = 'https://api.github.com/repos/{0}/{1}/releases/tags/{2}' -f $Owner, $Repository, $Tag
	} else {
		$uri = 'https://api.github.com/repos/{0}/{1}/releases/latest' -f $Owner, $Repository
	}

	Invoke-RestMethod $uri -Verbose
}
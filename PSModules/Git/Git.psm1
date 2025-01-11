[System.Management.Automation.CommandInfo]$defaultGitCommand = gcm git

function Invoke-DefaultGitCommand {
	Write-Host ('Invoking: git', $args) -ForegroundColor Green
	& $defaultGitCommand @args
}

function Start-Rebase([int]$Last) {
	git rebase -i "HEAD~$Last"
}

sal igit Invoke-DefaultGitCommand

. $PSScriptRoot\Branch.ps1
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\LogGraph.ps1
. $PSScriptRoot\LogPretty.ps1
. $PSScriptRoot\Repository.ps1
. $PSScriptRoot\Tag.ps1

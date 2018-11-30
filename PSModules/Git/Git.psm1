function Start-Rebase([int]$Last) {
	git rebase -i "HEAD~$Last"
}

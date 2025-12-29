$LOCALPROFILEDIR = Join-Path $HOME .psprofiles
$LOCALPROFILE_BASENAME = 'profile'
$LOCALPROFILE = Join-Path $LOCALPROFILEDIR "$LOCALPROFILE_BASENAME.ps1"

function New-LocalProfile {
	if (Test-Path $LOCALPROFILE) {
		# Backup current profile
		Rename-Item -Path $LOCALPROFILE -NewName "$LOCALPROFILE_BASENAME-$(Get-Date -Format yyMMdd-HHmmss).ps1"
	}

	New-Item $LOCALPROFILE -Force
}

Export-ModuleMember -Function @(
	'New-LocalProfile'
) -Variable @(
	'LOCALPROFILE'
	'LOCALPROFILEDIR'
)

param (
	[string]$Directory = '.',
	[string]$IconFile = '',
	[int]$IconIndex = 0,
	[string]$FolderType = '',
	[string]$InfoTip = ''
)

${desktop.ini} = @"
[.ShellClassInfo]
IconResource=$IconFile,$IconIndex
InfoTip=$InfoTip
[ViewState]
Mode=
Vid=
FolderType=$FolderType
"@

$ini = Join-Path $Directory 'desktop.ini'

Set-Content -Path $ini -Value ${desktop.ini}

(Get-Item $ini -Force).Attributes = 'Archive, Hidden, System'
(Get-Item $ini -Force).Directory.Attributes = 'ReadOnly, Directory'

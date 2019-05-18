function New-Directory([string[]]$Path) { New-Item $Path -Force -ItemType Directory }
Set-Alias nd New-Directory
function Remove-Directory([string[]]$Path) { Remove-Item $Path -Recurse -Force -Confirm }
Set-Alias rd Remove-Directory

#Requires -RunAsAdministrator

Push-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\

sp Explorer ShowRecent 0 # Do not show recently used files in Quick access
sp Explorer ShowFrequent 0 # Do not show frequently used folders in Quick access
sp Explorer\Advanced Hidden 1 # Show hidden files, folders, or drives
sp Explorer\Advanced HideFileExt 0 # Show extensions for known file types
sp Explorer\Advanced ShowTaskViewButton 0 # Hide Task View button
sp Explorer\Advanced TaskbarSmallIcons 1 # User small taskbar buttons
sp ContentDeliveryManager SubscribedContent-338388Enabled 0 # Hide suggestions occasionally in Start
sp Search SearchboxTaskbarMode 0 # Hide search box

Pop-Location

Push-Location HKCU:\Software\Policies\Microsoft\Windows\

ni Explorer
sp Explorer DisableSearchBoxSuggestions 1 # Disable web search in the Start menu

Pop-Location

Push-Location HKCU:\Software\Microsoft\IME\15.0\IMEJP\MSIME

sp . InputSpace 2 # Space: Always Half-width

Pop-Location

Push-Location 'HKCU:\Control Panel'

sp Accessibility\StickyKeys Flags 506 # Disable sticky keys shortcut
sp Desktop CursorBlinkRate -1 # Cursor blink rate: None
sp Desktop\WindowMetrics ScrollWidth -320 # -255 on Windows 11, too thin!

Pop-Location

. $PSScriptRoot/Uninstall-WindowsApps.ps1

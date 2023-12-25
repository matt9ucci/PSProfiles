function New-CommandCompletionResult {
	[Alias('CMCOMP')]
	param (
		[string]$CompletionText,
		[string]$ToolTip
	)

	New-Object System.Management.Automation.CompletionResult $CompletionText, $CompletionText, ([System.Management.Automation.CompletionResultType]::Command), $ToolTip
}

function New-ParameterNameCompletionResult {
	[Alias('PNCOMP')]
	param (
		[string]$CompletionText,
		[string]$ToolTip
	)

	New-Object System.Management.Automation.CompletionResult $CompletionText, $CompletionText, ([System.Management.Automation.CompletionResultType]::ParameterName), $ToolTip
}

$multipassCompleters = @{}

$multipassCompleters['multipass'] = {
	CMCOMP delete   'Delete instances'
	CMCOMP exec     'Run a command on an instance'
	CMCOMP find     'Display available images to create instances from'
	CMCOMP get      'Get a configuration option'
	CMCOMP help     'Display help about a command'
	CMCOMP info     'Display information about instances'
	CMCOMP launch   'Create and start an Ubuntu instance'
	CMCOMP list     'List all available instances'
	CMCOMP mount    'Mount a local directory in the instance'
	CMCOMP networks 'List available network interfaces'
	CMCOMP purge    'Purge all deleted instances permanently'
	CMCOMP recover  'Recover deleted instances'
	CMCOMP restart  'Restart instances'
	CMCOMP set      'Set a configuration option'
	CMCOMP shell    'Open a shell on a running instance'
	CMCOMP start    'Start instances'
	CMCOMP stop     'Stop running instances'
	CMCOMP suspend  'Suspend running instances'
	CMCOMP transfer 'Transfer files between the host and instances'
	CMCOMP umount   'Unmount a directory from an instance'
	CMCOMP version  'Show version details'
}

$multipassCompleterCommon = {
	PNCOMP '-?'   'Display this help'
	PNCOMP '-h'   'Display this help'
	PNCOMP --help 'Display this help'
	PNCOMP '-v'      'Increase logging verbosity, repeat up to three times for more detail'
	PNCOMP --verbose 'Increase logging verbosity, repeat up to three times for more detail'
}

$multipassCompleters['multipass find'] = {
	$multipassCompleterCommon.Invoke()
	PNCOMP --show-unsupported 'Show unsupported cloud images as well'
	PNCOMP --format 'Output list in the requested format. Valid formats are: table (default), json, csv and yaml'
}

$multipassCompleters['multipass launch'] = {
	$multipassCompleterCommon.Invoke()
	PNCOMP '-c'     'Number of CPUs to allocate'
	PNCOMP --cpus 'Number of CPUs to allocate'
	PNCOMP '-d'     'Disk space to allocate. Positive integers, in bytes, or with K, M, G suffix. Minimum: 512M.'
	PNCOMP --disk 'Disk space to allocate. Positive integers, in bytes, or with K, M, G suffix. Minimum: 512M.'
	PNCOMP '-m'    'Amount of memory to allocate. Positive integers, in bytes, or with K, M, G suffix. Mimimum: 128M.'
	PNCOMP --mem 'Amount of memory to allocate. Positive integers, in bytes, or with K, M, G suffix. Mimimum: 128M.'
	PNCOMP '-n'     'Name for the instance'
	PNCOMP --name 'Name for the instance'
	PNCOMP --cloud-init 'Path to a user-data cloud-init configuration, or '-' for stdin'
}

$commandNames = @('multipass')
if ($names = (Get-Alias -Definition multipass -ErrorAction Ignore).Name) {
	$commandNames += $names
}

Register-ArgumentCompleter -Native -CommandName $commandNames -ScriptBlock {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	if ($commandAst.CommandElements[0].Value -eq 'multipass') {
		if ($commandAst.CommandElements[1].Value -eq 'find') {
			$completer = $multipassCompleters['multipass find']
		} elseif ($commandAst.CommandElements[1].Value -eq 'launch') {
			$completer = $multipassCompleters['multipass launch']
		} else {
			$completer = $multipassCompleters['multipass']
		}

		if ($completer -is [scriptblock]) {
			(Invoke-Command -ScriptBlock $completer) | Where-Object CompletionText -Like "$wordToComplete*"
		}
	}
}

function Debug-Completer {
	$commandAst | fl * > $PSScriptRoot\commandAst.txt
	$commandAst | gm >> $PSScriptRoot\commandAst.txt
	$commandAst.CommandElements[0] >> $PSScriptRoot\commandAst.txt	
	$commandAst.CommandElements[1] >> $PSScriptRoot\commandAst.txt	
}

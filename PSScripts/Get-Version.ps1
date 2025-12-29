param (
	[ValidateSet('aws', 'command', 'js', 'language', 'rust')]
	[string[]]
	$Tag
)

@{
	Tag         = 'language'
	Name        = 'dotnet'
	ScriptBlock = { dotnet --version }
},
@{
	Tag         = 'language'
	Name        = 'go'
	ScriptBlock = { go version }
},
@{
	Tag         = 'language'
	Name        = 'java'
	ScriptBlock = { (java --version | Out-String).Trim() }
},
@{
	Tag         = 'language'
	Name        = 'mono'
	ScriptBlock = { mono --version=number }
},
@{
	Tag         = 'language', 'js'
	Name        = 'node'
	ScriptBlock = { node --version }
},
@{
	Tag         = 'language', 'js'
	Name        = 'npm'
	ScriptBlock = { npm --version }
},
@{
	Tag         = 'language', 'js'
	Name        = 'yarn'
	ScriptBlock = { yarn --version }
},
@{
	Tag         = 'language'
	Name        = 'powershell'
	ScriptBlock = { powershell -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' }
},
@{
	Tag         = 'language'
	Name        = 'pwsh'
	ScriptBlock = { pwsh -Version }
},
@{
	Tag         = 'language'
	Name        = 'python'
	ScriptBlock = { python --version }
},
@{
	Tag         = 'language'
	Name        = 'python3'
	ScriptBlock = { python3 --version }
},
@{
	Tag         = 'language', 'rust'
	Name        = 'rustc'
	ScriptBlock = { rustc --version }
},
@{
	Tag         = 'rust'
	Name        = 'cargo'
	ScriptBlock = { cargo --version }
},
@{
	Tag         = 'rust'
	Name        = 'rustup'
	ScriptBlock = { rustup --version }
},
@{
	Tag         = 'aws'
	Name        = 'aws'
	ScriptBlock = { aws --version }
},
@{
	Tag         = 'aws'
	Name        = 'cdk'
	ScriptBlock = { cdk --version }
},
@{
	Tag         = 'aws'
	Name        = 'sam'
	ScriptBlock = { sam --version }
},
@{
	Tag         = 'aws'
	Name        = 'session-manager-plugin'
	ScriptBlock = { session-manager-plugin --version }
},
@{
	Tag         = 'command'
	Name        = 'docker'
	ScriptBlock = { docker --version }
},
@{
	Tag         = 'command'
	Name        = 'git'
	ScriptBlock = { git --version }
},
@{
	Tag         = 'command'
	Name        = 'gh'
	ScriptBlock = { gh --version }
},
@{
	Tag         = 'command'
	Name        = 'make'
	ScriptBlock = { (make --version | Out-String).Trim() }
} | ? { ($Tag.Count -le 0) -or (Compare-Object $_.Tag $Tag -ExcludeDifferent).Count } | % {
	[pscustomobject]@{
		Name    = $_.Name
		Version = $(
			try {
				(Invoke-Command $_.ScriptBlock 2> $null) ?? $PSStyle.Formatting.Error + 'Error' + $PSStyle.Reset
			} catch {
				$PSStyle.Formatting.Error + 'Error' + $PSStyle.Reset
			}
		)
		Command = $_.ScriptBlock.ToString().Trim()
		Tag     = $_.Tag
	}
}

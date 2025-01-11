function Get-CommandInfo {
	cargo --list | % Trim | % {
		$s = $_ -split '\s{4,}'
		[pscustomobject]@{ Name = $s[0]; Description = $s[1] }
	} | Sort-Object Name -Unique
}

function Install-FmtConfigFile4User {
	New-Item -Path $env:APPDATA\rustfmt -ItemType Directory -Force | Out-Null
	Copy-Item -Path $PSScriptRoot/rustfmt4user.toml -Destination $env:APPDATA\rustfmt\rustfmt.toml
}

function Uninstall-FmtConfigFile4User {
	Remove-Item -Path $env:APPDATA\rustfmt -ErrorVariable ev
}

function Get-FmtConfigFile4User {
	Get-Content $env:APPDATA\rustfmt\rustfmt.toml
}

function Out-FmtConfigFile {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path,

		[ValidateSet('current', 'minimal', 'default')]
		[string]
		$Config = 'default'
	)

	$params = @(
		'--print-config'
		$Config
		$Path
	)

	rustfmt @params
}

function Show-Doc {
	param (
		[string]
		$Name,

		[string]
		$Topic
	)

	$params = @()
	if ($Name) {
		$params += "--$Name"
	}
	if ($Topic) {
		$params += $Topic
	}

	rustup doc @params
}

function Get-DocLocation {
	param (
		[string]
		$Name
	)

	$params = @('--path')
	if ($Name) {
		$params += "--$Name"
	}

	rustup doc @params
}

function Uninstall-Rust {
	rustup self uninstall
	Uninstall-FmtConfigFile4User
}

if (([string[]]$pathArray = $env:Path -split [System.IO.Path]::PathSeparator) -notcontains "$HOME/.cargo/bin") {
	$env:Path = ($pathArray + "$HOME/.cargo/bin") -join [System.IO.Path]::PathSeparator
}
rustup completions powershell | Out-String | Invoke-Expression

Register-ArgumentCompleter -CommandName (Get-Command -Module Rust -Noun *Doc*).Name -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	@{ CompletionText = 'alloc'; ToolTip = 'The Rust core allocation and collections library' },
	@{ CompletionText = 'book'; ToolTip = 'The Rust Programming Language book' },
	@{ CompletionText = 'cargo'; ToolTip = 'The Cargo Book' },
	@{ CompletionText = 'core'; ToolTip = 'The Rust Core Library' },
	@{ CompletionText = 'edition-guide'; ToolTip = 'The Rust Edition Guide' },
	@{ CompletionText = 'embedded-book'; ToolTip = 'The Embedded Rust Book' },
	@{ CompletionText = 'nomicon'; ToolTip = 'The Dark Arts of Advanced and Unsafe Rust Programming' },
	@{ CompletionText = 'proc_macro'; ToolTip = 'A support library for macro authors when defining new macros' },
	@{ CompletionText = 'reference'; ToolTip = 'The Rust Reference' },
	@{ CompletionText = 'rust-by-example'; ToolTip = 'A collection of runnable examples that illustrate various Rust concepts and standard libraries' },
	@{ CompletionText = 'rustc'; ToolTip = 'The compiler for the Rust programming language' },
	@{ CompletionText = 'rustdoc'; ToolTip = 'Generate documentation for Rust projects' },
	@{ CompletionText = 'std'; ToolTip = 'Standard library API documentation' },
	@{ CompletionText = 'test'; ToolTip = 'Support code for rustc''s built in unit-test and micro-benchmarking framework' },
	@{ CompletionText = 'unstable-book'; ToolTip = 'The Unstable Book' } | ? CompletionText -Like $wordToComplete* | % {
		[System.Management.Automation.CompletionResult]::new($_.CompletionText, $_.CompletionText, 'Text', $_.ToolTip)
	}
}

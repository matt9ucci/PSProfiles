. $PSScriptRoot\Administrator.ps1
. $PSScriptRoot\Bitwise.ps1
. $PSScriptRoot\Command.ps1
. $PSScriptRoot\Directory.ps1
. $PSScriptRoot\Hash.ps1
. $PSScriptRoot\HttpProxyWindows.ps1
. $PSScriptRoot\PSReadLine.ps1

function Backup-Item {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path,

		[string]
		$Destination,

		[ValidateSet('LastWriteTime', 'Now')]
		$Date = 'Now',

		[ValidateSet('yyMMdd', 'yyMMddHHmmss')]
		[string]
		$DateFormat = 'yyMMdd',

		[switch]
		$Archive
	)

	if (!(Test-Path $Path)) {
		Write-Warning "Backup failed: '$Path' does not exist."
		return
	}

	$dst = if ($Destination) {
		$Destination
	} else {
		$item = Get-Item $Path

		$datetime = switch ($Date) {
			LastWriteTime { $item.LastWriteTime }
			Now { Get-Date }
		}

		"{0}-{1:$DateFormat}{2}" -f @(
			$item.BaseName, $datetime, $item.Extension
		)
	}

	if ($Archive) {
		Compress-Archive $Path "$dst.zip"
	} else {
		Copy-Item $Path $dst -Container -Recurse
	}
}

function New-Junction {
	param (
		[Parameter(Mandatory, Position = 0)]
		[Alias('Target')]
		[string]
		$Value,

		[string]
		$Path = '.',

		[string]
		$Name = (Split-Path $Value -Leaf)
	)

	New-Item -Path $Path -Name $Name -Value $Value -ItemType Junction
}

function New-SymbolicLink {
	param (
		[Parameter(Mandatory, Position = 0)]
		[Alias('Target')]
		[string]
		$Value,

		[string]
		$Path = '.',

		[string]
		$Name = (Split-Path $Value -Leaf)
	)

	New-Item -Path $Path -Name $Name -Value $Value -ItemType SymbolicLink
}

function New-GodMode([string]$Name = 'GodMode') {
	New-Item -Path "$Name.{ED7BA470-8E54-465E-825C-99712043E01C}" -ItemType Directory
}

function Get-Accelerator([string]$Name = '*') {
	$accelerators = [powershell].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
	$accelerators.GetEnumerator() | Where-Object Key -Like $Name | Sort-Object -Property Key
}

function Get-Assembly {
	param (
		[SupportsWildcards()]
		[string]
		$ManifestModule = '*'
	)

	[System.AppDomain]::CurrentDomain.GetAssemblies() |
	? ManifestModule -Like $ManifestModule |
	Sort-Object Location
}

function Edit-Hosts { saps notepad.exe $env:SystemRoot\System32\drivers\etc\hosts -Verb RunAs }
function Edit-Profile {
	param (
		[ValidateSet('AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost', 'Private')]
		[string]
		$Name = 'CurrentUserAllHosts'
	)

	if ($Name -eq 'Private') {
		if (!(Test-Path $PROFILEDIR.Private)) { New-Item $PROFILEDIR.Private -ItemType Directory }
		code "$($PROFILEDIR.Private)\profile.ps1"
	} else {
		code $PROFILE."$Name"
	}
}
function Edit-SshConfig { code $HOME\.ssh\config }

function Export-PwshProxyClixml {
	param (
		[Parameter(Mandatory)]
		[uri]
		$Proxy,

		[pscredential]
		$ProxyCredential,

		[string]
		$Path = (Join-Path (Split-Path $PROFILE) PwshProxy.xml)
	)

	$pwshProxy = [pscustomobject]@{
		Proxy           = $Proxy
		ProxyCredential = $ProxyCredential
	}

	Export-Clixml -Path $Path -InputObject $pwshProxy
}

function Get-Constructor {
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[type]
		$Type
	)

	foreach ($c in $Type.GetConstructors()) {
		[string[]]$paramStrings = $c.GetParameters() | % {
			'[{0}]${1}' -f ($_.ParameterType.FullName, $_.Name)
		}

		'{0}({1})' -f $c.DeclaringType.Name, ($paramStrings -join ', ')
	}
}

function Compare-PSObjectProperties {
	param (
		$ReferenceObject,
		$DifferenceObject
	)

	$referenceProperties = $ReferenceObject.psobject.Properties
	$differenceProperties = $DifferenceObject.psobject.Properties
	$names = $referenceProperties.Name + $differenceProperties.Name | Sort-Object -Unique
	foreach ($n in $names) {
		$result = Compare-Object $ReferenceObject $DifferenceObject -Property $n -ErrorAction Ignore
		if ($result) {
			[PSCustomObject]@{
				Property   = $n
				Reference  = $result | Where-Object SideIndicator -EQ '<=' | ForEach-Object $n
				Difference = $result | Where-Object SideIndicator -EQ '=>' | ForEach-Object $n
			}
		}
	}
}

function Save-WebResource {
	param (
		[uri]
		$Uri,

		[string]
		$OutFile = (Join-Path $DOWNLOADS ((Split-Path $Uri -Leaf) -replace "[$([System.IO.Path]::GetInvalidFileNameChars())]"))
	)

	(Test-Path $OutFile) -or (Invoke-WebRequest $Uri -OutFile $OutFile -Verbose) > $null
	Get-Item $OutFile
}

function New-ModuleItem {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	if (Test-Path $Name) {
		Write-Warning "$Name already exists."
		return
	}

	New-Item -Path (Join-Path $Name "$Name.psm1") -Force

	$param = @{
		Path                 = Join-Path $Name "$Name.psd1"
		RootModule           = "$Name.psm1"
		CompatiblePSEditions = 'Core'
		Author               = 'Matt Gucci'
		LicenseUri           = 'https://github.com/matt9ucci/{0}/blob/master/LICENSE' -f $Name
		ProjectUri           = 'https://github.com/matt9ucci/{0}' -f $Name
		ReleaseNotes         = 'Initial release'
	}
	New-ModuleManifest @param
	$withoutComment = Get-Content $param.Path | % {
		if (($line = ($_ -replace '#.*').Trim())) {
			$line
		}
	}
	Set-Content $param.Path $withoutComment
}

function New-ModuleManifestFromModule {
	param (
		[string]
		$Name
	)

	[psmoduleinfo]$m = Import-Module $Name -PassThru
	$template = @"
@{

RootModule           = '$($m.Name)'
ModuleVersion        = $("'0.0.0.{0}'" -f (Get-Date -Format 'yyMMdd'))
CompatiblePSEditions = 'Core'
Author               = 'Matt Gucci'
Copyright            = '(c) Matt Gucci. All rights reserved.'
PowerShellVersion    = '6.0'

FunctionsToExport = @(
	$(($m.ExportedFunctions.Keys | % { "'{0}'" -f $_ }) -join "`n`t")
)
CmdletsToExport = @(
	$(($m.ExportedCmdlets.Keys | % { "'{0}'" -f $_ }) -join "`n`t")
)
VariablesToExport = @(
	$(($m.ExportedVariables.Keys | % { "'{0}'" -f $_ }) -join "`n`t")
)
AliasesToExport = @(
	$(($m.ExportedAliases.Keys | % { "'{0}'" -f $_ }) -join "`n`t")
)

}
"@

	New-Item -Path ($m.Path -replace 'psm1$', 'psd1') -Value $template
}

function Show-SpecialFolder {
	param (
		[System.Environment+SpecialFolder]
		$Name
	)

	Invoke-Item ([System.Environment]::GetFolderPath($Name))
}

function Search-MicrosoftDocs {
	param (
		[string[]]
		$Word
	)

	$search = $word -join '+'
	saps "https://docs.microsoft.com/en-us/search/index?search=$search"
}

function New-PrivateProfile {
	New-Item "$($PROFILEDIR.Private)\profile.ps1" -Force
}

Set-Alias msdocs Search-MicrosoftDocs

function ConvertTo-PlainText {
	[Alias('ToPlainText')]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[securestring]
		$SecureString
	)
	[System.Net.NetworkCredential]::new('', $SecureString).Password
}

function Show-ByteTable {
	param ([byte]$FirstByte = 0x00, [byte]$LastByte = 0xFF)

	$FirstByte..$LastByte | % {
		[pscustomobject]@{
			Decimal = '{0:D3}' -f $_
			Hex = '0x{0:X2}' -f $_
			Bit = [System.Convert]::ToString($_, 2).PadLeft(8, '0')
		}
	} | Format-Table
}

function ToHash {
	param (
		[string[]]$Path,
		[ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
		[string]$Algorithm = 'SHA256'
	)
	$fh = Get-FileHash @PSBoundParameters
	Set-Clipboard $fh.hash
	$fh
}

filter FromStream {
	[System.IO.StreamReader]::new($_).ReadToEnd()
}

filter ToHex([switch]$Upper) {
	if ($Upper) {
		[System.Convert]::ToString($_, 16).ToUpper()
	} else {
		[System.Convert]::ToString($_, 16)
	}
}

filter FromHex {
	[System.Convert]::ToInt64($_, 16)
}

filter ToBit([UInt32]$ZeroPadding = 8) {
	[System.Convert]::ToString($_, 2).PadLeft($ZeroPadding, '0')
}

filter FromBit {
	[System.Convert]::ToInt64($_, 2)
}

filter Tax {
	$result = @(
		[pscustomobject]@{ Rate = 8; Tax = $_ * 0.08 }
		[pscustomobject]@{ Rate = 10; Tax = $_ * 0.10 }
	)

	$result | ft

	'Price: {0}, Diff: {1}' -f $_, ($result[1].Tax - $result[0].Tax)
}

filter Factorial {
	if ($_ -le 1) {
		1
	} else {
		$tmp = $_ * ($_ - 1 | Factorial)
		Write-Debug ('{0, 8} {1, -1}' -f $_, $tmp)
		$tmp
	}
}

function Get-ZipArchiveEntry {
	[OutputType([System.IO.Compression.ZipArchiveEntry])]
	param (
		[Parameter(Mandatory)]
		[string]
		$Path
	)

	[System.IO.Compression.ZipArchive]$zipArchive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $Path))
	$zipArchive.Entries
	$zipArchive.Dispose()
}

function Set-HistoryToClipboard {
	[Alias('shycb')]
	param (
		[ValidateRange(0, [int]::MaxValue)]
		[int]
		$Last
	)

	$histories = Get-History
	if ($Last) {
		$histories = $histories | select -Last $Last
	}
	$histories | % CommandLine | Set-Clipboard
}

function Out-SortedJson {
	param (
		[string]
		$Path
	)

	$result = [ordered]@{}
	Get-Content $Path | ConvertFrom-Json -OutVariable original | Get-Member -MemberType NoteProperty | Sort-Object Name | % {
		$result[$_.Name] = $original.$($_.Name)
	}
	[pscustomobject]$result | ConvertTo-Json
}

function Set-Prompt {
	param (
		[scriptblock]
		$Definition
	)

	$value = if ($Definition) {
		$Definition.ToString()
	} else {
		pwsh -NoProfile -Command '(Get-Item Function:prompt).Definition' | Out-String
	}
	Set-Item -Path Function:prompt -Value $value
}

function New-CommandJunction {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path,

		[string]
		$Name = (Split-Path $Path -Leaf)
	)

	New-Item -ItemType Junction -Path $HOME\Commands\$Name -Value $Path
}

filter FromBase64 {
	param (
		[System.Text.Encoding]
		$Encoding = [System.Text.Encoding]::UTF8
	)
	$Encoding.GetString([System.Convert]::FromBase64String($_))
}

filter FromBase64ToUtf8 {
	[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))
}

filter FromUrlEncodedString {
	[System.Web.HttpUtility]::UrlDecode($_)
}

filter ToNarrowJaJp {
	[Microsoft.VisualBasic.Strings]::StrConv($_, [Microsoft.VisualBasic.VbStrConv]::Narrow, (Get-Culture -Name ja-JP).LCID)
}

function Show-WindowsSetting {
	param (
		[ArgumentCompleter({
				param ($commandName, $parameterName, $wordToComplete)
				$windowsSetting = @{
					'Notification Area Icons' = { 'explorer', 'shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}' }
				}
				$windowsSetting.Keys | ? { $_ -match $wordToComplete.Trim("'") } | % { "'{0}'" -f $_ }
			})]
		[string]
		$Name
	)

	$params = $windowsSetting.$Name.Invoke()
	Start-Process @params
}

<#
.LINK
	https://docs.github.com/en/rest/reference/licenses#get-all-commonly-used-licenses
#>
function Get-LicenseFromGithub {
	param (
		[ValidateSet('apache-2.0', 'mit', 'mpl-2.0')]
		[string]
		$Key
	)

	$params = @{
		Uri = 'https://api.github.com/licenses' + $(if ($Key) { "/$Key" } else { '' })
	}
	Invoke-RestMethod @params
}

<#
.LINK
	https://docs.github.com/en/rest/reference/licenses#get-a-license
#>
function New-LicenseFile {
	param (
		[ValidateSet('agpl-3.0', 'apache-2.0', 'bsd-2-clause', 'bsd-3-clause', 'bsl-1.0', 'cc0-1.0', 'epl-2.0', 'gpl-2.0', 'gpl-3.0', 'lgpl-2.1', 'mit', 'mpl-2.0', 'unlicense')]
		[Parameter(Mandatory)]
		[string]
		$Key,

		[switch]
		$Commit
	)

	$response = Get-LicenseFromGithub $Key

	$licenseText = $response.body
	if ($key -eq 'mit') {
		$licenseText = $licenseText -replace '\[year\]', [datetime]::Today.Year
		$licenseText = $licenseText -replace '\[fullname\]', 'Masatoshi Higuchi'
	}

	$params = @{
		Path  = 'LICENSE'
		Value = $licenseText
	}
	Set-Content @params -NoNewline

	$response | Select-Object name, description, implementation | Format-List

	if ($Commit) {
		git add $params.Path
		git commit -m 'New LICENSE'
	}
}

function New-ReadmeFile {
	param (
		[switch]
		$Commit
	)

	$params = @{
		Path  = 'README.md'
		Value = "# $(Split-Path (Get-Location) -Leaf)"
	}
	Set-Content @params

	if ($Commit) {
		git add $params.Path
		git commit -m 'New README'
	}
}

function Format-Json {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Path,

		[System.Text.Encoding]
		$Encoding = [System.Text.Encoding]::UTF8,

		[int]
		$Depth = 100,

		[ValidateSet('jq', 'PowerShell')]
		[string]
		$Formatter = 'PowerShell'
	)

	foreach ($jsonPath in $Path) {
		$json = Get-Content $jsonPath -Encoding $Encoding
		switch ($Formatter) {
			PowerShell {
				(ConvertFrom-Json -InputObject $json | ConvertTo-Json -Depth $Depth) -split '\n' | % {
					$_ -replace '\s\s', "`t"
				}
			}
			jq {
				$json | jq --tab .
			}
		}
	}
}

function Get-ComputerWindowsInfo {
	Get-ComputerInfo | select *Windows*
}

function Get-TypeHierarchy {
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[type]
		$Type
	)

	if (($baseType = $Type.BaseType)) {
		Get-TypeHierarchy $baseType
	}
	$Type
}

function Set-BytesString {
	param (
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$BytesString,

		[Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Path
	)

	[byte[]]$bytes = foreach ($byteString in ($BytesString -split ' ')) {
		try {
			[System.Convert]::ToByte($byteString, 16)
		} catch {
			throw "$byteString"
		}
	}

	Set-Content -Path $Path -Value $bytes -AsByteStream
}

function Expand-UserAppArchive {
	param (
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Path,

		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Name = (Get-Item $Path).BaseName
	)

	$destinationPath = Join-Path $USERAPPS $Name
	Expand-Archive -Path $Path -DestinationPath $destinationPath
	Invoke-Item $destinationPath
}

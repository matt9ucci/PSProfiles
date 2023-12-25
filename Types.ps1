$params = @{
	TypeName   = 'System.IO.FileInfo'
	MemberType = 'ScriptProperty'
	MemberName = 'Size'
	Value      = {
		if ($PSVersionTable.PSVersion.Major -gt 5) {
			switch ($this.Length) {
				{ $_ -ge 1GB } { "{0,6}`e[91mGB" -f [System.Math]::Ceiling($_/1GB); break }
				{ $_ -ge 1MB } { "{0,6}`e[33mMB" -f [System.Math]::Ceiling($_/1MB); break }
				{ $_ -ge 1KB } { "{0,6}`e[92mKB" -f [System.Math]::Ceiling($_/1KB); break }
				default { "{0,7}`e[36mB" -f $_ }
			}
		} else {
			switch ($this.Length) {
				{ $_ -ge 1GB } { "{0,6}GB" -f [System.Math]::Ceiling($_/1GB); break }
				{ $_ -ge 1MB } { "{0,6}MB" -f [System.Math]::Ceiling($_/1MB); break }
				{ $_ -ge 1KB } { "{0,6}KB" -f [System.Math]::Ceiling($_/1KB); break }
				default { "{0,7}B" -f $_ }
			}
		}
	}
}
Update-TypeData @params

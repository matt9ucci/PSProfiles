function Get-Tag {
	param (
		[string]
		$Pattern = '*'
	)

	igit tag --list $Pattern
}

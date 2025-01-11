$env:JAVA_HOME_PARENT = if ($env:JAVA_HOME_PARENT) {
	$env:JAVA_HOME_PARENT
} elseif ($IsWindows) {
	"$env:ProgramFiles\Java"
} else {
	'/usr/lib/jvm/'
}

$env:JDK_HOME = if ($env:JDK_HOME) {
	$env:JDK_HOME
} else {
	(Get-ChildItem $env:JAVA_HOME_PARENT -Filter jdk* | Sort-Object @{ Expression = { ($_.Name -replace 'jdk(.*)_(.*)','$1.$2') -as [version] } } -Bottom 1).FullName
}
$env:JAVA_HOME = if ($env:JAVA_HOME) {
	$env:JAVA_HOME
} else {
	$env:JDK_HOME
}

$env:Path = @(
	"$env:JDK_HOME\bin"
	$env:Path
) -join [System.IO.Path]::PathSeparator

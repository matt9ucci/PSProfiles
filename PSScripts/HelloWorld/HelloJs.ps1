<#
.LINK
	https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/JavaScript_basics
#>
param (
	[string]
	$Name = 'HelloJavaScript'
)

New-Item (Join-Path $Name scripts) -ItemType Directory -Force

Push-Location $Name

Add-Content -Path index.html -Value @"
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>$Name</title>
</head>
<body>
	<h1>Say</h1>
	<script src="scripts/main.js"></script>
</body>
</html>
"@

Add-Content -Path scripts/main.js -Value @"
document.querySelector('h1').textContent = 'Hello JavaScript!';
"@

Pop-Location

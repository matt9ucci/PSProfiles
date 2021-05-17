. $PSScriptRoot/Venv.ps1

function Start-HttpServer {
	param (
		[UInt16]
		$Port = 8000
	)

	python -m http.server $Port
}

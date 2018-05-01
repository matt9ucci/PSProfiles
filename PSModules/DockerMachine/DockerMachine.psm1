function Connect-DockerMachine([string]$Name = 'default') {
	docker-machine env --shell powershell --no-proxy $Name | Invoke-Expression
}

Register-ArgumentCompleter -CommandName Connect-DockerMachine -ParameterName Name -ScriptBlock {
	Param($commandName, $parameterName, [string]$wordToComplete)

	if ($wordToComplete) {
		docker-machine ls --quiet --filter name=$wordToComplete
	} else {
		docker-machine ls --quiet
	}
}

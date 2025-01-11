function Open-DockerHub {
	param (
		$Repository
	)

	saps https://hub.docker.com/r/$Repository
}
<#
.LINK
	https://github.com/docker/app/blob/master/README.md
#>

New-Item HelloWorld -ItemType Directory

Push-Location HelloWorld

Add-Content -Path docker-compose.yml -Value @'
version: '3.6'
services:
  hello:
    image: hashicorp/http-echo
    command: ["-text", "${text}"]
    ports:
      - ${port}:5678
'@

docker app init --compose-file docker-compose.yml hello

Set-Content ./hello.dockerapp/parameters.yml @'
port: 5678
text: hello development
'@

Pop-Location

Write-Host @'
# Next step
docker run -d -p 5000:5000 --restart always --name registry registry:2
docker app build . -f hello.dockerapp -t localhost:5000/hello:0.1.0
docker app push localhost:5000/hello:0.1.0
docker app run localhost:5000/hello:0.1.0
'@

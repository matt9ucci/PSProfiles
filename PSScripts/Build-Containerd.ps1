git clone --branch master https://github.com/containerd/containerd.git $env:GOPATH\src\github.com\containerd\containerd
Set-Location $env:GOPATH\src\github.com\containerd\containerd
git checkout -qf 09a5b1f8af9bbc652f0b168fcaaab4a070d338ef
choco install -y mingw --version 5.3.0
$env:Path += ";C:\tools\mingw64\bin"

Set-Location $env:GOPATH\src\github.com\containerd\containerd
bash.exe -elc 'export PATH=/c/tools/mingw64/bin:$HOME/go/bin:$PATH; script/setup/install-dev-tools;'
mingw32-make.exe check
mingw32-make.exe build binaries

ri -Confirm $HOME/.gitconfig

git config --global user.name 'Matt Gucci'
git config --global user.email 8044346+matt9ucci@users.noreply.github.com

git config --global core.editor vi
git config --global credential.helper wincred

git config --global core.longpaths true

& $PSScriptRoot\Initialize-GitAlias.ps1

git config --global url.https://.insteadOf git://

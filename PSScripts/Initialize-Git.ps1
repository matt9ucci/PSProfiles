ri -Force $HOME/.gitconfig

git config --global user.name 'Matt Gucci'
git config --global user.email matt9ucci@gmail.com

git config --global core.editor vi
git config --global credential.helper wincred

git config --global alias.br branch
git config --global alias.c commit
git config --global alias.co checkout
git config --global alias.l1 'log --oneline'
git config --global alias.rb 'rebase -i'
git config --global alias.st status

git config --global url.https://.insteadOf git://

#!/bin/bash

curl https://krypt.co/kr | sh

INITIALIZED_FLAG=".startup_script_initialized"

if [ -f "${INITIALIZED_FLAG}" ]; then
	exit 0
fi

touch $INITIALIZED_FLAG



sudo apt update &&\
sudo apt install -y gnupg2 ca-certificates lsb-release \
    apt-transport-https software-properties-common

sudo apt install -y git tmux mosh vim-gtk


echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -

sudo apt update &&\
sudo apt install -y nginx


curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

sudo apt update &&\
sudo apt install -y docker-ce docker-ce-cli containerd.io

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


sudo apt install -y  locales
sudo echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen
sudo locale-gen ja_JP.UTF-8
sudo /usr/sbin/update-locale LANG=ja_JP.UTF-8
sudo localedef -f UTF-8 -i ja_JP ja_JP.utf8


sudo mkdir -p /usr/local/etc/bash_completion.d
sudo wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -O /usr/local/etc/bash_completion.d/git-completion.bash
sudo chmod a+x  /usr/local/etc/bash_completion.d/git-completion.bash
sudo wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O /usr/local/etc/bash_completion.d/git-prompt.sh
sudo chmod a+x /usr/local/etc/bash_completion.d/git-prompt.sh


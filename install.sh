#!/bin/bash

rm -rf ~/.vim* ~/vim*

# add library configure support here
sudo apt-get install -y python-dev python3-dev

sudo apt-get install -y \
	libncurses5-dev libgnome2-dev libgnomeui-dev \
	libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
	libcairo2-dev libx11-dev libxpm-dev libxt-dev

sudo apt remove -y vim vim-runtime gvim
sudo apt remove -y vim-tiny vim-common vim-gui-common vim-nox
sudo upgrade

#Optional: so vim can be uninstalled again via `dpkg -r vim`
# sudo apt-get install -y checkinstall 

sudo rm -rf /usr/local/share/vim /usr/bin/vim

cd ~
git clone https://github.com/vim/vim
cd vim

./configure \
	--with-features=huge \
	--enable-multibyte \
	--enable-pythoninterp=yes \
	--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
	--enable-python3-interp=yes \
	--with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
	--enable-gui=gtk2 \
	--enable-cscope \
	--with-compiledby="amead24" \
	--prefix=/usr/local

make VIMRUNTIMEDIR=/usr/local/share/vim/vim81
sudo make install

sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

# Clone and install Vundle
cd ~
echo 'Downloading and Installing Vundle'
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Copy over vim configuration 
cd ~/settings
echo 'Copying personal vim settings'
cp -R ./colors/. ~/.vim/colors/
cp ./vim-conf.vim ~/.vimrc

# copy over tmux configuration
echo 'Copying personal tmux settings'
cp ./tmux.conf ~/.tmux.conf

cd ~

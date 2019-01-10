#!/bin/bash
Usage() {
	( echo "
	-b | --build-binary : to create vim81 binary with python3
	-p | --build-python : to create python dependencies for vim-python
	-r | --build-rust   : to create rust depenencies for vim-rust
	-c | --build-cpp    : to create cpp depenencies for ???
	"
	) 1>&2
	exit 1
}


build_core(){
        # Clone and install Vundle
        echo 'Downloading and Installing Vundle...'
        cd ~ && rm -rf ~/.vim/bundle/Vundle.vim
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        vim +PluginInstall +qall

        # Copy over vim configuration
        echo 'Copying personal vim settings...'
	cp -R settings/colors/ ~/.vim/colors/
        cp settings/vim.conf ~/.vimrc
        sudo chown $(id -u):$(id -g) ~/.viminfo

        # copy over tmux configuration
        echo 'Copying personal tmux settings...'
        cp settings/tmux.conf ~/.tmux.conf

        cp settings/bash_aliases ~/.bash_aliases
        if grep -p '-f ~/.bash_aliases' ~/.bashrc; then
                echo -e 'if [ -f ~/.bash_aliases ]; then\n\t. ~/.bash_aliases\nfi' >> ~/.bashrc
        fi

        # set default editor to vim
        echo "export EDITOR='vim'" >> ~/.bashrc
        echo "export VISUAL='vim'" >> ~/.bashrc

        source ~/.bashrc && cd settings
}


build_binary(){
	# add library configure support here
	echo 'Installing dependencies...'
	sudo apt-get -y remove vim
	sudo apt build-dep -y vim
	
	# Python3.6 Support
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt update
	sudo apt-get install -y python3.6-dev libpython3.6

	echo 'Reinstalling Vim from Github...'
	sudo rm -rf ~/.vim* ~/vim*
	cd ~ && git clone https://github.com/vim/vim ~/.vim
	cd ~/.vim && ./configure \
		--with-features=huge \
		--enable-multibyte \
		--enable-python3interp vi_cv_path_python3=/usr/bin/python3.6 \
		--with-python3-config-dir=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu \
		--enable-gui=auto \
		--enable-cscope \
		--with-compiledby="amead24" \
		--enable-fail-if-missing \
		--prefix=/usr/local

	make VIMRUNTIMEDIR=/usr/local/share/vim/vim81
	sudo make install
}


build_python(){
	pip install --upgrade pip
	python -m pip install black flake8 isort
}


build_rust(){
	rustup component addrustfmt-preview
}


build_cpp(){
	sudo apt-get install astyle
}


while [ "$1" != "" ]; do
        case $1 in
                -b | --build-binary)
                        echo 'Building vim binary with 8.1 and python3 support'
                        build_binary
                        shift
                        ;;
                -p | --build-python)
                        echo 'Building python dependencies for vim'
                        build_python
                        shift
                        ;;
                -r | --build-rust)
                        echo 'Building rustlang dependencies for vim'
                        build_rust
                        shift
                        ;;
                -c | --build-cpp)
                        echo 'Building cpp dependencies for vim'
                        shift
                        ;;
                *)
                        Usage
                        ;;
        esac
done
build_core

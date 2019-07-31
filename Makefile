FEDORAOSVERSION=30
#FEDORAOSVERSION=`rpm -E %fedora`

all: build

fedora-workstation:
	sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(FEDORAOSVERSION).noarch.rpm
	sudo dnf install -y toolbox gnome-tweaks gnome-todo gstreamer1-libav gstreamer1-plugins-ugly xclip tilix fzf

fedora-silverblue-gvm:
	sudo dnf install -y make binutils bison gcc
	bash gvm.sh

fedora-silverblue-go:
	sudo dnf install -y neovim make fzf
	go get -u github.com/golang/dep/cmd/dep
	nvim +GoUpdateBinaries +qall

sync:
	mkdir -p ~/development
	mkdir -p ~/.config/nvim

	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	[ -f ~/.config/nvim/init.vim ] || ln -s $(PWD)/vimrc ~/.config/nvim/init.vim
	nvim +PlugInstall +qall
	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.bashrc ] || ln -s $(PWD)/bashrc ~/.bashrc
	[ -f ~/development/bin ] || ln -s $(PWD)/bin ~/development/bin

clean:
	rm -f ~/development/bin
	rm -f ~/.vimrc
	rm -f ~/.config/nvim/init.vim
	rm -f ~/.bashrc


.PHONY: all clean sync build run kill

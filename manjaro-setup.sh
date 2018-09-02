#!/bin/bash

{

echo "Welcome"
echo "This setup works for Arch-based distro(I only used in Manjaro, never tested on others distros)"
DOTFILES=$HOME/.onhernandes/dotfiles
SUBLIME_USER_PACKAGE=$HOME/.config/sublime-text-3/Packages/User

ensure_home_folder() {
    if [[ ! -d $HOME/.onhernandes ]]; then
        mkdir $HOME/.onhernandes
    fi

		pacman -S --noconfirm git
		git clone git@github.com:onhernandes/dotfiles.git $DOTFILES
}

pacman_install() {
    echo "Installing Pacman Packages"

    wget https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
    echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf

    PACMAN_PACKAGES="openssh docker docker-compose curl mongodb mongodb-tools keepassxc easytag xclip xf86-input-synaptics fzf ruby sublime-text neovim cmake freetype2 fontconfig pkg-config make rustup"
		pacman -S --noconfirm $PACMAN_PACKAGES
}

yaourt_install() {
    echo "Installing Yaourt Packages"
    YAOURT_PACKAGES="google-chrome woeusb spotify postman rambox"
    yaourt -S --noconfirm $YAOURT_PACKAGES
}

npm_packages_setup() {
    echo "Installing NPM Packages..."
    sudo npm install -g getme nodemon standard hexo-cli hexo jest jest-cli neovim prettier jjson
}

ruby_gems_setup() {
    gem install rdoc neovim tmuxinator
}

services_setup() {
    echo "Setting some services"
    SERVICES=(mongodb docker)
    # sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    for serv in ${SERVICES[@]}; do
        systemctl enable $serv
        systemctl start $serv
    done
}

dotfiles_setup() {
    echo "Setting misc dotfiles"

    # Set .gitconfig and .gitignore_global
    if [[ -f $DOTFILES/commands/git/gitconfig ]]; then
        ln -s $DOTFILES/commands/git/gitconfig /etc/gitconfig
    fi

    if [[ -f $DOTFILES/commands/git/gitignore_global ]]; then
        ln -s $DOTFILES/commands/git/gitignore_global /etc/gitignore_global
    fi

    # Setting ST3 files
    if [[ -d $SUBLIME_USER_PACKAGE ]]; then
        ln -s $DOTFILES/sublime/Package\ Control.sublime-settings $SUBLIME_USER_PACKAGE
        ln -s $DOTFILES/sublime/Preferences.sublime-settings $SUBLIME_USER_PACKAGE
    fi

    # Setting custom commands
    chmod +x $DOTFILES/commands/gitlist && ln -s $DOTFILES/commands/gitlist /usr/bin
    chmod +x $DOTFILES/commands/license-mit && ln -s $DOTFILES/commands/license-mit /usr/bin
    chmod +x $DOTFILES/commands/subl-snippet && ln -s $DOTFILES/commands/subl-snippet /usr/bin

		# Setting vim and tmux config
		if [[ ! -d $HOME/.local/share/nvim/plugged ]]; then
		  mkdir $HOME/.local/share/nvim/plugged
    fi                             

		if [[ ! -d $HOME/.config/nvim ]]; then
		  mkdir $HOME/.config/nvim
    fi                            

		if [[ ! -d $HOME/.tmux ]]; then
		  mkdir -p $HOME/.tmux/plugins
    fi 

		ln -s $DOTFILES/vimrc $HOME/.vimrc
		ln -s $DOTFILES/vimrc $HOME/.config/nvim/init.vim
		ln -s $DOTFILES/tmux.conf $HOME/.tmux.conf

    curl https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.bash -o $HOME/.tmux/tmuxinator.bash
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $HOME/git-completion.bash
    echo -e ". $HOME/.git-completion.bash" >> $HOME/.bashrc
    echo -e "source $HOME/.tmux/tmuxinator.bash" >> $HOME/.bashrc
    echo -e 'export TMUXINATOR_CONFIG="$HOME/.onhernandes/dotfiles/tmuxinator"' >> $HOME/.bashrc
    echo -e 'export EDITOR=vi' >> $HOME/.bashrc
}

install_alacritty() {
  mkdir /tmp/alacritty
  git clone git@github.com:jwilm/alacritty.git /tmp/alacritty
  cd /tmp/alacritty
  rustup override set stable
  rustup update stable
  cargo build --release
  cp ./target/release/alacritty /usr/bin/alacritty
  cp $DOTFILES/Alacritty.desktop $HOME/.local/share/applications/
  cd $HOME
}

initialize_me() {
    ensure_home_folder
    pacman_install
    yaourt_install

    install_alacritty

    npm_packages_setup
    ruby_gems_setup
    services_setup
    dotfiles_setup

    source $HOME/.bashrc
}

initialize_me

}

init() {
  mkdir -p ~/Development/MyStuff/dotfiles/
  git config --global user.email "bruno@brunoxavier.com.br"
  git config --global user.name "Bruno Xavier"
  git clone https://github.com/bxavier/dotfiles.git  ~/Workspace/MyStuff/dotfiles/
  cd ~/Workspace/MyStuff/dotfiles
}

update_upgrade(){
  echo 'Update and Upgrade'
  sudo apt update -y && sudo apt upgrade -y
}

vscode() {
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install -y apt-transport-https
    sudo apt update
    sudo apt install -y code 
    cat $PWD/extensions.list | xargs -n 1 code --install-extension
}    

update_vscode_extension_list() {
  code --list-extensions >> $PWD/extensions.list
}

nvm() {
  rm -rf $HOME/.nvm
  export NVM_DIR="$HOME/.nvm" && (
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  ) && \. "$NVM_DIR/nvm.sh"
  nvm install node
  
}

teams() {
  wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.4.00.13653_amd64.deb -O teams.deb
  sudo apt install -y ./teams.deb
  rm -rf teams.deb
}

chrome() {
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
	update_upgrade
	sudo apt install -y google-chrome-stable
}

zsh() {
  rm -rf $HOME/.oh-my-zsh
  sudo apt install -y zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	chsh -s $(which zsh)
  git clone https://github.com/denysdovhan/spaceship-prompt.git ~/.oh-my-zsh/themes/spaceship-prompt --depth=1
  ln -s ~/.oh-my-zsh/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/themes/spaceship.zsh-theme
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
} 

firacode() {
  sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
  sudo apt update
  sudo apt install fonts-firacode
}

reboot() {
  shutdown -r 0
}

setup_dotfiles() {
  rm -f ~/.config/Code/User/settings.json
  ln -vsf $PWD/.config/Code/User/settings.json ~/.config/Code/User/settings.json
  ln -vsf $PWD/.zshrc $HOME/.zshrc
}

install() {
  update_upgrade
  firacode
  zsh
  vscode
  chrome
  teams
  nvm

  setup_dotfiles
}

if [ $# -eq 0 ] 
  then
  echo "No arguments supplied, running init"
  init
fi

for i in "$@"; do
  case $i in
    vscode)
      vscode
      ;;
    update_vscode_extension_list)
      update_vscode_extension_list
      ;;
    teams)
      teams
      ;;
    chrome)
      chrome
      ;;
    zsh)
      zsh
      ;;
    firacode)
      firacode
      ;;
    nvm)
      nvm
      ;;
    install)
      install
      ;;
    *)
      echo "Unknown option $i"
      exit 1
      ;;
  esac
done

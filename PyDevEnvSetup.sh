#!/usr/bin/env bash
# _*_ coding: UTF-8 _*_

# CREATOR: mike.lu@hp.com
# CHANGE DATE: 10/15/2024
__version__="1.2"


# Python開發環境自動安裝程式


CheckNetwork() {
	wget -q --spider www.google.com > /dev/null
	[[ $? != 0 ]] && echo -e "❌ 無網路連線! 請檢查並重試\n" && exit || :
}

# 檢查程式最新版本
UpdateScript() {
    release_url=https://api.github.com/repos/DreamCasterX/PyDevEnvSetup/releases/latest
    new_version=$(wget -qO- "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    release_note=$(wget -qO- "${release_url}" | grep '"body":' | awk -F\" '{print $4}')
    tarball_url="https://github.com/DreamCasterX/PyDevEnvSetup/archive/refs/tags/${new_version}.tar.gz"
    if [[ $new_version != $__version__ ]]
    then
        echo -e "⭐️ 發現新版本!\n\n版本: $new_version\n發行說明:\n$release_note"
        sleep 2
        echo -e "\n下載並安裝更新..."
        pushd "$PWD" > /dev/null 2>&1
        wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".PyDevEnvSetup.tar.gz" "${tarball_url}"
        if [[ -e ".PyDevEnvSetup.tar.gz" ]]
        then
            tar -xf .PyDevEnvSetup.tar.gz -C "$PWD" --strip-components 1 > /dev/null 2>&1
            rm -f .PyDevEnvSetup.tar.gz
            rm -f README.md
            popd > /dev/null 2>&1
            sleep 3
            sudo chmod 755 PyDevEnvSetup.sh
            echo -e "更新完成! 請重新執行\n\n" ; exit 1
        else
            echo -e "\n❌ 更新失敗" ; exit 1
        fi
    else
        echo -e "✅ 已是最新版本\n"
    fi
}

Install_zsh() {	
    echo
    echo "╭───────────────────────────────────────╮"
    echo "│  安裝zsh/zinit套件/Powerlevel10k主題  |"
    echo "│                                       │"
    echo "╰───────────────────────────────────────╯"
    echo
    [[ -f /usr/bin/zsh ]] && sudo rm -f ~/.zshrc ~/.zshprofile ~/.zsh_history ~/.p10k.zsh ~/.zsh_history.new && sudo apt remove zsh -y --purge  
    sudo apt update && sudo apt install -y zsh git curl
    sudo usermod -s /bin/zsh $USER
    touch ~/.zshrc
    touch ~/.zprofile
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

	printf "\n# My alias
	alias ll='ls -al'\n\n" >> ~/.zshrc

	printf "\n# zsh 套件四天王
	zinit light zsh-users/zsh-completions
	zinit light zsh-users/zsh-autosuggestions
	zinit light zsh-users/zsh-history-substring-search
	zinit light zdharma-continuum/fast-syntax-highlighting\n\n" >> ~/.zshrc

	printf "# Oh My Zsh 功能
	zinit snippet OMZ::lib/completion.zsh
	zinit snippet OMZ::lib/history.zsh
	zinit snippet OMZ::lib/key-bindings.zsh
	zinit snippet OMZ::lib/theme-and-appearance.zsh\n\n" >> ~/.zshrc

	printf "# key binding
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down\n\n" >> ~/.zshrc

	printf "# Powerlevel10k
	zinit ice depth=1; zinit light romkatv/powerlevel10k\n\n" >> ~/.zshrc

	printf '# Pyenv 環境變數設置
	export PYENV_ROOT="$HOME/.pyenv"
	command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"\n\n' >> ~/.zshrc

	printf '# Poetry 環境變數設置
	export PATH=$PATH:$HOME/.local/bin\n\n' >> ~/.zshrc
    echo "請重新登入系統以完成設置"
    zsh
    chsh -s $(which zsh)
    source ~/.zshrc
	# 手動設定powerlevel10k或執行"p10k configure"
}

Install_fastfetch() {	
    echo
    echo "╭───────────────────────────────────────╮"
    echo "│             安裝fastfetch             |"
    echo "│                                       │"
    echo "╰───────────────────────────────────────╯"
    echo
    [[ -f ~/.p10k.zsh ]] && sed -i 's/POWERLEVEL9K_INSTANT_PROMPT=verbose/POWERLEVEL9K_INSTANT_PROMPT=off/' ~/.p10k.zsh 2> /dev/null  # p10k必須要在裝完zsh後就設定好
    sudo apt update && sudo apt install lolcat -y  # 安裝lolcat
    # Download fastfetch
    fastfetch_release_url=https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest
    fastfetch_new_version=$(wget -qO- "${fastfetch_release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    fastfetch_deb_url="https://github.com/fastfetch-cli/fastfetch/releases/download/$fastfetch_new_version/fastfetch-linux-amd64.deb"
    wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".fastfetch.deb" "${fastfetch_deb_url}"
    if [[ -e ".fastfetch.deb" ]]; then
        sudo dpkg -i .fastfetch.deb && rm -f .fastfetch.deb && fastfetch --gen-config-force > /dev/null 2>&1
    else
        echo -e "\n\e[31m下載主程式失敗.\e[0m" ; exit 1
    fi
    # Download customized config file
    config_release_url=https://api.github.com/repos/DreamCasterX/SysInfo/releases/latest
    config_new_version=$(wget -qO- "${config_release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    config_tarball_url="https://github.com/DreamCasterX/SysInfo/archive/refs/tags/${config_new_version}.tar.gz"
    wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".SysInfo.tar.gz" "${config_tarball_url}"
    if [[ -e ".SysInfo.tar.gz" ]]; then
        tar -xf .SysInfo.tar.gz -C "$PWD" --strip-components 1 SysInfo-$config_new_version/config.jsonc > /dev/null 2>&1
        rm -f .SysInfo.tar.gz
        popd > /dev/null 2>&1
        sleep 3
        sudo chmod 755 config.jsonc
        mv config.jsonc ~/.config/fastfetch/	
    else
        echo -e "\n\e[31m下載設定檔失敗.\e[0m" ; exit 1
    fi
    [[ ! `grep '啟用fastfetch' ~/.zshrc` ]] && sed -i '4s/^/\n\n# 啟用fastfetch\n    fastfetch --logo none | lolcat\n\n/' ~/.zshrc
    echo -e "\n\e[32m完成! 開啟一個新終端機檢視\e[0m\n"
    # 手動修改設定~/.config/fastfetch/config.jsonc
}

Install_pyenv() {	
    echo
    echo "╭───────────────────────────────────────╮"
    echo "│             安裝pyenv                 |"
    echo "│                                       │"
    echo "╰───────────────────────────────────────╯"
    echo
    sudo apt update && sudo apt install -y --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    CUR_PY_VER=`python3 -V | awk '{print $NF}'`
    echo -e "\n當前使用中的Python版本: $CUR_PY_VER"
    read -p "輸入要安裝的Python版本(ex: 3.11.9): " NEW_PY_VER
    pyenv install $NEW_PY_VER
    pyenv global $NEW_PY_VER
    echo -e "\e[32mDone!\e[0m"
    source ~/.zshrc
}

Install_poetry() {	
    echo
    echo "╭───────────────────────────────────────╮"
    echo "│             安裝Poetry                |"
    echo "│                                       │"
    echo "╰───────────────────────────────────────╯"
    echo
    CUR_PY_VER=`python3 -V | awk '{print $NF}' | awk '{split($0, parts, "."); print parts[1] "." parts[2]}'`
    [[ `sudo dpkg -l | grep python$CUR_PY_VER-venv` ]] || sudo apt update && sudo apt install curl python$CUR_PY_VER-venv -y
    curl -sSL https://install.python-poetry.org | python3 -
    poetry config virtualenvs.in-project true
    # 移至建立專案目錄執行"poetry init"
}

Install_docker() {	
    echo
    echo "╭───────────────────────────────────────╮"
    echo "│             安裝Docker                |"
    echo "│                                       │"
    echo "╰───────────────────────────────────────╯"
    echo
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
    echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo docker run hello-world
    sudo usermod -aG docker $USER && sudo chmod a+rw /var/run/docker.sock
}


echo -e "  \n安裝zsh [1]   安裝fastfetch [2]   安裝pyenv [3]   安裝poetry [4]   安裝docker [5]   更新程式 [U]   離開 [Q]\n"
read -p "輸入選項: " ACTION
while [[ $ACTION != [12345UuQq] ]]
do
    echo -e "選項錯誤!"
    read -p "輸入選項: " ACTION
done
[[ $ACTION == '1' ]] && CheckNetwork && Install_zsh ; [[ $ACTION == '2' ]] && CheckNetwork && Install_fastfetch ; [[ $ACTION == '3' ]] && CheckNetwork && Install_pyenv ; 
[[ $ACTION == '4' ]] && CheckNetwork && Install_poetry ; [[ $ACTION == '5' ]] && CheckNetwork && Install_docker ; 
[[ $ACTION == [Uu] ]] && CheckNetwork && UpdateScript ; [[ $ACTION == [Qq] ]] && exit

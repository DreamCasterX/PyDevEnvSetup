#!/usr/bin/env bash

# CREATOR: mike.lu@hp.com
# CHANGE DATE: 05/16/2024
__version__="0.1"


# Python開發環境自動安裝程式


CheckNetwork() {
	wget -q --spider www.google.com > /dev/null
	[[ $? != 0 ]] && echo -e "❌ 無網路連線! 請檢查並重試\n" && exit || :
}

# 檢查程式最新版本
UpdateScript() {
	release_url=https://api.github.com/repos/DreamCasterX/PyDevEnvSetup/releases/latest
	new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
	release_note=$(curl -s "${release_url}" | grep '"body":' | awk -F\" '{print $4}')
	tarball_url="https://github.com/DreamCasterX/PyDevEnvSetup/archive/refs/tags/${new_version}.tar.gz"
	if [[ $new_version != $__version__ ]]
	then
		echo -e "⭐️ 發現新版本!\n\nVersion: $new_version\nRelease note:\n$release_note"
		sleep 2
		echo -e "\nDownloading update..."
		pushd "$PWD" > /dev/null 2>&1
		curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".PyDevEnvSetup.tar.gz" "${tarball_url}"
		if [[ -e ".PyDevEnvSetup.tar.gz" ]]
		then
		tar -xf .PyDevEnvSetup.tar.gz -C "$PWD" --strip-components 1 > /dev/null 2>&1
		rm -f .PyDevEnvSetup.tar.gz
		rm -f README.md
		popd > /dev/null 2>&1
		sleep 3
		chmod 777 PyDevEnvSetup.sh
		echo -e "更新完成! 請重新執行\n\n" ; exit 1
		else
		echo -e "\n❌ 更新失敗" ; exit 1
		fi 
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

	zsh
	chsh -s $(which zsh)
	source ~/.zshrc
	# 手動設定powerlevel10k或執行"p10k configure"
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
 	source ~/.zshrc
}

Install_poetry() {	
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│             安裝poetry                |"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	CUR_PY_VER=`python3 -V | awk '{print $NF}' | awk '{split($0, parts, "."); print parts[1] "." parts[2]}'`
	[[ `sudo dpkg -l | grep python$CUR_PY_VER-venv` ]] || sudo apt update && sudo apt install python$CUR_PY_VER-venv -y
	curl -sSL https://install.python-poetry.org | python3 -
	poetry config virtualenvs.in-project true
	# 移至建立專案目錄執行"poetry init"
}

Install_docker() {	
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│             安裝docker                |"
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

	# 完成安裝後(似乎會失敗)
	sudo usermod -aG docker $USER
}


echo -e "  \n安裝zsh [1]   安裝pyenv [2]   安裝poetry [3]   安裝docker [4]   更新程式 [U]   離開 [Q]\n"
read -p "輸入選項: " ACTION
while [[ $ACTION != [1234UuQq] ]]
do
	echo -e "選項錯誤!"
	read -p "輸入選項: " ACTION
done
[[ $ACTION == '1' ]] && Install_zsh ; [[ $ACTION == '2' ]] && Install_pyenv ; [[ $ACTION == '3' ]] && Install_poetry ; [[ $ACTION == '4' ]] && Install_docker ; [[ $ACTION == [Uu] ]] && UpdateScript ; [[ $ACTION == [Qq] ]] && exit

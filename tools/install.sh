#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/gmcui/dotfiles/master/tools/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/gmcui/dotfiles/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/gmcui/dotfiles/master/tools/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   DOTS=~/.bash sh install.sh
#
# Respects the following environment variables:
#   DOTS    - path to the dotfiles repository folder (default: $HOME/.oh-my-bash)
#   REPO    - name of the GitHub repo to install from (default: ohmyzsh/ohmyzsh)
#   REMOTE  - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   KEEP_BASH_PROFILE - 'yes' means the installer will not replace an existing .bash_profile (default: no)
#   KEEP_BASHRC       - 'yes' means the installer will not replace an existing .bashrc (default: no)
#   KEEP_VIMRC        - 'yes' means the installer will not replace an existing .vimrc (default: no)
#   KEEP_SCREENRC     - 'yes' means the installer will not replace an existing .screenrc (default: no)
#
# You can also pass some arguments to the install script to set some these options:
#   --keep-bash-profile: sets KEEP_BASH_PROFILE to 'yes'
#   --keep-bashrc: sets KEEP_BASHRC to 'yes'
#   --keep-vimrc: sets KEEP_VIMRC to 'yes'
#   --keep-screenrc: sets KEEP_SCREENRC to 'yes'
# For example:
#   sh install.sh --keep-bashrc
#
set -e

# Default settings
DOTS=${DOTS:-~/.dotfiles}
REPO=${REPO:-gmcui/dotfiles}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

# Other options
KEEP_BASH_PROFILE=${KEEP_BASH_PROFILE:-no}
KEEP_BASHRC=${KEEP_BASHRC:-no}
KEEP_VIMRC=${KEEP_VIMRC:-no}
KEEP_SCREENRC=${KEEP_SCREENRC:-no}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

setup_dotfiles() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	echo "${BLUE}Cloning Dot Files...${RESET}"

	command_exists git || {
		error "git is not installed"
		exit 1
	}

	if [ "$OSTYPE" = cygwin ] && git --version | grep -q msysgit; then
		error "Windows/MSYS Git is not supported on Cygwin"
		error "Make sure the Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

	if [ -d $DOTS ]; then
		echo "${GREEN}Already exists ${DOTS}, git clone skipped.${RESET}"
	else
		git clone -c core.eol=lf -c core.autocrlf=false \
			-c fsck.zeroPaddedFilemode=ignore \
			-c fetch.fsck.zeroPaddedFilemode=ignore \
			-c receive.fsck.zeroPaddedFilemode=ignore \
			--depth=1 --branch "$BRANCH" "$REMOTE" "$DOTS" || {
			error "git clone of dotfiles repo failed"
			exit 1
		}
	fi

	echo
}

install_dotfile() {
	DOTFILE=$1
	KEEP_DOTFILE=$2

	# Keep most recent old .dot_file at .dot_file.pre-oh-my-bash, and older ones
	# with datestamp of installation that moved them aside, so we never actually destroy
	# a user's original bash_profile
	echo "${BLUE}Looking for an existing .${DOTFILE}...${RESET}"

	# Must use this exact name so uninstall.sh can find it
	OLD_DOT_FILE="${HOME}/.${DOTFILE}.pre-dotfile"
	if [ -f ~/.$DOTFILE ] || [ -h ~/.$DOTFILE ]; then
		# Skip this if the user doesn't want to replace the existing .dotfile
		if [ $KEEP_DOTFILE = yes ]; then
			echo "${YELLOW}Found ~/.${DOTFILE}.${RESET} ${GREEN}Keeping...${RESET}"
			return
		fi
		if [ -e "$OLD_DOT_FILE" ]; then
			OLD_OLD_DOT_FILE="${OLD_DOT_FILE}-$(date +%Y-%m-%d_%H-%M-%S)"
			if [ -e "$OLD_OLD_DOT_FILE" ]; then
				error "$OLD_OLD_DOT_FILE exists. Can't back up ${OLD_DOT_FILE}"
				error "re-run the installer again in a couple of seconds"
				exit 1
			fi
			mv "$OLD_DOT_FILE" "${OLD_OLD_DOT_FILE}"

			echo "${YELLOW}Found ~/.${DOTFILE}.pre-dotfile." \
				"${GREEN}Backing up to ${OLD_OLD_DOT_FILE}${RESET}"
		fi
		echo "${YELLOW}Found ~/.${DOTFILE}.${RESET} ${GREEN}Backing up to ${OLD_DOT_FILE}${RESET}"
		mv ~/.$DOTFILE "${OLD_DOT_FILE}"
	fi

	echo "${GREEN}Using the dotfile template file and installing it to ~/.${DOTFILE}.${RESET}"
	sed -e "s#DOTFILE_DIR#${DOTS}#g" "$DOTS/templates/$DOTFILE.template" > ~/.$DOTFILE-temp
	if [ $# -gt 2 ] && [ $3 = append ]; then
		# append to existing dotfile
		cat ~/.$DOTFILE-temp >> ~/.$DOTFILE
	else
		# write new dotfile
		mv -f ~/.$DOTFILE-temp ~/.$DOTFILE
	fi

	echo
}

setup_bash_profile() {
	install_dotfile bash_profile $KEEP_BASH_PROFILE
}

setup_bashrc() {
	install_dotfile bashrc $KEEP_BASHRC append
}

setup_vimrc() {
	install_dotfile vimrc $KEEP_VIMRC
}

setup_screenrc() {
	install_dotfile screenrc $KEEP_SCREENRC
}

main() {
 	# Run as unattended if stdin is closed
 	if [ ! -t 0 ]; then
 		RUNBSH=no
 		CHSH=no
 	fi
 
 	# Parse arguments
 	while [ $# -gt 0 ]; do
 		case $1 in
 			--unattended) RUNBSH=no; CHSH=no ;;
 			--skip-chsh) CHSH=no ;;
 			--keep-bash-profile) KEEP_BASH_PROFILE=yes ;;
 			--keep-bashrc) KEEP_BASHRC=yes ;;
 			--keep-vimrc) KEEP_VIMRC=yes ;;
 			--keep-screenrc) KEEP_SCREENRC=yes ;;
 			--keep-zshrc) KEEP_ZSHRC=yes ;;
 		esac
 		shift
 	done
 
 	setup_color
 
 	if ! command_exists bash; then
 		echo "${YELLOW}Bash is not installed.${RESET} Please install bash first."
 		exit 1
 	fi

#   	if [ -d "$DOTS" ]; then
# 		cat <<-EOF
# 			${YELLOW}You already have Oh My Bash installed.${RESET}
# 			You'll need to remove '${DOTS}' if you want to install.
# 		EOF
#   		exit 1
#   	fi

	setup_dotfiles
	setup_bash_profile
	setup_bashrc
	setup_vimrc
	setup_screenrc
 
}

main "$@"

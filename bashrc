# .bashrc

# source this file in your ~/.bashrc like this:
#
# # Source custom bashrc
# if [ -f $HOME/dotfiles/bashrc ]; then
#     source $HOME/dotfiles/bashrc
# fi


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
export EDITOR=vim
export VISUAL=$EDITOR
export PS1="\[\033[1;32m\][\u@\h \W]\$\[\033[0m\] "
export HISTCONTROL=ignoredups:ignorespace

# git complete
#source ~/.git-completion.bash

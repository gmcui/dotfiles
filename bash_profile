# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export PATH=$PATH:$HOME/bin

unset USERNAME
umask 002

# Keychain
if command -v keychain 2>&1; then
    if [[ "${OSTYPE}" != "darwin"* ]]; then
        # '--clear' enhances security by requiring private key password on each new shell
        # However it causes big problem with MacVim by stopping it from opening any windows
        keychain --clear --quiet id_dsa
    fi
    [ -f ~/.ssh/id_dsa ] && keychain --quiet id_dsa
    [ -f ~/.ssh/id_rsa ] && keychain --quiet id_rsa
    . ~/.keychain/$HOSTNAME-sh
else
    echo "keychain is not installed!"
fi

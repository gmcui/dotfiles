## Quick Start

This script should be run via curl:

```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/gmcui/dotfiles/master/tools/install.sh)"
```

or wget:

```bash
  sh -c "$(wget -qO- https://raw.githubusercontent.com/gmcui/dotfiles/master/tools/install.sh)"
```

As an alternative, you can first download the install script and run it afterwards:

```bash
  wget https://raw.githubusercontent.com/gmcui/dotfiles/master/tools/install.sh
  sh install.sh
```

You can tweak the install behavior by setting variables when running the script. For
example, to change the path to the .dotfiles repository:

```bash
  DOTS=~/.mydotfiles sh install.sh
```

Respects the following environment variables:

-   DOTS - path to the dotfiles repository folder (default: $HOME/.dotfiles)
-   REPO - name of the GitHub repo to install from (default: gmcui/dotfiles)
-   REMOTE - full remote URL of the git repo to install (default: GitHub via HTTPS)
-   BRANCH - branch to check out immediately after install (default: master)

Other options:

-   KEEP_BASH_PROFILE - 'yes' means the installer will not replace an existing .bash_profile (default: no)
-   KEEP_BASHRC - 'yes' means the installer will not replace an existing .bashrc (default: no)
-   KEEP_VIMRC - 'yes' means the installer will not replace an existing .vimrc (default: no)
-   KEEP_SCREENRC - 'yes' means the installer will not replace an existing .screenrc (default: no)

You can also pass some arguments to the install script to set some these options:

-   --keep-bash-profile: sets KEEP_BASH_PROFILE to 'yes'
-   --keep-bashrc: sets KEEP_BASHRC to 'yes'
-   --keep-vimrc: sets KEEP_VIMRC to 'yes'
-   --keep-screenrc: sets KEEP_SCREENRC to 'yes'

For example:

```bash
  sh install.sh --keep-bashrc
```

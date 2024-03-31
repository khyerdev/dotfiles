#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='exa -x'
alias lsa='exa -laahXM --smart-group --git --no-quotes'
alias lst='exa -lahXMT --smart-group --git --no-quotes'
alias lstg='lst --git-ignore'
alias lsgt='lstg'
alias grep='grep --color=auto'
alias pacman='pacman --color=auto'
alias nvimcfg='nvim ~/.config/nvim/init.lua'
alias hyprcfg='nvim $HOME/.config/hypr/hyprland.conf'
alias ard='arduino-cli'
alias resetdpi='solaar config "G502 Gaming Mouse" dpi 700'
alias vi='/bin/vim'
alias vim='nvim'

export EDITOR=nvim

PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"

# pnpm
export PNPM_HOME="/home/khyernet/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

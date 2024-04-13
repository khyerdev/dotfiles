if status is-interactive
    # Commands to run in interactive sessions can go here
    alias cd 'z'
    alias ls 'exa -x'
    alias lsa 'exa -laahXM --smart-group --git --no-quotes --icons=always'
    alias lst 'exa -lahXMT --smart-group --git --no-quotes --icons=always'
    alias lstg 'lst --git-ignore'
    alias lsgt 'lstg'
    alias grep 'grep --color=auto'
    alias pacman 'pacman --color=auto'
    alias nvimcfg 'nvim ~/.config/nvim/init.lua'
    alias hyprcfg 'nvim $HOME/.config/hypr/hyprland.conf'
    alias ard 'arduino-cli'
    alias resetdpi 'solaar config "G502 Gaming Mouse" dpi 700'
    alias vi '/bin/vim'
    alias vim 'nvim'
    alias get_tty 'cat /sys/devices/virtual/tty/tty0/active'
    alias tclock 'tty-clock -tscC 4'
    thefuck --alias | source

    export EDITOR=nvim

    if not tty | grep tty &>> /dev/null
        set PS1 '[\u@\h \W]\$ '
        eval "$(starship init fish)"
    end

    # pnpm
    export PNPM_HOME="/home/khyernet/.local/share/pnpm"
end

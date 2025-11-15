# Exports
export PATH=/home/kvl/.local/bin/:$PATH
export PATH=/home/kvl/src/:$PATH
export PATH=/home/kvl/Applications/:$PATH
export PATH=/home/kvl/.nix-profile/bin/:$PATH
export PATH=/home/kvl/.local/share/cargo/bin/:$PATH
export PATH=/usr/local/mysql/bin/:$PATH
export mySql="/usr/local/mysql/bin/mysql -u root -p"


# Prompt
autoload -U colors && colors
ZSH_THEME="m3-round"
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[white]%}@%{$fg[green]%}%M %{$fg[blue]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments
DISABLE_AUTO_UPDATE="true"
# Autoload zsh's `add-zsh-hook` and `vcs_info` functions
# (-U autoload w/o substition, -z use zsh style)
autoload -Uz add-zsh-hook vcs_info

# Set prompt substitution so we can use the vcs_info_message variable
setopt prompt_subst

# Run the `vcs_info` hook to grab git info before displaying the prompt
add-zsh-hook precmd vcs_info

# Style the vcs_info message
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%b%u%c'
# Format when the repo is in an action (merge, rebase, etc)
zstyle ':vcs_info:git*' actionformats '%F{14}⏱ %*%f'
zstyle ':vcs_info:git*' unstagedstr '*'
zstyle ':vcs_info:git*' stagedstr '+'
# This enables %u and %c (unstaged/staged changes) to work,
# but can be slow on large repos
zstyle ':vcs_info:*:*' check-for-changes true

# Set the right prompt to the vcs_info message
RPROMPT='⎇ ${vcs_info_msg_0_}'

zshcache_time="$(date +%s%N)"
autoload -Uz add-zsh-hook
rehash_precmd() {
  if [[ -a /var/cache/zsh/pacman ]]; then
    local paccache_time="$(date -r /var/cache/zsh/pacman +%s%N)"
    if (( zshcache_time < paccache_time )); then
      rehash
      zshcache_time="$paccache_time"
    fi
  fi
}
add-zsh-hook -Uz precmd rehash_precmd

#** MY ADDS **#
# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# # vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char
# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'
bindkey -s '^f' '~/.local/bin/tmux-sessionizer\n'

# Edit line in vim with ctrl-e:
HISTFILE="$HOME/.config/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
set -o vi
set -o AUTO_CD

sd(){
  cd $(find ~ -type d | fzf)
}
hisSearch() {
  history 1 -1 | cut -c 8- | sort | uniq | fzf | tr -d '\n' | \
    ( [[ $XDG_SESSION_TYPE == 'wayland' ]] && wl-copy || xclip -sel c )
}
0x0Copy(){
  curl -F"file=@$(find $HOME -type f | fzf)" 0x0.st | \
    ( [[ $XDG_SESSION_TYPE == 'wayland' ]] && wl-copy || xclip -sel c )
}
pacsearch() { 
  paru -Ssq "$*" | grep "$*" | fzf; 
}

# zle-line-init() { zle -K vicmd; }
# zle -N zle-line-init

source /home/kvl/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /home/kvl/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/kvl/.config/zsh/aliasrc
source /home/kvl/.config/zsh/zsh-autopair/autopair.zsh
fpath=(/home/kvl/zsh-completions/src $fpath)
autopair-init

colorscript random

# eval "$(starship init zsh)"

[[ -f /etc/bash.command-not-found ]] || . /etc/bash.command-not-found

eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="/home/kvl/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
fastfetch

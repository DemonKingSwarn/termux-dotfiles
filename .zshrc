#  ____  _____ __  __  ___  _   _
# |  _ \| ____|  \/  |/ _ \| \ | | (c) Swarnaditya Singh aka DemonKingSwarn
# | | | |  _| | |\/| | | | |  \| | Github- https://github.com/demonkingswarn
# | |_| | |___| |  | | |_| | |\  |
# |____/|_____|_|  |_|\___/|_| \_|
#

# Enable colors and change prompt:
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
PS2="> "

export PATH="$PATH:$HOME/.local/bin"

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.local/state/zsh/history

PROMPT_EOL_MARK=' ⏎ '

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
_comp_options+=(globdots)		# Include hidden files.

# vi mode
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

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

function chst {
    [ -z $1 ] && echo "no args provided!" || (curl -s cheat.sh/$1 | bat --style=plain)
}

fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

#yt() {
#    mpv ytdl://ytsearch:"$*"
#}

hst() {
    hist=$(cat $HOME/.local/state/zsh/history | sort | uniq | fzf)
    printf "%s" "$hist" | wl-copy
}

help() {
    "$@" --help 2>&1 | bat --plain --language=help
}

pipdepuninstall () 
{ 
    pip install -q pipdeptree
    pipdeptree -p$1 -fj | jq ".[] | .package.key" | xargs pip uninstall -y
}

upfile() {
    dir=$(uuidgen | cut -d'-' -f1)
    mkdir /tmp/$dir
    cp $1 /tmp/$dir
    zip -r /tmp/$dir.zip /tmp/$dir
    zipcloak /tmp/$dir.zip
    curl -F"file=@/tmp/$dir.zip" 0x0.st
}

epic() {
    cd $HOME/.local/share/wine/drive_c/Program\ Files\ \(x86\)/Epic\ Games/Launcher/Portal/Binaries/Win64/
}

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

alias stow='stow --ignore=.git --ignore=.gitignore'

source "$HOME/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

clear
eval "$(starship init zsh)"

#figlet "$(date '+ %I:%M %p')" | lolcat

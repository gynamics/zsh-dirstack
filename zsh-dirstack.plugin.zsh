# A Simple Directory Stack

# enable direcotry stack
setopt autopushd
setopt pushdminus
setopt pushdsilent
setopt pushdtohome
setopt pushdignoredups
setopt pushdminus

# save directory stack in a local file
DIRSTACKFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/dirs"
DIRSTACKSIZE=20

# create zsh cache directory if it does not exist
[[ ! -d ${XDG_CACHE_HOME:-$HOME/.cache} ]] && mkdir ${XDG_CACHE_HOME:-$HOME/.cache}
[[ ! -d ${DIRSTACKFILE%/*} ]] && mkdir ${DIRSTACKFILE%/*}

# filter out all invalid directory entries
dirstack-valid-entries() {
    for dir in ${dirstack}; do
        if [[ -d "${dir}" ]]; then
            echo "${dir}"
        fi
    done
}

dirstack-clean() {
    dirstack=( "${(@f)"$(dirstack-valid-entries)"}" )
}

# fzf/skim integration
# if you can replace a custom finder by change DIRSTACK_FINDER command.
DIRSTACK_FINDER="sk --height 40% --cycle --layout=reverse"

function _dirstack_widget() {
    dirstack-clean
    local dir=$(
        dirs -v| eval $DIRSTACK_FINDER | sed 's/^[[:digit:]]\+[[:space:]]*//')
    if [[ -z "$dir" ]]; then
        zle redisplay
        return 0
    fi
    zle push-line
    BUFFER="builtin cd -- ${${(q)dir}/\\~/~}" # do not escape the leading '~'
    zle accept-line
    local ret=$?
    unset dir
    zle reset-prompt
    return $ret
}

# bindkey to M-d (normally Alt + d)
zle     -N             _dirstack_widget
bindkey -M emacs '\ed' _dirstack_widget
bindkey -M vicmd '\ed' _dirstack_widget
bindkey -M viins '\ed' _dirstack_widget

# read last dirs on load
if [[ -f "$DIRSTACKFILE" ]] && [[ $#dirstack -eq 0 ]]; then
    dirstack=( "${(@f)"$(< "$DIRSTACKFILE")"}" )
    # clean up the stack
    dirstack-clean
    # open last directory if it exist
    #[[ -d "${dirstack[1]}" ]] && cd -- "${dirstack[1]}"
fi

# sync directory stack file on exit
zshexit() {
    print -l -- "$PWD" "${(u)dirstack[@]}" > $DIRSTACKFILE
}

# complete from dirstack
zstyle ':completion:*' complete-options true

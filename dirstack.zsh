# A Simple Directory Stack

# enable direcotry stack
setopt autopushd 
setopt pushdminus 
setopt pushdsilent
setopt pushdtohome
setopt pushdignoredups
setopt pushdminus

# save directory stack in a local file
DIRSTACKFILE="${HOME}/.cache/zsh_dirs"
DIRSTACKSIZE=20

# create zsh directory in .cache if it does not exist
[[ ! -d ${DIRSTACKFILE%/*} ]] && mkdir ${DIRSTACKFILE%/*}

# read last dirs on load
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  # open last directory if it exist
  #[[ -d $dirstack[1] ]] && cd $dirstack[1]
fi

# sync directory stack file on exit
zshexit() {
  print -l $PWD ${(u)dirstack} > $DIRSTACKFILE
}

# complete from dirstack
zstyle ':completion:*' complete-options true

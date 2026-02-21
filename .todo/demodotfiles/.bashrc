#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ '
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export PAGER="nvim -R"
export EDITOR="nvim"
export VISUAL="nvim"

# Keyboard: Swedish international Dvorak, CapsLock/Escape swap
setxkbmap se -variant us_dvorak -option caps:swapescape 2>/dev/null

# argc-completions
export ARGC_COMPLETIONS_ROOT="/home/skogix/.local/src/argc-completions"
export ARGC_COMPLETIONS_PATH="$ARGC_COMPLETIONS_ROOT/completions/linux:$ARGC_COMPLETIONS_ROOT/completions"
export PATH="$ARGC_COMPLETIONS_ROOT/bin:$PATH"
# To add completions for only the specified command, modify next line e.g. argc_scripts=( cargo git )
argc_scripts=( $(ls -p -1 "$ARGC_COMPLETIONS_ROOT/completions/linux" "$ARGC_COMPLETIONS_ROOT/completions" | sed -n 's/\.sh$//p') )
source <(argc --argc-completions bash "${argc_scripts[@]}")

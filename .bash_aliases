# Custom Aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# List files
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# System
alias h='history'
alias path='echo -e ${PATH//:/\\n}'

# Clear node_modules, target, build, dist folders using npkill
alias npkill='for folder in node_modules target build dist; do npx npkill --target "$folder" --sort size; done'

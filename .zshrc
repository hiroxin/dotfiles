# .zshrc

if type gls > /dev/null 2>&1; then
    if [ -f ~/.colorrc ]; then
        eval "$(dircolors ~/.colorrc)"
    fi
    alias ls='ls --color=auto'
else
    export LSCOLORS=xbfxcxdxbxegedabagacad
    alias ls='ls -G'
fi


# === Environment Variables ===============================

export LANG=ja_JP.UTF-8

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

# Added by Antigravity
export PATH="/Users/h_nakano/.antigravity/antigravity/bin:$PATH"


# === Alias ===============================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias be='bundle exec'
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ll='ls -alF'


# === fzf util ============================================

source <(fzf --zsh)

# --- Git ---------------------------------------
# gbr - checkout git branch
gbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# gbrr - checkout git branch (including remote branches)
gbrr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# gcoc - checkout git commit
gcoc() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# gshow - git commit browser
gshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# --- FileSystem --------------------------------
# Interactive cd
function icd() {
    if [[ "$#" != 0 ]]; then
        builtin cd "$@";
        return
    fi
    while true; do
        local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
        local dir="$(printf '%s\n' "${lsd[@]}" |
            fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                echo $__cd_path;
                echo;
                ls -p --color=always "${__cd_path}";
        ')"
        [[ ${#dir} != 0 ]] || return 0
        builtin cd "$dir" &> /dev/null
    done
}


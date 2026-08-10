
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# ===============================
# Zsh 启动性能分析（可选）
# ===============================
# 调试时启用：
# zmodload zsh/zprof

# ===============================
# Zim 初始化
# ===============================
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# 下载 zimfw 插件管理器（若缺失）
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# 初始化 Zim 模块
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
source ${ZIM_HOME}/init.zsh

# ===============================
# Zsh 基础配置
# ===============================

# 历史配置
setopt HIST_IGNORE_ALL_DUPS

# 输入模式
bindkey -v
WORDCHARS=${WORDCHARS//[\/]}

# 自动补全优化（缓存模式）
zstyle ':completion:*' rehash true
zstyle ':compinstall' filename "$HOME/.zshrc"
# autoload -Uz compinit
# compinit -C

# ===============================
# 模块后置配置
# ===============================

# zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# zsh-history-substring-search
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# ===============================
# 延迟加载模块（提速关键）
# ===============================
# 只在第一个提示符前跑一次，跑完自己摸掉 hook。
autoload -Uz add-zsh-hook
add-zsh-hook precmd _defer_plugins
_defer_plugins() {
  add-zsh-hook -d precmd _defer_plugins

  # zoxide：目录跳转，z 跳转 / zi 用 fzf 选
  (( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

  # fzf：集成与自定义命令，详见 ~/.zsh/fzf/README.md
  [[ -f ~/.zsh/fzf.zsh ]] && source ~/.zsh/fzf.zsh

  unfunction _defer_plugins
}

# ===============================
# 环境变量与代理
# ===============================
export PATH="$HOME/.npm-global/bin:/opt/homebrew/opt/ruby/bin:$HOME/.local/bin:$PATH"

# 密钥与 token 统一放在 ~/.zsh/secrets.zsh（不进仓库）
# 新机器：cp ~/.zsh/secrets.zsh.example ~/.zsh/secrets.zsh 后填值
[[ -f ~/.zsh/secrets.zsh ]] && source ~/.zsh/secrets.zsh

# 代理配置
[[ -f ~/.zsh/proxy.zsh ]] && source ~/.zsh/proxy.zsh

# ===============================
# 别名 (Aliases)
# ===============================
alias k='kubectl'
alias lg='lazygit'
alias docker=podman

# Trip Dev kubectl 别名
alias tdk='kubectl --kubeconfig=$HOME/.kube/trip-dev.config'
alias tdkcg='kubectl --kubeconfig=$HOME/.kube/trip-dev.config config get-contexts'
alias tdkcu='kubectl --kubeconfig=$HOME/.kube/trip-dev.config config use-context'

# Trip Testing kubectl 别名
alias ttk='kubectl --kubeconfig=$HOME/.kube/trip-testing.config'
alias ttkcg='kubectl --kubeconfig=$HOME/.kube/trip-testing.config config get-contexts'
alias ttkcu='kubectl --kubeconfig=$HOME/.kube/trip-testing.config config use-context'

# Trip Prod kubectl 别名
alias tpk='kubectl --kubeconfig=$HOME/.kube/trip-prod.config'
alias tpkcg='kubectl --kubeconfig=$HOME/.kube/trip-prod.config config get-contexts'
alias tpkcu='kubectl --kubeconfig=$HOME/.kube/trip-prod.config config use-context'

# ===============================
# 性能分析（调试用）
# ===============================
# 调试时取消注释以下行以查看启动耗时
# zprof

[[ -s "/Users/junpeng/.gvm/scripts/gvm" ]] && source "/Users/junpeng/.gvm/scripts/gvm"

# Added by Antigravity
export PATH="/Users/junpeng/.antigravity/antigravity/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Ada CLI
export PATH="$HOME/.ada-cli/bin:$PATH"


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"






export SSL_CERT_FILE="$HOME/.ctrip-certs.pem"

# --- Node TLS: trust Ctrip internal CA (for pi / opencode / npm to reach *.ctripcorp.com) ---
export NODE_EXTRA_CA_CERTS="$HOME/.ctrip-certs.pem"

# Added by git-ai install.sh on Fri Jul 31 12:37:53 CST 2026
export PATH="/Users/junpeng/.git-ai/bin:$PATH"

# Node V8 compile cache: speeds up node CLI startup (pi, etc.) ~10-20%
export NODE_COMPILE_CACHE="$HOME/.cache/node-compile-cache"

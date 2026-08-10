# ~/.zsh/fzf.zsh
# =====================================================
#          fzf 配置
# =====================================================
# 由 .zshrc 的 precmd hook 延迟加载。
#
# 键位（官方默认）:
#   ^T      选文件/目录，插入命令行
#   Alt-C   选目录并 cd
#   ^R      历史命令搜索（? 切换预览）
#   Tab     补全，由 fzf-tab 接管（见 .zimrc）
#
# 自定义命令见 ~/.zsh/fzf/ ，用 util 查看清单。
# =====================================================

(( $+commands[fzf] )) || return 0

# -----------------------------------------------------
# 通用外观
# 遍历交给 fzf 内建 walker，不设 FZF_DEFAULT_COMMAND
# -----------------------------------------------------
export FZF_DEFAULT_OPTS='--height=50% --min-height=15 --reverse
  --tiebreak=end
  --preview-window=right:60%:wrap
  --bind=ctrl-e:down,ctrl-u:up
  --bind=ctrl-alt-u:preview-up,ctrl-alt-e:preview-down'

# 预览命令：优先 bat，退回 cat
if (( $+commands[bat] )); then
  export FZF_PREVIEW_FILE_CMD='bat --style=numbers --color=always --line-range=:500'
else
  export FZF_PREVIEW_FILE_CMD='cat'
fi

if (( $+commands[eza] )); then
  export FZF_PREVIEW_DIR_CMD='eza --tree --level=1 --color=always'
else
  export FZF_PREVIEW_DIR_CMD='ls -la'
fi

# 跳过的目录，walker 与自定义脚本共用
export FZF_WALKER_SKIP='.git,node_modules,venv,.venv,target,dist,.next'

# -----------------------------------------------------
# 官方集成：key-bindings + completion
# -----------------------------------------------------
# completion.zsh 会把 Tab 抢去绑 fzf-completion，而 .zimrc 里的
# fzf-tab 已经接管了 Tab（且补全体验更好，带上下文感知），
# 所以 source 后把 Tab 还给 fzf-tab。
source <(fzf --zsh)

if (( $+widgets[fzf-tab-complete] )); then
  bindkey '^I' fzf-tab-complete
fi

# ^T 选文件/目录
export FZF_CTRL_T_OPTS="--walker=file,dir,follow,hidden
  --walker-skip=$FZF_WALKER_SKIP
  --preview '[[ -d {} ]] && $FZF_PREVIEW_DIR_CMD {} || $FZF_PREVIEW_FILE_CMD {}'"

# Alt-C 选目录并 cd
export FZF_ALT_C_OPTS="--walker=dir,follow,hidden
  --walker-skip=$FZF_WALKER_SKIP
  --preview '$FZF_PREVIEW_DIR_CMD {}'"

# ^R 历史，默认藏起预览，? 展开看长命令
export FZF_CTRL_R_OPTS="--preview 'echo {2..}'
  --preview-window=down:3:hidden:wrap
  --bind='?:toggle-preview'"

# 补全的预览同 ^T（fzf-tab 接管 Tab 后这两项只在
# 手动调 fzf-completion 时生效，保留作为后路）
export FZF_COMPLETION_TRIGGER='**'
export FZF_COMPLETION_PATH_OPTS="--walker=file,dir,follow,hidden
  --preview '[[ -d {} ]] && $FZF_PREVIEW_DIR_CMD {} || $FZF_PREVIEW_FILE_CMD {}'"
export FZF_COMPLETION_DIR_OPTS="--walker=dir,follow,hidden
  --preview '$FZF_PREVIEW_DIR_CMD {}'"

# -----------------------------------------------------
# 自定义命令（autoload，清单见 util）
# 只抓可执行文件，避开 README.md 这类文档
# -----------------------------------------------------
_fzf_fpath=${0:A:h}/fzf
if [[ -d $_fzf_fpath ]]; then
  fpath+=$_fzf_fpath
  autoload -Uz $_fzf_fpath/*(.x:t)
fi
unset _fzf_fpath

# 按内容检索文件：fif <pattern>
fif() {
  if (( $# == 0 )); then
    echo "用法: fif <pattern>" >&2
    return 1
  fi
  local file
  file=$(rg --files-with-matches --no-messages -- "$1" |
    fzf --preview "rg --ignore-case --pretty --context 5 -- ${(q)1} {}") || return
  [[ -n $file ]] && ${EDITOR:-vim} "$file"
}

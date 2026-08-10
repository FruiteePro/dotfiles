#!/usr/bin/env bash
#
# 把仓库里的配置软链到 home 下的目标位置。
# 已存在的普通文件会先备份成 <目标>.bak.<时间戳>，不会直接覆盖。
#
# 用法:
#   ./install.sh            实际建链并按需安装依赖
#   ./install.sh --dry      只打印将要做什么
#   ./install.sh --no-deps  只建链，跳过依赖安装

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
SKIP_DEPS=0
for arg in "$@"; do
  case "$arg" in
    --dry)     DRY_RUN=1 ;;
    --no-deps) SKIP_DEPS=1 ;;
    *) echo "未知参数: $arg" >&2; exit 1 ;;
  esac
done

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    echo "跳过 $2 (仓库中缺少 $1)"
    return
  fi

  # 已经指向正确位置，无需处理
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "已链接 $2"
    return
  fi

  if (( DRY_RUN )); then
    if [[ -e "$dst" && ! -L "$dst" ]]; then
      echo "将备份并链接 $2"
    else
      echo "将链接 $2"
    fi
    return
  fi

  mkdir -p "$(dirname "$dst")"

  # 现有的普通文件或目录先备份，软链直接替换
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="$dst.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$backup"
    echo "已备份 $2 -> $(basename "$backup")"
  fi

  ln -sfn "$src" "$dst"
  echo "已链接 $2"
}

link zsh/.zshrc             .zshrc
link zsh/.zimrc             .zimrc
link zsh/.zsh/proxy.zsh     .zsh/proxy.zsh
link zsh/.zsh/fzf.zsh       .zsh/fzf.zsh
link zsh/.zsh/fzf           .zsh/fzf
link config/ghostty/config  .config/ghostty/config
link pi/settings.json       .pi/agent/settings.json

# 首次安装时生成密钥文件骨架，已存在则不动
SECRETS="$HOME/.zsh/secrets.zsh"
if [[ ! -e "$SECRETS" ]]; then
  if (( DRY_RUN )); then
    echo "将创建 .zsh/secrets.zsh (从 example 复制)"
  else
    mkdir -p "$(dirname "$SECRETS")"
    cp "$DOTFILES/zsh/.zsh/secrets.zsh.example" "$SECRETS"
    chmod 600 "$SECRETS"
    echo "已创建 .zsh/secrets.zsh，请填入真实值"
  fi
fi

# =====================================================
# 依赖安装
# fzf：.zshrc 的 fzf 集成和 .zimrc 的 fzf-tab 都需要本体
# ripgrep：fif 按内容检索
# bat / eza：fzf 预览窗的文件与目录渲染
# 目录遍历用 fzf 0.47+ 内建 walker，不再需要 fd / tree
# =====================================================
BREW_DEPS=(fzf ripgrep bat eza)

# brew formula 名与实际命令名不一致的做个映射
dep_command() {
  case "$1" in
    ripgrep) echo rg ;;
    *)       echo "$1" ;;
  esac
}

install_deps() {
  local missing=() formula
  for formula in "${BREW_DEPS[@]}"; do
    command -v "$(dep_command "$formula")" >/dev/null 2>&1 || missing+=("$formula")
  done

  if (( ${#missing[@]} == 0 )); then
    echo "依赖齐全: ${BREW_DEPS[*]}"
    return
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "缺少依赖但未找到 brew，请手动安装: ${missing[*]}"
    return
  fi

  if (( DRY_RUN )); then
    echo "将执行 brew install ${missing[*]}"
    return
  fi

  echo "安装缺失依赖: ${missing[*]}"
  brew install "${missing[@]}"
}

echo
if (( SKIP_DEPS )); then
  echo "已跳过依赖安装 (--no-deps)"
else
  install_deps
fi

echo
echo "完成。新开一个 shell 生效。"

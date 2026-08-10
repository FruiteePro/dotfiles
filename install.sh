#!/usr/bin/env bash
#
# 把仓库里的配置软链到 home 下的目标位置。
# 已存在的普通文件会先备份成 <目标>.bak.<时间戳>，不会直接覆盖。
#
# 用法:
#   ./install.sh          实际建链
#   ./install.sh --dry    只打印将要做什么

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
[[ "${1:-}" == "--dry" ]] && DRY_RUN=1

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

echo
echo "完成。新开一个 shell 生效。"

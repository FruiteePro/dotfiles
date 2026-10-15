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
link zsh/.zsh/bws-secrets.zsh .zsh/bws-secrets.zsh
link bin/sec                .local/bin/sec
link config/ghostty/config  .config/ghostty/config
link pi/settings.json            .pi/agent/settings.json
link pi/settings-extensions.json .pi/agent/settings-extensions.json
link pi/AGENTS.md                .pi/agent/AGENTS.md
link pi/prompts/commit.md        .pi/agent/prompts/commit.md

# 密钥改由 Bitwarden Secrets Manager 同步（见 bin/sec），不再生成 secrets.zsh 骨架

# =====================================================
# 依赖安装
# fzf：.zshrc 的 fzf 集成和 .zimrc 的 fzf-tab 都需要本体
# zoxide：目录跳转（z / zi）
# ripgrep：fif 按内容检索
# bat / eza：fzf 预览窗的文件与目录渲染
# 目录遍历用 fzf 0.47+ 内建 walker，不再需要 fd / tree
# =====================================================
BREW_DEPS=(fzf zoxide ripgrep bat eza)

# brew formula 名与实际命令名不一致的做个映射
dep_command() {
  case "$1" in
    ripgrep) echo rg ;;
    *)       echo "$1" ;;
  esac
}

# bws（Bitwarden Secrets Manager CLI）不在 Homebrew，从官方 release 下载。
# 版本和 sha256 写死，升级时同时改两处：
# https://github.com/bitwarden/sdk-sm/releases 的 bws-sha256-checksums-<版本>.txt
BWS_VERSION=2.1.0
BWS_SHA256=286159545c7c834d93785c5a86e91d51026a5cc9858713936f391beb1ead2524   # bws-macos-universal

install_bws() {
  local current
  current=$(bws --version 2>/dev/null | awk '{print $2}') || true
  if [[ "$current" == "$BWS_VERSION" ]]; then
    echo "bws 已是 $BWS_VERSION"
    return
  fi
  if [[ "$(uname -s)" != Darwin ]]; then
    echo "非 macOS，跳过 bws 自动安装"
    return
  fi
  if (( DRY_RUN )); then
    echo "将安装 bws $BWS_VERSION 到 ~/.local/bin"
    return
  fi

  local zip="bws-macos-universal-$BWS_VERSION.zip" tmp
  tmp=$(mktemp -d)
  echo "安装 bws $BWS_VERSION"
  curl -fsSL -o "$tmp/$zip" "https://github.com/bitwarden/sdk-sm/releases/download/bws-v$BWS_VERSION/$zip"
  if ! echo "$BWS_SHA256  $tmp/$zip" | shasum -a 256 -c - >/dev/null; then
    rm -rf "$tmp"
    echo "bws 校验失败，未安装" >&2
    return 1
  fi
  unzip -oq "$tmp/$zip" -d "$tmp"
  mkdir -p "$HOME/.local/bin"
  install -m 755 "$tmp/bws" "$HOME/.local/bin/bws"
  rm -rf "$tmp"
  echo "已安装 $("$HOME/.local/bin/bws" --version)"
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
  install_bws
fi

echo
echo "完成。新开一个 shell 生效。"

# 新机器还没配 bws token 时，提示密钥初始化步骤
if ! security find-generic-password -a "$USER" -s bws-access-token >/dev/null 2>&1; then
  echo
  echo "密钥未初始化（Bitwarden Secrets Manager）："
  echo "  1. 在 https://vault.bitwarden.com 的 Secrets Manager 里给这台机器建 machine account，"
  echo "     授权 shell-secrets 项目（Can read, write），生成 access token"
  echo "  2. security add-generic-password -U -a \"\$USER\" -s bws-access-token -w   # 粘贴 token"
  echo "  3. sec sync"
fi

# 从 autojump 迁过来的机器，提示导入历史数据后再卸载
if command -v autojump >/dev/null 2>&1; then
  echo
  echo "检测到 autojump，配置已改用 zoxide。导入历史数据后可以卸载："
  echo "  zoxide import autojump < ~/Library/autojump/autojump.txt"
  echo "  brew uninstall autojump"
fi

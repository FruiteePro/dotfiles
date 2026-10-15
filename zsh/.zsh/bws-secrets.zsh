# 交互 shell 的密钥加载与快捷命令。核心逻辑在 ~/.local/bin/sec（dotfiles/bin/sec）。
#
# 启动时只读本机钥匙串缓存 bws-env-cache（约 30ms，不联网）；缓存由 sec sync 从
# Bitwarden Secrets Manager 拉取生成。没有缓存时什么也不做，不影响 shell 启动。
#
#   secset NAME    创建或更新密钥，并刷新当前 shell
#   secsync        从云端拉取（别的机器或网页改过之后执行），并刷新当前 shell
#   secrun CMD     用缓存里的密钥执行 CMD（等同 sec run -- CMD）
#   seclist        列出缓存里的变量名

_bws_secrets_load() {
  local blob line
  blob=$(security find-generic-password -a "$USER" -s "${BWS_CACHE_SVC:-bws-env-cache}" -w 2>/dev/null) || return 1
  while IFS= read -r line || [[ -n $line ]]; do
    [[ $line == [A-Za-z_]*=* ]] && export "$line"
  done < <(print -rn -- "$blob" | base64 -d)
  return 0
}

secsync() { sec sync "$@" && _bws_secrets_load; }
secset()  { sec set "$@" && _bws_secrets_load; }
secrun()  { sec run -- "$@"; }
seclist() { sec list; }

_bws_secrets_load

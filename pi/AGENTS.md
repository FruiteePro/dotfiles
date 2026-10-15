# 全局指令

- 未经用户批准，不要更改代码。所有更改必须先向用户确认后再执行。
- commit message 必须使用英文描述。
- 回答用户时使用中文。

## 长期记忆（Basic Memory）

- 开始非琐碎任务、或用户提到“之前 / 上次 / 定过”时，先加载 `basic-memory` skill 检索相关记忆。
- 做出技术决策、解决疑难问题、得知用户偏好或项目约定后，按 `basic-memory` skill 写入记忆，并告诉用户记了什么。写记忆不属于“更改代码”，不需要事先确认。
- 未经用户明确要求，不删除记忆。

## 密钥与环境变量

- 密钥存在 Bitwarden Secrets Manager，本机读钥匙串缓存（`~/.local/bin/sec`，见 `~/dotfiles/README.md`「密钥」）。
- Agent 的 bash 不加载 `~/.zshrc`，继承的环境变量可能是旧的或缺失的。需要密钥的命令一律用 `sec run -- <命令>` 执行，例如 `sec run -- python3 scripts/xxx.py`。
- 只能用 `sec list` 查看有哪些变量名。不要输出、打印或回显密钥的值（包括 `env`、`printenv`、`echo $XXX`、`sec run -- env`），也不要把值写进命令参数、文件、日志或回复。
- 缺变量或值失效时，请用户执行 `secset NAME`，不要自己去读 `~/.zsh/secrets.zsh`、钥匙串或 `~/.pm2/dump.pm2`。

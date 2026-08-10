# dotfiles

个人配置，通过软链接管理。

## 安装

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh --dry   # 先看一遍将要做什么
./install.sh
```

`install.sh` 建完链会检测并用 brew 装缺少的依赖（fzf / fd / ripgrep / tree）。
不想动安装就加 `--no-deps`，只建链。

已存在的普通文件会备份成 `<目标>.bak.<时间戳>`，不会被直接覆盖。

装完把密钥填进 `~/.zsh/secrets.zsh`（首次运行 `install.sh` 会从 example 生成）。

## 内容

| 仓库路径 | 链接到 | 说明 |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | zsh 主配置，密钥已外置 |
| `zsh/.zimrc` | `~/.zimrc` | Zim 模块清单 |
| `zsh/.zsh/proxy.zsh` | `~/.zsh/proxy.zsh` | 代理开关函数 |
| `zsh/.zsh/fzf.zsh` | `~/.zsh/fzf.zsh` | fzf 选项与按键绑定 |
| `zsh/.zsh/fzf/` | `~/.zsh/fzf/` | fzf widget 与小工具（autoload） |
| `config/ghostty/config` | `~/.config/ghostty/config` | Ghostty 终端 |
| `pi/settings.json` | `~/.pi/agent/settings.json` | pi coding agent |

## fzf

`~/.zsh/fzf.zsh` 延迟加载（由 `.zshrc` 的 `precmd` hook 触发），绑定：

| 按键 | 功能 |
|---|---|
| `^P` | 文件/目录查找并插入命令行 |
| `^T` | 选目录并 cd |
| `^R` | 历史命令搜索 |
| `^F` | 当前目录内容全文搜索 |

`~/.zsh/fzf/` 里的脚本以 autoload 函数形式提供：`bip`/`bup`/`bcp`（brew 装/升/卸）、
`fp`（看 PATH）、`kp`/`ks`（按进程/端口 kill）、`fif`（内容检索）、`util`（命令速查）。

## 密钥

所有 token 放 `~/.zsh/secrets.zsh`，该文件不进仓库。仓库里只有
`zsh/.zsh/secrets.zsh.example` 作为变量名清单。

`.zshrc` 末尾通过下面这行加载：

```zsh
[[ -f ~/.zsh/secrets.zsh ]] && source ~/.zsh/secrets.zsh
```

## 依赖

- [Zim](https://zimfw.sh/) — `.zshrc` 里会自动下载 zimfw.zsh
- fzf / fd / ripgrep / tree — `install.sh` 自动检测并用 brew 安装
- [Ghostty](https://ghostty.org/)
- [pi](https://pi.dev/) — `settings.json` 里引用的 npm 包会自动安装

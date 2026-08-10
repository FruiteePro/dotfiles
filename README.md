# dotfiles

个人配置，通过软链接管理。

## 安装

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh --dry   # 先看一遍将要做什么
./install.sh
```

`install.sh` 建完链会检测并用 brew 装缺少的依赖（fzf / zoxide / ripgrep / bat / eza）。
不想动安装就加 `--no-deps`，只建链。

已存在的普通文件会备份成 `<目标>.bak.<时间戳>`，不会被直接覆盖。

装完把密钥填进 `~/.zsh/secrets.zsh`（首次运行 `install.sh` 会从 example 生成）。

## 内容

| 仓库路径 | 链接到 | 说明 |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | zsh 主配置，密钥已外置 |
| `zsh/.zimrc` | `~/.zimrc` | Zim 模块清单 |
| `zsh/.zsh/proxy.zsh` | `~/.zsh/proxy.zsh` | 代理开关函数 |
| `zsh/.zsh/fzf.zsh` | `~/.zsh/fzf.zsh` | fzf 集成与预览配置 |
| `zsh/.zsh/fzf/` | `~/.zsh/fzf/` | 自定义 fzf 命令（autoload） |
| `config/ghostty/config` | `~/.config/ghostty/config` | Ghostty 终端 |
| `pi/settings.json` | `~/.pi/agent/settings.json` | pi coding agent |

## fzf

`~/.zsh/fzf.zsh` 延迟加载（由 `.zshrc` 的 `precmd` hook 触发），
通过 `source <(fzf --zsh)` 用官方集成，键位保持上游默认：

| 按键 | 功能 |
|---|---|
| `^T` | 选文件/目录，插入命令行 |
| `Alt-C` | 选目录并 cd |
| `^R` | 历史命令搜索，`?` 展开预览看长命令 |
| `Tab` | 补全，由 fzf-tab 接管 |

目录遍历用 fzf 0.47+ 的内建 walker，不依赖 `fd`。预览用 `bat` 看文件、
`eza --tree` 看目录，两者缺失时自动退回 `cat` / `ls`。

`~/.zsh/fzf/` 里的脚本以 autoload 函数提供，输 `util` 看完整清单：

| 命令 | 功能 |
|---|---|
| `bip` / `bup` / `bcp` | brew 选包安装 / 升级 / 卸载 |
| `fp` | 浏览 `$PATH` 及其中的可执行文件 |
| `fps` | 选进程输出 PID，供其他命令复用 |
| `kp` / `ks` | 按进程 / 按 TCP 端口 kill |
| `fif` | 按内容检索文件并打开 |
| `util` | 上面这张表 |

## 目录跳转

用 zoxide，`.zshrc` 里延迟初始化：

```zsh
z dotfiles      # 跳到权重最高的匹配项
zi dot          # 候选多时用 fzf 选，带预览
```

从 autojump 迁过来的，旧数据用 `zoxide import autojump` 导入。
新机器上数据库从零累积，正常 `cd` 一段时间就能用。

## 密钥

所有 token 放 `~/.zsh/secrets.zsh`，该文件不进仓库。仓库里只有
`zsh/.zsh/secrets.zsh.example` 作为变量名清单。

`.zshrc` 末尾通过下面这行加载：

```zsh
[[ -f ~/.zsh/secrets.zsh ]] && source ~/.zsh/secrets.zsh
```

## 依赖

- [Zim](https://zimfw.sh/) — `.zshrc` 里会自动下载 zimfw.zsh
- fzf / zoxide / ripgrep / bat / eza — `install.sh` 自动检测并用 brew 安装
- 需自行安装（有别名指向它们，但不纳入自动安装）：kubectl、podman、lazygit
- [Ghostty](https://ghostty.org/)
- [pi](https://pi.dev/) — `settings.json` 里引用的 npm 包会自动安装

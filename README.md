# dotfiles

个人配置，通过软链接管理。

## 安装

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh --dry   # 先看一遍将要做什么
./install.sh
```

已存在的普通文件会备份成 `<目标>.bak.<时间戳>`，不会被直接覆盖。

装完把密钥填进 `~/.zsh/secrets.zsh`（首次运行 `install.sh` 会从 example 生成）。

## 内容

| 仓库路径 | 链接到 | 说明 |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | zsh 主配置，密钥已外置 |
| `zsh/.zimrc` | `~/.zimrc` | Zim 模块清单 |
| `zsh/.zsh/proxy.zsh` | `~/.zsh/proxy.zsh` | 代理开关函数 |
| `config/ghostty/config` | `~/.config/ghostty/config` | Ghostty 终端 |
| `pi/settings.json` | `~/.pi/agent/settings.json` | pi coding agent |

## 密钥

所有 token 放 `~/.zsh/secrets.zsh`，该文件不进仓库。仓库里只有
`zsh/.zsh/secrets.zsh.example` 作为变量名清单。

`.zshrc` 末尾通过下面这行加载：

```zsh
[[ -f ~/.zsh/secrets.zsh ]] && source ~/.zsh/secrets.zsh
```

## 依赖

- [Zim](https://zimfw.sh/) — `.zshrc` 里会自动下载 zimfw.zsh
- [Ghostty](https://ghostty.org/)
- [pi](https://pi.dev/) — `settings.json` 里引用的 npm 包会自动安装

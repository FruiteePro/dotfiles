# fzf 用法

配置入口是 `../fzf.zsh`，由 `.zshrc` 的 `precmd` hook 延迟加载。
本目录放自定义命令，以 autoload 函数形式提供。

## 键位

沿用 fzf 上游默认，没有自己改绑。

| 键 | 功能 |
|---|---|
| `^T` | 选文件/目录，把路径插入当前命令行 |
| `Alt-C` | 选目录并 `cd` 进去 |
| `^R` | 历史命令搜索 |
| `Tab` | 补全，由 fzf-tab 接管 |

`^T` 支持多选，空格键或 `Tab` 标记，选中的路径会用引号包好一起插入。

`^R` 默认藏起预览窗，按 `?` 展开看完整命令（长命令或多行命令有用）。
再按 `^R` 可以切换排序方式（按相关度 / 按时间）。

`^P` `^N` 不是 fzf 的，归 `history-substring-search`：先敲几个字母，
再按 `^P` 只翻含这几个字母的历史。跟 `^R` 是两种不同的找法。

## 选择器内的按键

在 fzf 界面里：

| 键 | 功能 |
|---|---|
| `^E` / `^U` | 下一项 / 上一项（除了方向键） |
| `Tab` / `Shift-Tab` | 标记 / 取消标记（多选模式下） |
| `^Alt-E` / `^Alt-U` | 预览窗向下 / 向上滚 |
| `Shift-↓` / `Shift-↑` | 同上，fzf 自带 |
| `^/` | 切换长行折行 |
| `Enter` | 确认 |
| `^C` / `Esc` | 取消 |

上表前三项里，`^E`/`^U` 和 `^Alt-E`/`^Alt-U` 是 `fzf.zsh` 里自己绑的，
其余是 fzf 默认。

搜索语法：

| 写法 | 含义 |
|---|---|
| `abc def` | 同时含 abc 和 def（顺序无关） |
| `'abc` | 精确匹配 abc，不做模糊 |
| `^abc` | 以 abc 开头 |
| `abc$` | 以 abc 结尾 |
| `!abc` | 排除含 abc 的 |
| `abc \| def` | 含 abc 或 def |

## 自定义命令

| 命令 | 功能 |
|---|---|
| `bip` | brew 选包安装，预览显示 `brew info` |
| `bup` | brew 选包升级，只列可升级的 |
| `bcp` | brew 选包卸载，只列手动装的（`brew leaves`），删前确认 |
| `fp` | 浏览 `$PATH`，回车看该目录下的可执行文件 |
| `fps` | 选进程输出 PID，供其他命令复用 |
| `kp` | 选进程并 kill |
| `ks` | 选监听中的 TCP 端口并 kill 对应进程 |
| `fif` | 按文件内容检索，选中后用 `$EDITOR` 打开 |
| `util` | 上面这张表，选中项会填到命令行（不直接执行） |

几个用法示例：

```zsh
# 按内容找文件
fif "func main"

# fps 输出 PID，拿去做别的事
kill -TERM $(fps)
lsof -p $(fps)

# kp / ks 默认 -9，可以传信号
kp 15        # SIGTERM 而非 SIGKILL
ks 15
```

`fps` 支持多选，多个 PID 之间用空格分隔，所以 `$(fps)` 可以直接展开成多个参数。

## 目录遍历

fzf 0.47+ 有内建 walker，不依赖 `fd` 或 `find`。`fzf.zsh` 里通过
`FZF_WALKER_SKIP` 统一设置跳过的目录：

```
.git,node_modules,venv,.venv,target,dist,.next
```

要临时改遍历范围，用 fzf 的选项而不是设 `FZF_DEFAULT_COMMAND`
（设了它会绕开 walker）：

```zsh
fzf --walker=file,dir,follow,hidden --walker-root=~/code --walker-skip=.git
```

`--walker` 的四个值：`file` 含文件、`dir` 含目录、`follow` 跟随软链、
`hidden` 含隐藏文件。

## 预览

文件用 `bat`，目录用 `eza --tree`。两者缺失时自动退回 `cat` 和 `ls -la`，
判断在 `fzf.zsh` 里通过 `$+commands[...]` 做，所以新机器上没装也不会报错。

预览命令存在 `FZF_PREVIEW_FILE_CMD` 和 `FZF_PREVIEW_DIR_CMD` 两个变量里，
自己写 fzf 调用时可以复用：

```zsh
git branch | fzf --preview 'git log --oneline -20 {1}'
ls | fzf --preview "$FZF_PREVIEW_FILE_CMD {}"
```

## 加些新命令

在本目录放一个可执行脚本，文件名就是命令名。开头写 `#!/usr/bin/env zsh`，
用 `local` 声明变量（会被 autoload 成函数，别污染全局）。

注意 `fzf.zsh` 用 `*(.x:t)` 只 autoload 可执行文件，所以新脚本记得
`chmod +x`，否则不会被加载。这个 glob 也是为了让本文档不被当成命令。

加完在 `util` 的清单里补一行，再更新本文档的命令表。

## 排错

改完配置想立刻生效：

```zsh
source ~/.zsh/fzf.zsh
```

某个命令改了但行为没变，是 autoload 的函数已经缓存了，重新加载：

```zsh
unfunction fps && autoload -Uz fps
```

看某个键实际绑在什么上：

```zsh
bindkey '^T'
bindkey | grep fzf
```

Tab 补全不对劲，先确认是 fzf-tab 在管而不是官方 completion：

```zsh
bindkey '^I'    # 应该是 fzf-tab-complete
```

fzf 本身的版本和选项：

```zsh
fzf --version
fzf --help | less
```

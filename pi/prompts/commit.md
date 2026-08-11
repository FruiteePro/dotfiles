---
description: 暂存并提交本次会话的改动，commit message 用英文
argument-hint: "[额外说明]"
---
为当前改动创建一个 git commit，按以下步骤执行：

1. 运行 `git status` 和 `git diff`（以及 `git diff --cached` 查看已暂存改动），了解改了什么。
2. 只提交属于本次会话工作范围内的改动。识别本次会话中你创建或修改的文件，把它们视为 in-scope。
3. 如果工作区里存在其他无关改动（你本次没有动过的文件），不要暂存它们。先列出这些无关改动并向用户确认，得到许可后才可包含。
4. 审查 in-scope 改动并按逻辑分组。暂存前，标记出可能包含密钥的文件（`.env`、凭证、token 等）。
5. 只用 `git add <files>` 暂存 in-scope 文件。禁止使用 `git add .` 或 `git add -A`，以免误带无关改动。
6. 用英文写 commit message，遵循 Conventional Commits 风格。第一行是 `type(scope): summary`，summary 控制在 72 字符以内。
7. 必须写 commit body：用分点（`-` 列表）清楚说明本次主要变更，每点一句话概括一项改动及其目的。body 与 summary 之间空一行。
8. 用 `git commit` 创建提交（可用多个 `-m` 分别传 summary 和 body，或用 `-F` 传入完整 message）。除非用户明确要求，不要使用 `--amend` 或 `--no-verify`。
9. 用 `git log -1 --stat` 展示结果。

额外说明：${@:-无}

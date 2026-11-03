/**
 * herdr-env: 按终端宿主只暴露对应的 herdr skill。
 *
 * - herdr-core（命令 hc / herdr-app）：进程环境里有 HC_TERMINAL_ID
 * - 旧版 herdr（命令 herdr）：进程环境里有 HERDR_ENV=1
 *
 * 不在对应环境时，从 <available_skills> 里去掉该 skill，
 * 并加一个 <terminal_host> 段落直接告诉模型当前环境。
 * 只对模型隐藏，手动 /skill:herdr 仍可用。
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function herdrEnv(pi: ExtensionAPI) {
  pi.on("before_agent_start", (event) => {
    const o = event.systemPromptOptions;
    const inHc = !!process.env.HC_TERMINAL_ID;
    const inHerdr = process.env.HERDR_ENV === "1";

    o.skills = o.skills.filter((s) => {
      if (s.name === "herdr") return inHerdr;
      if (s.name === "herdr-core") return inHc;
      return true;
    });

    o.sections.terminal_host = inHc
      ? "Running inside herdr-core. For terminals, sub-agents and the Herdr window use `hc` / `herdr-app` (skill: herdr-core). Never use the legacy `herdr` CLI."
      : inHerdr
        ? "Running inside legacy Herdr. Use the `herdr` CLI (skill: herdr). Do not use `hc` or `herdr-app`."
        : "Not running inside herdr or herdr-core. Do not use `herdr`, `hc` or `herdr-app` unless the user asks.";
  });
}

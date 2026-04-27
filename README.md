# OpenClaw Deploy Notes Skill

一个用于安装、修复、验证和记录 OpenClaw 部署过程的中文 Agent Skill。

它的重点不是“一次性甩出很多命令”，而是帮助 agent 先做最小只读检查，把问题分到正确层级，再按需深入。适合排查 OpenClaw Gateway、Dashboard、模型认证、web search、memory search、macOS 代理和用户范围等常见部署问题。

English summary: this is a Chinese OpenClaw skill for deployment diagnostics, repair guidance, and reusable deployment notes. It emphasizes minimal read-only checks, careful issue classification, and privacy-safe deployment records.

## 适合场景

- 在新机器上安装或验证 OpenClaw。
- 修复 Gateway、Dashboard WebSocket、模型认证、web search、memory search 问题。
- 排查 macOS 上 shell、launchctl、LaunchAgent、系统代理之间的漂移。
- 生成一份可复用、可交接、已脱敏的 OpenClaw 部署记录。

## 目录结构

```text
openclaw-deploy-notes/
├── SKILL.md
├── references/
│   ├── memory-search.md
│   └── proxy-and-ports.md
├── scripts/
│   └── openclaw_first_check.sh
└── assets/
    └── deployment-record-template.md
```

## 安装方式

把整个目录复制到你的 personal skills 目录：

```bash
mkdir -p ~/.agents/skills
cp -R openclaw-deploy-notes-skill ~/.agents/skills/openclaw-deploy-notes
```

然后新开一个 OpenClaw / Codex 会话，让运行时重新加载 skills。

## 使用方式

可以这样触发：

```text
请使用 openclaw-deploy-notes，帮我做第一轮只读健康检查，并按正常、非阻塞警告、需要处理的问题总结。
```

或者：

```text
请使用 openclaw-deploy-notes，帮我判断 memory status 里 Embeddings ready 但 Indexed 不是全部文件，这是不是部署故障。
```

## 设计原则

这个 skill 默认先做最小检查，不直接修改配置；除非用户明确授权，才进入修复步骤。它会优先区分 OpenClaw 本体、Gateway、模型/搜索/memory、网络代理、macOS 用户范围，避免把非阻塞 warning 误判成核心故障。

## 隐私与安全

不要把 API key、Gateway token、OAuth token、完整 `.env`、完整 `openclaw.json`、完整 LaunchAgent plist、logs、sessions 或 deployment records 上传到公开仓库。

本仓库只应该包含 skill 本体：`SKILL.md`、`references/`、`scripts/`、`assets/` 和仓库说明文件。

## License

MIT

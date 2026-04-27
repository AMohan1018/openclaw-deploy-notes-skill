---
name: openclaw-deploy-notes
description: 指导在新机器上安装、修复、验证和记录 OpenClaw 部署流程。适用于首次安装 OpenClaw、修复损坏安装、排查 gateway 或代理问题、配置模型认证、web search、memory search，或整理一份可复用的跨机器部署清单。Use when installing or repairing OpenClaw on a new machine.
---

# OpenClaw 部署说明

当任务是安装、修复、验证，或整理某台机器上的 OpenClaw 部署过程时，使用这个 skill。

## 目标

- 让 OpenClaw 在本机正常运行，并确保 Gateway 可用。
- 验证模型认证、web search 和 memory search 是否正常。
- 尽早暴露常见阻塞项：缺少 API key、代理问题、Gateway 服务问题、memory 文件缺失、端口配置漂移。
- 留下一份以后可以在别的机器上重复使用的部署清单。

## 工作流程

1. 在修改任何配置前，先检查当前状态。
2. 先把问题分到正确层级：OpenClaw Gateway、模型认证、网络代理、macOS 用户范围。
3. 如果用户已经给出具体错误，按该错误的专门排查优先级走，不要套用普通健康检查顺序。
4. 优先修复最小的阻塞问题。
5. 每次修改后立刻复测，不要同时改很多东西。
6. 优先选择稳定、可重复的配置，而不是一次性的终端临时修复。

## 默认回应节奏

第一次回应用户时，只给第一轮检查，不要给完整排查树。即使用户问“会检查哪些层级”，也只概括 3-4 个主层级：OpenClaw 本体、Gateway、模型/搜索/memory、网络代理。不要把所有可能层级一次性展开成 8-10 项。

第一轮默认只给这些命令：

```bash
~/.openclaw/bin/openclaw --version
~/.openclaw/bin/openclaw gateway status
~/.openclaw/bin/openclaw doctor
~/.openclaw/bin/openclaw memory status --deep
~/.openclaw/bin/openclaw config get tools.web.search.provider
```

如果需要实际执行第一轮检查，优先运行 `scripts/openclaw_first_check.sh`。这个脚本只读，不修改配置，用完整路径调用 OpenClaw，并输出版本、Gateway、doctor、memory、web search provider 结果。

只有当这些命令的输出显示异常，或者用户明确要求深入排查某一类问题时，才继续追加命令。不要在第一轮输出 `plutil`、`lsof`、`launchctl print`、大段 `ls -la`、多组 API key 环境变量检查，除非问题已经指向对应层级。

## 基础检查

排查安装问题时，先给用户一组最小只读检查，不要一开始列太多命令：

```bash
~/.openclaw/bin/openclaw --version
~/.openclaw/bin/openclaw gateway status
~/.openclaw/bin/openclaw doctor
~/.openclaw/bin/openclaw memory status --deep
~/.openclaw/bin/openclaw config get tools.web.search.provider
```

如果最小检查里出现异常，再按问题类型追加更细的检查。不要为了“完整”而一次性输出长命令清单。

如果 OpenClaw 是通过 CLI 安装脚本装上的，通常要记住：

- 可执行文件通常在 `~/.openclaw/bin/openclaw`
- 配置文件通常在 `~/.openclaw/openclaw.json`
- 环境文件通常在 `~/.openclaw/.env`
- 工作目录通常在 `~/.openclaw/workspace`
- Gateway 服务文件通常在 `~/Library/LaunchAgents/ai.openclaw.gateway.plist`
- 如果 dashboard 或后台执行环境里直接运行 `openclaw` 出现 `command not found`，但 `~/.openclaw/bin/openclaw` 可以运行，这通常只是 PATH 差异，不代表 OpenClaw 部署损坏。先使用完整路径继续检查，再决定是否需要修 `~/.zshrc` 或服务环境。
- 更新后要确认 CLI wrapper、Gateway 服务和实际 npm package 版本一致。如果 `openclaw update` 显示更新成功，但 `~/.openclaw/bin/openclaw --version` 仍是旧版本，要检查 wrapper 是否还指向旧的 `~/.openclaw/lib/node_modules/openclaw`。

## 常见阻塞点

### 模型认证

- `openai-codex/*` 使用的是 OAuth，和 `OPENAI_API_KEY` 不是一回事。
- 即使 Codex OAuth 已经正常，memory embeddings 仍然可能需要 `OPENAI_API_KEY`。
- 判断问题时要区分“模型能聊天”和“embedding provider 能工作”。前者通常看 Codex OAuth，后者通常看 `OPENAI_API_KEY`、provider 配置和网络出口。

### Doctor 与状态完整性

- `orphan transcript files` 通常表示旧的会话轨迹文件还留在磁盘上，但已经不再被当前 `sessions.json` 引用。它更像清理项或遗留痕迹，不代表 Gateway、模型调用、memory search 或 web search 损坏。
- 解读这类 warning 时，先看核心链路是否正常：Gateway 是否 reachable/RPC ok、memory 是否 `Embeddings: ready`、插件是否无 errors。如果这些都正常，把 orphan transcript files 归为非阻塞警告。
- 只有在用户想清理磁盘、整理会话状态，或怀疑 session store 一致性问题时，才继续做更细检查或归档；不要在第一轮健康检查后立刻修复。

### Skills requirements

- `Missing requirements: N` 通常表示有 N 个 skill 尚未满足各自前置条件，例如缺少外部 CLI、API key、平台能力、应用或授权。它是 skills 可用性摘要，不等于 OpenClaw 核心部署故障。
- 解读这个数字时，不要因为 N 很大就建议一次性全装。先确认用户当前要用哪个 skill；只有缺失项影响当前目标时，才把它升级为需要处理的问题。
- 如果 Gateway 正常、memory ready、plugins errors 为 0，则把单独的 `Missing requirements` 计数归为非阻塞警告。处理策略是按需补齐：做一个 skill，补一个 skill，验证一个 skill。
- 只有当关键 skill 不可用、eligible skills 太少已经影响实际工作，或 doctor/Control UI 明确指出某个 missing requirement 是当前路径必需时，才继续深入检查具体 requirements。

### 代理与网络

- 浏览器能访问外网，并不代表 OpenClaw CLI 或 Gateway 一定能连到 provider API。
- 如果机器依赖本地代理，必须同时为 shell 和 Gateway 服务明确配置代理环境变量。
- 修改代理环境变量后，要重新安装或重启 Gateway 服务，并再次验证。
- 不要把 OpenClaw Gateway 端口和代理端口混在一起。`18789` 通常是 OpenClaw Gateway 端口，`7890`、`59638`、`53633` 这类通常是本地代理端口。
- macOS 上至少要分清三层代理：shell 环境变量、`launchctl` 用户环境、系统网络代理。终端命令、从 Dock/Finder 启动的 GUI app、系统级网络服务可能读到不同的代理设置。
- 如果 OpenClaw Gateway 是 LaunchAgent，要检查服务文件里是否带上正确的 `HTTP_PROXY`、`HTTPS_PROXY`、`NO_PROXY`。
- 当用户遇到网络、代理、Codex 登录、OpenAI API、embedding 超时，或端口配置漂移时，读取 `references/proxy-and-ports.md` 再继续。

只有在代理或网络疑似异常时，再追加这些只读检查：

```bash
echo $HTTP_PROXY
echo $HTTPS_PROXY
echo $NO_PROXY
launchctl getenv HTTP_PROXY
launchctl getenv HTTPS_PROXY
launchctl getenv NO_PROXY
scutil --proxy | egrep 'HTTP|HTTPS|SOCKS|Proxy|Port'
plutil -p ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

解读代理结果时要明确说明：

- `echo $HTTP_PROXY` 只代表当前 shell。
- `launchctl getenv HTTP_PROXY` 代表当前 macOS 用户的 GUI/后台进程环境。
- `plutil -p ~/Library/LaunchAgents/ai.openclaw.gateway.plist` 才能看 Gateway 服务实际写入的环境。
- `scutil --proxy` 是系统网络服务代理，可能影响其他用户或系统级应用。

如果代理端口改过，优先统一到一个稳定端口，再更新 `~/.zshrc`、`~/.openclaw/.env` 和 Gateway LaunchAgent。系统网络代理需要单独判断是否应该改，因为它可能影响其他 macOS 用户。

### Dashboard 与 Gateway WebSocket

- 如果 dashboard 页面能打开，但显示 `disconnected (1006)`，先区分“HTTP 页面可访问”和“WebSocket/RPC 是否可用”。`curl -I http://127.0.0.1:18789/` 返回 200 只说明网页能加载，不代表 Gateway RPC 正常。
- 如果 `openclaw gateway status` 显示端口已监听，但 `Connectivity probe: failed` 或 `Gateway ... unreachable (timeout)`，优先看 Gateway 日志，不要先怀疑 token。
- 若日志反复出现 `bonjour`、`CIAO ANNOUNCEMENT CANCELLED`、`service stuck in announcing`，说明局域网发现广播插件可能拖住 Gateway。Bonjour 只是自动发现本机 Gateway 的可选插件，本机 loopback dashboard 不依赖它。
- 对只在本机使用的部署，可以先禁用 Bonjour 并重启 Gateway：

```bash
~/.openclaw/bin/openclaw plugins disable bonjour
~/.openclaw/bin/openclaw gateway restart
sleep 20
~/.openclaw/bin/openclaw gateway status
```

- 修复成功的信号是 `Connectivity probe: ok`，或 `openclaw status` 里 Gateway 变成 `reachable ... auth token`。
- 如果 Gateway 已经 reachable，但浏览器仍显示旧的 `1006`，让用户刷新页面，或运行 `~/.openclaw/bin/openclaw dashboard` 重新打开带当前 token 的 dashboard。不要让用户把 token 发到聊天里。

### Memory Search

- `Embeddings: ready` 表示 embedding provider 这条链路是健康的。
- `no memory files found` 不是故障，只是说明 memory 目录里还没有内容。
- 当用户询问 memory search、embedding、索引、长期记忆文件，或需要解读 `openclaw memory status --deep` 时，读取 `references/memory-search.md` 再继续。
- 在 `~/.openclaw/workspace/memory/` 下添加文件后，运行：

```bash
~/.openclaw/bin/openclaw memory index --force
~/.openclaw/bin/openclaw memory search "test query"
```

### 异步事件与 Heartbeat

- 如果 dashboard 反复弹出 `System (untrusted): ... Exec completed ... An async command you ran earlier has completed`，并触发额外模型回复或 `NO_REPLY`，优先检查 heartbeat 状态。
- `openclaw status` 中的 `Heartbeat 30m` 表示主 agent 会定时或因异步 exec 完成被唤醒。若用户只做本机手动使用，不需要后台主动唤醒，可把 `agents.defaults.heartbeat.every` 设为 `0m` 并重启 Gateway。
- 关闭 heartbeat 不会关闭 Gateway、dashboard、普通聊天、memory search 或 web search；它主要关闭后台定时/异步完成后的自动 follow-up。

## 用户范围

优先把 OpenClaw 的配置控制在当前用户内，尤其是临时学习账户或准备以后删除的账户。

- `~/.openclaw`、`~/.codex`、`~/.agents/skills`、`~/.zshrc` 和 `~/Library/LaunchAgents/ai.openclaw.gateway.plist` 通常只影响当前用户。
- `launchctl setenv` 默认影响当前登录用户的 GUI/CLI 进程环境，不会自动改另一个 macOS 用户。
- `sudo networksetup`、系统设置里的网络代理、`/Applications` 里的应用升级，可能影响整台机器或其他用户。
- 如果主账户不需要一起改，先避免做系统级修改；把当前用户跑通后，再单独决定是否整理整机代理。

## 良好部署习惯

- 不要把 API key 暴露在聊天记录或截图里。
- 如果可能，尽量使用固定代理端口。
- 优先把可复用技能放在 `~/.agents/skills`。
- 记录哪些步骤需要手动配置，这样下一台机器会更快。
- 每次修复后留下一个最小验证结果，比如 Gateway `RPC probe: ok`、memory `Embeddings: ready`、web search provider 已设置。
- 当用户要求整理部署记录、迁移清单、机器状态记录时，使用 `assets/deployment-record-template.md` 作为输出模板。
- 填写部署记录时，只写可验证事实；不能确认的字段写“未确认”，不要猜。记录要覆盖影响范围、证据、修改动作、验证结果和回滚方式，并且必须脱敏，不记录 API key、gateway token、OAuth token、完整 `.env`、完整 `openclaw.json` 或完整 LaunchAgent plist。
- 生成正式部署记录时，默认只运行第一轮最小检查和必要补充项。不要为了填满模板而一次性运行 `status --deep`、`skills list`、多组 config、完整日志读取等高输出命令；未知字段保留“未确认”，等用户要求再深化。

## 输出方式

在帮助用户部署 OpenClaw 时：

- 用白话解释每一步
- 把“这一步在做什么”和“要执行什么命令”分开说
- 明确指出 warning 是阻塞还是非阻塞
- 优先一次只推进一个小步骤
- 遇到代理或认证问题时，先解释是哪一层出了问题，再给命令。
- 如果需要用户手动处理系统设置，要明确说明这一步是否会影响其他 macOS 用户。
- 默认先给最小可执行命令集；只有用户贴出异常或要求深入排查时，再展开高级检查。
- 避免把十几条命令一次性丢给用户。更好的节奏是：先跑 3-5 条高信号命令，再根据输出决定下一步。
- 如果用户要求“只读检查”，回答里应该先说明“我先做第一轮只读检查”，然后只给最小检查集。不要把高级检查预先全部列出来。
- 如果已经实际运行了检查命令，回答里必须用简短清单列出“实际运行了哪些命令”。不要声称运行了命令却不列命令；不要贴完整输出，除非用户明确要求。
- 解读结果时，优先分成“正常”“非阻塞警告”“需要处理的问题”。如果没有阻塞，要明确说没有发现核心阻塞。

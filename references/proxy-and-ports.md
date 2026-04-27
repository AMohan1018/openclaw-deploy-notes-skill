# 代理与端口排查

这份参考只在用户遇到网络、代理、Codex 登录、OpenAI API、embedding 超时，或端口配置漂移时读取。第一轮健康检查正常时，不需要主动展开。

## 先区分两类端口

OpenClaw Gateway 端口和本地代理端口不是一回事。`18789` 通常是 OpenClaw Gateway 的本地控制端口，用于 dashboard、Gateway WS 和本机 RPC。`7890`、`59638`、`53633` 这类通常是本地代理端口，用于连接 OpenAI、Tavily、GitHub 等外部服务。

如果用户说“改端口后坏了”，先问清楚是哪类端口。Gateway 端口坏了，症状通常是 dashboard 或 `openclaw gateway status` 连不上。代理端口坏了，症状通常是 Codex OAuth token exchange 失败、embedding fetch timeout、外部 provider API 超时。

## macOS 上的三层代理

同一台 Mac 上，至少要分清三层代理。当前 shell 环境变量影响从这个终端启动的命令；`launchctl` 用户环境影响从 Dock/Finder 启动的 GUI app 和部分后台进程；系统网络代理来自 macOS 网络服务设置，可能影响系统级应用，也可能影响其他用户。

常用只读检查：

```bash
echo $HTTP_PROXY
echo $HTTPS_PROXY
echo $NO_PROXY
launchctl getenv HTTP_PROXY
launchctl getenv HTTPS_PROXY
launchctl getenv NO_PROXY
scutil --proxy | egrep 'HTTP|HTTPS|SOCKS|Proxy|Port'
```

解读时不要把三层混成一个结论。`echo` 结果正常，只说明当前终端正常；`launchctl getenv` 正常，才更能解释 GUI app 或后台服务是否会继承代理；`scutil --proxy` 正常，才说明系统网络服务层没有明显漂移。

## Gateway LaunchAgent 环境

OpenClaw Gateway 如果是 macOS LaunchAgent，服务实际拿到的环境要看 plist，而不是只看当前终端：

```bash
plutil -p ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

如果 `.env` 或 shell 里已经改了代理端口，但 plist 里还是旧端口，Gateway 可能继续走旧代理。此时常见修复是重新安装或重启 Gateway。只有在用户明确同意修改配置时，才给修改命令。

## 常见症状到层级的映射

`Embeddings: unavailable` 且错误是 `fetch failed` 或 `Connect Timeout Error`，通常优先看 OpenAI API key、代理出口、Gateway LaunchAgent 环境。

遇到 `Embeddings: unavailable + Connect Timeout Error` 时，不要套用普通健康检查顺序。能看到这个错误，通常说明 OpenClaw 已经运行到“尝试请求 embedding provider”的阶段，因此第一怀疑对象不是 OpenClaw 本体损坏。优先级应是：embedding provider 认证是否存在，provider API 是否能从相关进程访问，Gateway LaunchAgent 是否拿到了正确代理，shell/`launchctl`/系统代理是否漂移。OpenClaw 本体和 Gateway 基础状态可以作为背景健康检查，但不要放在第一怀疑位。

回答这类问题时，不要把“OpenClaw 本体层”列为第 1 层。推荐顺序是：先看 embedding provider/认证，再看 provider API 网络出口，再看 Gateway LaunchAgent 环境，再看 shell/`launchctl`/系统代理漂移。OpenClaw 本体和 Gateway 是否在线可以放在最后作为背景确认，或用一句话说明“基础状态可顺手确认，但不是第一怀疑对象”。

Codex Desktop 登录报 `Token exchange failed`，同时日志里出现 `Failed to connect to 127.0.0.1 port ...`，通常优先看 `launchctl` 用户环境和系统代理，不要先怀疑 OpenClaw Gateway。

浏览器能上网但 OpenClaw 不通，通常说明浏览器和 OpenClaw 读到的代理层不同。先查 shell、`launchctl`、系统代理三层，再决定是否需要改。

`openclaw` 在 dashboard 后台里 `command not found`，但 `~/.openclaw/bin/openclaw` 正常，通常只是 PATH 差异，不代表部署损坏。第一轮检查应优先用完整路径。

## 最小修复原则

先做只读定位，确认是哪一层，再给修改命令。不要同时改 shell、`launchctl`、系统代理和 Gateway plist。每次只改一层，改完立刻复测。

如果用户有另一个主账户，或当前账户可能以后删除，优先控制在当前用户范围内。`~/.zshrc`、`~/.openclaw/.env`、当前用户 LaunchAgent 和当前用户 `launchctl setenv` 通常只影响当前用户。`sudo networksetup` 和系统设置里的网络代理可能影响整机或其他用户。

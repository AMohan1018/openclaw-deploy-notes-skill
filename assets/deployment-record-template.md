# OpenClaw 部署记录

这份记录用于以后复盘、迁移到新机器，或交给另一个 agent 接手。填写时只记录事实和结论，不粘贴 API key、gateway token、OAuth token、完整配置文件或完整 plist。不能确认的内容写“未确认”，不要猜。

## 1. 记录元信息

| 项目 | 内容 |
| --- | --- |
| 记录日期与时区 |  |
| 记录人 / agent |  |
| 机器名 |  |
| macOS 用户 |  |
| 这是不是临时学习账户 |  |
| 本次目标 | 安装 / 修复 / 升级 / 迁移 / 健康检查 / 其他： |
| 本次是否允许修改配置 | 只读 / 允许当前用户范围修改 / 允许系统级修改 |

## 2. 影响范围

| 范围 | 当前结论 | 证据 |
| --- | --- | --- |
| 当前 macOS 用户 |  |  |
| 其他 macOS 用户 |  |  |
| 整机系统设置 |  |  |
| 外部账号或云端资源 |  |  |

说明：优先把 OpenClaw 配置限制在当前用户。若涉及系统代理、`sudo networksetup`、`/Applications` 应用升级、共享端口或主用户环境，必须单独标注。

## 3. 安装与版本

| 项目 | 内容 |
| --- | --- |
| OpenClaw 版本 |  |
| 安装方式 | install script / npm / pnpm / git checkout / 未确认 |
| CLI 路径 |  |
| CLI wrapper 是否指向当前版本 | 是 / 否 / 未确认 |
| 实际 package root |  |
| Node 路径 |  |
| 配置文件路径 |  |
| 工作区路径 |  |
| Gateway LaunchAgent 路径 |  |

最小验证命令：

```bash
~/.openclaw/bin/openclaw --version
~/.openclaw/bin/openclaw update --status
~/.openclaw/bin/openclaw gateway status
```

## 4. 核心健康状态

| 能力 | 状态 | 证据 | 是否阻塞 |
| --- | --- | --- | --- |
| CLI 可执行 |  |  |  |
| Gateway 运行 |  |  |  |
| Dashboard 页面 |  |  |  |
| Gateway WebSocket/RPC |  |  |  |
| 默认模型 |  |  |  |
| 模型认证 |  |  |  |
| Web search |  |  |  |
| Memory embeddings |  |  |  |
| Memory vector/FTS |  |  |  |
| Skills 加载 |  |  |  |
| Security audit |  |  |  |

判断规则：`Dashboard HTTP 200` 只说明网页能打开；要确认能聊天和操作，还要看 `Connectivity probe: ok` 或 `Gateway ... reachable ... auth token`。

## 5. Gateway 与 Dashboard

| 项目 | 内容 |
| --- | --- |
| Gateway mode | local / remote / 未确认 |
| Bind 地址 |  |
| Port |  |
| WebSocket URL |  |
| Dashboard URL |  |
| Auth 模式 | token / insecure / 未确认 |
| Token 是否存在 | 是 / 否，不记录明文 |
| Heartbeat | enabled / disabled / 未确认 |
| Bonjour/mDNS | enabled / disabled / 未确认 |
| 最近一次 Gateway 验证 |  |

常见问题记录：

| 症状 | 可能层级 | 处理结论 |
| --- | --- | --- |
| Dashboard `disconnected (1006)` | WebSocket/RPC、token、Bonjour/mDNS、Gateway 卡死 |  |
| `Connectivity probe: failed` 或 timeout | Gateway 可监听但不响应，或插件/sidecar 卡住 |  |
| 页面能打开但不能连接 | HTTP 正常，WebSocket 不正常 |  |

## 6. 模型、认证与密钥

| 项目 | 内容 |
| --- | --- |
| 默认模型 |  |
| 可用模型列表结论 |  |
| Codex OAuth 状态 | 可用 / 不可用 / 未确认 |
| `OPENAI_API_KEY` 是否存在 | 是 / 否 / 未确认，不记录明文 |
| Embedding provider |  |
| 是否区分聊天模型与 embedding provider | 是 / 否 |
| 认证问题是否影响当前使用 |  |

说明：`openai-codex/*` 通常走 OAuth；memory embeddings 可能仍需要 API key。聊天能用，不等于 embeddings 一定能用。

## 7. Web Search

| 项目 | 内容 |
| --- | --- |
| 是否启用 web_search |  |
| Managed provider |  |
| Native Codex web search | enabled / disabled / 未确认 |
| Provider key 是否存在 | 是 / 否 / 不需要 / 未确认，不记录明文 |
| 验证方式 |  |
| 当前结论 |  |

## 8. Memory Search

| 项目 | 内容 |
| --- | --- |
| Provider |  |
| Model |  |
| Workspace |  |
| Store |  |
| Sources |  |
| Indexed |  |
| Dirty | yes / no / 未确认 |
| Embeddings | ready / unavailable / 未确认 |
| Vector | ready / unavailable / 未确认 |
| FTS | ready / unavailable / 未确认 |
| 主要 issue |  |

解读：`Indexed: 1/9 files` 这类数字不一定是部署故障。只要 `Embeddings: ready`、`Vector: ready`、`FTS: ready`、`Dirty: no`，通常说明核心链路可用；若用户关心检索完整性，再做文件级排查。

## 9. 网络与代理

| 层级 | 当前值或结论 | 是否会影响其他用户 |
| --- | --- | --- |
| shell `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` |  | 否，通常只影响当前 shell |
| `launchctl getenv` 用户环境 |  | 通常只影响当前登录用户 |
| Gateway LaunchAgent 环境 |  | 通常只影响当前 OpenClaw 服务 |
| macOS 系统代理 `scutil --proxy` |  | 可能影响整机或当前网络服务 |
| 稳定代理端口 |  |  |
| 代理端口是否漂移过 | 是 / 否 / 未确认 |  |

结论：如果 `memory embeddings` 或 OAuth 是 timeout，要优先比较 shell、launchctl、LaunchAgent 三层代理是否一致。不要把 OpenClaw Gateway 端口 `18789` 和本地代理端口混在一起。

## 10. Skills 状态

| 项目 | 内容 |
| --- | --- |
| 个人 skills 目录 |  |
| 本次使用的 skill |  |
| 本次新增或修改的 skill 文件 |  |
| `openclaw skills list` ready 数量 |  |
| Missing requirements 数量 |  |
| 当前是否需要补依赖 | 是 / 否 / 按需 |
| 需要优先掌握的 skill |  |

原则：不要一次性补齐所有可选 requirements。先按用户真正要用的 skill 补依赖，做完一个、验证一个、记录一个。

## 11. 发现的问题与处理记录

| 时间 | 问题 | 证据 | 判断层级 | 修改动作 | 影响范围 | 验证结果 | 回滚方式 |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |

填写要求：每一项修改都要有“为什么改”“改了哪里”“怎么证明修好了”“怎么退回”。如果只是 warning 且非阻塞，也要写清楚为什么暂不处理。

## 12. 非阻塞警告

| Warning | 为什么不是阻塞 | 何时需要处理 |
| --- | --- | --- |
|  |  |  |

常见非阻塞例子：未启用 WhatsApp/pairing 时 `~/.openclaw/credentials` 不存在；未使用某些可选 skills 时 requirements 缺失；memory 索引文件数不是全部但 embeddings/vector/FTS 都 ready。

## 13. 当前可用性结论

用 3 到 6 句话写明这台机器当前能做什么、不能做什么、还有哪些需要后续补齐。

当前结论：


## 14. 下一步待办

| 优先级 | 待办 | 为什么要做 | 完成标准 |
| --- | --- | --- | --- |
| 高 |  |  |  |
| 中 |  |  |  |
| 低 |  |  |  |

## 15. 跨机器复用清单

下次迁移或重装时，优先复用这些信息：

| 项目 | 记录 |
| --- | --- |
| 安装命令或安装方式 |  |
| 必须准备的账号 |  |
| 必须准备的 API key 类型 |  |
| 固定代理端口 |  |
| 必须恢复的配置文件 |  |
| 必须恢复的 personal skills |  |
| 不建议复制的内容 | API key、token、OAuth 缓存、机器相关 LaunchAgent plist |
| 重装后第一轮验证命令 | `~/.openclaw/bin/openclaw --version`、`gateway status`、`doctor`、`memory status --deep`、`config get tools.web.search.provider` |

## 16. 脱敏检查

交付或保存前确认：

- 没有 API key、gateway token、OAuth token、cookie、完整 auth profile。
- 没有把 tokenized dashboard URL 原样写入记录。
- 没有把完整 `openclaw.json`、完整 `.env`、完整 LaunchAgent plist 粘进记录。
- 若引用日志，只保留错误关键词、时间、文件路径和结论。
- 若涉及主账户或其他用户，只写影响范围，不写对方隐私信息。

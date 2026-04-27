# Memory Search 排查

这份参考只在用户询问 memory search、embedding、索引、长期记忆文件，或 `openclaw memory status --deep` 输出解读时读取。第一轮健康检查正常时，不需要主动展开。

## 先分清三段链路

Memory search 至少包含三段：embedding provider 是否可用，memory 文件是否存在并进入索引，检索命令是否能找到相关内容。不要把这三段混在一起判断。

`Embeddings: ready` 说明 embedding provider 这条链路健康。它不保证一定有 memory 文件，也不保证某个查询一定能搜到结果。

`Indexed: 0/0 files` 或 `no memory files found` 通常不是故障，只说明 memory 源里还没有可索引文件。

`Indexed: 1/4 files` 这类结果要结合 `Dirty` 和错误信息判断。`Dirty: no` 且 embeddings/vector/FTS ready 时，通常不是核心部署阻塞；如果用户关心为什么不是全部文件，再进入文件级排查。

## 状态字段解读

`Provider: openai` 或其他 provider 表示用户已经指定了 memory search provider。`requested: openai` 说明配置层请求使用该 provider。

`Model: text-embedding-3-small` 表示当前 embedding 模型。只要 embeddings ready，模型名本身通常不是问题。

`Embeddings: unavailable` 表示 provider 链路不可用。此时先看错误类型：如果是 `Connect Timeout Error` 或 `fetch failed`，优先转到 `references/proxy-and-ports.md`；如果是 auth、quota、billing、invalid key，再优先看 API key 和 provider 账号状态。

`Vector: ready` 表示向量扩展或向量库可用。`FTS: ready` 表示关键词检索可用。二者 ready 但 embeddings unavailable，通常说明本地存储能力没坏，问题在 provider 或网络出口。

`Dirty: yes` 表示索引可能需要更新。可以建议只读查看状态，或在用户同意时运行 `~/.openclaw/bin/openclaw memory index --force`。

`Dirty: no` 表示当前索引状态没有明显待处理更新。此时不要因为 `Indexed` 数字看起来不满就直接判断故障。

## 何时建议重新索引

只有在用户添加、修改、删除了 memory 文件，或者 `Dirty: yes`，或者 search 明显找不到刚写入的内容时，才建议重新索引：

```bash
~/.openclaw/bin/openclaw memory index --force
```

重新索引后，用一个具体查询验证，而不是只看状态：

```bash
~/.openclaw/bin/openclaw memory search "test query"
```

如果用户刚创建第一份 memory 文件，可以建议在 `~/.openclaw/workspace/memory/` 下放一个小的 Markdown 文件，再索引和搜索。

## 何时不要排 memory 文件

如果错误是 `Embeddings: unavailable + Connect Timeout Error`，不要先排 memory 文件、memory 目录、索引条数或向量库。这个错误更像 provider API 访问失败，先看 provider 认证、网络出口和 Gateway LaunchAgent 环境。

如果 `Embeddings: ready`、`Vector: ready`、`FTS: ready`，且 Gateway 正常，通常不要把 memory search 判成部署损坏。即使有少量非阻塞提示，也要把“核心链路健康”和“还有体验细节可优化”分开说。

## 输出方式

解读 memory status 时，优先按三类输出：provider 链路、索引/文件状态、检索能力。明确告诉用户哪些是核心阻塞，哪些只是内容或索引层面的后续优化。

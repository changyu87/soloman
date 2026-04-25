# Protocol: 上下文溢出

本文档定义了总控如何检测和处理接近上下文窗口限制的情况。

## 问题

总控（主会话）在每次以下操作时都会累积上下文：
- 用户消息
- 子代理调度 + 返回消息
- 文件读取
- 内部推理

最终上下文窗口会被填满，质量下降。范式必须优雅地处理这种情况。

## 检测

总控在 `state/current.md` 中跟踪两个指标：

| 指标 | 默认阈值 | 可配置位置 |
|---|---|---|
| 会话提示次数 | 15 | `config.yaml → settings.context_warn_prompts` |
| 子代理调度次数 | 10 | `config.yaml → settings.context_warn_agents` |

当**任一**阈值被超过时，进入优雅交接协议。

### 启发式原理

- 每次用户提示增加约 500-2000 token（用户消息 + 总控响应）
- 每次子代理调度增加约 500-1500 token（调度 + 返回消息）
- 在 15 次提示 + 10 次调度时，大约消耗 20-40K token
- Trae 会话通常支持 100-200K 上下文，但质量在达到硬限制之前就会下降
- 保守的阈值确保在质量下降之前进行交接

## 优雅交接协议

当阈值被超过时：

### 步骤 1：警告用户

```
Context is approaching capacity after {N} prompts and {M} subagent dispatches.
I'll prepare for a session handoff now.
```

### 步骤 2：调度档案员（如果最近未运行）

调度档案员执行以下操作：
- 更新 `knowledge/index.md`
- 将检查点写入 `state/checkpoints/`
- 捕获任何新的不变式或约定

如果档案员在过去 3 次交互内已运行，则跳过。

### 步骤 3：写入完整状态

用完整细节更新 `state/current.md`：
- 当前工作流及确切阶段
- 刚刚完成的内容
- 下一步应该做什么
- 任何待定决策或未解决的问题

确保 `state/session-log.md` 是最新的。

### 步骤 4：建议用户

```
State saved. Here's where we are:

- Workstream: ws-{NNN} — {description}
- Phase: {phase}
- Completed: {what's done}
- Next step: {what should happen when you resume}

To continue: start a new Trae session and type /soloman
The new session will automatically detect the saved state and offer to resume.
```

### 步骤 5：停止发起新工作

在交接建议之后，总控应：
- 仍然回答用户关于当前状态的问题
- **不**调度新的子代理
- **不**启动新的工作流
- 鼓励用户启动新会话

## 提前预警

在达到阈值的 80% 时（例如，阈值为 15 时达到 12 次提示）：

```
Note: We're at {N}/{threshold} prompts. Consider wrapping up the current task
before starting something new, or we'll need a session refresh soon.
```

这给用户一个机会干净地完成当前工作流。

## 调整阈值

用户可以在 `config.yaml` 中调整阈值：

```yaml
settings:
  context_warn_prompts: 15  # 对于简单对话可增大
  context_warn_agents: 10   # 如果子代理返回内容较小可增大
```

较低的阈值 = 更频繁的交接，但持续保持高质量。
较高的阈值 = 更少的交接，但存在质量下降的风险。

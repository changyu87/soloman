# 协议：状态管理

本文档定义了范式中会话和项目状态的管理方式。

## 双层状态模型

### 第一层：轻量状态（每次用户提示）

由总控直接写入。无需子代理。

**`state/current.md`** — 当前状态快照（约 20 行）：

```markdown
# Current State
Updated: {YYYY-MM-DDTHH:MM:SS}
Session prompts: {N} | Subagent dispatches: {N}
Active workstream: ws-{NNN} | Phase: {phase}
Last action: {description}
Next: {what should happen next}
审计器: {enabled/disabled}
Language: {detected language, e.g. "en", "zh-CN", "zh-CN primary, en mixed"}
```

**`state/session-log.md`** — 仅追加的会话事件日志：

```markdown
## [{HH:MM}] {Event Type}
{Brief description — 1-3 lines}
```

事件类型：`User Request`、`Enrichment Complete`、`Planner Dispatched`、`Planner Complete`、`User Approved`、`Builder Dispatched`、`Builder Complete`、`审计器 Complete`、`Workstream Complete`、`Context Warning`、`Session Handoff`。

**`state/resume.md`** — 预计算、有界大小的恢复摘要（≤20 行，≤1.2KB）。始终覆写——绝不追加。由总控在每个保存状态周期中、在追加 `session-log.md` 之后写入，以反映刚记录的一轮。总控在第 4 步（会话恢复）中读取此文件，而非无界的 `session-log.md`，从而保持启动令牌成本可控。

```markdown
# Session Resume
Updated: {YYYY-MM-DDTHH:MM:SS}
Language: {last-detected IETF tag, e.g. "zh-CN"}
Active workstream: ws-{NNN} | Phase: {phase | "none"}
Last action: {<=120 chars, one line}
Next: {<=120 chars, one line}
审计器: {enabled|disabled}

## Recent turns (last 5, newest first)
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}

## Open gates
- {e.g. "awaiting-approval: ws-007 plan" | "none"}
```

**更新规则**（第 6 步顺序）：(1) 更新 `current.md`；(2) 追加到 `session-log.md`；(3) 根据最新更新的 `current.md` + `session-log.md` 尾部（最近 5 条事件）+ 内存中待处理的关卡备注，完全重写 `resume.md`。由于 `resume.md` 每轮根据有界模板完全重写，只要遵循该模板，其增长在结构上不可能超出 ≤20 行 / ≤1.2KB 的预算。

**成本**：每次提示两次小文件写入（重写 current.md + 重写 resume.md）加一次追加（session-log.md）。仍然可以忽略不计。

### 第二层：重量状态（仅里程碑）

由档案员子代理写入。由总控派遣。

**何时派遣档案员进行状态更新**：
- 工作流完成
- 上下文溢出交接前
- 用户明确请求（"归档此内容"、"更新索引"）
- 新工作流启动（为规划器提供文件上下文）

**档案员写入的内容**：
- `knowledge/index.md` — 更新后的项目文件索引
- `knowledge/invariants.md` — 新发现的硬性规则
- `knowledge/conventions.md` — 新观察到的模式
- `state/checkpoints/{NNN}-{description}.md` — 全面快照

**检查点格式**：
```markdown
# Checkpoint: {description}
Date: {YYYY-MM-DD}
Trigger: {workstream-complete | context-overflow | user-request}

## Project State
- Active workstreams: [list]
- Completed workstreams: [list]
- Key files: [most important files and their current purpose]

## Recent Decisions
- [Decision]: [Rationale]

## Knowledge Updates
- New invariants: [list or "none"]
- New conventions: [list or "none"]
- Index changes: [summary]
```

**成本**：每个工作流约 3-5 次档案员调用。

---

## 恢复协议

当新会话启动并调用 `/soloman` 时，通过快速路径读取状态（有界令牌成本）；将无界的会话日志推迟到用户询问详情时：

1. **读取 `state/resume.md`** → 获取：语言、当前工作流、阶段、上一步操作、下一步操作、近期事件、待处理关卡。这是启动成本有界的入口点。
2. **用户确认恢复后**，读取 `state/current.md` 获取完整的轻量快照。
3. **仅当用户询问叙述性详情时**（"之前发生了什么？"、"显示历史记录"），读取 `state/session-log.md`。
4. **仅在需要时**，读取活跃工作流文件（简报、计划、状态、审计结果）。
5. **旧版回退**：若 `state/resume.md` 缺失或为空，但 `current.md` 有内容，则读取 `current.md` + `session-log.md` 的最后 30 行，构建等同于 `resume.md` 模式的摘要，并立即写入 `resume.md`，以便未来会话命中快速路径。
6. **向用户展示**："上一会话处于[阶段]。是否恢复？"

### 可能丢失的内容

主会话的内存推理细节——丰富过程中的推理、关于为何做出某些决策的微妙上下文（未写入文件的部分）。

### 缓解措施

- 会话日志捕获关键决策和事件
- 工作流文件捕获所有正式产物
- 检查点在里程碑处捕获全面快照
- 新会话可能重新读取某些文件，但这提供了新的视角

### 不会丢失的内容

- 所有文件产物（简报、计划、审计、构建状态）
- 所有知识库条目
- 所有检查点
- 会话日志

这些内容均在磁盘上，永久保留。

---

## 状态根目录

- **两种模式**：`$STATE_ROOT` = `$(pwd)/.paradigm`

`$STATE_ROOT` 下的目录结构在两种模式下完全相同。

**自模式补充说明**：当在范式自身的源代码仓库中运行时（通过当前工作目录中的 `PARADIGM.md` 检测），总控额外绑定 `$PARADIGM_REPO = $(pwd)`。仅铁匠使用此路径——用于将通用角色编辑写回源代码仓库（`$PARADIGM_REPO/roles/`）。所有其他状态（会话、工作流、检查点）仍位于 `$STATE_ROOT` 下，属于每个工作副本的本地状态，在源代码仓库中通过 gitignore 忽略。

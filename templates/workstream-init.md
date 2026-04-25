# 模板：工作流初始化

该模板定义了如何在已有项目中创建新的工作流。

## 何时创建工作流

以下情况需要创建新的工作流：
- 总控收到用户的新工作请求
- 信息充实阶段完成，请求已足够清晰以制定计划

## 步骤

### 1. 递增计数器

读取 `config.yaml → workstream_counter`，递增 1，写回。
使用新值作为 `{NNN}`（零填充至 3 位：001、002，依此类推）。

### 2. 创建工作流目录

```
workstreams/active/ws-{NNN}/
```

### 3. 编写 Brief

将充实后的需求写入 `ws-{NNN}/brief.md`：

```markdown
# Brief — ws-{NNN}
Date: {YYYY-MM-DD}
Requested by: User

## Goal
[What the user wants — clear, specific, 1-3 sentences]

## Constraints
- [Explicit constraints from user]
- [Inferred constraints from project context]

## Scope
- In scope: [what's included]
- Out of scope: [what's excluded]

## Success Criteria
- [How to know this is done]

## Context Files
- [File paths relevant to this workstream, gathered from 档案员 or 总控 knowledge]
```

### 4. 编写初始状态

写入 `ws-{NNN}/status.md`：

```markdown
# Workstream Status — ws-{NNN}
Updated: {timestamp}
Phase: planning
Created: {YYYY-MM-DD}

## Progress
- [x] Brief written
- [ ] Plan created
- [ ] Plan reviewed (审计器)
- [ ] User approved plan
- [ ] Build executed
- [ ] Build reviewed (审计器)
- [ ] Workstream complete
```

### 5. 更新会话状态

更新 `state/current.md` 以反映新的活跃工作流。
追加记录到 `state/session-log.md`。

## 工作流生命周期

```
Created → Planning → Plan Review → Approved → Building → Build Review → Complete
                  ↑                          ↑
                  └── User requests changes ─┘
```

完成后：将 `ws-{NNN}/` 从 `active/` 移动到 `completed/`。

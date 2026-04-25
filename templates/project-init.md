# 模板：项目初始化

该模板定义了在初始化新项目时创建的 `.paradigm/` 脚手架结构。

该脚手架在**两种模式**下运行——普通项目和自模式（范式源仓库）。在自模式下，生成的 `.paradigm/` 会被 gitignore 忽略，以便每个工作副本独立保存会话记录。

## 需要创建的目录结构

```
.paradigm/
├── config.yaml
├── state/
│   ├── current.md
│   ├── session-log.md
│   ├── resume.md
│   └── checkpoints/
├── workstreams/
│   ├── active/
│   └── completed/
├── roles/
└── knowledge/
    ├── index.md
    ├── invariants.md
    └── conventions.md
```

## 初始文件内容

### `config.yaml`

```yaml
project:
  name: "{directory name}"
  paradigm_version: "0.5.1"
  initialized: "{YYYY-MM-DD}"

settings:
  auditor: enabled
  context_warn_prompts: 15
  context_warn_agents: 10
  writing_plans_prompted: false

workstream_counter: 0
```

### `state/current.md`

```markdown
# Current State
Updated: {YYYY-MM-DDTHH:MM:SS}
Session prompts: 0 | Subagent dispatches: 0
Active workstream: none
Last action: Project initialized
Next: Awaiting user request
审计器: enabled
Language: en
```

### `state/session-log.md`

```markdown
# Session Log

## [{time}] Project Initialized
The Paradigm initialized for this project.
```

### `state/resume.md`

```markdown
# Session Resume
Updated: {YYYY-MM-DDTHH:MM:SS}
Language: en
Active workstream: none
Last action: Project initialized
Next: Awaiting user request
审计器: enabled

## Recent turns (last 5, newest first)
- [{time}] Project Initialized: scaffold created

## Open gates
- none
```

### `knowledge/index.md`

```markdown
# Project File Index

> Maintained by the 档案员. Last updated: {date}

## Structure
[To be populated by 档案员 on first scan]
```

### `knowledge/invariants.md`

```markdown
# Project Invariants

> Hard rules that must never be violated. Updated by 档案员 at milestones.

[No invariants established yet. These will be discovered during project work.]
```

### `knowledge/conventions.md`

```markdown
# Project Conventions

> Coding style, naming patterns, and other conventions. Updated by 档案员 at milestones.

[No conventions established yet. These will be discovered during project work.]
```

## 初始化后操作

创建脚手架后：
1. 可选：派遣档案员扫描项目并填充 `knowledge/index.md`
2. 可选：派遣军需官盘点可用资源
3. 向用户展示欢迎信息

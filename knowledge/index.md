# 项目文件索引 — Paradigm

> 由档案员维护。最后更新：2026-04-18

## 核心
- `SOLOMAN.md` — 人类文档、快速入门指南、自模式标记
- `changelog.md` — 版本历史和演进日志
- `install.sh` / `uninstall.sh` — 构建和移除已安装的技能包

## 技能
- `skill/SKILL.md` — Claude Code 技能定义 + 总控行为规范

## 角色（7 个内置 + 模板）
- `roles/_template.md` — 创建新角色的蓝图（由 铁匠 使用）
- `roles/interfacer.md` — 总控的参考文档（非子代理提示词）
- `roles/planner.md` — 子代理：生成执行计划
- `roles/builder.md` — 子代理：执行计划，编写代码/内容
- `roles/auditor.md` — 子代理：独立审查（可选）
- `roles/archivist.md` — 子代理：项目知识管理员
- `roles/forge.md` — 子代理：创建/编辑/删除角色（核心，不可删除）
- `roles/quartermaster.md` — 子代理：AI/硬件资源管理

## 协议
- `protocols/workflow.md` — 标准流程：丰富 → 规划 → 审计 → 构建 → 审计 → 完成。§5 是计划审批门禁的规范定义（"展示"和"批准"的含义；AskUserQuestion 选择永远不是批准）。
- `protocols/state-management.md` — 轻量级（每次提示词）+ 重量级（里程碑）状态
- `protocols/context-overflow.md` — 检测启发式和优雅交接协议
- `protocols/forge-protocol.md` — 角色创建、编辑、删除的规则
- `protocols/language.md` — 多语言交互/中文工件策略

## 模板
- `templates/project-init.md` — 新项目的 `.paradigm/` 脚手架
- `templates/workstream-init.md` — 工作流创建流程

## 知识（随附的参考资料）
- `knowledge/index.md` — 本文件
- `knowledge/invariants.md` — 硬性规则（条目 1–13；条目 12 = Route 前缀，条目 13 = 明确批准门禁）
- `knowledge/conventions.md` — 风格和命名约定

## 关键交叉引用
- 计划审批门禁：`protocols/workflow.md` §5（规范）↔ `skill/SKILL.md` 核心循环 §5 第 4 项 + 不变规则 13 ↔ `knowledge/invariants.md` 第 13 项
- Route 前缀：`skill/SKILL.md` 不变规则 12 ↔ `knowledge/invariants.md` 第 12 项
- 已安装包布局：`install.sh` 复制 `skill/SKILL.md` → `$SKILL_DIR/SKILL.md`（包根目录，不在 `skill/` 下）

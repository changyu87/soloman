# Protocol: 清除操作

破坏性、三层级的操作，用于重置范式状态。不进行任何备份。
根据不变式 14，需要用户明确的自由文本确认。

本协议是 `workflow.md` §5 的破坏性操作对应版本：两者都需要用户提供明确的自由文本令牌，且两者都明确禁止使用 AskUserQuestion（AUQ）作为门禁。AUQ 仅允许用于阶段 1 的层级选择（属于设计选择，而非审批）。

## 分类

`类别=元命令`，`关卡=直接`。与 `distill` 对应的破坏性操作。不变式 14 适用于阶段 2（参见下文§不变式）。

## 层级

| 层级 | 触发方式 | 删除内容 | 保留内容 |
|---|---|---|---|
| default | `/soloman clear`，自然语言短语如"clear soloman state"/"清空状态" | `$STATE_ROOT/state/*`（current.md, session-log.md, resume.md, checkpoints/） | config.yaml, workstreams/, knowledge/, roles/ |
| --active | `/soloman clear --active`；自然语言触发通过阶段 1 选择 | 上述内容 + `$STATE_ROOT/workstreams/active/*` | config.yaml, workstreams/completed/, knowledge/, roles/ |
| --all | `/soloman clear --all`；自然语言触发通过阶段 1 选择 | 整个 `$STATE_ROOT`（即 `.soloman/` 目录） | 无——项目下次会话需要重新初始化 |

注意：自然语言触发从不携带层级；它们总是通过阶段 1 的层级选择。只有带有显式 `--active`/`--all` 的斜杠式调用才能跳过阶段 1。

## 触发短语库（英文 + 中文）

每个自然语言触发**必须**包含一个锚定词（`paradigm`、`状态` 或 `session`）。通用短语如 `重新开始`、`从头开始`、`clean slate` 和单独的 `clear the X` 被明确排除，以避免在普通对话中误触发。

- **英文**："clear paradigm state", "clear the paradigm state", "wipe paradigm state", "wipe the paradigm state", "reset paradigm state", "reset the paradigm", "clear session state", "wipe session state", "end the paradigm session", "nuke paradigm", "remove paradigm state", "clean up paradigm state".
- **中文**："清空状态", "清理状态", "重置状态", "清空 paradigm", "paradigm 状态全清", "彻底清空 paradigm", "清理 paradigm", "重置 paradigm", "清空 session 状态", "清理当前 session", "结束 paradigm 工作流".

斜杠式也符合条件：首条消息是 `/soloman clear`（无参数）或一条 ≤3 个 token 的 `clear` 消息，可选后跟 `--active` / `--all` / `state` / `paradigm`。

## 流程（两阶段）

### 阶段 0 — 意图检测

在技能调用后的第一条用户消息时执行，也由会话中间轮次的常规 `类别=元命令` 分类器执行。仅检测清除范式状态的**意图**——不检测层级。斜杠式调用可能携带显式层级（`--active` / `--all`），此时跳过阶段 1。

### 阶段 1 — 层级选择

如果阶段 0 已携带显式层级则跳过。否则，总控通过 AskUserQuestion（如果 AUQ 不可用则使用编号列表）展示所有三个层级（default / --active / --all），每个层级附带一行"将删除 / 将保留"的摘要说明，使用用户检测到的语言。用户选择。**这是设计选择，不是破坏性操作审批。**

### 阶段 2 — 破坏性操作确认

1. 总控通过 Bash 工具运行 `scripts/clear.sh <tier>`（试运行）；捕获标准输出（清单）。
2. 总控以检测到的语言展示清单 + 确认提示。说明文字被翻译（警告行、"将被删除"/"不会被触及"标签、"请回复确切的短语"指示）。路径和字面令牌 `YES, CLEAR <tier>` 保持原样（ASCII，不翻译），以便审计器能够以语言无关的方式搜索日志。
3. 总控等待用户明确的自由文本回复，该回复必须与字面令牌 `YES, CLEAR <tier>` 匹配（对令牌字符串进行不区分大小写的精确匹配）。沉默、AskUserQuestion 回答或任何其他文本都将取消操作。
4. 匹配时：总控通过 Bash 工具运行 `scripts/clear.sh <tier> --confirmed`。
5. 总控报告已删除的内容。对于 `default` 和 `--active`，确认项目仍然已初始化。对于 `--all`，指示用户下次会话重新调用 `/soloman` 以进行重新初始化。

## 不变式

- 确认令牌是字面 ASCII：`YES, CLEAR default|active|all`。
- 不进行任何备份；确认门禁是唯一的保护措施。
- 同一脚本路径（`$SKILL_DIR/scripts/clear.sh`）同时服务于斜杠式和自然语言触发。
- `STATE_ROOT` 护栏：如果 `$STATE_ROOT` 不以 `.paradigm` 结尾，`--all` 分支拒绝继续执行。
- AskUserQuestion 可在阶段 1 中用于层级选择。AUQ **绝不**能作为阶段 2 的破坏性操作审批。参见不变式 14。

## 交叉引用

- `protocols/workflow.md` §5 — 此处镜像的审批门禁模式。
- `protocols/state-management.md` §恢复 — 与 resume.md 的交互。
- `knowledge/invariants.md` §14 — 规定了破坏性操作门禁。

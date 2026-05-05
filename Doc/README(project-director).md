# project-director 导航页

这套示例面向“从需求到交付”的完整项目流程编排，核心特点是由总控 Agent 串起需求、架构、开发、测试、终审、文档审计、主干集成，以及按需执行的远端 release 发布。

## 1. 入口

### 推荐总入口

- [agents/project-director.md](../agents/project-director.md)

适用场景：

- 用户只有原始需求，希望从需求分析一路推进到最终交付
- 需要统一维护阶段状态、进度日志、文档归档、`Pending_User_Actions` 和 GitLab 分支策略
- 需要一个总控角色在默认模式下尽量不打扰用户，自主推进到 `main` 合入；只有在用户明确授权时才处理 `release`

### 专项入口

| 入口 Agent | 适用场景 | 主要输出 |
|------------|----------|----------|
| [agents/pd-requirement-analyst.md](../agents/pd-requirement-analyst.md) | 只有原始需求，需要先整理成 PRD | `Agent_doc/PRD.md` |
| [agents/pd-architect-task-planner.md](../agents/pd-architect-task-planner.md) | 已有 PRD，需要产出架构和任务拆解 | `Agent_doc/System_Architecture_and_Task_Breakdown.md` |
| [agents/pd-developer.md](../agents/pd-developer.md) | 已有任务和架构，需要进入编码实现 | 代码、测试、`Agent_doc/pd-developer-doc/README_<模块名>.md` |
| [agents/pd-qa-tester.md](../agents/pd-qa-tester.md) | 需要设计测试用例、执行黑盒验证或补测 | `Agent_doc/pd-qa-tester-doc/Test_Cases_<任务标识>.md`、`Agent_doc/pd-qa-tester-doc/Test_Report_<任务标识>.md` |
| [agents/pd-qa-gatekeeper.md](../agents/pd-qa-gatekeeper.md) | 所有交付物基本齐备，需要做终审裁决或审计 release 合规性 | `Agent_doc/Quality_Check_Report.md` |

### 共享规则入口

- [agents/pd-references/AGENTS.md](../agents/pd-references/AGENTS.md)

这里定义了共享目录、进度日志、GitLab 流程、交付物路径和跨角色通用约束。仓库中的这份文件用于阅读和版本管理；运行时所有 Agent / 模板的交叉引用都必须指向 `{{AAS_HOME}}/agents/pd-references/`。如果该目录缺失，Agent 应立即报错停止，而不是在项目目录或 `Agent_doc/` 下再生成一套 framework 文件。

## 2. 顺序

推荐按以下顺序使用：

1. `project-director` 初始化项目、确认 `Agent_doc` 目录、恢复断点、校验 Git / GitLab 可用性。
2. `pd-requirement-analyst` 将原始需求整理成 `Agent_doc/PRD.md`。
3. `pd-architect-task-planner` 基于 PRD 产出架构设计和任务拆解文档。
4. `pd-developer` 按任务实现代码、单元测试和模块说明文档。
5. `pd-qa-tester` 预先设计测试用例，并在代码就绪后执行黑盒验证和代码审查。
6. `pd-qa-gatekeeper` 统一审查需求、架构、代码、测试和 Git 流程，给出准出或打回结论。
7. `project-director` 创建或刷新 `Agent_doc` 文档审阅分支，先把本轮文档归档结果独立出来。
8. `project-director` 执行阶段 6.5 的文档审计：归档历史版本、修复链接、生成 `Agent_doc/INDEX.md`，并确认 `Agent_doc/Pending_User_Actions.md` 存在。
9. `project-director` 执行 `main` 主干集成并做最终汇报；只有当用户明确要求时，才继续执行远端 `release` 的 squash-and-push，且结束后本地仍需切回 `main` 并保持 clean。

如果不是全流程使用，可以从任一专项入口开始，但前置产物必须满足对应 Agent 的输入要求。

## 3. 分工

| 角色 | 主要职责 | 不负责什么 | 典型输出 |
|------|----------|------------|----------|
| `project-director` | 统筹全流程、默认自主推进、维护 `Agent_doc` 归档 / 索引 / `Pending_User_Actions`、主干集成与按需 release 发布 | 不直接写 PRD、架构、业务代码或测试报告 | 进度推进、阶段决策、`Agent_doc/INDEX.md`、归档与合入说明 |
| `pd-requirement-analyst` | 解析原始需求、补齐隐性需求、生成 PRD | 不做技术设计和编码 | `Agent_doc/PRD.md` |
| `pd-architect-task-planner` | 设计系统架构、模块边界、任务拆解和依赖关系 | 不写业务代码、不执行测试 | `Agent_doc/System_Architecture_and_Task_Breakdown.md` |
| `pd-developer` | 实现代码、补齐单元测试、编写模块说明 | 不修改 PRD 或架构文档，不直接写 `main` / `release` | 代码、测试、`Agent_doc/pd-developer-doc/README_<模块名>.md` |
| `pd-qa-tester` | 设计测试用例、执行黑盒验证、做代码审查视角的检查 | 不直接改产品代码，不直接写 `main` / `release` | `Agent_doc/pd-qa-tester-doc/Test_Cases_<任务标识>.md`、`Agent_doc/pd-qa-tester-doc/Test_Report_<任务标识>.md` |
| `pd-qa-gatekeeper` | 终审所有交付物、检查一致性、审计 release 流程是否合规 | 不负责开发、合并或提交任何分支 | `Agent_doc/Quality_Check_Report.md` |

## 4. 当前修订后的关键约束

- 共享 framework 文件和模板在运行时只能从 `{{AAS_HOME}}/agents/pd-references/` 读取，不能再依赖仓库内的相对路径。
- 默认运行模式要求 `project-director` 从阶段 0 连续推进到阶段 7；中间可决策项由总控自行决定并写入 `Agent_doc/Agent_Progress_Log.md`。
- `project-director` 每次委派任何 `pd-*` Agent 或复用 Skill 时，都必须在子调用中显式带入三组共享硬约束：大文件分块处理、`model: "claude-opus-4.7"` 以及 `claude-opus-4.6` → `gpt-5.5` → `gpt-5.4` 的回退顺序，还有固定收尾追问“还有没有补充要做的事情？请一次性列出，我将继续在本轮内处理。”。
- 阶段性用户沟通采用“汇报并继续，除非用户显式修正”的节奏，而不是默认停下来等待确认；唯一需要用户显式授权的额外动作仍然是 `release` 分支的 squash-and-push。
- 多轮项目文档必须遵循 canonical / archive 分层：顶层保留最新文件，历史版本归档到 `Agent_doc/PRD/`、`Architecture/`、`QualityCheck/`、`pd-developer-doc/<module>/`、`pd-qa-tester-doc/TestCases/`、`pd-qa-tester-doc/TestReport/` 等目录。
- 阶段 6.5 结束时，`Agent_doc/INDEX.md` 和 `Agent_doc/Pending_User_Actions.md` 都应存在；即便本轮无待办，也要显式写出“本轮无待用户处理事项”。
- `release` 分支只允许 `project-director` 在用户明确授权时以 squash-and-push 方式操作；`pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` 不得越权写入。

## 5. 交接

| 上游角色 | 交接产物 | 下游角色 | 说明 |
|----------|----------|----------|------|
| `project-director` | 项目根目录、`Agent_doc` 路径、进度日志路径、Git 校验结果 | 全体角色 | 统一上下文由总控分发 |
| `pd-requirement-analyst` | `Agent_doc/PRD.md` | `pd-architect-task-planner`、`pd-qa-gatekeeper` | PRD 是后续所有设计与审查的起点 |
| `pd-architect-task-planner` | `Agent_doc/System_Architecture_and_Task_Breakdown.md` | `pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` | 为开发和测试提供模块边界与任务清单 |
| `pd-developer` | 代码、测试、`Agent_doc/pd-developer-doc/README_<模块名>.md` | `pd-qa-tester`、`pd-qa-gatekeeper` | 测试与终审都要消费开发产物 |
| `pd-qa-tester` | `Agent_doc/pd-qa-tester-doc/Test_Cases_<任务标识>.md`、`Agent_doc/pd-qa-tester-doc/Test_Report_<任务标识>.md` | `pd-qa-gatekeeper` | 终审依据之一 |
| `pd-qa-gatekeeper` | `Agent_doc/Quality_Check_Report.md` | `project-director` | 总控据此决定打回或进入归档与合入 |
| `project-director` | `Agent_doc/INDEX.md`、`Agent_doc/Pending_User_Actions.md`、文档审阅分支信息 | 用户 / 下一轮迭代 | 作为本轮归档索引、遗留事项清单和后续恢复入口 |
| 全体角色 | `Agent_doc/Agent_Progress_Log.md` | 全体角色 | 用于断点恢复、阶段移交和流程留痕 |

## 6. 示例

### 示例 A：从原始需求启动整套流程

建议入口：`project-director`

示例提问：

> 请作为项目总监，基于我下面的需求启动完整流程：先整理 PRD，再做架构与任务拆解，再安排开发、测试和终审。项目根目录是 `<path>`，需要兼容 GitLab 分支流程，并在准出后完成 `Agent_doc` 审计与主干集成；如果我明确要求，再处理 release。

### 示例 B：已经有 PRD，只做架构与任务拆解

建议入口：`pd-architect-task-planner`

示例提问：

> 这里是现有的 `Agent_doc/PRD.md`，请基于它生成系统架构设计和任务拆解文档，输出到 `Agent_doc/System_Architecture_and_Task_Breakdown.md`。

### 示例 C：已有任务文档，直接进入开发

建议入口：`pd-developer`

示例提问：

> 请根据 `Agent_doc/System_Architecture_and_Task_Breakdown.md` 中的 `TASK-003` 完成代码实现、单元测试和模块说明文档，验收标准必须全部覆盖。

### 示例 D：对现有交付物做终审

建议入口：`pd-qa-gatekeeper`

示例提问：

> 请审查 `Agent_doc` 下现有的 PRD、架构文档、测试报告、进度日志和分支记录，给出明确的准出或打回结论；如果用户要求发布，请额外审计 release 流程是否满足只新增一个 squash 提交且不改写 `main` / `origin/main` 历史。
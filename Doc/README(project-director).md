# project-director 导航页

这套示例面向“从需求到交付”的完整项目流程编排，核心特点是由总控 Agent 串起需求、架构、开发、测试、终审和最终归档。

## 1. 入口

### 推荐总入口

- [agents/project-director.agent.md](../agents/project-director.agent.md)

适用场景：

- 用户只有原始需求，希望从需求分析一路推进到最终交付
- 需要统一维护阶段状态、进度日志、文档归档和 GitLab 分支策略
- 需要一个总控角色协调其他 Agent，并控制是否进入下一阶段

### 专项入口

| 入口 Agent | 适用场景 | 主要输出 |
|------------|----------|----------|
| [agents/pd-requirement-analyst.agent.md](../agents/pd-requirement-analyst.agent.md) | 只有原始需求，需要先整理成 PRD | `Agent_doc/PRD.md` |
| [agents/pd-architect-task-planner.agent.md](../agents/pd-architect-task-planner.agent.md) | 已有 PRD，需要产出架构和任务拆解 | `Agent_doc/System_Architecture_and_Task_Breakdown.md` |
| [agents/pd-developer.agent.md](../agents/pd-developer.agent.md) | 已有任务和架构，需要进入编码实现 | 代码、测试、模块说明 |
| [agents/pd-qa-tester.agent.md](../agents/pd-qa-tester.agent.md) | 需要设计测试用例、执行黑盒验证或补测 | 测试用例、测试报告 |
| [agents/pd-qa-gatekeeper.agent.md](../agents/pd-qa-gatekeeper.agent.md) | 所有交付物基本齐备，需要做终审裁决 | `Agent_doc/Quality_Check_Report.md` |

### 共享规则入口

- [pd-references/AGENTS.md](../agents/pd-references/AGENTS.md)

这里定义了共享目录、进度日志、GitLab 流程、交付物路径和跨角色通用约束。阅读任何单个 Agent 前，最好先看这份共享说明。

## 2. 顺序

推荐按以下顺序使用：

1. `project-director` 初始化项目、确认 `Agent_doc` 目录、恢复断点、确认 GitLab 可用性。
2. `pd-requirement-analyst` 将原始需求整理成 `Agent_doc/PRD.md`。
3. `pd-architect-task-planner` 基于 PRD 产出架构设计和任务拆解文档。
4. `pd-developer` 按任务实现代码、单元测试和模块说明文档。
5. `pd-qa-tester` 一边预先设计测试用例，一边在代码就绪后执行黑盒验证并出报告。
6. `pd-qa-gatekeeper` 统一审查需求、架构、代码、测试和 Git 流程，给出准出或打回结论。
7. `project-director` 根据终审结论执行归档、文档分支准备和最终主干集成。

如果不是全流程使用，可以从任一专项入口开始，但前置产物必须满足对应 Agent 的输入要求。

## 3. 分工

| 角色 | 主要职责 | 不负责什么 | 典型输出 |
|------|----------|------------|----------|
| `project-director` | 统筹全流程、阶段编排、状态管理、最终归档与主干集成 | 不直接写 PRD、架构、业务代码或测试报告 | 进度推进、阶段决策、归档和合入说明 |
| `pd-requirement-analyst` | 解析原始需求、补齐隐性需求、生成 PRD | 不做技术设计和编码 | `Agent_doc/PRD.md` |
| `pd-architect-task-planner` | 设计系统架构、模块边界、任务拆解和依赖关系 | 不写业务代码、不执行测试 | `Agent_doc/System_Architecture_and_Task_Breakdown.md` |
| `pd-developer` | 实现代码、补齐单元测试、编写模块说明 | 不修改 PRD 或架构文档 | 代码、测试、`README_<模块名>.md` |
| `pd-qa-tester` | 设计测试用例、执行黑盒验证、做代码审查视角的检查 | 不直接改产品代码 | `Test_Cases_*.md`、`Test_Report_*.md` |
| `pd-qa-gatekeeper` | 终审所有交付物、检查一致性、给出准出/打回结论 | 不负责开发、合并或提交分支 | `Agent_doc/Quality_Check_Report.md` |

## 4. 交接

| 上游角色 | 交接产物 | 下游角色 | 说明 |
|----------|----------|----------|------|
| `project-director` | 项目根目录、`Agent_doc` 路径、进度日志路径、GitLab 校验结果 | 全体角色 | 统一上下文由总控分发 |
| `pd-requirement-analyst` | `Agent_doc/PRD.md` | `pd-architect-task-planner`、`pd-qa-gatekeeper` | PRD 是后续所有设计与审查的起点 |
| `pd-architect-task-planner` | `Agent_doc/System_Architecture_and_Task_Breakdown.md` | `pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` | 为开发和测试提供模块边界与任务清单 |
| `pd-developer` | 代码、测试、`Agent_doc/pd-developer-doc/README_*.md` | `pd-qa-tester`、`pd-qa-gatekeeper` | 测试与终审都要消费开发产物 |
| `pd-qa-tester` | `Agent_doc/pd-qa-tester-doc/Test_Cases_*.md`、`Test_Report_*.md` | `pd-qa-gatekeeper` | 终审依据之一 |
| `pd-qa-gatekeeper` | `Agent_doc/Quality_Check_Report.md` | `project-director` | 总控据此决定打回或进入归档与合入 |
| 全体角色 | `Agent_doc/Agent_Progress_Log.md` | 全体角色 | 用于断点恢复、阶段移交和流程留痕 |

## 5. 示例

### 示例 A：从原始需求启动整套流程

建议入口：`project-director`

示例提问：

> 请作为项目总监，基于我下面的需求启动完整流程：先整理 PRD，再做架构与任务拆解，再安排开发、测试和终审。项目根目录是 `<path>`，需要兼容 GitLab 分支流程。

### 示例 B：已经有 PRD，只做架构与任务拆解

建议入口：`pd-architect-task-planner`

示例提问：

> 这里是现有的 `PRD.md`，请基于它生成系统架构设计和任务拆解文档，输出到 `Agent_doc/System_Architecture_and_Task_Breakdown.md`。

### 示例 C：已有任务文档，直接进入开发

建议入口：`pd-developer`

示例提问：

> 请根据 `System_Architecture_and_Task_Breakdown.md` 中的 `TASK-003` 完成代码实现、单元测试和模块说明文档，验收标准必须全部覆盖。

### 示例 D：对现有交付物做终审

建议入口：`pd-qa-gatekeeper`

示例提问：

> 请审查 `Agent_doc` 下现有的 PRD、架构文档、测试报告和进度日志，给出明确的准出或打回结论，并说明依据。
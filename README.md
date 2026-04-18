# AgentAndSkill

这是一个围绕 Agent / Skill 协作方式整理出来的实践型工程。它的目标不是单纯堆提示词，而是把两类高频工作流拆成可复用、可导航、可扩展的角色体系与模板体系：一条面向“从需求到交付”的项目流程，一条面向“项目学习与知识沉淀”的学习流程。

整体组织更接近一套可持续维护的 `.copilot` 风格目录预演：`agents/` 放角色定义，`skills/` 放能力模块，`Doc/` 放导航说明与入口文档。

## 这份工程里有什么

| 模块 | 定位 | 组成 | 当前状态 |
|------|------|------|----------|
| `project-director` | 从原始需求一路推进到架构、开发、测试、终审和归档 | `pd-requirement-analyst`、`pd-architect-task-planner`、`pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` | 我已经在实际场景中用过 |
| `pl-coordinator` | 围绕一个现有项目做学习规划、项目扫描、深挖、知识库沉淀与复盘 | `pl-resource-collector`、`pl-explorer`、`pl-support-engineer`、`pl-deep-diver`、`pl-tutor`、`pl-analyst`，以及若干辅助 Skill | 目前还没有正式使用 |

## 适合什么场景

- 如果你想把一个需求从模糊描述推进到可交付结果，重点看 `project-director` 这条线。
- 如果你想系统化地学习一个项目、沉淀阅读路径和知识库，重点看 `pl-coordinator` 这条线。
- 如果你只需要局部能力，也可以单独复用 `skills/` 下的扫描、依赖分析、链路追踪、测试草案和知识库汇总能力。

## 补充说明

- [project-director 导航页](./Doc/README%28project-director%29.md)
- [pl-coordinator 导航页](./Doc/README%28pl-coordinator%29.md)

## 我的使用情况

- `project-director` 是这份工程里我已经实际应用过的一套流程，它更偏向真实项目交付时的阶段编排和留痕管理。
- `pl-coordinator` 是我为“项目学习与知识沉淀”整理出来的另一套流程，目前还处在设计完成、等待实战验证的阶段。

## 致谢

感谢“恩师”：

- GitHub Copilot
- GPT-5.4
- Claude Opus 4.6
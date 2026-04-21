# AgentAndSkill

这是一个围绕 Agent / Skill 协作方式整理出来的实践型工程。它的目标不是单纯堆提示词，而是把两类高频工作流拆成可复用、可导航、可扩展、可治理的角色体系与模板体系：一条面向“从需求到交付”的项目流程，一条面向“项目学习与知识沉淀”的学习流程。

当前版本相比早期整理稿，已经不只是角色说明合集，而是补齐了更明确的执行约束：统一的 Superpowers 技能接入规则、分角色的强制调用场景、主干与 release 分支的职责边界，以及面向真实协作场景的验证与留痕要求。

整体组织更接近一套可持续维护的 `.copilot` 风格目录预演：`agents/` 放角色定义，`skills/` 放能力模块，`Doc/` 放导航说明与入口文档。

## 这份工程里有什么

| 模块 | 定位 | 组成 | 当前状态 |
|------|------|------|----------|
| `project-director` | 从原始需求一路推进到架构、开发、测试、终审、归档，并按需负责远端 release 发布 | `pd-requirement-analyst`、`pd-architect-task-planner`、`pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` | 已实际使用；本轮补强了 release 工作流、分支权限边界和 Superpowers 强约束 |
| `pl-coordinator` | 围绕一个现有项目做学习规划、项目扫描、深挖、知识库沉淀与复盘 | `pl-resource-collector`、`pl-explorer`、`pl-support-engineer`、`pl-deep-diver`、`pl-tutor`、`pl-analyst`，以及若干辅助 Skill | 设计已成型；本轮补齐了整套学习流程的 Superpowers 对齐规则与验证要求 |

## 本轮修订重点

### 1. 两条流程都接入了统一的 Superpowers 约束

- `agents/pd-references/AGENTS.md` 和 `agents/pl-references/AGENTS.md` 现在都定义了共享的 Superpowers Skill Integration 规则。
- 约束从“可以使用技能”升级成“在特定场景必须显式调用技能”，例如方案澄清、写计划、并行分派、调试、测试驱动、收尾验证、代码评审等。
- 调用方式也被统一下来：通过 `superpowers:<skill-name>` 命名空间显式调用，而不是把技能当作仓库内文件路径引用。

### 2. 项目交付流程正式增加了 release 发布治理

- `project-director` 现在不仅负责主干集成，还在用户明确要求时独占执行远端 `release` 分支发布。
- 发布方式被固定为 squash-and-push 工作流：在临时分支上汇总 `main` 的目标提交，推送到远端 `release`，且不得改写本地 `main` 或远端 `origin/main` 历史。
- `pd-references/AGENTS.md` 增加了完整的前置校验、执行步骤、后置不变量和失败中止规则，确保 release 发布是可审计、可回溯的。

### 3. 多个 Agent 的职责边界变得更明确

- `pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` 都新增了对 `main` / `release` 的禁止操作说明，避免角色越权。
- `pd-qa-gatekeeper` 的终审范围也扩展到 release 流程合规性审计：如果用户授权发布，需要检查 release 是否只新增一个压缩提交，以及 `main` / `origin/main` 历史是否保持不变。
- `pd-requirement-analyst`、`pd-architect-task-planner` 以及整条 `pl-*` 学习链路，都补充了在各自阶段必须执行的验证或协作技能，减少“文档写了但执行不一致”的问题。

### 4. 学习向 Skills 也同步纳入了同一套规则

- `skills/pl-analyze-deps`、`pl-build-kb`、`pl-gen-tests`、`pl-scan-project`、`pl-trace-flow` 现在都补充了与 Superpowers 的联动说明。
- 这意味着不只是 Agent 层面，连扫描、依赖分析、测试草案、知识库汇总这类技能模块也开始强调并行拆分、故障调试和完成前验证。

## 适合什么场景

- 如果你想把一个需求从模糊描述推进到可交付结果，重点看 `project-director` 这条线。
- 如果你想系统化地学习一个项目、沉淀阅读路径和知识库，重点看 `pl-coordinator` 这条线。
- 如果你只需要局部能力，也可以单独复用 `skills/` 下的扫描、依赖分析、链路追踪、测试草案和知识库汇总能力。

## 当前版本的运行特征

- 这是一个偏“制度化协作”的 Agent / Skill 工程，不再只是静态模板集合。
- 角色描述里除了输入、输出和中间产物，还强调谁能改哪个分支、什么场景必须先验证、何时必须显式调用外部技能。
- 如果你打算把这套内容迁移到自己的 Copilot CLI 工作流，建议同时准备好 Superpowers 插件环境；当前文档已经默认把它视为协作约束的一部分。

## 补充说明

- [project-director 导航页](./Doc/README%28project-director%29.md)
- [pl-coordinator 导航页](./Doc/README%28pl-coordinator%29.md)

## 我的使用情况

- `project-director` 是这份工程里我已经实际应用过的一套流程，它更偏向真实项目交付时的阶段编排、分支治理和留痕管理。
- `pl-coordinator` 是我为“项目学习与知识沉淀”整理出来的另一套流程，目前还处在设计完成、等待更多实战验证的阶段，但流程约束和技能联动已经补齐。

## 致谢

感谢恩师：

- GitHub Copilot
- GPT-5.4
- Claude Opus 4.6
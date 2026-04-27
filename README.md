# AgentAndSkill

这是一个围绕 Agent / Skill 协作方式整理出来的实践型工程。它的目标不是单纯堆提示词，而是把两类高频工作流拆成可复用、可导航、可扩展、可治理的角色体系与模板体系：一条面向“从需求到交付”的项目流程，一条面向“项目学习与知识沉淀”的学习流程。

当前版本相比早期整理稿，已经从“角色说明合集”推进到“可执行的协作框架”。除了统一的 Superpowers 技能接入规则和分角色强制调用场景，这一轮还把共享框架文件的位置、文档版本归档方式、默认自主推进策略、待用户处理事项记录和收尾审计流程都写成了硬约束。

整体组织仍然是 `.copilot` 风格目录预演：`agents/` 放角色定义，`skills/` 放能力模块，`Doc/` 放导航说明与入口文档。需要注意的是，仓库中的 `agents/pd-references/` 和 `agents/pl-references/` 继续作为版本化内容存在，但 Agent / Skill 在运行时的交叉引用已经统一切换到 `~/.copilot/agents/pd-references/` 与 `~/.copilot/agents/pl-references/`。

## 这份工程里有什么

| 模块 | 定位 | 组成 | 当前状态 |
|------|------|------|----------|
| `project-director` | 从原始需求一路推进到架构、开发、测试、终审、文档审计、主干集成，并按需负责远端 release 发布 | `pd-requirement-analyst`、`pd-architect-task-planner`、`pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` | 已实际使用；本轮补强了运行时 framework 路径、默认自主推进、`Agent_doc` 归档审计、`Pending_User_Actions` 和 release 工作流 |
| `pl-coordinator` | 围绕一个现有项目做学习规划、项目扫描、深挖、知识库沉淀、复盘和文档审计 | `pl-resource-collector`、`pl-explorer`、`pl-support-engineer`、`pl-deep-diver`、`pl-tutor`、`pl-analyst`，以及若干辅助 Skill | 设计已成型；本轮补齐了运行时 framework 路径、学习文档归档、默认自主推进、`Pending_User_Actions` 和最终索引输出 |

## 本轮修订重点

### 1. 共享框架文件位置被收敛成硬规则

- `pd-*` Agent 及其模板现在统一引用 `~/.copilot/agents/pd-references/`。
- `pl-*` Agent / Skill 及其模板现在统一引用 `~/.copilot/agents/pl-references/`。
- 如果运行时无法读取这些目录，Agent 必须停止并报错，而不是在用户项目里偷偷再生成一份 `AGENTS.md` 或模板文件。
- 这让仓库内的 `*-references/` 更像“受版本控制的源内容与说明入口”，而不是执行时依赖的相对路径。

### 2. PD / PL 两条线都新增了多轮文档归档治理

- `agents/pd-references/AGENTS.md` 新增 `Document Versioning And Archival (multi-round projects)`，明确 `Agent_doc` 下最新文档保留 canonical 文件名，历史版本必须迁移到 `PRD/`、`Architecture/`、`QualityCheck/` 等子目录。
- `agents/pl-references/AGENTS.md` 新增 `Document Versioning And Archival (multi-round learning)`，要求 `LEARNINGS` 下历史版本按 `PLAN/`、`MAP/`、`PATH/`、`REPORTS/HISTORY/` 等目录归档。
- 两条线都要求“移动 + 改名归档”，禁止直接删除历史版本，并且必须把归档动作追加到共享进度日志。

### 3. `project-director` 从“总控调度”升级为“默认自主闭环”

- 默认模式下，`project-director` 会从阶段 0 一直推进到阶段 7，除非用户显式取消这种自动推进方式。
- 任何因权限、环境或外部依赖无法完成的事项，都要沉淀到 `Agent_doc/Pending_User_Actions.md`，即便“本轮无待办”也必须显式生成该文件。
- 新增阶段 6.5：`Agent_doc` 文档审计与版本整理。该阶段要求盘点版本化文档、修复相对链接、生成 `Agent_doc/INDEX.md`，并补做归档提交。
- 完成主干集成后，本地必须切回 `main` 且 `git status` clean，才能对外宣布项目完成。
- 远端 `release` 分支仍然只允许由 `project-director` 在用户明确要求时执行 squash-and-push。

### 4. `pl-coordinator` 也新增了默认自主推进与学习文档审计

- 默认模式下，`pl-coordinator` 会从阶段 0 一直推进到阶段 6，中间的角色调度和范围取舍自行决策，并写入 `LEARNINGS/LEARNING_PROGRESS.md`。
- 若有不能由 Agent 自行完成的事项，必须写入 `LEARNINGS/Pending_User_Actions.md`；无待办也必须保留“本轮无待用户处理事项”的明确记录。
- 新增阶段 5.5：学习文档审计与版本整理。该阶段会归档多轮学习文档、修复引用、生成 `LEARNINGS/INDEX.md`，并在最终总结里显式报出索引和待办文件路径。
- 如果学习流程涉及 Git 推送，其收尾约束与 `project-director` 对齐：最终本地切回 `main` 并保持 clean。

### 5. 显式技能调用和角色边界继续收紧

- 两套共享 `AGENTS.md` 继续要求在对应场景显式调用 `superpowers:<skill-name>`，不允许只在文档里提到技能名。
- `pd-developer`、`pd-qa-tester` 不得直接写 `main` 或 `release`；`pd-qa-gatekeeper` 可以审计 release 合规性，但仍不执行 push / merge。
- `skills/pl-analyze-deps`、`pl-build-kb`、`pl-gen-tests`、`pl-scan-project`、`pl-trace-flow` 也同步改为引用 `~/.copilot/agents/pl-references/`，并继续保留并行拆分、调试、测试驱动和完成前验证的强约束。

## 适合什么场景

- 如果你想把一个需求从模糊描述推进到可交付结果，重点看 `project-director` 这条线。
- 如果你想系统化地学习一个项目、沉淀阅读路径和知识库，重点看 `pl-coordinator` 这条线。
- 如果你只需要局部能力，也可以单独复用 `skills/` 下的扫描、依赖分析、链路追踪、测试草案和知识库汇总能力。

## 当前版本的运行特征

- 这是一个偏“制度化协作”的 Agent / Skill 工程，不再只是静态模板集合。
- 运行时共享 framework 文件与模板被外置到 `~/.copilot/agents/...`，仓库内容更偏向版本管理、审阅和演化基线。
- 两条总控流程都把“默认自主推进 + 归档审计 + `Pending_User_Actions` + 索引输出”作为标准收尾动作。
- 如果你打算把这套内容迁移到自己的 Copilot CLI 工作流，除了准备好 Superpowers 插件环境，还要同步准备 `~/.copilot/agents/pd-references/` 和 `~/.copilot/agents/pl-references/` 这两套共享 framework 文件。

## 快速同步到 `~/.copilot`

为了便于把当前仓库中的 `agents/` 和 `skills/` 增量同步到用户目录，根目录新增了 `sync_to_copilot.sh`。

这个脚本的行为约束如下：

- 以脚本所在仓库根目录作为唯一 source of truth，不依赖运行时当前工作目录。
- 默认对比并同步到 `~/.copilot/agents` 和 `~/.copilot/skills`。
- 如果发现差异，则以当前仓库内容为准执行增量覆盖；仅做新增 / 覆盖，不删除目标目录下额外存在的文件。
- 默认直接应用；如果只想先查看差异，可以先执行 dry-run。
- 如需调试或同步到其他位置，可以通过环境变量 `COPILOT_HOME` 覆盖默认目标目录。

示例：

```bash
./sync_to_copilot.sh --dry-run
./sync_to_copilot.sh
COPILOT_HOME=/tmp/copilot-sandbox ./sync_to_copilot.sh --dry-run
```

如果你后续继续修改了当前仓库中的 Agent / Skill 定义，建议在提交前先跑一次 `./sync_to_copilot.sh --dry-run`，确认会写入哪些内容。

## 补充说明

- [project-director 导航页](./Doc/README%28project-director%29.md)
- [pl-coordinator 导航页](./Doc/README%28pl-coordinator%29.md)
- [变更记录](./CHANGELOG.md)

## 我的使用情况

- `project-director` 是这份工程里我已经实际应用过的一套流程，它更偏向真实项目交付时的阶段编排、分支治理、文档归档和留痕管理。
- `pl-coordinator` 是我为“项目学习与知识沉淀”整理出来的另一套流程，目前还处在设计完成、等待更多实战验证的阶段，但流程约束、文档审计和技能联动已经补齐。

## 致谢

感谢恩师：

- GitHub Copilot
- GPT-5.4
- Claude Opus 4.6
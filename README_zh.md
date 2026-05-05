# AgentAndSkill

[English](./README.md) | **中文**

这是一个围绕 Agent / Skill 协作方式整理出来的实践型工程。它的目标不是单纯堆提示词，而是把两类高频工作流拆成可复用、可导航、可扩展、可治理的角色体系与模板体系：一条面向"从需求到交付"的项目流程，一条面向"项目学习与知识沉淀"的学习流程。

当前版本已经从"角色说明合集"推进到"可执行的协作框架"。除了统一的 Superpowers 技能接入规则和分角色强制调用场景，还把共享框架文件的位置、文档版本归档方式、默认自主推进策略、待用户处理事项记录和收尾审计流程都写成了硬约束。

仓库根目录提供一份 [AGENTS.md](./AGENTS.md) 作为"维护这套 Agent / Skill 工程本身"的总入口说明。它负责约束治理分层、变更同步面和反绕过审计要求，但不会替代 `agents/pd-references/AGENTS.md` 与 `agents/pl-references/AGENTS.md` 在实际运行时的共享规则职责。

整体组织仍然是 `.copilot` 风格目录预演：`agents/` 放角色定义，`skills/` 放能力模块，`Doc/` 放导航说明与入口文档。仓库中的 `agents/pd-references/` 和 `agents/pl-references/` 作为版本化内容存在，Agent / Skill 在运行时的交叉引用已经统一切换到 `{{AAS_HOME}}/agents/pd-references/` 与 `{{AAS_HOME}}/agents/pl-references/`（部署时由 `sync.sh` 自动替换为实际平台路径）。

仓库中的 Agent 源文件命名已经统一收敛为 `*.md`；如果要兼容 Copilot 侧偏好的 `*.agent.md` 命名，可以在部署时通过 `sync.sh --agent-suffix agent.md` 自动转换。

## 这份工程里有什么

| 模块 | 定位 | 组成 | 当前状态 |
|------|------|------|----------|
| `project-director` | 从原始需求一路推进到架构、开发、测试、终审、文档审计、主干集成，并按需负责远端 release 发布 | `pd-requirement-analyst`、`pd-architect-task-planner`、`pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper`，以及 `pd-check-repo-readiness`、`pd-audit-agent-doc` | 已实际使用 |
| `pl-coordinator` | 围绕一个现有项目做学习规划、项目扫描、深挖、知识库沉淀、复盘和文档审计 | `pl-resource-collector`、`pl-explorer`、`pl-support-engineer`、`pl-deep-diver`、`pl-tutor`、`pl-analyst`，以及若干辅助 Skill | 设计已成型，待更多实战验证 |

## 支持的平台

| 平台 | 默认目标路径 | 环境变量覆盖 | 部署命令 |
|------|-------------|-------------|----------|
| GitHub Copilot CLI | `~/.copilot/` | `COPILOT_HOME` | `./sync.sh --target copilot` |
| Claude Code | `~/.claude/aas-marketplace/plugins/agent-and-skill/` | `AAS_HOME` | `./sync.sh --target claude-code` |
| OpenCode | `~/.opencode/` | `OPENCODE_HOME` | `./sync.sh --target opencode` |

## 最新修订重点

### 1. 统一多平台同步入口
- `sync.sh` 已替代 `sync_to_copilot.sh`，统一支持 Copilot CLI、Claude Code 和 OpenCode。
- 部署前可通过 `--validate` 或 `--validate-only` 先执行仓库一致性校验。
- 同步前会检查 Superpowers 是否存在，并给出各平台对应的安装提示。

### 2. 运行时路径与文件命名归一化
- 所有运行时跨文件引用统一改为平台无关的 `{{AAS_HOME}}` 占位符。
- `sync.sh` 在部署时把 `{{AAS_HOME}}` 替换成目标平台的真实路径。
- 仓库内 Agent 源文件由 `*.agent.md` 统一为 `*.md`；部署到 Copilot 时可通过 `--agent-suffix agent.md` 兼容旧命名。

### 3. 治理与可发现性增强
- 根级 [AGENTS.md](./AGENTS.md) 成为仓库治理入口。
- [registry/agent_skill_registry.json](./registry/agent_skill_registry.json) 提供机器可读清单。
- [Doc/Agent_Skill_Index.md](./Doc/Agent_Skill_Index.md) 提供跨 PD / PL / Skill 的人工可读总索引。
- [tools/validate_copilot_assets.py](./tools/validate_copilot_assets.py) 负责校验共享 AGENTS 继承、链接、关键文件和模板一致性。

### 4. 共享规则与技能面扩展
- PD 侧新增 `pd-check-repo-readiness` 和 `pd-audit-agent-doc` 两个可复用 Skills。
- PD / PL 两套共享 AGENTS 都新增了大文件分块处理、子代理显式模型选择、强制收尾追问和运行时反绕过审计规则。
- 仓库同时补齐了 repo readiness 与 archive audit 模板，支撑这些流程落地。

## 快速部署

根目录的 `sync.sh` 脚本用于把当前仓库中的 `agents/` 和 `skills/` 增量同步到目标平台目录。

### 前置条件

本工程依赖 [Superpowers](https://github.com/obra/superpowers) 插件。`sync.sh` 部署前会自动检查是否已安装，未安装时提示安装命令（可通过 `--skip-check` 跳过）。

**Copilot CLI 安装 Superpowers：**
```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

**Claude Code 安装 Superpowers：**
```bash
# 在 Claude Code 会话内执行
/plugin install superpowers@claude-plugins-official
```

**OpenCode 安装 Superpowers：**
```bash
git clone https://github.com/obra/superpowers ~/.opencode/plugins/superpowers
```

### 部署示例

```bash
# 部署到 Copilot（预览 + 执行）
./sync.sh --target copilot --dry-run
./sync.sh --target copilot

# 部署到 Claude Code（预览 + 执行）
./sync.sh --target claude-code --dry-run
./sync.sh --target claude-code

# 部署到 OpenCode（预览 + 执行）
./sync.sh --target opencode --dry-run
./sync.sh --target opencode

# 部署前校验仓库一致性
./sync.sh --target copilot --validate --dry-run

# 仅校验，不部署
./sync.sh --target copilot --validate-only

# 部署时输出 Copilot 风格的 .agent.md 文件名
./sync.sh --target copilot --agent-suffix agent.md --dry-run

# 使用自定义目标路径
COPILOT_HOME=/tmp/copilot-sandbox ./sync.sh --target copilot --dry-run

# 跳过 superpowers 检查
./sync.sh --target copilot --skip-check
```

### 脚本行为

- 以脚本所在仓库根目录作为唯一 source of truth。
- 通过 `--target` 参数选择部署目标：`copilot`、`claude-code` 或 `opencode`。
- 仅做新增 / 覆盖，不删除目标目录下额外存在的文件。
- 源文件中所有跨文件路径引用使用平台无关的 `{{AAS_HOME}}` 占位符；`sync.sh` 部署时自动替换为目标平台的实际路径。
- 仓库中的 Agent 源文件统一以 `*.md` 存放；如果是 Copilot 目标，可通过 `--agent-suffix agent.md` 输出 `*.agent.md`。
- 部署到 Claude Code 时，自动创建插件清单并同步到插件缓存目录。
- 根目录 `AGENTS.md` 不在同步范围内——它是仓库维护治理入口，不是运行时同步产物。

## 核心特性

### 1. 共享框架文件位置收敛为硬规则
- `pd-*` Agent 统一引用 `{{AAS_HOME}}/agents/pd-references/`。
- `pl-*` Agent / Skill 统一引用 `{{AAS_HOME}}/agents/pl-references/`。

### 2. 多轮文档归档治理
- PD 线：`Agent_doc` 下 canonical 文件 + 按类型子目录归档历史版本。
- PL 线：`LEARNINGS` 下 canonical 文件 + 按类型子目录归档历史版本。

### 3. 默认自主闭环
- `project-director` 默认从阶段 0 推进到阶段 7，含阶段 6.5 文档审计。
- `pl-coordinator` 默认从阶段 0 推进到阶段 6，含阶段 5.5 学习文档审计。
- 所有因权限/环境无法完成的事项，统一写入 `Pending_User_Actions.md`。

### 4. 通用执行细则
- 大文件分块读写、子代理显式模型选择、强制收尾追问。
- 运行时反绕过审计：父 Agent 委派子代理时必须显式带入关键规则。

### 5. 仓库治理与校验
- 根级 `AGENTS.md` 负责治理分层与变更准入。
- `registry/agent_skill_registry.json` 提供机器可读清单。
- `Doc/Agent_Skill_Index.md` 提供人工可读的总览入口。
- `tools/validate_copilot_assets.py` 检查引用、链接、声明一致性。
- PD 侧新增 `pd-check-repo-readiness` 和 `pd-audit-agent-doc` 两个辅助 Skills。

## 补充说明

- [仓库治理入口](./AGENTS.md)
- [project-director 导航页](./Doc/README%28project-director%29.md)
- [pl-coordinator 导航页](./Doc/README%28pl-coordinator%29.md)
- [Agent / Skill 总索引](./Doc/Agent_Skill_Index.md)
- [变更记录](./CHANGELOG.md)

## 我的使用情况

- `project-director` 是这份工程里我已经实际应用过的一套流程，它更偏向真实项目交付时的阶段编排、分支治理、文档归档和留痕管理。
- `pl-coordinator` 是我为"项目学习与知识沉淀"整理出来的另一套流程，目前还处在设计完成、等待更多实战验证的阶段，但流程约束、文档审计和技能联动已经补齐。

## 致谢

感谢恩师：

- GitHub Copilot
- GPT-5.4
- Claude Opus 4.6

# Agent / Skill 总索引

本文件提供一份面向维护者和使用者的统一入口，用来解决“角色很多，但缺少横向对比视图”的问题。

机器可读清单见 [registry/agent_skill_registry.json](../registry/agent_skill_registry.json)。

## 1. 如何使用这份索引

1. 如果你想跑完整交付流程，从 PD 总控入口开始。
2. 如果你想跑完整学习流程，从 PL 总控入口开始。
3. 如果你只需要局部能力，优先看对应专项 Agent；若任务更窄，再看 Skill。
4. 如果你要维护这套仓库本身，先看根级 [AGENTS.md](../AGENTS.md)，再跑 [tools/validate_copilot_assets.py](../tools/validate_copilot_assets.py)。

## 2. 共享规则入口

| 体系 | 共享规则 | 作用 |
|------|----------|------|
| PD | [agents/pd-references/AGENTS.md](../agents/pd-references/AGENTS.md) | 定义 `Agent_doc`、GitLab 流程、主干 / release 约束、文档归档和反绕过审计 |
| PL | [agents/pl-references/AGENTS.md](../agents/pl-references/AGENTS.md) | 定义 `LEARNINGS`、学习产物布局、Agent / Skill 协作、文档归档和反绕过审计 |

## 3. PD 总览

### 3.1 Agent

| 名称 | 类型 | 适用场景 | 主要输出 | 主要下游 |
|------|------|----------|----------|----------|
| `project-director` | 总控 | 从需求到交付的完整编排 | `Agent_doc/Agent_Progress_Log.md`、`Agent_doc/INDEX.md`、`Agent_doc/Pending_User_Actions.md` | 全体 PD Agent |
| `pd-requirement-analyst` | 专项 | 原始需求转 PRD | `Agent_doc/PRD.md` | `pd-architect-task-planner`、`pd-qa-gatekeeper` |
| `pd-architect-task-planner` | 专项 | PRD 转架构与任务拆解 | `Agent_doc/System_Architecture_and_Task_Breakdown.md` | `pd-developer`、`pd-qa-tester`、`pd-qa-gatekeeper` |
| `pd-developer` | 专项 | 编码实现与模块说明 | 代码、测试、`Agent_doc/pd-developer-doc/README_<模块名>.md` | `pd-qa-tester`、`pd-qa-gatekeeper` |
| `pd-qa-tester` | 专项 | 测试用例设计与黑盒验证 | `Test_Cases_*.md`、`Test_Report_*.md` | `pd-qa-gatekeeper` |
| `pd-qa-gatekeeper` | 专项 | 终审与准出裁决 | `Agent_doc/Quality_Check_Report.md` | `project-director` |

### 3.2 Skill

| 名称 | 适用场景 | 主要输出 | 典型协作方 |
|------|----------|----------|------------|
| `pd-check-repo-readiness` | 阶段 0 的 Git / GitLab / `Agent_doc` 预检 | `Agent_doc/Other/Repo_Readiness_Check.md` + 进度日志记录 | `project-director`、`pd-qa-gatekeeper` |
| `pd-audit-agent-doc` | 阶段 6.5 的 `Agent_doc` 版本整理、索引生成与待办校验 | `Agent_doc/INDEX.md`、`Agent_doc/Pending_User_Actions.md` + 进度日志记录 | `project-director`、`pd-qa-gatekeeper` |

## 4. PL 总览

### 4.1 Agent

| 名称 | 类型 | 适用场景 | 主要输出 | 主要下游 |
|------|------|----------|----------|----------|
| `pl-coordinator` | 总控 | 围绕现有项目组织完整学习流程 | `LEARNINGS/LEARNING_PLAN.md`、`LEARNINGS/INDEX.md`、`LEARNINGS/Pending_User_Actions.md` | 全体 PL Agent / Skill |
| `pl-resource-collector` | 专项 | 建资源库 | `LEARNINGS/RESOURCES/RESOURCE_LIBRARY.md` | `pl-explorer`、`pl-tutor`、`pl-analyst` |
| `pl-explorer` | 专项 | 建立项目全景认知 | `LEARNINGS/PROJECT_MAP.md`、可选 `LEARNINGS/DEPENDENCY_MAP.md` | `pl-deep-diver`、`pl-tutor`、`pl-analyst` |
| `pl-support-engineer` | 专项 | 排查环境与工具阻塞 | `LEARNINGS/SUPPORT/SUPPORT_LOG.md` | `pl-coordinator`、`pl-deep-diver`、`pl-tutor` |
| `pl-deep-diver` | 专项 | 深挖模块或链路 | `LEARNINGS/DEEP_DIVE/*`、`LEARNINGS/FLOWS/*`、可选测试分析 | `pl-tutor`、`pl-analyst` |
| `pl-tutor` | 专项 | 组织学习路径与知识库 | `LEARNINGS/LEARNING_PATH.md`、`LEARNINGS/KNOWLEDGE_BASE/INDEX.md` | `pl-analyst`、`pl-coordinator` |
| `pl-analyst` | 专项 | 学习复盘与评估 | `LEARNINGS/REPORTS/LEARNING_REPORT.md` | `pl-coordinator`、`pl-tutor` |

### 4.2 Skill

| 名称 | 适用场景 | 主要输出 | 典型协作方 |
|------|----------|----------|------------|
| `pl-scan-project` | 项目扫描 | `LEARNINGS/PROJECT_MAP.md` | `pl-explorer` |
| `pl-analyze-deps` | 依赖分析 | `LEARNINGS/DEPENDENCY_MAP.md` | `pl-explorer`、`pl-tutor` |
| `pl-trace-flow` | 调用链 / 信号链追踪 | `LEARNINGS/FLOWS/<topic>.md` | `pl-deep-diver` |
| `pl-gen-tests` | 通过测试逆向理解代码 | `LEARNINGS/TESTS/test_<module>.*`、`TEST_ANALYSIS_<module>.md` | `pl-deep-diver` |
| `pl-build-kb` | 汇总知识库 | `LEARNINGS/KNOWLEDGE_BASE/INDEX.md` | `pl-tutor` |

## 5. 维护者入口

### 5.1 机器校验

- 直接校验：`python3 tools/validate_copilot_assets.py`
- 同步前校验：`bash ./sync.sh --target copilot --validate --dry-run`

### 5.2 归档与审计模板

| 场景 | 模板 |
|------|------|
| PD 仓库 / GitLab 预检 | [agents/pd-references/repo_readiness_template.md](../agents/pd-references/repo_readiness_template.md) |
| PD 文档归档审计 | [agents/pd-references/archive_audit_checklist_template.md](../agents/pd-references/archive_audit_checklist_template.md) |
| PL 文档归档审计 | [agents/pl-references/archive_audit_checklist_template.md](../agents/pl-references/archive_audit_checklist_template.md) |

## 6. 现状说明

这份索引的目标不是替代角色文件，而是补齐一份“横向对比图”。真正的运行时规则仍以共享 AGENTS 为准；真正的完整职责仍以各自的 `.md` / `SKILL.md` 为准。
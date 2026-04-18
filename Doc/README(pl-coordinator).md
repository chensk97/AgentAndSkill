# pl-coordinator 导航页

这套示例面向“项目学习与知识沉淀”的端到端流程。当前目录应视为未来 `.copilot/` 根目录的预演版本：`agents/` 与 `skills/` 同级，`agents/pl-references/` 负责共享规则和模板，`skills/` 下各技能保持目录化结构。

## 1. 入口

### 推荐总入口

- [agents/pl-coordinator.agent.md](../agents/pl-coordinator.agent.md)

适用场景：

- 想从零开始组织一轮完整的项目学习流程
- 需要统一制定学习计划、分配角色、跟踪进度、处理阻塞和做最终复盘
- 不确定应该先看资源、先扫项目，还是直接深挖模块，需要总控角色帮你排顺序

### 专项入口

| 入口 Agent | 适用场景 | 主要输出 |
|------------|----------|----------|
| [agents/pl-resource-collector.agent.md](../agents/pl-resource-collector.agent.md) | 先整理参考资料、工具、论文、数据集和示例项目 | `LEARNINGS/RESOURCES/RESOURCE_LIBRARY.md` |
| [agents/pl-explorer.agent.md](../agents/pl-explorer.agent.md) | 先快速建立项目全景认知 | `LEARNINGS/PROJECT_MAP.md` |
| [agents/pl-support-engineer.agent.md](../agents/pl-support-engineer.agent.md) | 学习过程中遇到环境、依赖、工具或性能问题 | `LEARNINGS/SUPPORT/SUPPORT_LOG.md` |
| [agents/pl-deep-diver.agent.md](../agents/pl-deep-diver.agent.md) | 需要专项分析某个模块、接口、函数或 HDL 逻辑块 | `LEARNINGS/DEEP_DIVE/*`、`LEARNINGS/FLOWS/*` |
| [agents/pl-tutor.agent.md](../agents/pl-tutor.agent.md) | 已经有若干学习文档，需要组织学习路径与知识库 | `LEARNINGS/LEARNING_PATH.md`、`LEARNINGS/KNOWLEDGE_BASE/INDEX.md` |
| [agents/pl-analyst.agent.md](../agents/pl-analyst.agent.md) | 需要评估学习效果、总结方法并生成复盘报告 | `LEARNINGS/REPORTS/LEARNING_REPORT.md` |

### 技能入口

| 技能 | 更适合谁触发 | 主要作用 |
|------|--------------|----------|
| [skills/pl-scan-project/SKILL.md](../skills/pl-scan-project/SKILL.md) | `pl-explorer` 或针对项目扫描的直接请求 | 生成项目地图 |
| [skills/pl-analyze-deps/SKILL.md](../skills/pl-analyze-deps/SKILL.md) | `pl-explorer` 或依赖专题分析请求 | 生成依赖分析 |
| [skills/pl-trace-flow/SKILL.md](../skills/pl-trace-flow/SKILL.md) | `pl-deep-diver` 或链路分析请求 | 生成调用链 / 信号链分析 |
| [skills/pl-gen-tests/SKILL.md](../skills/pl-gen-tests/SKILL.md) | `pl-deep-diver` 或测试式学习请求 | 生成测试草案与测试分析 |
| [skills/pl-build-kb/SKILL.md](../skills/pl-build-kb/SKILL.md) | `pl-tutor` 或知识库汇总请求 | 汇总知识库索引 |

说明：技能通常更适合作为辅助工作流，由 Agent 在合适阶段触发，或者由用户通过明确任务描述去促发，而不是当作整套流程的总入口。

## 2. 顺序

推荐顺序如下：

1. `pl-coordinator` 初始化上下文、确认学习目标、建立 `LEARNINGS` 目录和总计划。
2. 如需要外部资料、教程、工具说明或数据集，先由 `pl-resource-collector` 建立资源库。
3. `pl-explorer` 先完成全景扫描；若依赖复杂，可联动 `pl-scan-project` 与 `pl-analyze-deps`。
4. 若在扫描或分析中遇到环境、依赖、脚本或工具问题，由 `pl-support-engineer` 兜底处理。
5. `pl-deep-diver` 对关键模块做深挖；必要时联动 `pl-trace-flow` 与 `pl-gen-tests`。
6. `pl-tutor` 在已有地图、深挖结果和资源库基础上组织学习路径，并汇总知识库；必要时联动 `pl-build-kb`。
7. `pl-analyst` 对本轮学习过程、产物和效果做复盘分析。
8. `pl-coordinator` 根据分析结果闭环，决定是否进入下一轮学习计划。

如果只是想解决某个局部问题，可以从专项入口直接进入，不必走完整顺序。

## 3. 分工

### Agent 分工

| 角色 | 主要职责 | 不负责什么 | 典型输出 |
|------|----------|------------|----------|
| `pl-coordinator` | 制定学习计划、协调阶段推进、分发上下文、跟踪阻塞、组织闭环 | 不替代其他角色做具体扫描、深挖或复盘 | `LEARNING_PLAN.md`、进度推进与阶段决策 |
| `pl-resource-collector` | 搜集、筛选、分类和维护学习资源 | 不做项目源码分析本身 | `RESOURCE_LIBRARY.md` |
| `pl-explorer` | 扫描项目结构、技术栈、入口和核心模块 | 不做模块级深入解读 | `PROJECT_MAP.md` |
| `pl-support-engineer` | 处理环境、依赖、脚本、工具和平台问题 | 不直接代替其他角色完成学习分析 | `SUPPORT_LOG.md` |
| `pl-deep-diver` | 对指定模块、接口或链路做深度分析 | 不做全仓库概览 | `DEEP_DIVE/*`、`FLOWS/*` |
| `pl-tutor` | 基于既有文档编排学习顺序、生成知识库入口 | 不凭空生成未分析的内容 | `LEARNING_PATH.md`、`KNOWLEDGE_BASE/INDEX.md` |
| `pl-analyst` | 评估学习效果、总结成功模式、提出改进建议 | 不负责一线探索或技术排障 | `REPORTS/LEARNING_REPORT.md` |

### Skill 分工

| 技能 | 典型触发阶段 | 作用 |
|------|--------------|------|
| `pl-scan-project` | 项目扫描阶段 | 结构化生成项目地图 |
| `pl-analyze-deps` | 全景扫描补充阶段 | 解析依赖来源、用途和风险 |
| `pl-trace-flow` | 深挖阶段 | 追踪调用链、数据流或信号流 |
| `pl-gen-tests` | 深挖补充阶段 | 把模块理解转成测试切入点 |
| `pl-build-kb` | 知识沉淀阶段 | 汇总已有文档为知识库索引 |

## 4. 交接

| 上游角色/技能 | 交接产物 | 下游角色/技能 | 说明 |
|----------------|----------|----------------|------|
| `pl-coordinator` | 学习目标、计划、`LEARNING_PROGRESS.md`、阶段上下文 | 全体 Agent / Skill | 所有后续角色共用的调度基线 |
| `pl-resource-collector` | `LEARNINGS/RESOURCES/RESOURCE_LIBRARY.md` | `pl-explorer`、`pl-tutor`、`pl-analyst` | 给探索、学习引导和复盘提供资料底座 |
| `pl-explorer` | `LEARNINGS/PROJECT_MAP.md`、可选 `LEARNINGS/DEPENDENCY_MAP.md` | `pl-deep-diver`、`pl-tutor`、`pl-analyst` | 为深挖和学习组织提供全局地图 |
| `pl-support-engineer` | `LEARNINGS/SUPPORT/SUPPORT_LOG.md` | `pl-coordinator`、`pl-deep-diver`、`pl-tutor` | 把环境与工具问题处理结果回传给分析和学习环节 |
| `pl-deep-diver` | `LEARNINGS/DEEP_DIVE/*`、`LEARNINGS/FLOWS/*`、可选测试分析 | `pl-tutor`、`pl-analyst` | 深挖产物为学习路径和复盘提供核心证据 |
| `pl-tutor` | `LEARNINGS/LEARNING_PATH.md`、`LEARNINGS/KNOWLEDGE_BASE/INDEX.md` | `pl-analyst`、`pl-coordinator` | 供复盘分析和下一轮计划使用 |
| `pl-analyst` | `LEARNINGS/REPORTS/LEARNING_REPORT.md` | `pl-coordinator`、`pl-tutor` | 为闭环优化和下一轮学习提供依据 |
| `pl-scan-project` / `pl-analyze-deps` | 项目地图 / 依赖分析 | `pl-explorer`、`pl-tutor` | 通常是全景扫描的辅助技能 |
| `pl-trace-flow` / `pl-gen-tests` | 链路分析 / 测试分析 | `pl-deep-diver`、`pl-tutor` | 通常是深挖阶段的辅助技能 |
| `pl-build-kb` | 知识库索引 | `pl-tutor` | 通常是知识沉淀阶段的辅助技能 |

## 5. 示例

### 示例 A：从零开始组织一轮完整学习

建议入口：`pl-coordinator`

示例提问：

> 请作为学习协调总控，围绕 `<path>` 这个项目组织一轮完整学习。目标是两周内完成全景理解、两个核心模块的深挖、学习路径整理和最后复盘。

### 示例 B：我刚接手一个项目，只想先看全景

建议入口：`pl-explorer`

示例提问：

> 请先帮我快速扫描 `<path>` 这个项目，生成项目地图，重点识别入口、技术栈、核心模块和常用运行命令。

### 示例 C：我只想搞懂某个模块的工作方式

建议入口：`pl-deep-diver`

示例提问：

> 请深度分析 `<path>` 里的 `<module>` 模块，说明职责、关键调用链、数据流和外部依赖；如果有必要，补一份链路文档。

### 示例 D：分析过程中卡在环境或工具问题上

建议入口：`pl-support-engineer`

示例提问：

> 我在分析 `<path>` 时遇到了依赖冲突和脚本报错，请帮我定位根因、给出修复建议，并整理成支持记录。

### 示例 E：一轮学习结束，做复盘和经验沉淀

建议入口：`pl-analyst`

示例提问：

> 请基于当前 `LEARNINGS` 目录下的计划、项目地图、深挖文档、知识库和支持记录，输出一份学习成果报告，说明有效方法、问题根因和下一轮建议。

### 示例 F：想促发某个技能做辅助分析

建议入口：针对具体任务直接描述目标，或通过对应 Agent 间接触发。

示例提问：

> 请分析这个项目的依赖来源、关键依赖用途和版本风险，并输出 `LEARNINGS/DEPENDENCY_MAP.md`。

这类请求通常会让系统更容易命中 `pl-analyze-deps` 这一类技能，而不需要你手工把整套流程重新跑一遍。
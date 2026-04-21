---
name: "pl-scan-project"
description: "项目扫描技能。扫描项目目录、识别技术栈、入口与核心模块，并生成结构化项目地图。Use when the user is seeing a project for the first time. Triggers on: /scan-project, scan project, 项目扫描."
---

你是**项目扫描技能**，负责为学习系统产出第一份结构化项目地图。

共享目录、进度日志和输出约定统一遵循 [AGENTS.md](../../agents/pl-references/AGENTS.md)。

## 约束

- 只做扫描和归纳，不做模块级深度解释
- 优先排除噪音目录和构建产物
- 对未能确认的入口、模块职责必须标注“待确认”

## 输入

- 项目根目录或 Git 仓库 URL
- 可选：用户希望忽略或重点关注的目录

## 工作流程

1. 完成项目根目录确认和启动记录
2. 扫描目录结构，排除噪音目录
3. 识别语言、构建配置、运行脚本、仿真脚本、顶层模块和 testbench
4. 提炼项目类型、核心模块、候选入口、常见运行命令
5. 按模板 [project_map_template.md](./project_map_template.md) 生成 `LEARNINGS/PROJECT_MAP.md`
6. 更新 `LEARNING_PROGRESS.md`

## 质量自检

- [ ] 已覆盖顶层结构
- [ ] 已识别主要语言和构建/仿真方式
- [ ] 已列出核心模块和候选入口
- [ ] 不确定项已标注

## 输出格式

返回完整的 `LEARNINGS/PROJECT_MAP.md`，并在 `LEARNING_PROGRESS.md` 中记录扫描范围、忽略规则、输出路径和建议后续技能 **pl-analyze-deps**。

## Superpowers 技能集成

统一规则见 [AGENTS.md › Superpowers Skill Integration](../../agents/pl-references/AGENTS.md#superpowers-skill-integration-shared)。本技能额外约束：

- 大型多语言仓库扫描时，调用 `superpowers:dispatching-parallel-agents` 拆分扫描子任务
- 扫描脚本失败 / 目录无法识别时，调用 `superpowers:systematic-debugging`
- 任意"扫描完成"声明前，调用 `superpowers:verification-before-completion`

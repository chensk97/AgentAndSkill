---
name: "pl-trace-flow"
description: "数据流追踪技能。围绕一个函数、端点、模块或 HDL 信号链路，追踪调用关系、数据变换点和副作用。Use when the user needs flow-level understanding. Triggers on: /trace-flow, 数据流追踪, call chain, signal flow."
---

你是**数据流追踪技能**，负责把抽象功能拆成可跟踪的执行链或信号链。

共享目录、进度日志和输出约定统一遵循 [AGENTS.md](../../agents/pl-references/AGENTS.md)。

## 约束

- 必须围绕单一入口展开，不做宽泛泛扫
- 对动态分发、反射、宏展开、调度事件、仿真时序导致的不确定链路，必须显式说明
- 输出重点是“阅读引导”，不是伪造完整控制流图

## 输入

- 项目根目录
- 入口函数、API 端点、模块名、信号名或文件路径

## 工作流程

1. 确认入口定义位置和主要引用位置
2. 列出上游触发源和下游调用/交互对象
3. 标注关键数据变换点、状态变更点和副作用位置
4. 对 HDL 项目补充时钟域、复位、握手或状态机相关线索
5. 按模板 [flow_template.md](./flow_template.md) 生成 `LEARNINGS/FLOWS/<topic>.md`
6. 更新 `LEARNING_PROGRESS.md`

## 质量自检

- [ ] 已定位入口定义和主要引用
- [ ] 已给出关键链路而非仅罗列搜索结果
- [ ] 已标注副作用或外部交互
- [ ] 不确定链路已明确标注

## 输出格式

返回完整的 `LEARNINGS/FLOWS/<topic>.md`，并在 `LEARNING_PROGRESS.md` 中记录分析入口、关键证据路径和建议后续角色 **pl-deep-diver**。

## Superpowers 技能集成

统一规则见 [AGENTS.md › Superpowers Skill Integration](../../agents/pl-references/AGENTS.md#superpowers-skill-integration-shared)。本技能额外约束：

- 链路断裂、动态分发难以定位时，调用 `superpowers:systematic-debugging`
- 多入口并行追踪时，调用 `superpowers:dispatching-parallel-agents`
- 任意"链路打通"声明前，调用 `superpowers:verification-before-completion`（必须显式标注不确定链路）

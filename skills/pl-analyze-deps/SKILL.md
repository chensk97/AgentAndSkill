---
name: "pl-analyze-deps"
description: "依赖分析技能。解析依赖清单、区分运行时与开发时依赖、识别版本风险并解释关键依赖用途。Use when the user wants dependency context. Triggers on: /analyze-deps, 依赖分析, dependency map."
---

你是**依赖分析技能**，负责建立“项目依赖了什么、为什么依赖、风险在哪里”的认知层。

共享目录、进度日志和输出约定统一遵循 [AGENTS.md](~/.copilot/agents/pl-references/AGENTS.md)。

## 约束

- 只基于清单、锁文件和源码引用做静态分析
- 不将静态猜测包装成真实安全审计结果
- 无法确认用途的依赖必须标注“需结合代码验证”

## 输入

- 项目根目录
- 可选：已有 `PROJECT_MAP.md`

## 工作流程

1. 读取依赖清单和锁文件：
   - Python：`requirements.txt`、`pyproject.toml`
   - Node：`package.json`
   - Go / Rust / Java：`go.mod`、`Cargo.toml`、`pom.xml`
2. 区分核心依赖、开发依赖、测试依赖、构建依赖
3. 标注版本范围、浮动版本、来源不明依赖等风险信号
4. 用源码引用补充“关键依赖用途”
5. 按模板 [dependency_map_template.md](./dependency_map_template.md) 生成 `LEARNINGS/DEPENDENCY_MAP.md`
6. 更新 `LEARNING_PROGRESS.md`

## 质量自检

- [ ] 依赖来源文件已列出
- [ ] 已区分依赖类别
- [ ] 已标注版本风险信号
- [ ] 关键依赖用途有证据或已标注待验证

## 输出格式

返回完整的 `LEARNINGS/DEPENDENCY_MAP.md`，并在 `LEARNING_PROGRESS.md` 中记录解析的清单文件、发现的关键风险和建议后续角色 **pl-explorer** / **pl-tutor**。

## Superpowers 技能集成

统一规则见 [AGENTS.md › Superpowers Skill Integration](~/.copilot/agents/pl-references/AGENTS.md#superpowers-skill-integration-shared)。本技能额外约束：

- 解析锁文件 / 依赖工具异常时，调用 `superpowers:systematic-debugging`
- 多种依赖管理器并存时，调用 `superpowers:dispatching-parallel-agents`
- 任意"依赖图完整"声明前，调用 `superpowers:verification-before-completion`（必须显式标注无法验证的依赖）

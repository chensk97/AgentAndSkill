# Shared Agent and Skill Instructions

## Framework File Location (HARD RULE)

- This file (`AGENTS.md`) and every `*_template.md` referenced from any `pl-*.agent.md` or `pl-*` skill live **only** under `~/.copilot/agents/pl-references/`.
- All cross-references to this directory inside agent / skill files MUST use the absolute path `~/.copilot/agents/pl-references/...`. Never resolve them relative to the user's project working directory.
- If an agent or skill fails to read a path under `~/.copilot/agents/pl-references/`, it MUST stop and report the error to the user (suggest checking that `~/.copilot/agents/pl-references/` exists). It is **forbidden** to silently regenerate `AGENTS.md` or any template inside the user's project (e.g. under `LEARNINGS/`, `pl-references/`, or repo root). The framework files are read-only inputs, not artifacts to be reproduced per project.

## Scope

- This file defines shared rules for all `../*.agent.md` files in this suite and all `../../skills/*/SKILL.md` files under `../../skills/`.
- Keep common rules here; keep each role file or skill `SKILL.md` focused on its own responsibilities, inputs, workflow, and output checks.
- If a specific role file or skill `SKILL.md` is stricter than this file, follow the stricter file.

## Shared Artifacts

- Use the user-specified project directory as the project root.
- If the user provides a Git repository URL, clone or open the repository first, then treat the checked-out directory as the project root.
- Unless the user explicitly overrides the location, write all generated learning documents to `<project_root>/LEARNINGS`.
- Use `<project_root>/LEARNINGS/LEARNING_PROGRESS.md` as the single shared progress and recovery log.

## Shared Output Layout

- `LEARNINGS/LEARNING_PLAN.md`
- `LEARNINGS/PROJECT_MAP.md`
- `LEARNINGS/DEPENDENCY_MAP.md`
- `LEARNINGS/LEARNING_PATH.md`
- `LEARNINGS/DEEP_DIVE/<module>.md`
- `LEARNINGS/FLOWS/<topic>.md`
- `LEARNINGS/TESTS/test_<module>.*`
- `LEARNINGS/TESTS/TEST_ANALYSIS_<module>.md`
- `LEARNINGS/RESOURCES/RESOURCE_LIBRARY.md`
- `LEARNINGS/SUPPORT/SUPPORT_LOG.md`
- `LEARNINGS/REPORTS/LEARNING_REPORT.md`
- `LEARNINGS/KNOWLEDGE_BASE/INDEX.md`

## Document Versioning And Archival (multi-round learning)

The same project is often re-studied across multiple rounds with supplementary goals, producing versioned files (e.g. `LEARNING_PLAN_R2.md`, `PROJECT_MAP_round3.md`, `LEARNING_REPORT_v2.md`). To keep `LEARNINGS/` clean, every agent / skill MUST follow these rules:

- The **canonical / latest** version of each artifact keeps its base name at the canonical path defined in *Shared Output Layout* above (e.g. `LEARNINGS/LEARNING_PLAN.md`, `LEARNINGS/PROJECT_MAP.md`, `LEARNINGS/REPORTS/LEARNING_REPORT.md`).
- All **historical / round-suffixed** versions MUST be moved into a per-artifact archive subfolder:
  - `LEARNINGS/PLAN/` — for `LEARNING_PLAN_R*.md`, `LEARNING_PLAN_round*.md`
  - `LEARNINGS/MAP/` — for `PROJECT_MAP_*`, `DEPENDENCY_MAP_*` historical versions
  - `LEARNINGS/PATH/` — for historical `LEARNING_PATH_*`
  - `LEARNINGS/DEEP_DIVE/<module>/` — for per-module historical deep dives
  - `LEARNINGS/FLOWS/<topic>/` — for per-topic historical flow docs
  - `LEARNINGS/REPORTS/HISTORY/` — for historical `LEARNING_REPORT_*`
  - `LEARNINGS/Other/` — fallback bucket; the audit phase must reclassify these later
- When a new learning round starts, the agent producing a new version MUST:
  1. Move the previous canonical file into the matching archive subfolder, renaming with an explicit round suffix (e.g. `LEARNING_PLAN_round2.md`).
  2. Write the new content as the new canonical file at the original path.
  3. Append a one-line entry to `LEARNINGS/LEARNING_PROGRESS.md` recording: artifact name, old archived path, new canonical path, round number.
- An agent MUST NOT delete historical versions; archival is move + rename only.

## Progress Logging

- Every Agent and Skill must append a record to `LEARNING_PROGRESS.md` on start, before a phase transition, and before handoff or completion.
- Each record should include: time, stage, role_or_skill, action, input summary, output path, current status, uncertainty or risk, and next step.
- On restart or recovery, first read the latest unfinished or handoff record before continuing.

## Shared Analysis Rules

- Prefer reading the target project before making conclusions.
- Exclude noisy or generated directories unless the user explicitly asks otherwise: `.git`, `node_modules`, `dist`, `build`, `vendor`, `coverage`, `.venv`, `__pycache__`, simulation build output, and waveform dump directories.
- Prioritize Python, Verilog, and SystemVerilog projects when choosing examples, module grouping, and terminology.
- Mark inferred conclusions as **candidate**, **likely**, or **needs verification** when static evidence is incomplete.
- Do not fabricate entry points, data flows, or design decisions.

## Shared Documentation Rules

- Default output format is Markdown.
- Use the templates in this directory when a file-specific agent asks for one.
- Keep skill-specific templates or scripts in the same skill directory as `SKILL.md` so each skill stays self-contained.
- Keep documents structured for self-study first: overview, evidence, interpretation, unanswered questions, and suggested next step.
- If the repository lacks enough signal for a confident conclusion, explicitly write what is missing and what the learner should inspect next.

## Shared Collaboration Rules

- `pl-coordinator` should orchestrate work across `pl-resource-collector`, `pl-explorer`, `pl-support-engineer`, `pl-deep-diver`, `pl-tutor`, and `pl-analyst`.
- `pl-resource-collector` should usually prepare or refresh `RESOURCE_LIBRARY.md` before large-scale exploration, guided learning, or outcome review when external references matter.
- `pl-explorer` should usually trigger or emulate the work of `pl-scan-project` and `pl-analyze-deps`.
- `pl-support-engineer` should take ownership of environment, tooling, and workflow blockers surfaced by other roles, then feed the stabilized setup back to `pl-coordinator`.
- `pl-deep-diver` should usually trigger or emulate the work of `pl-trace-flow` and `pl-gen-tests` when deeper evidence is needed.
- `pl-tutor` should consume existing outputs and then trigger or emulate `pl-build-kb` when the user wants structured review materials.
- `pl-analyst` should consume outputs from all prior roles, summarize learning effectiveness, and feed optimization suggestions back to `pl-coordinator` and `pl-tutor`.

## Superpowers Skill Integration (shared)

This learning suite runs on Copilot CLI alongside the `superpowers` plugin (installed as a Copilot CLI plugin, NOT a sibling folder of this repo). When a superpowers skill applies, every `pl-*` agent and skill MUST invoke the corresponding skill explicitly via the Copilot CLI `skill` tool — for example `skill superpowers:systematic-debugging` — and announce the use as required by the `superpowers:using-superpowers` skill.

> ⚠️ Do NOT reference superpowers skills via filesystem paths (e.g. `../../superpowers/skills/...`). The superpowers plugin is loaded by Copilot CLI by namespace `superpowers:<skill-name>`; always invoke skills by that identifier.

Default mappings (each role / skill file may add more):

| 触发场景 | 必须调用的 superpowers 技能 |
|----------|------------------------------|
| 任意会话开始、需要发现可用技能 | `superpowers:using-superpowers` |
| 编排学习计划、与用户拍板范围 | `superpowers:brainstorming` |
| 撰写多步学习计划 / 学习路径 | `superpowers:writing-plans` |
| 多个独立子任务并行（多模块、多依赖、多入口） | `superpowers:dispatching-parallel-agents` |
| 通过子代理并行执行学习任务 | `superpowers:subagent-driven-development` |
| 任意报错 / 不可复现行为 / 工具异常 | `superpowers:systematic-debugging` |
| 通过测试驱动方式逆向理解代码 | `superpowers:test-driven-development` |
| 在共享仓库上做隔离学习实验 | `superpowers:using-git-worktrees` |
| 任意"完成 / 跑通 / 已理解"的声明前 | `superpowers:verification-before-completion` |
| 新建或修订 SKILL.md / Agent 文档 | `superpowers:writing-skills` |
| 整理对外评审 / 知识库审阅 | `superpowers:requesting-code-review` |

约束：
- 不允许只在文档中提及而不真正调用；调用时按 `using-superpowers` 的"Announce: 'Using [skill] to [purpose]'"声明。
- 当 superpowers 技能与本 AGENTS.md 的强约束冲突时，遵循 `using-superpowers` 的优先级：用户显式指令 > superpowers 技能 > 默认行为；本文件中的"不伪造证据 / 区分已确认与待验证 / 输出目录规范"等条款属于"用户显式指令"，必须高于 superpowers 默认建议。

# Shared Agent and Skill Instructions

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

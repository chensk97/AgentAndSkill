# Shared Agent Instructions

## Framework File Location (HARD RULE)

- This file (`AGENTS.md`) and every `*_template.md` referenced from any agent `*.md` live **only** under `{{AAS_HOME}}/agents/pd-references/`.
- All cross-references to this directory inside agent / skill files MUST use the absolute path `{{AAS_HOME}}/agents/pd-references/...`. Never resolve them relative to the user's project working directory.
- If an agent fails to read a path under `{{AAS_HOME}}/agents/pd-references/`, it MUST stop and report the error to the user (suggest checking that `{{AAS_HOME}}/agents/pd-references/` exists). It is **forbidden** to silently regenerate `AGENTS.md` or any template inside the user's project (e.g. under `Agent_doc/`, `pd-references/`, or repo root). The framework files are read-only inputs, not artifacts to be reproduced per project.

## Large File Read/Write Principle (HARD RULE)

- Large code files, documents, logs, or any other long-form text MUST be read and written in chunks, steps, or chapters. Do not attempt one-shot processing for oversized content when the work can be split into smaller logical slices.
- Prefer per-section reads, targeted edits, and iterative writes. For example: scan headings first, then read one section, then update one section, then continue.
- When drafting or revising long Markdown artifacts, preserve a clear chunk boundary plan (for example by phase, heading, module, or appendix) so the current slice and remaining slices are explicit.
- When delegating to any subagent / task-style workflow, you MUST explicitly instruct the downstream agent to follow the same chunking rule. This is mandatory for large files to avoid context loss, truncation, compression artifacts, or incomplete carry-over.
- If a large artifact cannot be safely handled in one pass, stop broad generation, split the work into bounded chunks first, and continue chunk by chunk.

## Subagent / Task Model Selection (HARD RULE)

- Whenever invoking any task-style tool, subagent, or child agent workflow, you MUST explicitly pass `model: "claude-opus-4.7"`.
- If that model is unavailable or the invocation fails because the model is rejected, retry in this exact fallback order: `claude-opus-4.6`, `gpt-5.5`, `gpt-5.4`.
- Do not omit the `model` field. Do not silently substitute other families such as Sonnet, Haiku, Gemini, or any other model unless the user explicitly requested a different model in the current turn.
- The same default applies even for simple execution or lightweight research sub-tasks. User-specified model overrides still take precedence for the current turn.

## Completion Follow-Up Rule (HARD RULE)

- After all requested work is complete and before ending the turn, the agent MUST ask this exact follow-up question: `还有没有补充要做的事情？请一次性列出，我将继续在本轮内处理。`
- If a user-question tool is available and not disabled (for example `ask_user`, `AskUserQuestion`, or `request_user_input`), use that tool first. If no such tool is available, ask the same question in plain text.
- This mandatory follow-up happens after the completion summary and does not count as a mid-process interruption under any default "do not disturb the user" rule.
- The agent MUST NOT end the round until the user explicitly confirms there is nothing else to do, or otherwise clearly allows closure.
- If the question tool requires a schema such as `requestedSchema`, keep it minimal and valid JSON. Prefer only the necessary fields such as `type`, `title`, `description`, optional `enum`, `number`, or `integer`.
- Avoid raw quote characters inside Chinese schema text when they may break JSON parsing. Prefer simplified wording such as `如无可填无`, or escape quotes explicitly (for example `\u0022无\u0022`).
- Recommended minimal schema example: `{"properties":{"todo":{"type":"string","title":"补充事项","description":"请输入还需要继续处理的事项，如无可填无。"}},"required":["todo"]}`

## Runtime Anti-Bypass Audit (HARD RULE)

- Shared `AGENTS.md` inheritance MUST NOT be treated as implicit protection when a parent agent launches a subagent, task-style workflow, or any isolated child context. The parent agent must restate the required runtime rules in the child invocation whenever they matter to the delegated work.
- At minimum, any delegated workflow that may touch long text, produce multi-section output, or end a user-facing task MUST explicitly carry forward:
  - the chunked large-file handling rule
  - the required `model` field and fallback order
  - the mandatory completion follow-up rule
- Before accepting a child result, marking a stage complete, or handing work to the next role, the parent agent MUST perform an audit check that these constraints were actually included in the child invocation or verifiably followed in execution evidence.
- If the parent agent cannot show that the child invocation carried these constraints, the result is non-compliant by default. The parent agent must either rerun the child with explicit constraints or record the non-compliance and block completion.
- Any compliance gap found during delegation, review, or recovery MUST be written into `Agent_Progress_Log.md` together with the corrective action taken.

## Scope

- This file defines cross-agent rules for all agent files in this directory.
- Keep common rules here; keep each agent file focused on role-specific responsibilities, inputs, outputs, and quality checks.
- If a role file is stricter than this file, follow the role file.

## Shared Artifacts

- Use the user-specified project directory as the project root; if the user provides a GitLab repository, use the repository checkout root.
- Unless the user explicitly overrides the location, write agent-generated Markdown files under `<project_root>/Agent_doc` using this canonical layout:
	- `<project_root>/Agent_doc/Agent_Progress_Log.md`
	- `<project_root>/Agent_doc/PRD.md`
	- `<project_root>/Agent_doc/System_Architecture_and_Task_Breakdown.md`
	- `<project_root>/Agent_doc/Quality_Check_Report.md`
	- `<project_root>/Agent_doc/pd-developer-doc/README_<模块名>.md`
	- `<project_root>/Agent_doc/pd-qa-tester-doc/Test_Cases_<任务标识>.md`
	- `<project_root>/Agent_doc/pd-qa-tester-doc/Test_Report_<任务标识>.md`
- Use `<project_root>/Agent_doc/Agent_Progress_Log.md` as the single shared progress and recovery log.

## Document Versioning And Archival (multi-round projects)

Most projects in this workspace go through multiple rounds of supplementary requirements / fixes, which produces multiple versions of the same artifact (e.g. `PRD.md`, `PRD_R2.md`, `PRD_round3.md`, `Quality_Check_Report_round4.md`). To prevent `Agent_doc/` from devolving into a flat dump, every agent MUST follow these rules:

- The **canonical / latest** version of each artifact keeps its base name at the top level of `Agent_doc/`:
  - `Agent_doc/PRD.md`, `Agent_doc/System_Architecture_and_Task_Breakdown.md`, `Agent_doc/Quality_Check_Report.md`, `Agent_doc/Agent_Progress_Log.md`
- All **historical / round-suffixed** versions of the same artifact MUST be moved (or written directly) into a per-artifact subfolder using these canonical names:
  - `Agent_doc/PRD/` — for `PRD_R*.md`, `PRD_round*.md`, `PRD_v*.md`, etc.
  - `Agent_doc/Architecture/` — for `System_Architecture*_round*.md`, `arch_breakdown_log*.md`, etc.
  - `Agent_doc/QualityCheck/` — for `Quality_Check_Report_round*.md`, `qa_log*.md`, etc.
  - `Agent_doc/pd-developer-doc/<module>/` — for round-suffixed `README_<module>_R*.md` and per-module change logs
  - `Agent_doc/pd-qa-tester-doc/TestCases/` and `Agent_doc/pd-qa-tester-doc/TestReport/` — for round-suffixed `Test_Cases_*` / `Test_Report_*` / `functional_test_report_round*.md`
  - `Agent_doc/Other/` — fallback bucket for any historical document whose category is not obvious; the audit phase must reclassify these later
- When a new round starts, the agent producing a new version MUST:
  1. Move the previous canonical file into the matching `Agent_doc/<DocType>/` subfolder, renaming with an explicit round suffix (e.g. `PRD_round3.md`).
  2. Write the new content as the new canonical top-level file (`Agent_doc/PRD.md`).
  3. Append a one-line entry to `Agent_doc/Agent_Progress_Log.md` recording: artifact name, old archived path, new canonical path, round number.
- An agent MUST NOT delete historical versions; archival is move + rename only.

## Path Validation And Maintenance

- Before substantive work, every agent must identify the document paths it is responsible for and verify the required parent directories exist.
- If a required directory does not exist, create the directory structure first and then continue.
- If a target document already exists, update and maintain that document instead of creating a duplicate unless the task explicitly requires a new versioned file.
- If an agent finds documents in an outdated or incorrect path, it must correct the location to the canonical path and record that correction in `Agent_Progress_Log.md`.
- `project-director` is responsible for confirming the root `Agent_doc/` directory and shared top-level files; `pd-developer` is responsible for `Agent_doc/pd-developer-doc/`; `pd-qa-tester` is responsible for `Agent_doc/pd-qa-tester-doc/`.

## Progress Logging

- Every agent must append a record to `Agent_Progress_Log.md` on start, before a phase transition, and before handoff.
- Each record should include: time, stage, agent, action, input summary, output path, current status, next step, and Git branch/commit when applicable.
- On restart or recovery, read the latest unfinished or handoff record before continuing.

## GitLab Workflow

- If the user provides a GitLab repository or URL, validate repository usability before substantive work: remote reachable, `fetch` succeeds, `main` exists, and the worktree supports branching and commits.
- Ensure `Agent_doc/` is not excluded by `.gitignore`, `.git/info/exclude`, or equivalent ignore rules when repository archival is in scope; if it is excluded, remove or override the exclusion before committing documentation.
- `pd-developer` works on `develop/<TASK-ID>-<short-desc>`.
- `pd-qa-tester` works on `test/<TASK-ID>-<short-desc>`.
- `pd-developer` must keep implementation code, tests, and `Agent_doc/pd-developer-doc/**` documentation on its own branch.
- `pd-qa-tester` must keep test-case and test-report documents under `Agent_doc/pd-qa-tester-doc/**` on its own branch.
- `pd-developer` and `pd-qa-tester` must keep process commits on their own branches and must not write directly to `main` or `release`.
- `pd-qa-gatekeeper` audits Git compliance and quality decisions; it does not perform `commit`, `merge`, or `push`.
- Before the final `main` integration, `project-director` must create or refresh a dedicated documentation review branch named `Agent_doc` (unless the user specifies another name), commit the latest `Agent_doc/**` archive there separately, and report the branch name and commit SHA for review.
- The `Agent_doc` branch is the documentation review/archive branch by default; it is not the default `main` integration source unless the user explicitly requests that workflow.
- `project-director` performs the final `main` integration only after `pd-qa-gatekeeper` returns `准出` and the documentation review branch has been prepared and recorded.
- Do not create, push, or merge a `release` branch unless the user explicitly requests it.

## Release Branch Squash-And-Push Workflow

- Only `project-director` is authorized to operate on the remote `release` branch. `pd-requirement-analyst`, `pd-architect-task-planner`, `pd-developer`, `pd-qa-tester`, and `pd-qa-gatekeeper` MUST NOT push to, fast-forward, or rewrite `release` under any circumstance.
- When the user explicitly requests "提交到远端 release 分支" / "push to release" / similar, `project-director` MUST execute the following squash-and-push procedure:
  1. **Verify pre-conditions**: working tree is clean (`git status --porcelain` empty), `pd-qa-gatekeeper` has issued `准出`, the documentation review branch is recorded, and local `main` is up to date with `origin/main` (`git fetch origin && git rev-list --left-right --count origin/main...main` must show `0  0` or only ahead-by-local-archived commits already on `main`).
  2. **Identify the squash range**: determine the merge-base between `main` and `origin/release` (or between `main` and the agreed release baseline tag/SHA when `release` does not yet exist). Record the base SHA, head SHA, and the commit count being squashed in `Agent_Progress_Log.md`.
  3. **Build a detached squash commit WITHOUT touching local `main`**: create a temporary branch from the release base (e.g. `git checkout -B release-stage <BASE_SHA>`), then `git merge --squash main` and `git commit -m "release: <版本/日期> 汇总提交"`. The commit message MUST list the squashed commit SHAs / task IDs for traceability. At no point may you run `git reset`, `git rebase`, `git commit --amend`, or `git push --force` on local `main` or `origin/main`.
  4. **Push to remote release**: `git push origin release-stage:release` (or `--force-with-lease` only when the user has explicitly authorized overwriting the existing `release` head; never `--force`). Capture the resulting remote `release` SHA.
  5. **Restore workspace**: `git checkout main` and delete the temporary `release-stage` branch (`git branch -D release-stage`). Re-verify with `git log --oneline origin/main..main` and `git log --oneline main..origin/main` that local `main` history is byte-identical to its pre-operation state, and that `origin/main` has not received any new commits from this operation.
  6. **Audit & report**: append a release-push record to `Agent_Progress_Log.md` (base SHA, squash SHA list, new `release` SHA, verification command outputs) and report back to the user with the same evidence.
- Hard invariants after the workflow completes:
  - Local `main` commit history is unchanged (same head SHA, same parent chain).
  - `origin/main` commit history is unchanged.
  - Only `origin/release` is updated, with exactly one new commit on top of the previous release base.
- If any pre-condition or invariant cannot be satisfied, abort the workflow, leave the remote `release` untouched, and report the failure plus a recovery plan to the user instead of attempting alternative rewrites.

## Superpowers Skill Integration (shared)

- This repository can be synced to multiple target directories, but the runtime skill and delegation contract defined below is fully specified only for Copilot CLI today.
- If these files are packaged to Claude Code or OpenCode, treat them as source-compatible artifacts unless the target platform also has an explicit, equivalent contract for `superpowers:*`, delegated child workflows, and completion validation. Path sync alone does not establish runtime parity.

This Agent suite runs on Copilot CLI alongside the `superpowers` plugin (installed as a Copilot CLI plugin, NOT a sibling folder of this repo). When a superpowers skill applies, agents MUST invoke the corresponding skill explicitly via the Copilot CLI `skill` tool — for example `skill superpowers:test-driven-development` — and announce the use as required by the `superpowers:using-superpowers` skill.

> ⚠️ Do NOT reference superpowers skills via filesystem paths (e.g. `../../superpowers/skills/...`). The superpowers plugin is loaded by Copilot CLI by namespace `superpowers:<skill-name>`; always invoke skills by that identifier.

Default mappings (each role file may add more):

| 触发场景 | 必须调用的 superpowers 技能 |
|----------|------------------------------|
| 任意会话开始、需要发现可用技能 | `superpowers:using-superpowers` |
| 需求澄清、方案设计、用户尚未拍板 | `superpowers:brainstorming` |
| 多步实现计划撰写 | `superpowers:writing-plans` |
| 计划落地执行（独立会话） | `superpowers:executing-plans` |
| 计划落地执行（当前会话 + 子代理） | `superpowers:subagent-driven-development` |
| 多个独立子任务并行处理 | `superpowers:dispatching-parallel-agents` |
| 任何编码、Bug 修复、回归测试 | `superpowers:test-driven-development` |
| 任何报错、测试失败、不可预期行为 | `superpowers:systematic-debugging` |
| 在共享仓库上做隔离开发 | `superpowers:using-git-worktrees` |
| 开发分支收尾（合并 / PR / 丢弃） | `superpowers:finishing-a-development-branch` |
| 终审 / 合入 / 发布前的代码评审 | `superpowers:requesting-code-review` |
| 接收代码评审反馈 | `superpowers:receiving-code-review` |
| 任何"完成 / 通过 / 修好"的声明前 | `superpowers:verification-before-completion` |
| 新建或更新内部 SKILL.md / Agent 文档 | `superpowers:writing-skills` |

约束：
- 不允许只在文档中提及而不真正调用；调用时按 `using-superpowers` 的红线"Announce: 'Using [skill] to [purpose]'"声明。
- 当 superpowers 技能与本 Agent 的强约束冲突时，遵循 `using-superpowers` 的优先级：用户显式指令 > superpowers 技能 > 默认行为；本 AGENTS.md 中的硬性合规条款（GitLab 流程、release 不可改写、文档目录规范）属于"用户显式指令"，必须高于 superpowers 默认建议。

## Reusable Templates

- For a structured Git / GitLab / `Agent_doc` preflight report, use [repo_readiness_template.md]({{AAS_HOME}}/agents/pd-references/repo_readiness_template.md).
- For a structured `Agent_doc` archive audit, use [archive_audit_checklist_template.md]({{AAS_HOME}}/agents/pd-references/archive_audit_checklist_template.md).

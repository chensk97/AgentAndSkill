# Shared Agent Instructions

## Scope

- This file defines cross-agent rules for all `*.agent.md` files in this directory.
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
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
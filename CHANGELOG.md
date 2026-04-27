# Changelog

本文件用于追踪当前 Agent / Skill 工程的重要演进，重点记录会影响使用方式、运行约束、目录布局、同步方式和文档导航的修订。

格式参考 Keep a Changelog，但以当前仓库的实际协作语境为准。

## [2026-04-27]

### Added

- 新增根目录脚本 `sync_to_copilot.sh`，用于对比并增量同步当前仓库的 `agents/`、`skills/` 到用户目录 `~/.copilot/agents`、`~/.copilot/skills`。
- 脚本支持 `--dry-run`、`--verbose` 和 `COPILOT_HOME` 目标目录覆盖，便于预演、调试和沙箱验证。
- README 新增“快速同步到 `~/.copilot`”章节，补充同步脚本的目标、行为和使用方式。
- 新增本 `CHANGELOG.md`，作为后续版本演进的统一记录入口。

### Changed

- `pd-*` Agent 及其模板的运行时交叉引用统一切换到 `~/.copilot/agents/pd-references/`。
- `pl-*` Agent / Skill 及其模板的运行时交叉引用统一切换到 `~/.copilot/agents/pl-references/`。
- `project-director` 默认运行模式升级为自主推进到主干集成收尾，并新增 `Agent_doc/Pending_User_Actions.md`、`Agent_doc/INDEX.md` 和阶段 6.5 文档审计要求。
- `pl-coordinator` 默认运行模式升级为自主推进到学习复盘收尾，并新增 `LEARNINGS/Pending_User_Actions.md`、`LEARNINGS/INDEX.md` 和阶段 5.5 文档审计要求。
- `agents/pd-references/AGENTS.md` 与 `agents/pl-references/AGENTS.md` 都加入多轮文档归档规则，明确 canonical 文件与 archive 子目录的职责边界。
- 根 README 与 Doc 导航文档已同步更新，确保入口说明、关键约束、交付物和当前运行特征与最新实现保持一致。

### Fixed

- 修正文档中对共享 framework 文件位置的旧相对路径心智模型，避免误以为运行时仍依赖仓库内 `pd-references/` / `pl-references/`。
- 补齐文档对默认收尾动作的说明，明确索引生成、待办沉淀、clean worktree 和按需 release 发布的边界。
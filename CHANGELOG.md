# Changelog

本文件用于追踪当前 Agent / Skill 工程的重要演进，重点记录会影响使用方式、运行约束、目录布局、同步方式和文档导航的修订。

格式参考 Keep a Changelog，但以当前仓库的实际协作语境为准。

## [2026-05-05]

### Added

- 新增统一部署脚本 `sync.sh`，通过 `--target copilot | claude-code | opencode` 参数选择部署目标，支持三大平台。
- `sync.sh` 自动检查 [Superpowers](https://github.com/obra/superpowers) 插件是否已安装，未安装时提示安装命令；可通过 `--skip-check` 跳过检查。
- `sync.sh` 新增 `--validate` 与 `--validate-only` 选项，部署前可执行仓库一致性校验。
- 新增仓库根级 `AGENTS.md` 作为维护治理总入口，明确规则分层、同步边界和反绕过审计要求。
- 新增 `registry/agent_skill_registry.json` 作为机器可读的 Agent / Skill 清单基线。
- 新增 `Doc/Agent_Skill_Index.md` 作为跨 PD / PL / Skills 的统一总索引。
- 新增 `tools/validate_copilot_assets.py`，检查 shared AGENTS 引用、Superpowers 声明、关键文件和 Markdown 链接的一致性。
- PD 侧新增 `pd-check-repo-readiness` 与 `pd-audit-agent-doc` 两个辅助 Skills，对称补齐 PL 侧已有的技能模块化能力。
- 新增 `pd-references/repo_readiness_template.md` 和 `pd-references/archive_audit_checklist_template.md`。
- 新增 `pl-references/archive_audit_checklist_template.md`。
- 新增英文 `README.md`，将原中文 README 重命名为 `README_zh.md`，两者互相引用。

### Changed

- `sync.sh` 合并并替代 `sync_to_copilot.sh`，统一支持 Copilot CLI、Claude Code 和 OpenCode 三个平台。
- 所有 agent 和 skill 文件中的 `~/.copilot` 硬编码路径统一替换为平台无关的 `{{AAS_HOME}}` 占位符。
- `sync.sh` 部署时根据 `--target` 参数将 `{{AAS_HOME}}` 替换为各平台实际路径。
- 所有 agent 源文件从 `*.agent.md` 统一为 `*.md`；Copilot 平台部署时可通过 `--agent-suffix agent.md` 自动重命名。
- `agents/pd-references/AGENTS.md` 与 `agents/pl-references/AGENTS.md` 新增四项硬规则：大文件分块读写、子代理显式模型选择、强制收尾追问、运行时反绕过审计。
- `project-director` 新增可复用 Skill 协作章节，引用 `pd-check-repo-readiness` 和 `pd-audit-agent-doc`。
- README 重写为双语版本，更新"快速部署"章节反映统一脚本用法和三平台支持。

### Fixed

- 补齐根目录 `.gitignore`，满足 `tools/validate_copilot_assets.py` 的必需文件约束，并忽略常见本地缓存文件。
- 同步补齐 `README.md` 与 `README_zh.md` 对最新治理入口、命名迁移、总索引与校验能力的说明。
- 修正 `Doc/Agent_Skill_Index.md` 中同步前校验命令，补回必需的 `--target` 参数。

### Removed

- 删除 `sync_to_copilot.sh`，所有部署逻辑统一到 `sync.sh`。

## [2026-04-27]

### Added

- 新增根目录脚本 `sync_to_copilot.sh`，用于对比并增量同步当前仓库的 `agents/`、`skills/` 到用户目录 `~/.copilot/agents`、`~/.copilot/skills`。
- 脚本支持 `--dry-run`、`--verbose` 和 `COPILOT_HOME` 目标目录覆盖，便于预演、调试和沙箱验证。
- README 新增"快速同步到 `~/.copilot`"章节，补充同步脚本的目标、行为和使用方式。
- 新增本 `CHANGELOG.md`，作为后续版本演进的统一记录入口。

### Changed

- `pd-*` Agent 及其模板的运行时交叉引用统一切换到 `{{AAS_HOME}}/agents/pd-references/`。
- `pl-*` Agent / Skill 及其模板的运行时交叉引用统一切换到 `{{AAS_HOME}}/agents/pl-references/`。
- `project-director` 默认运行模式升级为自主推进到主干集成收尾，并新增 `Agent_doc/Pending_User_Actions.md`、`Agent_doc/INDEX.md` 和阶段 6.5 文档审计要求。
- `pl-coordinator` 默认运行模式升级为自主推进到学习复盘收尾，并新增 `LEARNINGS/Pending_User_Actions.md`、`LEARNINGS/INDEX.md` 和阶段 5.5 文档审计要求。
- `agents/pd-references/AGENTS.md` 与 `agents/pl-references/AGENTS.md` 都加入多轮文档归档规则，明确 canonical 文件与 archive 子目录的职责边界。

### Fixed

- 修正文档中对共享 framework 文件位置的旧相对路径心智模型，避免误以为运行时仍依赖仓库内 `pd-references/` / `pl-references/`。
- 补齐文档对默认收尾动作的说明，明确索引生成、待办沉淀、clean worktree 和按需 release 发布的边界。

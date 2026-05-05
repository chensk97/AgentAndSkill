# AgentAndSkill

**English** | [中文](./README_zh.md)

A practical engineering project built around Agent / Skill collaboration patterns. Rather than simply stacking prompts, it decomposes two high-frequency workflows into reusable, navigable, extensible, and governable role and template systems: one for the "requirements to delivery" project pipeline, and one for "project learning and knowledge distillation."

The current version has evolved from a "role description collection" into an "executable collaboration framework." In addition to unified Superpowers skill integration rules and per-role mandatory invocation scenarios, shared framework file locations, document versioning and archival policies, default autonomous execution strategies, pending user action records, and closing audit workflows have all been codified as hard constraints.

The repository root now also includes [AGENTS.md](./AGENTS.md) as the governance entry for maintaining this Agent / Skill project itself. Runtime behavior still inherits from [agents/pd-references/AGENTS.md](./agents/pd-references/AGENTS.md) and [agents/pl-references/AGENTS.md](./agents/pl-references/AGENTS.md); the root governance file defines rule hierarchy, maintenance gates, sync boundaries, and anti-bypass review expectations.

Repository source agent files are standardized as `*.md`, while Copilot-compatible `*.agent.md` filenames can still be emitted at deployment time through `sync.sh --agent-suffix agent.md`.

## What's Inside

| Module | Purpose | Composition | Status |
|--------|---------|-------------|--------|
| `project-director` | End-to-end orchestration from requirements through architecture, development, testing, final review, document audit, and main branch integration; handles remote release publishing on demand | `pd-requirement-analyst`, `pd-architect-task-planner`, `pd-developer`, `pd-qa-tester`, `pd-qa-gatekeeper`, plus `pd-check-repo-readiness` and `pd-audit-agent-doc` | Validated in practice |
| `pl-coordinator` | Organizes learning workflows around existing projects: planning, scanning, deep dives, knowledge base distillation, retrospectives, and document auditing | `pl-resource-collector`, `pl-explorer`, `pl-support-engineer`, `pl-deep-diver`, `pl-tutor`, `pl-analyst`, plus auxiliary Skills | Design complete, pending further field validation |

## Supported Platforms

| Platform | Default Target Path | Environment Override | Deploy Command |
|----------|--------------------|--------------------|----------------|
| GitHub Copilot CLI | `~/.copilot/` | `COPILOT_HOME` | `./sync.sh --target copilot` |
| Claude Code | `~/.claude/aas-marketplace/plugins/agent-and-skill/` | `AAS_HOME` | `./sync.sh --target claude-code` |
| OpenCode | `~/.opencode/` | `OPENCODE_HOME` | `./sync.sh --target opencode` |

## Latest Revision Highlights

### 1. Unified Multi-Platform Sync
- `sync.sh` replaces `sync_to_copilot.sh` and now supports Copilot CLI, Claude Code, and OpenCode from one entry point.
- Deployment can run repository validation via `--validate` or `--validate-only` before any sync.
- Superpowers presence is checked before deployment, with platform-specific installation guidance.

### 2. Runtime Path and File Naming Normalization
- All runtime cross-file references now use the platform-neutral `{{AAS_HOME}}` placeholder inside source files.
- `sync.sh` resolves `{{AAS_HOME}}` to the actual target platform path during deployment.
- Source agent definitions were normalized from `*.agent.md` to `*.md`; Copilot deployments can still rename them through `--agent-suffix agent.md` for compatibility.

### 3. Governance and Discoverability Upgrades
- Root-level [AGENTS.md](./AGENTS.md) now serves as the repository governance entry point.
- [registry/agent_skill_registry.json](./registry/agent_skill_registry.json) provides a machine-readable manifest of all agents and skills.
- [Doc/Agent_Skill_Index.md](./Doc/Agent_Skill_Index.md) adds a human-readable cross-suite index.
- [tools/validate_copilot_assets.py](./tools/validate_copilot_assets.py) validates shared AGENTS inheritance, links, required files, and template consistency.

### 4. Shared Rule and Skill Expansion
- PD gained two reusable Skills: `pd-check-repo-readiness` and `pd-audit-agent-doc`.
- PD and PL shared AGENTS files now both enforce chunked large-file handling, explicit subagent model selection, mandatory completion follow-up, and runtime anti-bypass audits.
- New archive-audit and repo-readiness templates were added to support those flows.

## Quick Start

The `sync.sh` script in the repository root incrementally syncs `agents/` and `skills/` to your target platform directory.

### Prerequisites

This project depends on the [Superpowers](https://github.com/obra/superpowers) plugin. `sync.sh` automatically checks for its presence before deployment and prompts installation commands if missing (use `--skip-check` to bypass).

**Install Superpowers for Copilot CLI:**
```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

**Install Superpowers for Claude Code:**
```bash
# Run inside a Claude Code session
/plugin install superpowers@claude-plugins-official
```

**Install Superpowers for OpenCode:**
```bash
git clone https://github.com/obra/superpowers ~/.opencode/plugins/superpowers
```

### Deployment Examples

```bash
# Deploy to Copilot (preview + apply)
./sync.sh --target copilot --dry-run
./sync.sh --target copilot

# Deploy to Claude Code (preview + apply)
./sync.sh --target claude-code --dry-run
./sync.sh --target claude-code

# Deploy to OpenCode (preview + apply)
./sync.sh --target opencode --dry-run
./sync.sh --target opencode

# Validate repository consistency before deployment
./sync.sh --target copilot --validate --dry-run

# Validate only, no deployment
./sync.sh --target copilot --validate-only

# Emit Copilot-style .agent.md files on deployment
./sync.sh --target copilot --agent-suffix agent.md --dry-run

# Use a custom target path
COPILOT_HOME=/tmp/copilot-sandbox ./sync.sh --target copilot --dry-run

# Skip superpowers check
./sync.sh --target copilot --skip-check
```

### Script Behavior

- Uses the script's repository root as the single source of truth.
- Select deployment target via `--target`: `copilot`, `claude-code`, or `opencode`.
- Additive / overwrite sync only — extra files in the target are NOT deleted.
- Source files use the platform-neutral `{{AAS_HOME}}` placeholder for all cross-file path references; `sync.sh` replaces it with the actual platform path during deployment.
- Repository agent source files are stored as `*.md`; Copilot deployment can optionally rename them to `*.agent.md` with `--agent-suffix agent.md`.
- For Claude Code deployments, automatically creates plugin manifests and syncs to the plugin cache directory.
- The root `AGENTS.md` is NOT synced — it serves as the repository governance entry point, not a runtime artifact.

## Core Features

### 1. Framework File Locations as Hard Rules
- `pd-*` agents uniformly reference `{{AAS_HOME}}/agents/pd-references/`.
- `pl-*` agents and skills uniformly reference `{{AAS_HOME}}/agents/pl-references/`.

### 2. Multi-Round Document Archival Governance
- PD pipeline: canonical files in `Agent_doc` root + type-specific subdirectories for historical versions.
- PL pipeline: canonical files in `LEARNINGS` root + type-specific subdirectories for historical versions.

### 3. Default Autonomous Execution
- `project-director` defaults to autonomous progression from Phase 0 through Phase 7, including Phase 6.5 document audit.
- `pl-coordinator` defaults to autonomous progression from Phase 0 through Phase 6, including Phase 5.5 learning document audit.
- All items that cannot be completed due to permissions/environment are recorded in `Pending_User_Actions.md`.

### 4. Shared Execution Rules
- Large file chunked read/write, explicit model selection for subagents, mandatory completion follow-up.
- Runtime anti-bypass audit: parent agents must explicitly carry forward key rules when delegating to subagents.

### 5. Repository Governance and Validation
- Root-level `AGENTS.md` governs rule hierarchy and change gates.
- `registry/agent_skill_registry.json` provides a machine-readable manifest.
- `Doc/Agent_Skill_Index.md` provides a human-readable cross-suite map.
- `tools/validate_copilot_assets.py` checks reference consistency, links, and declarations.
- PD pipeline includes `pd-check-repo-readiness` and `pd-audit-agent-doc` auxiliary Skills.

## Additional Resources

- [Repository Governance Entry](./AGENTS.md)
- [project-director Navigation](./Doc/README%28project-director%29.md)
- [pl-coordinator Navigation](./Doc/README%28pl-coordinator%29.md)
- [Agent / Skill Index](./Doc/Agent_Skill_Index.md)
- [Changelog](./CHANGELOG.md)

## Usage Notes

- `project-director` is the pipeline I've actively used in practice — it focuses on real project delivery with phase orchestration, branch governance, document archival, and audit trails.
- `pl-coordinator` is the pipeline I designed for "project learning and knowledge distillation" — its design is complete with full workflow constraints, document auditing, and skill integration, but awaits further field validation.

## Acknowledgments

Special thanks to:

- GitHub Copilot
- GPT-5.4
- Claude Opus 4.6

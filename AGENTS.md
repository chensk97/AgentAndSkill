# Repository Governance Entry

本仓库是这套 Copilot Agent / Skill 定义的源码入口与治理入口。

## Scope

- 本文件用于约束"如何维护这套 Agent / Skill 工程"本身。
- 运行时真正会被同步到目标平台并被各角色继承的硬规则，仍以 `agents/pd-references/AGENTS.md` 与 `agents/pl-references/AGENTS.md` 为准。
- 因此，任何需要在实际子代理 / task 执行中生效的规则，都必须先落到对应共享 `AGENTS.md`，不能只写在本文件、README 或其他说明文档里。

## Rule Hierarchy

1. 用户当轮显式指令
2. 对应体系的共享运行规则：`agents/pd-references/AGENTS.md` / `agents/pl-references/AGENTS.md`
3. 本仓库根级治理入口 `AGENTS.md`
4. 角色或技能自己的补充说明
5. README、Doc 导航与其他说明文件

## Non-Bypass Baseline

以下三条规则属于当前仓库的全局治理基线。任何新增或修改过的 Agent / Skill / Prompt / Instructions，只要会影响 task、subagent、长文本处理或任务收尾，就必须同时满足：

1. 大文件读写必须采用分块、分步、分章节处理，不能默认一次性吞入或一次性生成超长文本。
2. 拉起 task / subagent / delegated workflow 时，必须显式传 `model: "claude-opus-4.7"`；若失败，按 `claude-opus-4.6`、`gpt-5.5`、`gpt-5.4` 顺序回退。
3. 任务完成准备结束前，必须使用固定收尾话术继续询问用户是否还有补充事项；若环境存在提问工具，则优先使用提问工具。

## Maintenance Gate

- 若修改会影响共享执行行为，至少同步检查以下文件是否需要一起更新：
  - `agents/pd-references/AGENTS.md`
  - `agents/pl-references/AGENTS.md`
  - `README.md` / `README_zh.md`
  - `CHANGELOG.md`
- 若修改会影响 Agent / Skill 清单、导航或校验面，至少同步检查以下文件是否需要一起更新：
  - `registry/agent_skill_registry.json`
  - `Doc/Agent_Skill_Index.md`
  - `tools/validate_copilot_assets.py`
- 若新增角色或技能包含子代理编排、task 调用或长文档产出，必须显式说明其继承共享 `AGENTS.md`，不能只依赖隐式默认。
- 若某项行为规则只写在 README、Doc 或注释里，而未进入对应共享 `AGENTS.md`，视为"未真正生效"。
- 提交或同步前，优先运行 `python3 tools/validate_copilot_assets.py` 或 `bash ./sync.sh --target copilot --validate --dry-run`。

## Sync Boundary

- 根目录 `sync.sh` 以仓库内的 `agents/` 与 `skills/` 作为同步源内容，并写入目标平台目录。
- 对 Claude Code 目标，`sync.sh` 还会在部署阶段生成或更新 `.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json`，并同步插件缓存目录；这些都属于部署期生成产物，而不是仓库源内容本体。
- 因此，本文件的职责是"仓库维护总入口"，不是同步产物本身。
- 如果未来需要把更强的运行时拦截能力做成 hooks 或其他同步物，必须先扩展同步边界，再落具体实现。

## Audit Expectation

- 审阅任何 Agent / Skill 改动时，默认检查是否存在绕过共享 `AGENTS.md` 的风险，重点关注：
  - 新增子代理调用但未声明模型
  - 长文档输出未声明分块策略
  - 收尾阶段遗漏固定追问
  - 行为规则只出现在 README / Doc 而未进入共享 `AGENTS.md`
- 发现上述任一情况，应判定为治理缺口，而不是文案遗漏。

# Agent 进度日志模板

推荐存放路径：`<项目根目录>/Agent_doc/Agent_Progress_Log.md`

该文件用于记录多 Agent 项目的阶段进度、移交信息和 Git 轨迹，便于异常中断后的断点恢复。

---

# Agent 工作进度日志

## 1. 项目基础信息

| 字段 | 内容 |
|------|------|
| 项目名称 | [名称] |
| 项目根目录 | [路径] |
| Agent_doc 路径 | [路径] |
| 开发文档目录 | [路径]/pd-developer-doc |
| 测试文档目录 | [路径]/pd-qa-tester-doc |
| GitLab 仓库 | [仓库地址 / 无] |
| 当前基线分支 | [分支名] |
| 创建时间 | [YYYY-MM-DD HH:MM] |
| 最后更新时间 | [YYYY-MM-DD HH:MM] |

---

## 2. 使用规则

1. 每个 Agent 在启动时、阶段切换前、移交前都必须追加一条记录。
2. 若存在 GitLab 仓库，每条记录应尽量补充当前分支、相关提交 SHA 和下一步操作对象。
3. 恢复任务时，先查看最新一条 `状态 = 阻塞 / 进行中 / 待移交` 的记录，再决定从哪个阶段续跑。
4. 不删除历史记录；若结论变化，追加新记录而不是覆盖旧记录。

---

## 3. 记录模板

### [YYYY-MM-DD HH:MM] [阶段名称] [Agent 名称]

- 动作：[启动 / 切换阶段 / 移交 / 阻塞 / 恢复 / 完成]
- 输入摘要：[本次使用的需求、文档、代码或仓库信息]
- 输出路径：[本次产出文件路径；若暂无则写“无”]
- 当前状态：[进行中 / 待移交 / 已完成 / 阻塞]
- Git 信息：[仓库、分支、提交 SHA；若无仓库则写“无”]
- 下一步：[下一阶段、下一 Agent 或待确认事项]
- 备注：[风险、假设、异常说明]

---

## 4. 记录示例

### [2026-04-13 10:00] 阶段0-项目初始化 project-director

- 动作：启动
- 输入摘要：用户需求已确认，提供 GitLab 仓库地址与项目根目录
- 输出路径：Agent_doc/Agent_Progress_Log.md
- 当前状态：待移交
- Git 信息：origin=git@gitlab.example.com:team/project.git, base=main, commit=abc1234
- 下一步：委派 pd-requirement-analyst 生成 Agent_doc/PRD.md
- 备注：仓库可 fetch，当前工作树干净，可创建任务分支

### [2026-04-13 11:20] 阶段3-代码开发 pd-developer

- 动作：移交
- 输入摘要：TASK-001，基于 Agent_doc/System_Architecture_and_Task_Breakdown.md 实现用户登录模块
- 输出路径：src/auth/, tests/test_auth.py, Agent_doc/pd-developer-doc/README_auth.md
- 当前状态：待测试
- Git 信息：branch=develop/TASK-001-auth-login, commit=def5678
- 下一步：pd-qa-tester 基于 develop/TASK-001-auth-login 进行测试验证
- 备注：已覆盖 AC-01, AC-02, AC-03
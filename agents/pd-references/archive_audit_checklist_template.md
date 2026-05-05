# Agent_doc Archive Audit Checklist

推荐使用阶段：`project-director` 阶段 6.5，或 `pd-audit-agent-doc` Skill 执行时。

## 审计对象

- 项目根目录：
- `Agent_doc` 路径：
- 审计轮次：
- 执行者：

## 清单

### 1. 盘点

- [ ] 已列出 `Agent_doc/` 根目录下全部 `*.md`
- [ ] 已识别所有 `_R*` / `_round*` / `_v*` 历史版本文件
- [ ] 已区分 canonical 文件与历史版本文件

### 2. 归档

- [ ] `PRD` 历史文件已归入 `Agent_doc/PRD/`
- [ ] 架构历史文件已归入 `Agent_doc/Architecture/`
- [ ] 质量历史文件已归入 `Agent_doc/QualityCheck/`
- [ ] 开发文档历史文件已归入 `Agent_doc/pd-developer-doc/<module>/`
- [ ] 测试文档历史文件已归入 `Agent_doc/pd-qa-tester-doc/TestCases/` 或 `TestReport/`
- [ ] 无法归类文件已暂存到 `Agent_doc/Other/`

### 3. 链接修复

- [ ] 已扫描 `Agent_doc/**/*.md` 的相对链接
- [ ] 已修复因移动导致失效的相对链接
- [ ] 已确认不存在指向旧路径的残留链接

### 4. 索引与待办

- [ ] `Agent_doc/INDEX.md` 已生成或更新
- [ ] `Agent_doc/Pending_User_Actions.md` 已存在
- [ ] 即便无待办，也已写明“本轮无待用户处理事项”

### 5. 留痕

- [ ] `Agent_doc/Agent_Progress_Log.md` 已记录本次审计结果
- [ ] 已记录归档移动路径、索引更新与修复动作
- [ ] 已给出下一步建议或恢复入口
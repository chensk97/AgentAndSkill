# LEARNINGS Archive Audit Checklist

推荐使用阶段：`pl-coordinator` 阶段 5.5 执行时。

## 审计对象

- 项目根目录：
- `LEARNINGS` 路径：
- 审计轮次：
- 执行者：

## 清单

### 1. 盘点

- [ ] 已递归列出 `LEARNINGS/` 下全部 `*.md`
- [ ] 已识别所有 `_R*` / `_round*` / `_v*` 历史版本文件
- [ ] 已区分 canonical 文件与历史版本文件

### 2. 归档

- [ ] 计划历史文件已归入 `LEARNINGS/PLAN/`
- [ ] 项目地图 / 依赖图历史文件已归入 `LEARNINGS/MAP/`
- [ ] 学习路径历史文件已归入 `LEARNINGS/PATH/`
- [ ] 深挖历史文件已归入 `LEARNINGS/DEEP_DIVE/<module>/`
- [ ] 链路历史文件已归入 `LEARNINGS/FLOWS/<topic>/`
- [ ] 复盘历史文件已归入 `LEARNINGS/REPORTS/HISTORY/`
- [ ] 无法归类文件已暂存到 `LEARNINGS/Other/`

### 3. 链接修复

- [ ] 已扫描 `LEARNINGS/**/*.md` 的相对链接
- [ ] 已修复因移动导致失效的相对链接
- [ ] 已确认不存在指向旧路径的残留链接

### 4. 索引与待办

- [ ] `LEARNINGS/INDEX.md` 已生成或更新
- [ ] `LEARNINGS/Pending_User_Actions.md` 已存在
- [ ] 即便无待办，也已写明“本轮无待用户处理事项”

### 5. 留痕

- [ ] `LEARNINGS/LEARNING_PROGRESS.md` 已记录本次审计结果
- [ ] 已记录归档移动路径、索引更新与修复动作
- [ ] 已给出下一步建议或恢复入口
# Claude

## Plugins

```bash
/plugin marketplace add anthropics/skills

/plugin install document-skills@anthropic-agent-skills
/plugin install superpowers@anthropic-agent-skills
/plugin install ralph-loop@anthropic-agent-skills
/plugin install skill-creator@anthropic-agent-skills
```

## Skills

- flutter-design-demo

## Agent

- golang-backend-developer
- flutter-layout-developer

## 好用的

- 全局规则
  - 生成 task 时，把任务分配到 interface 级别，按照 design function signature -> implement unit test -> implement function body 的顺序生成任务
  - Never use TODOs or placeholders for core logic. All functions must be fully implemented with error handling and logging. If a dependency is missing, ask me to install it rather than skipping the implementation.
- 本地开发工具
  - docker 可以通过 docker 命令使用
  - 后端框架 kratos 命令
  - 手机端 flutter 命令
- 测试
  - 尽量合并可以合并的单元测试，减少测试数目

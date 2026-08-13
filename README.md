# sqlgen-km/skills

sqlgen 多方言 SQL 代码生成器的配套技能仓库，为代码开发 agent 提供 `sqlgen-dev` 技能。

## 结构

```
skills/
├── README.md
└── sqlgen-dev/          # sqlgen 开发指南技能
    ├── SKILL.md         # 技能主体：架构、工作流、关键陷阱
    ├── references/      # 分支/专题参考文档（渐进披露）
    └── templates/       # 模板（sqlg.yaml 等）
```

## 使用

将 `sqlgen-dev/` 目录放入 agent 的技能目录（如 Hermes 的 `~/.hermes/skills/`），
agent 在开发/维护 sqlgen 相关任务时加载 `sqlgen-dev` 技能即可获得完整的
架构、DSL 规范、代码生成流程与历史陷阱上下文。

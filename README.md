# sqlgen-km/skills

sqlgen 多方言 SQL 代码生成器的配套技能仓库，为代码开发 agent 提供 `sqlgen-dev` 技能。

## 结构

```
skills/
├── README.md
├── install.sh          # 技能安装脚本
└── sqlgen-dev/         # sqlgen DSL 编写指南技能
    ├── SKILL.md        # 总揽（定位 + 三入口）
    ├── references/     # dsl-writing / configuration / forbidden
    └── templates/      # sqlg.yaml 配置模板
```

## 安装

### 一键脚本

```bash
./install.sh hermes              # 安装到 Hermes Agent
./install.sh claude              # 安装到 Claude Code
./install.sh agents              # 安装到通用 Agent Skills 目录（Codex/Cursor/Copilot/Gemini CLI 共享）
./install.sh all                 # 安装到全部（默认）
./install.sh --list              # 查看各 agent 安装状态
./install.sh --uninstall claude  # 卸载
./install.sh --dry-run all       # 只预览不执行
```

支持目标：

| target | 安装目录 |
|--------|---------|
| hermes | `~/.hermes/skills/software-development/sqlgen-dev/` |
| claude | `~/.claude/skills/sqlgen-dev/` |
| agents | `~/.agents/skills/sqlgen-dev/`（Codex / Cursor / Copilot / Gemini CLI 共享） |

追加新 agent 系统：在 `install.sh` 的注册表加一行并同步 `ALL_TARGETS` 即可。

### 手动安装

将 `sqlgen-dev/` 目录复制到目标 agent 的技能目录。

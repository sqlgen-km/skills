---
name: sqlgen-dev
description: sqlgen DSL 编写指南 — 编写 .sql DSL 文件生成 Go/Java 数据访问代码（PG/Oracle/MSSQL/MySQL 四方言）
category: software-development
---

# sqlgen DSL 编写指南

sqlgen 是 SQL 代码生成器：一份 DSL（`.sql` 文件，PG 标准 SQL + `--` 指令注释）→ 生成 Go/Java 数据访问代码，同一份 DSL 生成 PG/Oracle/MSSQL/MySQL 四方言实现。

## 三个入口

| 主题 | 文档 |
|------|------|
| DSL 如何写 | `references/dsl-writing.md` |
| 配置如何配 | `references/configuration.md` |
| 禁止哪些特性 | `references/forbidden.md` |

## 最小示例

```sql
-- package: basic

-- model: User { id int64, name string }

-- param: name string
-- name: FindByName :many
-- model: User
SELECT id, name FROM users WHERE name = @name
```

完整语法见 `references/dsl-writing.md`，语法规范以 sqlgen 仓库 `docs/DSL-SPEC.md` 为准。

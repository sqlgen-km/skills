# 禁止的特性

## RETURNING 限制

仅支持 **INSERT 单列 RETURNING**。以下模式生成时报错：

| 禁止 | 错误信息 |
|------|---------|
| `RETURNING *` | `RETURNING * not supported` |
| `RETURNING a, b` | `multi-column RETURNING not supported` |
| `UPDATE ... RETURNING` | `UPDATE RETURNING not supported` |
| `DELETE ... RETURNING` | `DELETE RETURNING not supported` |

迁移写法：

| 原模式 | 改为 |
|--------|------|
| `INSERT ... RETURNING *` + `model: T` | `INSERT ... RETURNING id` + `model int64` |
| `INSERT ... RETURNING a, b` + `model: T` | `INSERT ... RETURNING id` + `model int64` |
| `UPDATE ... RETURNING` | `UPDATE ...` + `:exec` |
| `DELETE ... RETURNING` | `DELETE FROM ...` + `:execrows` |

## IN 子句约束

- `IN (@x)`（括号内单个参数）→ 生成报错，改用 `= ANY(@x)`（数组）或 `= @x`（标量）。
- `IN (1, 2, 3)` 字面量、`IN (@a, @b)` 多参数、`IN (SELECT ...)` 子查询 → 正常保留。

## 不支持的语法

| 禁止 | 替代 |
|------|------|
| `::` 类型转换 | `CAST(x AS type)` |
| `CASE WHEN @param` | 应用层 |
| `UNION` | `LEFT JOIN + OR` |

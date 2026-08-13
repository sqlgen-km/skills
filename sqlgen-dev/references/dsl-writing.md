# DSL 如何写

DSL 文件 = `--` 指令注释 + SQL 语句，指令间用空行分隔作用域。

## 1. 指令清单

| 指令 | 作用 | 示例 |
|------|------|------|
| `-- package: name` | 包名 | `-- package: basic` |
| `-- model: Name { ... }` | 定义带字段的模型 | `-- model: User { id int64, name string }` |
| `-- model: Name={...}` | 显式列→字段映射模型 | `-- model: User={id:user_id,name}` |
| `-- model: Name` | 引用模型（作返回类型） | `-- model: User` |
| `-- model { ... }` | 内联匿名模型（作返回类型） | `-- model { id int64, name string }` |
| `-- model int64` / `string` | 标量返回类型 | `-- model int64` |
| `-- param: n T, ...` | 方法参数（`-- param:` 留空 = 无参） | `-- param: id int64, limit int32` |
| `-- name: M :mode` | 查询名 + 执行模式 | `-- name: FindByID :one` |
| `-- @...` | 生成代码 doc comment | `-- @根据ID查询用户` |

`--` 后无 `@` 且非指令的行是纯注释，不参与生成。

## 2. 模型定义

### 字段映射

SQL 列名（snake_case）默认映射为 Go/Java 字段名（PascalCase）：

| SQL 列 | Go 字段 |
|--------|---------|
| `id` | `ID` |
| `display_name` | `DisplayName` |
| `created_at` | `CreatedAt` |

列名与字段名不一致时用 `sql_col:GoField` 显式声明（未声明列按默认规则）：

```sql
-- model: OrderSummary={ id, order_no, owner_name:Owner, total_count:Count }
```

### 三种形式

```sql
-- 1) 命名模型（可被 param/返回类型引用）
-- model: User { id int64, name string, email string }

-- 2) 内联匿名模型（仅作返回类型，生成类型名 = 方法名）
-- name: GetBrief :one
-- model { id int64, name string }
SELECT id, name FROM users WHERE id = @id

-- 3) 标量返回
-- name: CountAll :one
-- model int64
SELECT COUNT(*) FROM users
```

### SELECT 行为

- `SELECT *` 自动替换为 model 的显式列名。
- SELECT 列数可多于 model 字段数，多余列被丢弃，不报错。

## 3. 查询定义

```sql
-- name: MethodName :mode
-- model: ReturnType
SQL 语句;
```

### 执行模式

| `:mode` | 返回类型 |
|---------|---------|
| `:one` | `(*T, error)` |
| `:one` + 标量 | `(T, error)` |
| `:many` | `([]*T, error)` |
| `:exec` | `error` |
| `:execrows` | `(int64, error)` |

### 返回类型

| `-- model:` | `:one` 返回 | `:many` 返回 |
|------------|-----------|-----------|
| `: User` | `(*User, error)` | `([]*User, error)` |
| `int64` / `string` | `(int64, error)` | `([]int64, error)` |
| 内联 `{ fields }` | `(*MethodName, error)` | `([]*MethodName, error)` |

## 4. 参数

### 类型映射

| DSL 类型 | Go 类型 |
|----------|---------|
| `int` / `int64` / `int32` | 同左 |
| `float64` | `float64` |
| `string` | `string` |
| `bool` | `bool` |
| `time.Time` | `time.Time` |
| `[]int64` / `[]string` | 同左 |
| `*string` / `*int64` / `*bool` | 同左（可空参数） |
| `ModelName` | model struct |

### 参数引用

- 标量参数：`@name`
- 结构体字段：`@filter.gender`（`filter` 是 `-- param:` 声明的模型参数）

### 可空参数（可选过滤）

`*string` / `*int64` 等可空参数用 `OR @param IS NULL` 模式：

```sql
-- param: name *string, gender string, age *int64
-- name: FindUsers :many
-- model: User
SELECT id, display_name
FROM users
WHERE (name = @name OR @name IS NULL)
  AND gender = @gender
  AND (age = @age OR @age IS NULL)
```

## 5. 场景写法

### INSERT 单列 RETURNING

```sql
-- param: name string
-- name: InsertUser :one
-- model int64
INSERT INTO users (name) VALUES (@name) RETURNING id
```

### ON CONFLICT（UPSERT）

```sql
-- DO UPDATE
-- param: sku string, name string, price float64
-- name: UpsertProduct :exec
INSERT INTO products (sku, name, price)
VALUES (@sku, @name, @price)
ON CONFLICT (sku) DO UPDATE SET name = @name, price = @price

-- DO NOTHING（配合 RETURNING id）
-- param: sku string, name string
-- name: UpsertIgnore :one
-- model int64
INSERT INTO products (sku, name)
VALUES (@sku, @name)
ON CONFLICT (sku) DO NOTHING
RETURNING id
```

### ILIKE（模糊搜索）

```sql
-- param: name string
-- name: SearchByName :many
-- model: User
SELECT id, name FROM users WHERE name ILIKE @name
```

### 数组成员 `= ANY(@arr)`

```sql
-- param: group_ids []int64
-- name: FindGroupNamesByIDs :many
-- model: Group
SELECT id, name FROM groups WHERE id = ANY(@group_ids)
```

### LIMIT / OFFSET

```sql
-- param: limit int32, offset int32
-- name: ListUsers :many
-- model: User
SELECT id, name FROM users ORDER BY id LIMIT @limit OFFSET @offset
```

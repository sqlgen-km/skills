# 配置如何配

sqlgen 在工作目录读取 `sqlg.yaml`。

## 完整示例

```yaml
engines: [pg, mysql, oracle, mssql]   # 全局方言，默认 ["pg"]

go:                                   # 可选：Go 代码生成
  tags: [json]
  packages:
    - out: "internal/persistence/sqlgen"
      files: ["sqlgen/*.sql"]

java:                                 # 可选：Java 代码生成
  packages:
    - modelPackage: "com.dc.entity"
      mapperPackage: "com.dc.mapper"
      engineSubPackage: false
      out: "src/main/java"
      files: ["sqlgen/*.sql"]
```

`go` 和 `java` 至少配一个。

## 字段

### 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| `engines` | `[]string` | 全局方言，默认 `["pg"]` |
| `go` | 对象 | 配了才生成 Go 代码 |
| `java` | 对象 | 配了才生成 Java 代码 |

### go

| 字段 | 说明 |
|------|------|
| `tags` | 全局 struct tag（如 `json`） |
| `packages` | 包列表 |

### go.packages

| 字段 | 说明 |
|------|------|
| `out` | 输出目录 |
| `tags` | 局部 tag，覆盖全局 |
| `files` | glob 匹配 `.sql` 文件 |

### java.packages

| 字段 | 说明 |
|------|------|
| `modelPackage` | 实体包名 |
| `mapperPackage` | Mapper 接口包名 |
| `out` | 输出目录 |
| `files` | glob 匹配 `.sql` 文件 |
| `engineSubPackage` | `true` 时引擎实现进 `mapperPackage.{engine}` 子包 |

## `{stem}` 自动追加

`modelPackage` / `mapperPackage` 会自动追加 `.{stem}`（stem = DSL 文件名去后缀），每个 DSL 文件独立命名空间。配置里写不写 `{stem}` 都行，写了会被自动替换后重新追加。

## 生产配置示例

参考 `/work/weichuang/datacenter/java/sqlg.yaml`：

```yaml
engines: [pg, mysql, oracle]

java:
  packages:
    - modelPackage: "com.dc.entity"
      mapperPackage: "com.dc.mapper.{stem}"
      out: "src/main/java"
      files: ["sqlgen/*.sql"]
```

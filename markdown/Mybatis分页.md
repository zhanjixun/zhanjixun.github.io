# Mybatis分页
MyBatis 的分页是指将数据库中的大量数据，按照指定的条数分批次显示的操作。由于数据库一次性加载成千上万条数据会产生巨大的性能开销（甚至导致 OOM），分页是后端开发中的“刚需”。

在 MyBatis 中，实现分页主要有三种方式：**逻辑分页（RowBounds）**、**物理分页（原生 SQL）** 和 **拦截器分页（PageHelper）**。

------

### 1. 物理分页 vs 逻辑分页

这是理解分页最核心的两个概念：

- **物理分页 (推荐)**：直接在 SQL 语句中加入分页关键字（如 MySQL 的 `LIMIT`）。数据库只返回当前页的那几条数据。**性能高，内存占用小。**
- **逻辑分页**：先执行 `SELECT *` 把所有数据查出来加载到 JVM 内存里，然后通过 Java 代码（如 List 的 subList）截取其中的一部分。**数据量大时会撑爆内存，极不推荐。**

------

### 2. 三种常见的实现方案

#### ① 原生 SQL 物理分页 (最直接)

在 Mapper XML 中手动编写特定数据库的分页语法。

- **优点**：性能最好，完全可控。
- **缺点**：不同数据库语法不同（MySQL 是 `LIMIT`，Oracle 是 `ROWNUM`），切换数据库时很麻烦。

XML

```
<select id="selectUsers" resultType="User">
  SELECT * FROM users 
  ORDER BY id 
  LIMIT #{offset}, #{limit}
</select>
```

#### ② RowBounds 逻辑分页 (不推荐)

MyBatis 内置了一个 `RowBounds` 对象，你可以在调用 Mapper 方法时传入它。

- **原理**：MyBatis 会查询出所有结果，然后在内存中进行截取。
- **适用场景**：仅适用于数据量极小（几十条）的情况。

#### ③ PageHelper 插件 (最流行)

这是目前国内 Java 项目中使用率最高的分页插件。它利用了 MyBatis 的**拦截器（Interceptor）**机制。

- **原理**：它会拦截你的 SQL 执行请求，在执行之前，自动根据你当前的数据库类型（MySQL, Oracle, PostgreSQL 等）在 SQL 末尾加上对应的分页代码。

- **使用方式**：

  Java

  ```
  // 只需要在查询前调用一行代码
  PageHelper.startPage(1, 10); 
  List<User> list = userMapper.selectAll();
  // 得到的 list 实际上是一个 Page 类型，包含了总行数、总页数等
  PageInfo<User> pageInfo = new PageInfo<>(list);
  ```

------

### 3. 分页插件的工作原理图

分页插件并不是魔法，它在 MyBatis 执行过程中拦截了 `Executor`，动态修改了原始 SQL。

------

### 4. 总结与建议

| **方案**                  | **分页类型** | **优点**                 | **缺点**                  |
| ------------------------- | ------------ | ------------------------ | ------------------------- |
| **原生 SQL**              | 物理分页     | 性能极致，无额外依赖     | 编写麻烦，数据库移植性差  |
| **RowBounds**             | 逻辑分页     | 简单，MyBatis 自带       | **大数据量下有 OOM 风险** |
| **PageHelper**            | 物理分页     | 代码侵入小，支持多数据库 | 需要引入第三方依赖        |
| **MyBatis Plus 分页插件** | 物理分页     | 配置简单，使用方便       | 仅限 MyBatis Plus 用户    |

**开发建议**：

- 如果是普通 Spring Boot 项目，直接使用 **PageHelper**。
- 如果是使用 **MyBatis Plus**，则直接使用其自带的 `PaginationInnerInterceptor`。
- 永远**避免**在没有 LIMIT 的情况下执行大表全表扫描。

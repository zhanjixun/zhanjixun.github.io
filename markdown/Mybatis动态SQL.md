# Mybatis动态SQL

MyBatis 动态 SQL 的原理是使用 OGNL（Object-Graph Navigation Language）从 SQL 参数对象中计算表达式的值，根据表达式的值动态拼接 SQL，以此来完成动态 SQL 的功能。

MyBatis 解析动态 SQL 的核心在于其内部的**脚本解析引擎**。它并没有在运行时简单地使用字符串替换，而是将 XML 中的 SQL 片段解析为一棵**节点树**，并在执行时根据传入的参数动态地“拼凑”出最终的 SQL 语句。

以下是 MyBatis 解析动态 SQL 的核心流程和底层机制：

------

### 1. 核心组件介绍

在解析过程中，有几个关键类起着决定性作用：

- **SqlSource**: 代表从 XML 或注解中读取的 SQL 内容。动态 SQL 对应的实现类是 `DynamicSqlSource`。
- **SqlNode**: 接口，代表动态 SQL 树中的一个节点（如 `<if>`、`<where>`、文本片段等）。
- **DynamicContext**: 负责存放解析过程中的上下文信息，包括参数对象和最终生成的 SQL 字符串（StringBuilder）。

------

### 2. 解析过程：从 XML 到 SqlSource

当你启动 MyBatis（或首次加载 Mapper）时，解析就开始了：

1. **识别动态性**: MyBatis 遍历 SQL 语句，如果发现 SQL 中包含 `${}` 或任何动态标签（如 `<if>`、`<foreach>`），它就会将该 SQL 封装成 `DynamicSqlSource`。

2. **构建节点树**: 解析器（`XMLScriptBuilder`）会递归地解析 XML 标签。

   - 纯文本部分被解析为 `StaticTextSqlNode`。
   - `<if>` 被解析为 `IfSqlNode`。
   - `<where>`、`<set>` 被解析为 `TrimSqlNode` 的子类。

   这些节点最终组成一个 **MixedSqlNode**（即根节点，包含一个 List 存放所有子节点）。

------

### 3. 执行阶段：从 SqlSource 到 BoundSql

当真正调用 Mapper 方法执行查询时，动态解析才会最终完成：

1. **调用 apply() 方法**: MyBatis 遍历节点树，每个 `SqlNode` 都有一个 `apply(DynamicContext context)` 方法。
2. **逻辑判断**:
   - **IfSqlNode**: 使用 OGNL 表达式计算 `test` 属性的值。如果为 true，则调用其子节点的 `apply` 方法。
   - **ForEachSqlNode**: 循环遍历集合，重复调用子节点的解析逻辑。
   - **TrimSqlNode/WhereSqlNode**: 处理前缀（WHERE）和多余的后缀/连接符（如多出来的 `AND` 或 `OR`）。
3. **拼接字符串**: 每个被触发的节点都会将其内部的 SQL 文本追加到 `DynamicContext` 的 `StringBuilder` 中。

------

### 4. 占位符处理与预编译

在所有标签处理完毕后，MyBatis 会得到一条带有 `#{}` 的 SQL 字符串。

- **SqlSourceParser**: 接着会处理 `#{}`。
- 它将 `#{}` 替换为 JDBC 标准的占位符 `?`。
- 同时，它会将 `#{}` 中的属性信息（参数名、类型处理器等）记录在 `ParameterMapping` 对象中。
- 最终生成 `BoundSql` 对象，交由 JDBC 驱动执行 `PreparedStatement`。

------

### 总结

MyBatis 的动态 SQL 解析本质上是一个**组合模式（Composite Pattern）**的应用：

1. **启动阶段**：将 XML 转化为一棵由 `SqlNode` 组成的**逻辑树**。
2. **运行阶段**：利用 **OGNL** 表达式判断条件，递归遍历树，将符合条件的节点 SQL **拼接**起来。
3. **最后阶段**：将 `#{}` 替换为 `?`，生成可执行的预编译 SQL。

> **小贴士**：这也是为什么 `${}` 容易导致 SQL 注入的原因，因为它在拼接阶段就被直接替换成了字符串，而 `#{}` 会被处理为 `?` 占位符。



参考:

[一文掌握MyBatis的动态SQL使用与原理](https://huaweicloud.blog.csdn.net/article/details/128419213)

[详解MyBatis的动态SQL实现原理](https://www.jb51.net/program/290899si0.htm)

[MyBatis 动态SQL 详解！](https://blog.csdn.net/qq_56158663/article/details/146938402)
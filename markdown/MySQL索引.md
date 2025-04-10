# MySQL索引原理





参考:

[https://blog.csdn.net/qq_28018283/article/details/85050986](https://blog.csdn.net/qq_28018283/article/details/85050986)

[http://blog.codinglabs.org/articles/theory-of-mysql-index.html](http://blog.codinglabs.org/articles/theory-of-mysql-index.html)

## 索引失效场景

1. `LIKE以通配符开头`：模糊查询以 % 开头，例如：`LIKE '%abc'`
2. `不满足最左前缀原则`：联合索引 `(a, b, c)`，但查询条件未包含最左侧列`a`
3. `使用函数或表达式`：在索引列上使用函数、运算或表达式
4. `隐式类型转换`：字段类型与查询值类型不匹配（如字段是VARCHAR，但查询使用数字）
5. `OR连接非索引列`：OR 条件中包含未索引的列
6. `范围查询后的列`：联合索引中，范围查询（`>`, `<`, `BETWEEN`）后的列无法使用索引
7. `使用 != 或者 NOT IN`

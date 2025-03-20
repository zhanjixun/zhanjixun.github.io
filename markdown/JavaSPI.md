# Java SPI

Java中的SPI（Service Provider Interface）是一种服务发现机制，允许第三方为接口提供实现，实现解耦和动态扩展。

**目的**：解耦接口与实现，使应用无需硬编码依赖具体实现类，便于扩展。

**机制**：通过`java.util.ServiceLoader`类在运行时动态加载实现类。

## 工作原理

1. **定义接口**：在API模块中声明服务接口（如`com.example.MyService`）。
2. **实现接口**：服务提供者实现该接口（如`com.provider.MyServiceImpl`）。
3. **注册实现**：在提供者的JAR包中创建`META-INF/services/<接口全限定名>`文件，内容为实现类的全限定名。

## 使用步骤

```java
ServiceLoader<MyService> loader = ServiceLoader.load(MyService.class);
for (MyService service : loader) {
    service.doSomething();
}
```

## 应用场景

- **JDBC驱动加载**：JDBC 4.0+通过SPI自动加载数据库驱动，无需`Class.forName()`。
- **日志框架适配**：如SLF4J绑定不同日志实现（Logback、Log4j2）。
- **模块化扩展**：允许插件化架构，如支付网关的不同实现。

## 优点与限制

- 优点：
  - **解耦**：接口与实现分离，更换实现无需修改代码。
  - **动态扩展**：新增实现只需添加JAR包，符合开闭原则。
- 限制：
  - **无参构造器**：实现类需有无参构造函数。
  - **性能**：`ServiceLoader`每次调用会重新加载实例，需自行处理缓存。
  - **多实现选择**：需遍历或通过条件筛选具体实现。